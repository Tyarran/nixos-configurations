# Configuration NixOS avec ragenix

Ce dépôt contient la configuration NixOS pour l'hôte **orion** avec la gestion des secrets via **ragenix**.

## Structure du projet

```
nixos-configurations/
├── flake.nix                    # Point d'entrée de la configuration avec flakes
├── flake.lock                   # Versions verrouillées des dépendances
├── secrets.nix                  # Configuration des destinataires des secrets
├── orion/
│   ├── configuration.nix        # Configuration système principale
│   ├── hardware-configuration.nix  # Configuration matérielle
│   ├── users.nix                # Configuration des utilisateurs
│   └── services/                # Services (SSH, Samba, Cockpit, etc.)
├── secrets/
│   └── romain-password.age      # Mot de passe haché de l'utilisateur romain (chiffré)
└── README.md                    # Ce fichier
```

## Gestion des secrets avec ragenix

### Qu'est-ce que ragenix ?

**ragenix** est une implémentation Rust d'agenix pour gérer des secrets chiffrés dans NixOS en utilisant [age](https://age-encryption.org/). 
Les secrets sont chiffrés avec les clés publiques age dérivées des clés SSH et peuvent être stockés en toute sécurité dans Git.

### Avantages de ragenix

- Réimplémentation Rust performante d'agenix
- Utilise les clés SSH existantes (pas besoin de clés age séparées)
- Un fichier = un secret (contrairement à sops-nix qui utilise YAML)
- Déchiffrement automatique au démarrage du système
- Intégration native avec NixOS

### Secrets actuels

- `secrets/romain-password.age` : Mot de passe haché de l'utilisateur romain

### Clés configurées

Le fichier `secrets.nix` définit les destinataires autorisés à déchiffrer les secrets :

- **Admin (votre machine)** : `age1w9hrgxmtk30ysfqa480q0v5k9490wlq4p7yzcjg2w0qk44useqeqwpdyvy`
  - Dérivée de `~/.ssh/id_ed25519.pub`
- **Host orion** : `age1ahk9g5w9nu03tr25y2ql227ee20np75hzrkjgaj9ylfv0fdz7fcsvww5zc`
  - Dérivée de `/etc/ssh/ssh_host_ed25519_key.pub` sur orion

### Récupérer une clé publique age depuis SSH

```bash
# Pour votre machine locale
cat ~/.ssh/id_ed25519.pub | ssh-to-age

# Pour un serveur distant
ssh orion "cat /etc/ssh/ssh_host_ed25519_key.pub" | ssh-to-age

# Ou via ssh-keyscan
nix shell nixpkgs#ssh-to-age -c sh -c "ssh-keyscan 192.168.1.200 | grep ed25519 | ssh-to-age"
```

### Modifier un secret existant

```bash
# Éditer le secret (sera automatiquement déchiffré puis rechiffré)
ragenix --identity ~/.ssh/id_ed25519 --edit secrets/romain-password.age
```

### Créer un nouveau secret

```bash
# 1. Ajouter le secret dans secrets.nix
# "secrets/mon-nouveau-secret.age".publicKeys = [ admin orion ];

# 2. Créer et éditer le secret
ragenix --identity ~/.ssh/id_ed25519 --edit secrets/mon-nouveau-secret.age

# 3. Configurer NixOS pour utiliser le secret dans orion/configuration.nix
# age.secrets.mon-nouveau-secret = {
#   file = ../secrets/mon-nouveau-secret.age;
#   owner = "root";  # optionnel
#   group = "root";  # optionnel
#   mode = "0400";   # optionnel
# };
```

### Re-chiffrer tous les secrets (après changement de clés)

```bash
# Si vous avez modifié les destinataires dans secrets.nix
ragenix --identity ~/.ssh/id_ed25519 --rekey
```

### Générer un hash de mot de passe

Pour les secrets de type mot de passe utilisateur :

```bash
# Générer un hash SHA-512 (demande le mot de passe interactivement)
mkpasswd -m sha-512
```

## Configuration NixOS

### Dans flake.nix

Le module ragenix est importé automatiquement :

```nix
ragenix = {
  url = "github:yaxitech/ragenix";
  inputs.nixpkgs.follows = "nixpkgs";
};

# Dans nixosConfigurations
modules = [
  ./orion/configuration.nix
  ragenix.nixosModules.default
];
```

### Dans orion/configuration.nix

```nix
# Définir les chemins des clés privées pour le déchiffrement
age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

# Déclarer les secrets à déchiffrer
age.secrets.romain-password = {
  file = ../secrets/romain-password.age;
};
```

### Dans orion/users.nix

```nix
users.users.romain = {
  isNormalUser = true;
  extraGroups = [ "wheel" "sambashare" "podman" "samba" ];
  hashedPasswordFile = config.age.secrets.romain-password.path;
};
```

