#!/usr/bin/env bash

LINE='##################################################'
info() {
	echo "${LINE}"
	echo "INFO: ${1}"
	echo "${LINE}"
}

is_apt_source_installed() {
	grep -q "^deb .*${1}" /etc/apt/sources.list /etc/apt/sources.list.d/*
}

install_ppa() {
	if ! is_apt_source_installed "${1}"; then
		echo "Adding ${1}"
		sudo add-apt-repository "ppa:${1}" --yes
	fi
}

setup_network() {
	sudo systemctl daemon-reload --quiet
	sudo systemctl stop valet-dns --quiet && sudo systemctl disable valet-dns --quiet
	sudo rm /etc/resolv.conf
	sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
	sudo bash -c 'echo -e "[network]\ngenerateResolvConf = false\n[boot]\nsystemd=true\n[user]\ndefault=itineris" > /etc/wsl.conf'
	sudo chattr +i /etc/resolv.conf
}

# Allow remote network access inside WSL
info 'Configuring WSL network/internet access'
setup_network

# Add PPAs
info 'Adding Ubuntu PPAs/software repositories'
install_ppa git-core/ppa
install_ppa ondrej/php
if ! is_apt_source_installed 'github'; then
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
		sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
fi

# Update Ubuntu
info 'Updating Ubuntu packages'
sudo apt update --yes && sudo apt upgrade --yes

# Install build tools
info 'Installing build tools'
sudo apt install ca-certificates apt-transport-https software-properties-common build-essential --yes

# Install system tools
info 'Installing system tools'
sudo apt install curl git zsh gh --yes

info 'Installing LEMP stack'
# Install MariaDB
sudo apt install mariadb-server mariadb-client --yes
sudo systemctl stop mariadb
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo mysql_secure_installation
sudo systemctl restart mariadb
# Install Nginx
sudo apt install nginx --yes
# Install PHP
sudo apt install php8.1 php8.1-fpm --yes
# Install PHP extensions
sudo apt install php8.1-cli php8.1-common php8.1-curl php8.1-bcmath php8.1-gd php8.1-mbstring php8.1-mcrypt php8.1-opcache php8.1-mysql php8.1-readline php8.1-xml php8.1-zip unzip --yes
# Install Composer
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php &&
	sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer &&
	sudo chmod +x /usr/local/bin/composer
# Configure Composer authentication for Private Packagist
composer config --global --auth http-basic.repo.packagist.com itineris packagist_uut_4f4fa1ebdf7cf14dc2f6a3feaa2277cffe8fe96d64fddd4483f62d2f429501028ee3 #TODO: use env variable
# Install valet-linux dependencies
sudo apt install libnss3-tools jq xsel --yes
# Install valet-linux (requires password)
composer global require cpriego/valet-linux
# shellcheck disable=2016
COMPOSER_BIN_PATH_TEMPLATE='export PATH="${HOME}/.config/composer/vendor/bin:${PATH}"'
eval "${COMPOSER_BIN_PATH_TEMPLATE}"
echo "${COMPOSER_BIN_PATH_TEMPLATE}" >>~/.bashrc
echo "${COMPOSER_BIN_PATH_TEMPLATE}" >>~/.zshrc

info 'Installing dev tools'
# Install NVM
sudo apt remove nodejs --purge --yes
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
# shellcheck disable=2016
NVM_TEMPLATE='export NVM_DIR="${HOME}/.nvm"
[ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"  # This loads nvm
[ -s "${NVM_DIR}/bash_completion" ] && \. "${NVM_DIR}/bash_completion"  # This loads nvm bash_completion'
eval "${NVM_TEMPLATE}"
echo "${NVM_TEMPLATE}" >>~/.zshrc
nvm install 16
nvm use node 16
corepack enable
FONTAWESOME_AUTH_TEMPLATE='export FONTAWESOME_NPM_AUTH_TOKEN="8993C8D9-6881-4669-B92B-80237467F248"'
eval "${FONTAWESOME_AUTH_TEMPLATE}"
echo "${FONTAWESOME_AUTH_TEMPLATE}" >>~/.bashrc
echo "${FONTAWESOME_AUTH_TEMPLATE}" >>~/.zshrc
# shellcheck disable=2016
echo 'export PATH="${HOME}/.yarn/bin:${PATH}"' >>~/.bashrc
# shellcheck disable=2016
echo 'export PATH="${HOME}/.yarn/bin:${PATH}"' >>~/.zshrc

# Install WP-CLI
composer global require wp-cli/wp-cli-bundle

# Setup basic SSH config
mkdir -p "${HOME}/.ssh"
if [[ ! -f "${HOME}/.ssh/config" ]]; then
	echo "Host *
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_rsa" >"${HOME}/.ssh/config"
fi

# Generate SSH key and add to GitHub account (https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) with GitHub CLI
read -r -p 'Generate new SSH key? [y\n] ' SHOULD_KEYGEN
if [[ "${SHOULD_KEYGEN}" == [Yy] ]]; then
	read -r -p 'Enter your Git email address to use with the new key: ' KEY_EMAIL_ADDRESS
	ssh-keygen -t rsa -b 4096 -C "${KEY_EMAIL_ADDRESS}"
else
	echo 'Ensure you have added your id_rsa and id_rsa.pub files to ~/.ssh before continuing!'
fi
if [[ -f "${HOME}/.ssh/id_rsa" ]]; then
	chmod 600 "${HOME}/.ssh/id_rsa"
fi

# Start SSH agent
# shellcheck disable=2046
eval $(ssh-agent)
# Add default SSH key to ssh-agent
ssh-add ~/.ssh/id_rsa

# Python install
info 'Installing Python 3'
sudo apt install python3-pip python3-venv --yes

info 'Setup valet-linux'
valet install
# This is needed last because valet-linux will break DNS
setup_network

# Install Trellis CLI
info 'Installing Trellis CLI'
curl -sL https://roots.io/trellis/cli/get | bash -s -- -b ~/.local/bin
# shellcheck disable=2016
echo 'export PATH="${HOME}/.local/bin:${PATH}"' >>~/.bashrc
# shellcheck disable=2016
echo 'eval "$(trellis shell-init bash)"' >>~/.bashrc
# shellcheck disable=2016
echo 'export PATH="${HOME}/.local/bin:${PATH}"' >>~/.zshrc
# shellcheck disable=2016
echo 'eval "$(trellis shell-init zsh)"' >>~/.zshrc

# Create local directories
info 'Create local directories'
mkdir -p "${HOME}/Code/misc"
mkdir -p "${HOME}/Code/wordpress"

# Ensure networking is setup correctly
setup_network

# Set up GitHub CLI authentication
info 'Setting up GitHub CLI authentication'
echo 'If you choose to "Login with a web browser" then you should visit https://github.com/login/device on your local machine to enter in the one-time code'
echo 'WSL cannot open a web browser.'
gh auth login --git-protocol='ssh' --hostname='github.com'

# shellcheck disable=2016
info 'Setup finished! Test setting up a local project now using `clone-project`'

info 'Starting ZSH shell'
if [[ "${SHELL}" != */zsh ]]; then
	chsh -s "$(which zsh)"
fi
command zsh
