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
# Gets the GitHub URL <language><app><fileName>
# Writes url needed to get the sh script from this repo.
###############################################
function getGitHubUrl() {
    language="${1:sh}"
    app="${2:-rasberry-pi}"
    fileName="${3:-init.sh}"
    echo "https://raw.githubusercontent.com/SeanieGleason/rasberry-init-scripts/refs/heads/main/src/main/${language}/${app}/${fileName}"
}

################################################################################
# Inits the application in a Docker container.                                 #
# Copies files down from this repo, and sets docker container and starts it    #
################################################################################
function moveDockerFile() {
    local FUNC_NAME="${1}"

    already_done "$FUNC_NAME" && echo "$FUNC_NAME already done." && return
    local appDir="$HOME/$FUNC_NAME"
    echo "appDir=$appDir"
    mkdir -p "$appDir"
    cd "$appDir"

    for url in "${URLS[@]}"; do
        curl -fsSL -O "$url"
    done

    sudo docker compose up -d
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