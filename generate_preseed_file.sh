#!/usr/bin/env bash

set -e 

# Gerar arquivo preseed
echo "=== Gerador de preseed.cfg ==="
echo
read -p "Digite o nome do usuário administrador: " USERNAME
read -s -p "Digite a senha (também será utiliada pelo root): " PASSWORD
echo
read -s -p "Confirme a senha: " PASSWORD2
echo

if [ "$PASSWORD" != "$PASSWORD2" ]; then
    echo "Erro: senhas não conferem."
    exit 1
fi

# Gera hash SHA-512 (salt automático)
HASH=$(openssl passwd -6 "$PASSWORD")

# Local do preseed dentro da ISO
PRESEED_DIR="custom-disk/preseed"
PRESEED_FILE="${PRESEED_DIR}/preseed.cfg"
CASPER_DIR="custom-disk/casper"

mkdir -p $PRESEED_DIR
mkdir -p $CASPER_DIR

rm -rf $PRESEED_FILE

cat > "$PRESEED_FILE" <<EOF
### Modo automático
d-i auto-install/enable boolean true
d-i debconf/priority select critical

### Idioma
d-i debian-installer/locale string pt_BR.UTF-8
# Gerar apenas o locale pt_BR (evita gerar outros idiomas)
d-i locales/locales_to_be_generated multiselect pt_BR.UTF-8 UTF-8
d-i locales/default_environment_locale select pt_BR.UTF-8

d-i localechooser/languagelist select pt
d-i localechooser/countrylist select BR
d-i localechooser/preferred-locale string pt_BR.UTF-8
d-i localechooser/shortlist select BR

### Teclado ABNT2
d-i console-setup/ask_detect boolean false
d-i console-setup/layoutcode string br
d-i console-setup/variantcode string abnt2
d-i console-setup/confirm boolean true
d-i keyboard-configuration/ask_detect boolean false
d-i keyboard-configuration/xkb-keymap select br
d-i keyboard-configuration/layoutcode string br
d-i keyboard-configuration/variantcode string abnt2
d-i keyboard-configuration/confirm boolean true
d-i keyboard-configuration/layout select br
d-i keyboard-configuration/unsupported_layout boolean true
d-i keyboard-configuration/store_defaults_in_debconf_db boolean true

### Fuso horário
d-i time/zone string America/Sao_Paulo
d-i clock-setup/utc boolean true
d-i clock-setup/ntp boolean true

### Usuário
d-i passwd/user-password-crypted password $HASH
d-i passwd/user-fullname string $USERNAME
d-i passwd/username string $USERNAME
d-i passwd/user-password-crypted password $HASH
d-i user-setup/allow-password-weak boolean true

### Definir hostname aleatório
d-i preseed/late_command string \
    in-target bash -c '\
    HOSTNAME="DESKTOP-$(tr -dc A-Z0-9 </dev/urandom | head -c7)"; \
    echo "$HOSTNAME" > /etc/hostname; \
    echo "127.0.1.1 $HOSTNAME" > /etc/hosts; \
    echo "netcfg/get_hostname string $HOSTNAME" | debconf-set-selections'

### Drivers proprietários
ubiquity ubiquity/use_nonfree boolean true

### NÃO instalar codecs
ubiquity ubiquity/install/codecs boolean false

### Não baixar atualizações
ubiquity ubiquity/download_updates boolean false

### Reiniciar automaticamente
d-i finish-install/reboot_in_progress note
EOF

echo
echo "Arquivo preseed.cfg gerado com sucesso em $PRESEED_FILE"

# Copiar arquivo filesystem.manifest-remove
rm -f "$CASPER_DIR/filesystem.manifest-remove"
cp "filesystem.manifest-remove" $CASPER_DIR/
echo "Arquivo filesystem.manifest-remove copiado para $CASPER_DIR/"
