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

    # LibreOffice (UI + help + l10n)
    libreoffice*

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
    wamerican
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
    mintchat

  )

PKG_INSTALL=(
    clonezilla
    dosfstools
    exfatprogs
    gparted
    ntfs-3g
    testdisk
    wbrazilian
)

# Allow dots (.) in usernames.
sed -i "s/LC_ALL=C expr \"\$userdefault\" : '\[a-z\]\[-a-z0-9\]\*\$'/LC_ALL=C expr \"\$userdefault\" : '^[a-z][-.a-z0-9_]*$'/" /usr/lib/ubiquity/user-setup/user-setup-ask
sed -i "s/LC_ALL=C expr \"\$USER\" : '\[a-z\]\[-a-z0-9_\]\*\$'/LC_ALL=C expr \"\$USER\" : '^[a-z][-.a-z0-9_]*$'/" /usr/lib/ubiquity/user-setup/user-setup-ask
sed -i "s/LC_ALL=C expr \"\$userdefault\" : '\[a-z\]\[-a-z0-9\]\*\$'/LC_ALL=C expr \"\$userdefault\" : '^[a-z][-.a-z0-9_]*$'/" /usr/lib/ubiquity/user-setup/user-setup-ask-oem
sed -i "s/LC_ALL=C expr \"\$USER\" : '\[a-z\]\[-a-z0-9_\]\*\$'/LC_ALL=C expr \"\$USER\" : '^[a-z][-.a-z0-9_]*$'/" /usr/lib/ubiquity/user-setup/user-setup-ask-oem
sed -i '/^NAME_REGEX=/d' /etc/adduser.conf
echo "NAME_REGEX='^[a-z][-.a-z0-9_]*$'" >> /etc/adduser.conf

# Configure Ubiquity to use the preseed file and set it to automatic mode
sed -i 's|^Exec=.*|Exec=sudo --preserve-env=DBUS_SESSION_BUS_ADDRESS,XDG_DATA_DIRS,XDG_RUNTIME_DIR,GTK_THEME sh -c '\''debconf-set-selections /cdrom/preseed/preseed.cfg && WEBKIT_DISABLE_COMPOSITING_MODE=1 ubiquity gtk_ui --automatic'\''|' /usr/share/applications/ubiquity.desktop


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
apt autoremove --purge -y
apt clean -y
sudo apt remove --purge "${PKG_REMOVE[@]}"
