#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Publishes a new Docker image to Digital Ocean.
# If the app is currently live on App Platform, this should trigger an
# update deployment.

CONTAINER_REGISTRY=bam # update this to your registry

doctl auth init
doctl registry login --expiry-seconds 86400

docker compose build app
docker push registry.digitalocean.com/$CONTAINER_REGISTRY/super-duper-app

doctl registry logout