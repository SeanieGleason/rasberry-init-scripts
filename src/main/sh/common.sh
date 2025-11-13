#!/bin/bash

# File to store which setup steps have been completed
STATUS_FILE="$HOME/.setup_status"

# Ensure the status file exists
touch "$STATUS_FILE"

###############################################
# mark_done <name>
# Writes the function/task name to the status
# file to record that the step has finished.
###############################################
function mark_done() {
    echo "$1" >> "$STATUS_FILE"
}

###############################################
# already_done <name>
# Returns 0 (true) if the step name exists in
# the status file. Useful for skipping tasks.
###############################################
function already_done() {
    grep -Fxq "$1" "$STATUS_FILE"
}

###############################################
# Gets all file for the given app to install.
# Loops over 'sh' folder and downloads and installs all.
###############################################
downloadLibraryInstallFiles() {
    app="$1"
    local FUNC_NAME="downloadLibraryInstallFiles/$app"
    already_done "$FUNC_NAME" && echo "$FUNC_NAME already done." && return

    appDownloadUrl="https://raw.githubusercontent.com/SeanieGleason/rasberry-init-scripts/refs/heads/main/src/main/docker/$app"
    folderDownloadUrl="https://api.github.com/repositories/1095854083/contents/src/main/docker/$app"

    installJq

    curl -s "$folderDownloadUrl" | jq -r '.[] | select(.type=="file") | [.download_url] | @tsv' |
    while IFS=$'\t' read -r fileurl; do
        sudo curl -fsSL -O "$fileurl"
    done

    mark_done "$FUNC_NAME"
}

################################################################################
# Install Docker
################################################################################
function installDocker() {
    local FUNC_NAME="installDocker"
    already_done "$FUNC_NAME" && echo "$FUNC_NAME already done." && return

    sudo apt update
    sudo apt install -y ca-certificates curl gnupg lsb-release
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable
EOF

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable docker

    mark_done "$FUNC_NAME"
}

################################################################################
# Install jq
################################################################################
function installJq() {
    local FUNC_NAME="installJq"
    already_done "$FUNC_NAME" && echo "$FUNC_NAME already done." && return

    sudo apt update
    sudo apt install -y jq

    mark_done "$FUNC_NAME"
}

################################################################################
# Installs and starts dockerfiles
################################################################################
function startDockerCompose() {
    app="$1"
  local FUNC_NAME="startDockerCompose/$app"
  already_done "$FUNC_NAME" && echo "$app already done." && return

  mkdir -p "$HOME/$app"
  cd "$HOME/$app"
  downloadLibraryInstallFiles "$app"
  sudo docker compose up -d

  mark_done "$FUNC_NAME"
}