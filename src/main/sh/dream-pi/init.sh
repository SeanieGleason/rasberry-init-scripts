#!/bin/bash
set -e

source "../common.sh"

################################################################################
# URL's needed to setup DreamPi in docker.                                     #
################################################################################
URLS=(
    "$(getGitHubUrl "docker" "dream-pi" "Dockerfile")"
    "$(getGitHubUrl "docker" "dream-pi" "docker-compose.yaml")"
)

################################################################################
# Main execution                                                               #
################################################################################
function main() {
  moveDockerFile "dream-pi"
}

main

