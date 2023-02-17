#!/bin/sh

# ------------ Apps -----------------
notify-send -a 'Setup' -t 3000 'Flatpak' 'Adding Flathub repository, removing Fedora Flatpak repository. Installing requested apps.'

# flatpak remotes (Fedora flatpaks will miss codecs)
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpam remote-delete fedora

# flatpak install
flatpak update && flatpak install -y freetube firefox amberol vlc blanket kodi flatseal easyeffects syncthingy spot jellyfin-client celluloid

# the apps are currently all installed for testing. There will be questions for what to be installed and what not

# Media players: VLC, Celluloid
# Streaming: moonplayer, mellowplayer, kodi, freetube, firefox, tubefeeder, audiotube (youtube music), mediathekview,
# Music specific: Amberol, blanket, jellyfin-client
# Self-hosted: tv.plex.PlexHTPC, plexamp, jellyfin-client, girens (plex)
# Radio&Podcast: shortwave, gpodder, podcasts, cpod, 
# Tools: QNapi (add subtitles to videos), Flatseal (control flatpak permissions), easyeffects (improve sound quality), Syncthing (sync all your files locally or remotely)
# Require Account: Spotify, Spotube, Spot, Streamio
#      Spotube not working with arrow keys?
#      Spot really nice TV layout, requires GNOME keyring
#      Streamio ?
# Torrent apps: webtorrent, transmisson, deluge, 

# --------------- System settings ----------------

notify-send -a 'Setup' 'Updates' 'Enabling automatic updates of system and Apps.'
# auto updates for rpm-ostree and flatpaks
git clone https://github.com/tonywalker1/silverblue-update
sudo sh ./silverblue-update/install.sh

notify-send -t 20000 -a 'Setup' 'Enabling the Plasma-Bigscreen Desktop and auto-login.' 'If Problems occur, deactivate autologin, log out and remove "enable-bigscreen.sh" from the ~/.config/autostart/ folder.'

# enable Plasma-Bigscreen
printf"""#!/bin/bash
plasmashell --replace -p org.kde.plasma.mycroft.bigscreen
""" > ~/.config/autostart/enable-bigscreen.sh

# restart script
wget https://github.com/trytomakeyouprivate/Linux/raw/main/KDE/Plasma-Bigscreen-Fedora-Kinoite/Content/reboot-script.sh -P ~/.config/autostart

chmod +x ~/.config/autostart/*

#------------ Create Firefox Profile ---------
notify-send -t 20000 -a 'Setup' 'Firefox' 'Setting up TV profile. You can find everything under ~/.var/app/org.mozilla.firefox/.mozilla/firefox/****.default-release. Data sending Extensions are not installed automatically, but can be found in a bookmarks folder.'

cd ~/.var/app/org.mozilla.firefox/.mozilla/firefox

rm -rf *default

wget x
rsync -a TV-Firefox/ *.default-release
rm -rf TV-Firefox


# ---------- create Appstarters for Firefox Webapps -----------
#notify-send -t 20000 -a 'Setup' 'WebApps' 'Using the App "Webapps" you can now create a new Webapp. This is a seperate Firefox profile with permanently stored cookies and a simpler interface, that allows Websites to run smoother. Real PWA Support is currently not available on Firefox.'

# Add an appstarter launching a script for creating a new "Webapp"
# Script asks for name of Profile, opened URL, Cookie settings?

# a new profile is created with simple webapp css from https://github.com/filips123/PWAsForFirefox/tree/main/native/userchrome
# a new appstarter is created, launching $website from $profilename including a high-res icon (https://github.com/deepanprabhu/duckduckgo-images-api) or locally stored?


# ---------------- Setup KODI ----------------------

notify-send -a 'Setup' -t 7000 'Kodi' 'You installed Kodi. In the App you can now import Repositories located in the ~/Kodi folder, such as MediathekView.'

mkdir ~/Kodi

sudo flatpak override tv.kodi.Kodi --filesystem=~/Kodi

# MediathekView (german public television online)

wget https://kodirepo.mediathekview.de/repo-mv/repository.mediathekview/repository.mediathekview-1.0.0.zip -P Kodi

# Crew Kodi addon
xdg-open https://team-crew.github.io/

# Warehouse addon
xdg-open https://warehousecrates.github.io/TheWareHouse/


# ---- restore COPR command ------
# yes this is a really nice hack! Thanks to https://www.reddit.com/user/telemachuszero/

notify-send -a 'Setup' -t 5000 'COPR' 'You can now add COPR repositories using "sudo copr enable user/repo".'

printf"""#!/bin/bash
pushd /tmp

author="$(echo $2 | cut -d '/' -f1)"
reponame="$(echo $2 | cut -d '/' -f2)"

if [ ! $3 ]; then
 releasever="$(rpm -E %fedora)"
else
 releasever=$3
fi

if [[ "$1" == "enable" ]]; then
 echo "$author/$reponame -> $releasever"
 curl -fsSL https://copr.fedorainfracloud.org/coprs/$author/$reponame/repo/fedora-$releasever/$author-$reponame-fedora-.repo | sudo tee /etc/yum.repos.d/$author-$reponame.repo
elif [[ "$1" == "remove" ]]; then
 sudo rm /etc/yum.repos.d/$author-$reponame.repo
fi""" | sudo tee /var/usrlocal/bin/copr

sudo chmod +x /var/usrlocal/bin/copr

# ------- rpm-ostree -------------
notify-send -a 'Setup' -t 7000 'Installing Apps' 'Removing RPM Firefox, installing Desktop, Mycroft and Gnome-Keyring. You will get a message when ready to reboot.'
sudo copr enable lyessaadi/mycroft 
sudo copr enable darrencocco/plasma-bigscreen

rpm ostree override remove firefox firefox-langpacks --install plasma-bigscreen mycroft-core gnome-keyring

notify-send -a 'Setup' 'Setup Ready' 'Applications added to your system. You have to reboot to complete setup.'
