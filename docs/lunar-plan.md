# Plan : ajout de `lunar` + modules communs

Objectif : ajouter l'hôte `lunar` (XPS 13 Lunar Lake, x86_64, machine de travail) en remplacement de l'Arch actuelle, avec des modules communs partagés par thème. La bascule Arch -> NixOS est hors périmètre pour l'instant.

## Décisions actées

- Hôte `lunar` dans `lunar/`, sur le modèle de `nova/` et `orion/`.
- Modules communs par thème dans `modules/`, sélectionnés par `imports` ; refactor de `nova` et `orion` inclus.
- Nixpkgs stable (`nixos-26.05`), `unstable` au cas par cas ; toute la famille `hypr*` depuis `unstable`.
- Kernel `linuxPackages_latest`, systemd-boot, zram seul.
- `stateVersion = "26.11"` (comme le brouillon ; à surveiller au premier build, flake en 26.05).
- Disque : LUKS et ESP existants (UUID Arch), `@home` conservé et inchangé, nouveaux sous-volumes `@nixos` (racine) et `@nixos-var` (/var), repart de zéro côté /var. Pas de `@swap`.
- Session : Hyprland + GNOME de secours, GDM.
- Énergie : power-profiles-daemon, thermald, intel_lpmd, scx_cosmos (bascule AC/batterie par udev). Pas de TLP, ni seuils de charge, ni plafonds de fréquence.
- Dotfiles : chezmoi (pas de home-manager pour l'instant).
- Applis graphiques en flatpak déclaratif (`nix-flatpak`), y compris zen, chromium, 1Password, Bitwarden. En nixpkgs : système, CLI, dev, Hyprland, ghostty, rofi.
- Empreinte (`fprintd`) pour hyprlock, sudo et GDM. Pas de Yubikey, Brother, Logitech, Ledger, caméra.
- Services : Docker, Ollama, NordVPN, ClamAV, systemd-oomd, btrfs-balance. Écartés : TLP, earlyoom, ksm, powertop, cloudflared, docker-cleanup, postgresql/redis système.
- Locale/clavier/fuseau : identiques à `nova` (fr_FR.UTF-8, us intl, Europe/Paris).
- Secrets : agenix comme `nova` (`~/.age/age.key`), clé dédiée à `lunar`.
- Conformité (module `compliance`, importé par `lunar` seulement) :
  - SentinelOne : `requireFile` (v25.4.2.21), jamais de `.deb` dans le dépôt (`*.deb` ignoré), token dans agenix.
  - Vanta : `fetchurl` public épinglé (2.20.0), fichier `/etc/vanta.conf` complet dans agenix, redémarrage toutes les 12 h.

## Phase 0 : préparation

1. `jj new` / `jj describe`.
2. Mesure de référence : `drvPath` de `nova` et `orion` (`nix eval .#nixosConfigurations.<h>.config.system.build.toplevel.drvPath`).
3. `*.deb` dans `.gitignore`.
4. Générer la clé age de `lunar` (`~/.age/age.key`), ajouter la clé publique à `secrets.nix`.
5. Créer les secrets : `lunar-romain-password`, `lunar-sentinelone-token`, `lunar-vanta-conf`.

Validation : secrets déchiffrables, aucun secret en clair dans le dépôt.

## Phase 1 : modules communs et refactor de `nova`

Modules : `base` (Nix, nix-ld, fuseau, locale, clavier, NetworkManager, agenix, oomd, fstrim), `desktop` (pipewire, polices, nix-flatpak, GDM), `gnome`, `dev`, `hardware/intel`. Valeurs surchargeables via `lib.mkDefault`.

Validation : `drvPath` de `nova` comparé à la référence, puis `nixos-rebuild build --flake .#nova`.

## Phase 2 : (déplacée en phase 10)

Le refactor d'`orion` est reporté en fin de projet (voir phase 10). Conséquence pour la phase 1 : `base` reste **minimal** (réglages Nix/flakes/GC, fuseau, NetworkManager, agenix). Locale, clavier, `systemd-oomd`, `fstrim` et `nix-ld` vont dans un module séparé importé seulement par `nova` et `lunar`, pour ne rien imposer au serveur.

## Phase 3 : flake.nix

Input `nix-flatpak`, entrée `lunar` (x86_64), overlay `unstable` dans un module commun.

## Phase 4 : socle de `lunar`

`hardware-configuration.nix` (LUKS, ESP, `@nixos`, `@nixos-var`, `@home`), `configuration.nix` (systemd-boot, kernel latest, paramètres `xe.*`, sysctl, zram), `users.nix`.

Validation : `nixos-rebuild build --flake .#lunar`.

## Phase 5 : environnement graphique

Module `hyprland` (hypr* depuis unstable, uwsm, portail, waybar, swaync, rofi, ghostty...), GNOME de secours, PAM empreinte (sudo, GDM, hyprlock), flatpaks déclaratifs (vérifier chaque identifiant Flathub).

## Phase 6 : énergie et matériel

ppd, thermald, intel_lpmd, scx_cosmos (service + script de profil + udev), contournements à valider un par un (gpe6e, affinité IRQ, blacklist int3400, iwlwifi power_save).

## Phase 7 : services et dev

Docker, Ollama, btrfs-balance, NordVPN, ClamAV, paquets CLI/dev repris tels quels. Vérifier la disponibilité nixpkgs de : nordvpn, claude-code, pi-coding-agent (unstable), opencode, rtk, memcastle, jjui, claude-desktop.

## Phase 8 : conformité (la plus risquée)

Vanta (fetchurl, nix-ld ou buildFHSEnv, /var/vanta), SentinelOne (requireFile + message d'aide `nix-store --add-fixed`, FHS, /opt/sentinelone inscriptible, watchdog, token agenix). Doutes : eBPF sur kernel récent, exécution sans FHS réel.

Validation : build seulement ; test d'exécution possible uniquement au premier boot.

## Phase 9 : validation finale

`nixfmt .`, `statix check .`, `deadnix .`, build des 3 hôtes, comparaison des `drvPath`, relecture de `jj diff` (aucun secret ni `.deb`).

## Phase 10 : refactor d'`orion` (en dernier)

Faire le strict minimum : importer `base` (minimal), éventuellement regrouper ses services dans un module `server`. Conserver sa clé age (`/etc/age/age.key`), son `stateVersion = "25.11"` et ses surcharges (GC 30 jours, `sandbox = false`, `auto-optimise-store`).

Validation : depuis Orion lui-même (`nixos-rebuild build`), car l'évaluation depuis `nova` échoue sans builder aarch64 (service arion `arion-deconz`). Pas de comparaison de `drvPath` possible depuis x86_64 sans builder.

## Hors périmètre

Bascule Arch -> NixOS, migration chezmoi/home-manager, caméra, Yubikey, TLP.

## Points ouverts

- `stateVersion` 26.11 vs flake 26.05 : à vérifier au premier build.
- Clé Vanta exposée dans une session de travail : régénération optionnelle (`agenix -e`).
- Nom et disponibilité des paquets listés en phase 7.

## Statut d'implémentation

Phases 0 à 9 faites ; phase 10 (orion) volontairement non faite.

Vérifié :
- `nova` évalue ; `system-path` a les mêmes 217 dépendances qu'avant (ordre différent). Seules différences voulues : unités flatpak (`nix-flatpak` remplace `flatpak-repo`).
- `lunar` : évaluation sans avertissement et **build complet réussi** (kernel 7.2.10, Hyprland + GNOME, tous les services listés).
- `intel-lpmd` (paquet maison) compile ; hash Vanta confirmé.

Non testé (impossible sans démarrer sur `lunar`) :
- Exécution de SentinelOne (nix-ld, copie dans `/opt/sentinelone`, eBPF, enrôlement par token) et de Vanta (copie dans `/var/vanta`, `/etc/vanta.conf`).
- `WatchdogSec=30s` du .deb de SentinelOne volontairement omis.
- Empreinte (hyprlock, sudo, GDM), `scx_cosmos` AC/batterie, `intel_lpmd`, IRQ 29 (numéro repris de l'Arch).
- Mesa depuis `unstable` + kernel latest (choix pour Lunar Lake).
- Le `.deb` SentinelOne doit être dans le store avant le build :
  `nix-store --add-fixed sha256 SentinelAgent_linux_x86_64_v25_4_2_21.deb` (déjà fait sur cette machine).

Écarts et choix faits à l'implémentation :
- `claude-desktop`, `snypr`, `memcastle`, `whatsdesk` absents de nixpkgs : non installés (ZapZap et `hyprshot` les remplacent en partie).
- `nordvpn` : module importé depuis `nixpkgs-unstable` (absent de la stable) ; il impose `documentation.nixos.enable = false`.
- Wi-Fi via iwd (comme sur l'Arch) ; pas de gestion `wifi-powersave` par udev.
- `/home` en `neededForBoot` pour que la clé age soit lisible à l'activation.
- Flake : `nix flake` ignore les fichiers non suivis par git ; vérifié via `path:.`.
