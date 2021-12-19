#!/bin/bash

set -e

########################################################
# 
#         Pterodactyl-AutoAddons Installation
#
#         Created and maintained by Ferks-FK
#
#            Protected by GPL 3.0 License
#
########################################################

#### Variables ####
SCRIPT_VERSION="v1.0"
SUPPORT_LINK="https://discord.gg/buDBbSGJmQ"
PMA=""
MORE_BUTTONS="/var/www/pterodactyl/resources/scripts/components/server/MoreButtons.tsx"


print_brake() {
  for ((n = 0; n < $1; n++)); do
    echo -n "#"
  done
  echo ""
}

print_error() {
  COLOR_RED='\033[0;31m'
  COLOR_NC='\033[0m'

  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}


hyperlink() {
  echo -e "\e]8;;${1}\a${1}\e]8;;\a"
}


#### Colors ####

GREEN="\e[0;92m"
YELLOW="\033[1;33m"
red='\033[0;31m'
reset="\e[0m"


#### OS check ####

check_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$(echo "$ID")
    OS_VER=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si)
    OS_VER=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$(echo "$DISTRIB_ID")
    OS_VER=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then
    OS="debian"
    OS_VER=$(cat /etc/debian_version)
  elif [ -f /etc/SuSe-release ]; then
    OS="SuSE"
    OS_VER="?"
  elif [ -f /etc/redhat-release ]; then
    OS="Red Hat/CentOS"
    OS_VER="?"
  else
    OS=$(uname -s)
    OS_VER=$(uname -r)
  fi

  OS=$(echo "$OS")
  OS_VER_MAJOR=$(echo "$OS_VER" | cut -d. -f1)
}

#### Verify Compatibility ####

compatibility() {
echo
print_brake 57
echo -e "* ${GREEN}Checking if the addon is compatible with your panel...${reset}"
print_brake 57
echo
sleep 2
DIR="/var/www/pterodactyl/config/app.php"
CODE="    'version' => '1.6.6',"
if [ -f "$DIR" ]; then
  VERSION=$(cat "$DIR" | grep -n ^ | grep ^12: | cut -d: -f2)
    if [ "$VERSION" == "$CODE" ]; then
        echo
        print_brake 23
        echo -e "* ${GREEN}Compatible Version!${reset}"
        print_brake 23
        echo
      else
        echo
        print_brake 24
        echo -e "* ${red}Incompatible Version!${reset}"
        print_brake 24
        echo
        exit 1
    fi
  else
    echo
    print_brake 26
    echo -e "* ${red}The file doesn't exist!${reset}"
    print_brake 26
    echo
    exit 1
fi
}


#### Pre-configuring the addon ####

configure() {
  while [ -z "$PMA" ]; do
    echo
    echo -n -e "* Enter the exact URL to your PhpMyAdmin here (${YELLOW}https://phpmyadmin.com)${reset}: "
    read -r PMA
    [ -z "$PMA" ] && print_error "PMA cannot be empty!"
  done
  sed -i -e "s@<pma>@window.open('$PMA');@g" "$MORE_BUTTONS"
  #### Continue Script ####

  dependencies
  production
  bye
}



#### Install Dependencies ####

dependencies() {
echo
print_brake 30
echo -e "* ${GREEN}Installing dependencies...${reset}"
print_brake 30
echo
case "$OS" in
debian | ubuntu)
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash - && apt-get install -y nodejs && sudo apt-get install -y zip
;;
esac

if [ "$OS_VER_MAJOR" == "7" ]; then
curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash - && sudo yum install -y nodejs yarn && sudo yum install -y zip
fi

if [ "$OS_VER_MAJOR" == "8" ]; then
curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash - && sudo dnf install -y nodejs && sudo dnf install -y zip
fi
}


#### Panel Backup ####

backup() {
echo
print_brake 32
echo -e "* ${GREEN}Performing security backup...${reset}"
print_brake 32
if [ -f "/var/www/pterodactyl/PanelBackup/PanelBackup.zip" ]; then
echo
print_brake 45
echo -e "* ${GREEN}There is already a backup, skipping step...${reset}"
print_brake 45
echo
else
cd /var/www/pterodactyl
mkdir -p PanelBackup
zip -r PanelBackup.zip -- * .env
mv PanelBackup.zip PanelBackup
fi
}


#### Download Files ####

download_files() {
print_brake 25
echo -e "* ${GREEN}Downloading files...${reset}"
print_brake 25
cd /var/www/pterodactyl
mkdir -p temp
cd temp
curl -sSLo More_Buttons.tar.gz https://raw.githubusercontent.com/Ferks-FK/Pterodactyl-AutoAddons/${SCRIPT_VERSION}/addons/version1.x/More_Buttons/More_Buttons.tar.gz
tar -xzvf More_Buttons.tar.gz
cd More_Buttons/resources/scripts/components/server
cp -r MoreButtons.tsx /var/www/pterodactyl/resources/scripts/components/server
cp -r ServerConsole.tsx /var/www/pterodactyl/resources/scripts/components/server
cd /var/www/pterodactyl
rm -rf temp
}

#### Check if it is already installed ####

verify_installation() {
  if [ -f "$MORE_BUTTONS" ]; then
      print_brake 61
      echo -e "* ${red}This addon is already installed in your panel, aborting...${reset}"
      print_brake 61
      exit 1
    else
      backup
      download_files
      configure
  fi
}

#### Panel Production ####

production() {
DIR=/var/www/pterodactyl
if [ -d "$DIR" ]; then
echo
print_brake 25
echo -e "* ${GREEN}Producing panel...${reset}"
print_brake 25
npm i -g yarn
cd /var/www/pterodactyl
yarn install
yarn add @emotion/react
yarn build:production
fi
}


bye() {
print_brake 50
echo
echo -e "* ${GREEN}The addon ${YELLOW}More Buttons${GREEN} was successfully installed."
echo -e "* A security backup of your panel has been created."
echo -e "* Thank you for using this script."
echo -e "* Support group: ${YELLOW}$(hyperlink "$SUPPORT_LINK")${reset}"
echo
print_brake 50
}


#### Exec Script ####
check_distro
compatibility
verify_installation