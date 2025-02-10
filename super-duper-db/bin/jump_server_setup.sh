#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# install dependencies
sudo apt-get install golang-go python3-pip libpq-dev python-dev-is-python3

# install goose
if [[ $(which goose) ]]; then
  echo "Skipping goose installation."
else
  curl -fsSL \
    https://raw.githubusercontent.com/pressly/goose/master/install.sh |\
    sh 
fi

# install pgcli
if [[ $(which pgcli) ]]; then
  echo "Skipping pgcli installation."
else
  sudo pip install --break-system-packages pgcli
fi