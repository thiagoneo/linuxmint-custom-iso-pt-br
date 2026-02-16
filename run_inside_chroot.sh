#!/usr/bin/env bash

set -e

# Allow dots (.) in usernames.
sed -i "s/LC_ALL=C expr \"\$userdefault\" : '\[a-z\]\[-a-z0-9\]\*\$'/LC_ALL=C expr \"\$userdefault\" : '^[a-z][-.a-z0-9_]*$'/" /usr/lib/ubiquity/user-setup/user-setup-ask
sed -i "s/LC_ALL=C expr \"\$USER\" : '\[a-z\]\[-a-z0-9_\]\*\$'/LC_ALL=C expr \"\$USER\" : '^[a-z][-.a-z0-9_]*$'/" /usr/lib/ubiquity/user-setup/user-setup-ask
sed -i "s/LC_ALL=C expr \"\$userdefault\" : '\[a-z\]\[-a-z0-9\]\*\$'/LC_ALL=C expr \"\$userdefault\" : '^[a-z][-.a-z0-9_]*$'/" /usr/lib/ubiquity/user-setup/user-setup-ask-oem
sed -i "s/LC_ALL=C expr \"\$USER\" : '\[a-z\]\[-a-z0-9_\]\*\$'/LC_ALL=C expr \"\$USER\" : '^[a-z][-.a-z0-9_]*$'/" /usr/lib/ubiquity/user-setup/user-setup-ask-oem
sed -i '/^NAME_REGEX=/d' /etc/adduser.conf
echo "NAME_REGEX='^[a-z][-.a-z0-9_]*$'" >> /etc/adduser.conf

# Update system packages
apt update
apt -y upgrade
apt -y autoremove --purge
apt -y clean
