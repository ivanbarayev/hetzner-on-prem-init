#!/bin/bash

function NGINX {
  if ! which nginx > /dev/null 2>&1; then
    sudo apt install curl gnupg2 ca-certificates lsb-release dirmngr software-properties-common apt-transport-https -y
    curl -fSsL https://nginx.org/keys/nginx_signing.key | sudo gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg > /dev/null
    gpg --dry-run --quiet --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
    echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/debian `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
    echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99nginx
    sudo apt update -y
    sudo apt install nginx
    systemctl enable nginx
    systemctl start nginx
    systemctl status nginx
  else
    echo "@@@@@@@@@@@@@@@ NGINX already installed. Skipping installation... @@@@@@@@@@@@@@@"
  fi
}

function PG {
  if ! which psql > /dev/null 2>&1; then
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    sudo apt update
    sudo apt upgrade
    sudo apt install postgresql -y
    systemctl enable postgresql
    systemctl start postgresql
    systemctl status postgresql
  else
    echo "@@@@@@@@@@@@@@@ POSTGRES already installed. Skipping installation... @@@@@@@@@@@@@@@"
  fi
}

function NVM {
  if [ -d "${HOME}/.nvm/.git" ]; then
    echo "@@@@@@@@@@@@@@@ NVM already installed. Skipping installation... @@@@@@@@@@@@@@@"
  else
    sudo apt install build-essential libssl-dev
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    source ~/.bashrc
    command -v nvm
    read -p "Please type which NODE version you want to install (17, 18, 19, 20 etc) : " vers
    nvm install $vers
  fi
}

function GOLANG {
  if ! command -v go > /dev/null 2>&1; then
    read -p "Please type which GOLANG version you want to install (1.24.3, 1.24.5 etc) : " vers

    wget_result="$(wget -NS https://go.dev/dl/go$vers.linux-amd64.tar.gz 2>&1|grep "HTTP/"|awk '{print $2}')"

    if [ $wget_result = 200 || $wget_result = 302]; then
      sudo tar -C /usr/local -xzf go$vers.linux-amd64.tar.gz
      echo "export PATH=/usr/local/go/bin:${PATH}" | sudo tee -a $HOME/.profile
      source $HOME/.profile
    else
      echo "******* Something went wrong *******"
      exit 1
    fi
  else
    echo "@@@@@@@@@@@@@@@ GOLANG already installed. Skipping installation... @@@@@@@@@@@@@@@"
  fi
}

selections=(
  "Nginx"
  "PostgresSQL"
  "NVM"
  "GO Lang"
  "Git"
)

function choose_from_menu() {
  local -r prompt="$1" outvar="$2" options=("${@:3}")
  local cur=0 count=${#options[@]} index=0
  local esc=$(echo -en "\e") # cache ESC as test doesn't allow esc codes
  printf "$prompt\n"
  while true
    do
      # list all options (option list is zero-based)
      index=0
      for o in "${options[@]}"
      do
        if [ "$index" == "$cur" ]
          then echo -e " >\e[7m$o\e[0m" # mark & highlight the current option
        else echo "  $o"
        fi
          (( index++ ))
      done
      read -s -n3 key # wait for user to key in arrows or ENTER
        if [[ $key == $esc[A ]] # up arrow
          then (( cur-- )); (( cur < 0 )) && (( cur = 0 ))
        elif [[ $key == $esc[B ]] # down arrow
          then (( cur++ )); (( cur >= count )) && (( cur = count - 1 ))
        elif [[ $key == "" ]] # nothing, i.e the read delimiter - ENTER
          then break
        fi
        echo -en "\e[${count}A" # go up to the beginning to re-render
    done

    printf -v $outvar "${options[$cur]}"
}

choose_from_menu "Please make a choice:" selected_choice "${selections[@]}"

case $selected_choice in
  "Git")
    sudo apt install git -y
    ;;
  "Nginx")
    NGINX
    ;;
  "PostgresSQL")
    PG
    ;;
  "NVM")
    NVM
    ;;
  "GO Lang")
    GOLANG
    ;;
  "Quit")
    ;;
  *) echo "invalid option $REPLY";;
esac
