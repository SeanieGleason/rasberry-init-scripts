#!/bin/bash
set -e

source "../common.sh"

################################################################################
# Main execution                                                               #
################################################################################
function main() {
  startDockerCompose "save-file-converter"
}

main

