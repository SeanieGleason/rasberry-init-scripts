#!/bin/bash
set -e

source "../common.sh"

################################################################################
# Install HDParm
################################################################################
function installHDParm() {
    local FUNC_NAME="installHDParm"
    already_done "$FUNC_NAME" && echo "$FUNC_NAME already done." && return

    local usbDevice="/dev/sda1"
    sudo apt install -y hdparm
    sudo hdparm -I "$usbDevice" | grep 'Write cache'

    # Only append if not already present
    if ! grep -q "^$usbDevice" /etc/hdparm.conf; then
        sudo tee -a /etc/hdparm.conf > /dev/null <<EOF
$usbDevice {
    write_cache = on
    spindown_time = 120
}
EOF
    fi

    mark_done "$FUNC_NAME"
}

################################################################################
# Install Samba
################################################################################
function installSamba() {
    local FUNC_NAME="installSamba"
    already_done "$FUNC_NAME" && echo "$FUNC_NAME already done." && return

    sudo apt install -y samba
    sudo sed -i '/^\[global\]/a access based share enum = yes' /etc/samba/smb.conf

    # Only append shares if not already present
    if ! grep -q "\[alt\]" /etc/samba/smb.conf; then
        sudo tee -a /etc/samba/smb.conf > /dev/null <<'EOF'

[alt]
path = /media/HOME_SERVER/.alt/
public = no
writable = yes
guest ok = no
create mask = 0777
directory mask = 0777
valid users = pi
browseable = yes

[public]
path = /media/HOME_SERVER/public
writable = yes
guest ok = yes
create mask = 0777
directory mask = 0777
force user = pi
EOF
    fi

    sudo smbpasswd -a pi
    mark_done "$FUNC_NAME"
}

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
# Set USB Drive
################################################################################
function setUSBDrive() {
    local FUNC_NAME="setUSBDrive"
    already_done "$FUNC_NAME" && echo "$FUNC_NAME already done." && return

    sudo apt install -y ntfs-3g

    local usbPartition
    usbPartition=$(blkid -o device -l -t LABEL=HOME_SERVER)
    if [ -z "$usbPartition" ]; then
        echo "No USB partition labeled HOME_SERVER found."
        exit 1
    fi

    local mountPoint="/media/HOME_SERVER"
    sudo mkdir -p "$mountPoint"
    sudo mountpoint -q "$mountPoint" || sudo mount "$usbPartition" "$mountPoint"
    sudo chmod 777 "$mountPoint"

    # Add to fstab if not already present
    local uuid
    uuid=$(blkid -s UUID -o value "$usbPartition")
    if ! grep -q "$uuid" /etc/fstab; then
        echo "UUID=$uuid $mountPoint ntfs defaults 0 0" | sudo tee -a /etc/fstab > /dev/null
    fi

    mark_done "$FUNC_NAME"
}

################################################################################
# Main execution                                                               #
################################################################################

installDocker
preventDNSUpdate
setUSBDrive
installSamba
installHDParm
setupUpdateCommand

echo "Setup complete."
