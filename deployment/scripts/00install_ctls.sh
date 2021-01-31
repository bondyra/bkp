#!/usr/bin/env bash
set -e

TEMPDIR="$(mktemp -d)"
PLATFORM="$(uname | tr '[:upper:]' '[:lower:]')"
URL="https://releases.hashicorp.com/terraform/0.12.2/terraform_0.12.2_${PLATFORM}_amd64.zip"

curl "$URL" --output "terraform.zip"
unzip "terraform.zip"

sudo snap install helm --classic
