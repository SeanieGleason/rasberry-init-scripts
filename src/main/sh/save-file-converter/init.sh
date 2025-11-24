#!/bin/bash
set -e

source "../common.sh"

################################################################################
# URL's needed to setup DreamPi in docker.                                     #
################################################################################
URLS=(
    "$(getGitHubUrl "docker" "save-file-converter" "Dockerfile")"
    "$(getGitHubUrl "docker" "save-file-converter" "docker-compose.yaml")"
)

################################################################################
# Main execution                                                               #
################################################################################
function main() {
  moveDockerFiles "save-file-converter"
  moveFile "nginx.conf"
}

main

