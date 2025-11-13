#!/bin/bash
set -e

source "../common.sh"

################################################################################
# Install HDParm
################################################################################
function installHDParm() {
    local FUNC_NAME="installHDParm"
    already_done "$FUNC_NAME" && echo "$FUNC_NAME already done." && return

    local usbDevice
    usbDevice=$(blkid -o device -l -t LABEL=HOME_SERVER)
    if [ -z "$usbDevice" ]; then
        echo "No USB partition labeled HOME_SERVER found."
        exit 1
    fi

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

setUSBDrive
installSamba
installHDParm

echo "Setup complete."
