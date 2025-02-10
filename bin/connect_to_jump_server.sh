#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

function get_tf_output() {
  cd ./super-duper-infra
  terraform output -json "$1" | jq -r .
}

JUMP_SERVER_ADDRESS=$(get_tf_output jump_server_address)
JUMP_SERVER_DROPLET_NAME=$(get_tf_output jump_server_droplet_name)
JUMP_SERVER_VOLUME_PATH=$(get_tf_output jump_server_volume_path)
DATABASE_URL=$(get_tf_output database_url)
SSH_KEY=$(get_tf_output jump_server_ssh_private_key_path)

function scp_to_host() {
  scp -i $SSH_KEY "$1" "root@$JUMP_SERVER_ADDRESS:$2"
}

function create_jump_env() {
  printf "export DATABASE_URL=$DATABASE_URL\n" > .jump.env
}

create_jump_env
scp_to_host ./.jump.env "$JUMP_SERVER_VOLUME_PATH/.env"
rm ./.jump.env

doctl compute ssh $JUMP_SERVER_DROPLET_NAME --ssh-key-path $SSH_KEY