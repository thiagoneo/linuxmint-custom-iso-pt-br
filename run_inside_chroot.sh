#!/usr/bin/env bash

set -e

#--------------------------------- VARIÁVEIS ----------------------------------#
# Packages to remove when building a pt_BR-only ISO
PKG_REMOVE=(
    # language packs and translations (non-pt)
    language-pack-de-base
    language-pack-de
    language-pack-en-base
    language-pack-en
    language-pack-es-base
    language-pack-es
    language-pack-fr-base
    language-pack-fr
    language-pack-it-base
    language-pack-it
    language-pack-nl-base
    language-pack-nl
    language-pack-ru-base
    language-pack-ru
    language-pack-gnome-de-base
    language-pack-gnome-de
    language-pack-gnome-en-base
    language-pack-gnome-en
    language-pack-gnome-es-base
    language-pack-gnome-es
    language-pack-gnome-fr-base
    language-pack-gnome-fr
    language-pack-gnome-it-base
    language-pack-gnome-it
    language-pack-gnome-nl-base
    language-pack-gnome-nl
    language-pack-gnome-ru-base
    language-pack-gnome-ru

    # Firefox locales (non-pt)
    firefox-locale-de
    firefox-locale-en
    firefox-locale-es
    firefox-locale-fr
    firefox-locale-it
    firefox-locale-nl
    firefox-locale-ru

    # Thunderbird locales and app
    thunderbird*

    # LibreOffice locales and help files (non-pt)
    libreoffice-help*
    libreoffice-l10n*

    # Spell/Hyphen/mythes dictionaries (non-pt)
    aspell-en
    hunspell-de-at-frami
    hunspell-de-ch-frami
    hunspell-de-de-frami
    hunspell-en-au
    hunspell-en-ca
    hunspell-en-gb
    hunspell-en-us
    hunspell-en-za
    hunspell-es
    hunspell-fr-classical
    hunspell-fr
    hunspell-it
    hunspell-nl
    hunspell-ru
    hyphen-de
    hyphen-en-ca
    hyphen-en-gb
    hyphen-en-us
    hyphen-es
    hyphen-fr
    hyphen-it
    hyphen-nl
    hyphen-pt-pt
    mythes-de-ch
    mythes-de
    mythes-en-au
    mythes-en-us
    mythes-es
    mythes-fr
    mythes-it
    mythes-pt-pt
    mythes-ru
    wbritish
    wfrench
    witalian
    wspanish

    # media / communication / extras
    rhythmbox*
    celluloid
    hypnotix
    transmission*
    simple-scan
    # mintchat
    drawing
    pix
    warpinator
    thingy
  )

PKG_INSTALL=(
    clonezilla
    dosfstools
    exfatprogs
    gparted
    language-pack-pt-base
    language-pack-pt
    language-pack-gnome-pt-base
    language-pack-gnome-pt
    libreoffice-help-pt-br
    libreoffice-l10n-pt-br
    libreoffice-lightproof-pt-br
    ntfs-3g
    testdisk
    wbrazilian
)

# Update system packages
apt update

