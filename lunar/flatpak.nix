# Applications graphiques en Flatpak déclaratif (nix-flatpak, Flathub).
{ ... }:

{
  services.flatpak.packages = [
    # Navigateurs
    "app.zen_browser.zen"
    "org.chromium.Chromium"
    # Mots de passe
    "com.onepassword.OnePassword"
    "com.bitwarden.desktop"
    # Messagerie / mail
    "org.signal.Signal"
    "com.rtosta.zapzap"
    "org.telegram.desktop"
    "com.slack.Slack"
    "com.discordapp.Discord"
    "com.github.IsmaelMartinez.teams_for_linux"
    "com.getmailspring.Mailspring"
    "de.schmidhuberj.Flare"
    # Bureautique / notes / tâches
    "org.libreoffice.LibreOffice"
    "md.obsidian.Obsidian"
    "com.todoist.Todoist"
    "io.github.alainm23.planify"
    # Média / création
    "com.spotify.Client"
    "org.videolan.VLC"
    "com.obsproject.Studio"
    "org.gimp.GIMP"
    "org.kde.kdenlive"
    "org.darktable.Darktable"
    # Outils
    "org.gnome.meld"
    "com.github.tchx84.Flatseal"
  ];
}
