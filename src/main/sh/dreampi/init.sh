#!/bin/bash
set -e

source "../common.sh"

################################################################################
# URL's needed to setup DreamPi in docker.                                     #
################################################################################
URLS=(
    "$(getGitHubUrl "docker" "dreampi" "Dockerfile")"
    "$(getGitHubUrl "docker" "dreampi" "docker-compose.yaml")"
)

################################################################################
# Main execution                                                               #
################################################################################
function main() {
  moveDockerFiles "dreampi"
}

main