# Install additional packages
if [ ${#PKG_INSTALL[@]} -gt 0 ]; then
  echo "Installing additional packages..."
  apt install -y "${PKG_INSTALL[@]}"
fi

# Remove unwanted locale/language packages if list is set
if [ ${#PKG_REMOVE[@]} -gt 0 ]; then
  echo "Removing unneeded locale packages..."
  apt remove --purge -y "${PKG_REMOVE[@]}" || true
  apt autoremove --purge -y
  apt clean -y
fi

apt upgrade -y
# # Remove old kernels and unnecessary packages, and clean up
# apt purge -y $(dpkg -l 'linux-image-[0-9]*' \
# | awk '/^ii/{print $2}' \
# | grep -v "$(uname -r)") && sudo apt autoremove --purge -y
apt autoremove --purge -y
apt clean -y
apt remove --purge "${PKG_REMOVE[@]}"
apt-mark hold ubiquity ubiquity-frontend-gtk ubiquity-casper ubiquity-ubuntu-artwork plymouth plymouth-label plymouth-theme-spinner plymouth-theme-ubuntu-text

dpkg-reconfigure locales
dpkg-reconfigure keyboard-configuration

# Customize Plymouth theme with spinner/bgrt and Mint text logo
apt install --no-install-recommends -y librsvg2-bin
curl https://linuxmint.com/web/img/logo-mono.svg | rsvg-convert -h 64 -o /usr/share/plymouth/ubuntu-logo.png
cp -fv /usr/share/plymouth/ubuntu-logo.png /usr/share/plymouth/themes/spinner/watermark.png
apt remove --auto-remove --purge -y librsvg2-bin
update-alternatives --config default.plymouth <<< "1"
update-initramfs -u -k all

# Customize Linux Mint with dconf
mkdir -p /etc/dconf/profile

cat > /etc/dconf/profile/user <<EOF
user-db:user
system-db:local
EOF

mkdir -p /etc/dconf/db/local.d

cat > /etc/dconf/db/local.d/00-linuxmint-customizations <<EOF
[org/cinnamon]
enabled-applets=['panel1:left:0:menu@cinnamon.org:0', 'panel1:left:1:separator@cinnamon.org:1', 'panel1:left:2:grouped-window-list@cinnamon.org:2', 'panel1:right:0:user@cinnamon.org:3', 'panel1:right:1:systray@cinnamon.org:4', 'panel1:right:2:xapp-status@cinnamon.org:5', 'panel1:right:3:notifications@cinnamon.org:6', 'panel1:right:4:printers@cinnamon.org:7', 'panel1:right:5:removable-drives@cinnamon.org:8', 'panel1:right:6:keyboard@cinnamon.org:9', 'panel1:right:7:favorites@cinnamon.org:10', 'panel1:right:8:network@cinnamon.org:11', 'panel1:right:9:sound@cinnamon.org:12', 'panel1:right:10:power@cinnamon.org:13', 'panel1:right:11:calendar@cinnamon.org:14', 'panel1:right:12:cornerbar@cinnamon.org:15']

[org/cinnamon/cinnamon-session]
quit-delay-toggle=true

[org/cinnamon/desktop/media-handling]
automount-open=false

[org/nemo/preferences]
show-new-folder-icon-toolbar=true
show-reload-icon-toolbar=true
quick-renames-with-pause-in-between=true

[org/nemo/preferences/menu-config]
selection-menu-make-link=true

[org/x/editor/preferences/editor]
display-line-numbers=true
bracket-matching=true
highlight-current-line=true
EOF

dconf update

# Allow dots (.) in usernames.
sed -i "s/LC_ALL=C expr \"\$userdefault\" : '\[a-z\]\[-a-z0-9\]\*\$'/LC_ALL=C expr \"\$userdefault\" : '^[a-z][-.a-z0-9_]*$'/" /usr/lib/ubiquity/user-setup/user-setup-ask
sed -i "s/LC_ALL=C expr \"\$USER\" : '\[a-z\]\[-a-z0-9_\]\*\$'/LC_ALL=C expr \"\$USER\" : '^[a-z][-.a-z0-9_]*$'/" /usr/lib/ubiquity/user-setup/user-setup-ask
sed -i "s/LC_ALL=C expr \"\$userdefault\" : '\[a-z\]\[-a-z0-9\]\*\$'/LC_ALL=C expr \"\$userdefault\" : '^[a-z][-.a-z0-9_]*$'/" /usr/lib/ubiquity/user-setup/user-setup-ask-oem
sed -i "s/LC_ALL=C expr \"\$USER\" : '\[a-z\]\[-a-z0-9_\]\*\$'/LC_ALL=C expr \"\$USER\" : '^[a-z][-.a-z0-9_]*$'/" /usr/lib/ubiquity/user-setup/user-setup-ask-oem
sed -i '/^NAME_REGEX=/d' /etc/adduser.conf
echo "NAME_REGEX='^[a-z][-.a-z0-9_]*$'" >> /etc/adduser.conf

# Configure Ubiquity to use the preseed file and set it to automatic mode
sed -i '/^Exec=/c\
Exec=sudo --preserve-env=DBUS_SESSION_BUS_ADDRESS,XDG_DATA_DIRS,XDG_RUNTIME_DIR,GTK_THEME sh -c '\''debconf-set-selections /cdrom/preseed/preseed.cfg  && WEBKIT_DISABLE_COMPOSITING_MODE=1 ubiquity gtk_ui --automatic'\''' \
/usr/share/applications/ubiquity.desktop
