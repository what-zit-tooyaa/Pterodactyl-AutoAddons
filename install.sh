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

# Get the latest version before running the script #
get_release() {
curl --silent \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/Ferks-FK/Pterodactyl-AutoAddons/releases/latest |
  grep '"tag_name":' |
  sed -E 's/.*"([^"]+)".*/\1/'
}

GITHUB_STATUS_URL="https://www.githubstatus.com"
SCRIPT_VERSION="main"

# Visual Functions #
print_brake() {
  for ((n = 0; n < $1; n++)); do
    echo -n "#"
  done
  echo ""
}

hyperlink() {
  echo -e "\e]8;;${1}\a${1}\e]8;;\a"
}

YELLOW="\033[1;33m"
RESET="\e[0m"
RED='\033[0;31m'

error() {
  echo ""
  echo -e "* ${RED}ERROR${RESET}: $1"
  echo ""
}

# Check Sudo #
if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

# Check Git #
if [ -z "$SCRIPT_VERSION" ]; then
  error "Could not get the version of the script using GitHub."
  echo "* Please check on the site below if the 'API Requests' are as normal status."
  echo -e "${YELLOW}$(hyperlink "$GITHUB_STATUS_URL")${RESET}"
  exit 1
fi

# Check Curl #
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

cancel() {
echo
echo -e "* ${RED}Installation Canceled!${RESET}"
done=true
exit 1
}

done=false

echo
print_brake 70
echo "* Pterodactyl-AutoAddons Script @ $SCRIPT_VERSION"
echo
echo "* Copyright (C) 2021 - $(date +%Y), Ferks-FK."
echo "* https://github.com/Ferks-FK/Pterodactyl-AutoAddons"
echo
echo "* This script is not associated with the official Pterodactyl Project."
print_brake 70
echo

Backup() {
bash <(curl -s https://raw.githubusercontent.com/Ferks-FK/Pterodactyl-AutoAddons/"${SCRIPT_VERSION}"/backup.sh)
}

More_Buttons() {
bash <(curl -s https://raw.githubusercontent.com/Ferks-FK/Pterodactyl-AutoAddons/"${SCRIPT_VERSION}"/addons/version1.x/More_Buttons/build.sh)
}

More_Server_Info() {
bash <(curl -s https://raw.githubusercontent.com/Ferks-FK/Pterodactyl-AutoAddons/"${SCRIPT_VERSION}"/addons/version1.x/More_Server_Info/build.sh)
}

Server_Router_Icons() {
bash <(curl -s https://raw.githubusercontent.com/what-zit-tooyaa/Pterodactyl-AutoAddons/"${SCRIPT_VERSION}"/addons/version1.x/Server_Router_Icons/build.sh)
}

PMA_Button_NavBar() {
bash <(curl -s https://raw.githubusercontent.com/what-zit-tooyaa/Pterodactyl-AutoAddons/"${SCRIPT_VERSION}"/addons/version1.x/PMA_Button_NavBar/build.sh)
}

PMA_Button_Database_Tab() {
bash <(curl -s https://raw.githubusercontent.com/Ferks-FK/Pterodactyl-AutoAddons/"${SCRIPT_VERSION}"/addons/version1.x/PMA_Button_Database_Tab/build.sh)
}

MC_Paste() {
bash <(curl -s https://raw.githubusercontent.com/Ferks-FK/Pterodactyl-AutoAddons/"${SCRIPT_VERSION}"/addons/version1.x/MC_Paste/build.sh)
}

Bigger_Console() {
bash <(curl -s https://raw.githubusercontent.com/Ferks-FK/Pterodactyl-AutoAddons/"${SCRIPT_VERSION}"/addons/version1.x/Bigger_Console/build.sh)
}

Files_In_Editor() {
bash <(curl -s https://raw.githubusercontent.com/what-zit-tooyaa/Pterodactyl-AutoAddons/"${SCRIPT_VERSION}"/addons/version1.x/Files_In_Editor/build.sh)
}


while [ "$done" == false ]; do
  options=(
    "Restore Panel Backup (Restore your panel if you have problems or want to remove addons)"
    "Install More Buttons (Only 1.6.6 and 1.8.1)"
    "Install More Server Info (Only 1.8.1 and 1.9.0)"
    "Install Server Router Icons (Only 1.6.6 and v1.8.1)"
    "Install PMA Button NavBar (Only 1.6.6 and 1.8.1)"
    "Install PMA Button Database Tab (Only 1.6.6 and 1.8.1)"
    "Install MC Paste (Only 1.6.6 and 1.7.0)"
    "Install Bigger Console (Only 1.6.6 and 1.7.0)"
    "Install Files In Editor (Only 1.6.6 and v1.8.1)"


    "Cancel Installation"
  )

  actions=(
    "Backup"
    "More_Buttons"
    "More_Server_Info"
    "Server_Router_Icons"
    "PMA_Button_NavBar"
    "PMA_Button_Database_Tab"
    "MC_Paste"
    "Bigger_Console"
    "Files_In_Editor"


    "cancel"
  )

  echo "* Which addon do you want to install?"
  echo

  for i in "${!options[@]}"; do
    echo "[$i] ${options[$i]}"
  done

  echo
  echo -n "* Input 0-$((${#actions[@]} - 1)): "
  read -r action

  [ -z "$action" ] && error "Input is required" && continue

  valid_input=("$(for ((i = 0; i <= ${#actions[@]} - 1; i += 1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && eval "${actions[$action]}"
done