## Déploiement

### Construction locale

```bash
# Vérifier que la configuration compile
nixos-rebuild build --flake .#orion

# Construction à sec (voir ce qui serait fait)
nixos-rebuild build --flake .#orion --dry-run
```

### Déploiement distant sur orion

```bash
# Déployer depuis votre machine locale
nixos-rebuild switch \
  --flake .#orion \
  --target-host romain@192.168.1.200 \
  --build-host romain@192.168.1.200 \
  --sudo \
  --ask-sudo-password
```

### Déploiement direct sur orion

```bash
# 1. Copier la configuration sur orion
rsync -av --exclude=.git . romain@192.168.1.200:/tmp/nixos-config/

# 2. Se connecter à orion et appliquer
ssh romain@192.168.1.200
cd /tmp/nixos-config
sudo nixos-rebuild switch --flake .#orion
```

## Commandes utiles

### Mettre à jour les dépendances

```bash
# Mettre à jour tous les inputs du flake
nix flake update

# Mettre à jour seulement nixpkgs
nix flake lock --update-input nixpkgs
```

### Voir les secrets déchiffrés (sur le système cible)

```bash
# Les secrets sont déchiffrés dans /run/agenix/
ls -la /run/agenix/

# Voir le contenu d'un secret (attention : sensible !)
sudo cat /run/agenix/romain-password
```

### Linting et formatage

```bash
# Formatter tous les fichiers Nix
nixfmt .

# Analyse statique
statix check .

# Trouver le code mort
deadnix .
```

## Sécurité

- ✅ Les secrets chiffrés (`.age`) peuvent être commités dans Git
- ❌ Ne jamais commiter de fichiers non chiffrés contenant des secrets
- ✅ Les secrets sont déchiffrés uniquement au démarrage du système dans `/run/agenix/`
- ✅ Seuls les destinataires configurés dans `secrets.nix` peuvent déchiffrer
- ✅ Les clés privées SSH ne quittent jamais leur machine respective
- ✅ Le répertoire `/run/agenix/` est en RAM et est vidé à chaque redémarrage

## Dépannage

### Erreur "no identity matched any of the recipients"

Cela signifie qu'aucune clé privée disponible ne correspond aux destinataires du secret.

**Solutions :**

1. Vérifier que les clés publiques dans `secrets.nix` correspondent bien aux clés SSH :
   ```bash
   # Votre clé
   cat ~/.ssh/id_ed25519.pub | ssh-to-age
   
   # Clé d'orion
   ssh orion "cat /etc/ssh/ssh_host_ed25519_key.pub" | ssh-to-age
   ```

2. Mettre à jour `secrets.nix` avec les bonnes clés publiques

3. Re-chiffrer tous les secrets :
   ```bash
   ragenix --identity ~/.ssh/id_ed25519 --rekey
   ```

4. Si le secret est corrompu ou chiffré avec une ancienne clé, le recréer :
   ```bash
   mv secrets/romain-password.age secrets/romain-password.age.old
   ragenix --identity ~/.ssh/id_ed25519 --edit secrets/romain-password.age
   ```

### Erreur "age.identityPaths" manquant

Assurez-vous que `orion/configuration.nix` contient :

```nix
age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
```

### Le secret n'est pas accessible après déploiement

Vérifiez que :
1. La clé privée SSH existe sur orion : `ls -la /etc/ssh/ssh_host_ed25519_key`
2. Le secret est bien configuré dans `configuration.nix`
3. Le secret a été chiffré avec la bonne clé publique d'orion

### "Git tree is dirty" warning

C'est un avertissement normal si vous avez des modifications non commitées. Pour le corriger :

```bash
git add .
git commit -m "Update configuration"
```

## Workflow recommandé

1. **Modifier la configuration localement**
   ```bash
   # Éditer les fichiers de configuration
   nvim orion/configuration.nix
   ```

2. **Gérer les secrets**
   ```bash
   # Créer ou modifier un secret
   ragenix --identity ~/.ssh/id_ed25519 --edit secrets/mon-secret.age
   ```

3. **Tester localement**
   ```bash
   # Vérifier que ça compile
   nixos-rebuild build --flake .#orion
   ```

4. **Commiter les changements**
   ```bash
   git add .
   git commit -m "Description des changements"
   ```

5. **Déployer sur orion**
   ```bash
   nixos-rebuild switch --flake .#orion \
     --target-host romain@192.168.1.200 \
     --build-host romain@192.168.1.200 \
     --sudo --ask-sudo-password
   ```

## Ressources

- [Documentation ragenix](https://github.com/yaxitech/ragenix)
- [Documentation agenix](https://github.com/ryantm/agenix)
- [age encryption](https://age-encryption.org/)
- [NixOS Flakes](https://nixos.wiki/wiki/Flakes)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
