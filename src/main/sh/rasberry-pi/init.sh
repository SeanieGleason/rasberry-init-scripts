#!/bin/bash
set -e

source "../common.sh"

################################################################################
# Prevent DNS updates
################################################################################
function preventDNSUpdate() {
    local FUNC_NAME="preventDNSUpdate"
    already_done "$FUNC_NAME" && echo "$FUNC_NAME already done." && return

    # Only overwrite if not already set
    if ! grep -q "nameserver 192.168.0.1" /etc/resolv.conf; then
        echo "nameserver 192.168.0.1" | sudo tee /etc/resolv.conf > /dev/null
    fi
    sudo chattr +i /etc/resolv.conf || true

    mark_done "$FUNC_NAME"
}

################################################################################
# Setup Update Command
################################################################################
function setupUpdateCommand() {
    local FUNC_NAME="setupUpdateCommand"
    already_done "$FUNC_NAME" && echo "$FUNC_NAME already done." && return

    cat > ~/update.sh <<'EOF'
#!/bin/bash
set -e
sudo apt-get update --yes
sudo apt-get upgrade --yes
sudo apt-get dist-upgrade --yes
sudo apt autoremove --yes
EOF

    chmod +x ~/update.sh
    grep -qxF "alias update='yes | sudo ~/update.sh && sudo rm -r ~/etc-pihole/pihole-FTL.db && sudo reboot'" ~/.bashrc || \
        echo "alias update='yes | sudo ~/update.sh && sudo rm -r ~/etc-pihole/pihole-FTL.db && sudo reboot'" >> ~/.bashrc

    mark_done "$FUNC_NAME"
}

################################################################################
# Main execution                                                               #
################################################################################

installDocker
preventDNSUpdate
setupUpdateCommand

echo "Setup complete."