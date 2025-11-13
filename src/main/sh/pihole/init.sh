#!/bin/bash
set -e

source "../common.sh"

################################################################################
# Main execution                                                               #
################################################################################
function main() {
  startDockerCompose "pihole"
}

main

