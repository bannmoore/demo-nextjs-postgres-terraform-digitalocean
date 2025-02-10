#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

(
  cd ./super-duper-infra
  terraform destroy
)