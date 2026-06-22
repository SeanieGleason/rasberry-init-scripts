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
usbDevice=$(blkid -o device -l -t PARTLABEL=bambi)

if [ -z "$usbDevice" ]; then
    echo "No USB partition labeled bambi found."
    return
fi

sudo apt install -y hdparm
sudo hdparm -I "$usbDevice" | grep 'Write cache' || true

if ! grep -q "^$usbDevice" /etc/hdparm.conf 2>/dev/null; then
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

if ! grep -q "\[alt\]" /etc/samba/smb.conf; then
    sudo tee -a /etc/samba/smb.conf > /dev/null <<'EOF'

[alt]
path = /media/bambi
public = no
writable = yes
guest ok = no
create mask = 0777
directory mask = 0777
valid users = pi
browseable = yes

[public]
path = /media/PUBLIC
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

# Set USB Drive (LUKS)

################################################################################
function setUSBDrive() {
local FUNC_NAME="setUSBDrive"
already_done "$FUNC_NAME" && echo "$FUNC_NAME already done." && return

sudo apt install -y cryptsetup cryptsetup-initramfs

local luksPartition
luksPartition=$(blkid -o device -l -t PARTLABEL=bambi)

if [ -z "$luksPartition" ]; then
    echo "No LUKS partition labeled bambi found."
    exit 1
fi

local mapperName="bambi"
local mountPoint="/media/bambi"
local keyFile="/root/.luks-bambi.key"

############################################################################
# Create mount point
############################################################################

sudo mkdir -p "$mountPoint"

############################################################################
# Create key file
############################################################################

if [ ! -f "$keyFile" ]; then
    echo "Creating LUKS key file..."

    sudo dd if=/dev/urandom of="$keyFile" bs=4096 count=1 status=none
    sudo chmod 600 "$keyFile"

    echo "Adding key file to LUKS volume..."
    sudo cryptsetup luksAddKey "$luksPartition" "$keyFile"
fi

############################################################################
# Configure crypttab
############################################################################

local uuid
uuid=$(blkid -s UUID -o value "$luksPartition")

if ! grep -q "^${mapperName} " /etc/crypttab 2>/dev/null; then
    echo "${mapperName} UUID=${uuid} ${keyFile} luks,nofail" | \
        sudo tee -a /etc/crypttab > /dev/null
fi

############################################################################
# Unlock device
############################################################################

if ! sudo cryptsetup status "$mapperName" >/dev/null 2>&1; then
    sudo cryptsetup luksOpen \
        "$luksPartition" \
        "$mapperName" \
        --key-file "$keyFile"
fi

############################################################################
# Configure fstab
############################################################################

if ! grep -q "/dev/mapper/${mapperName}" /etc/fstab 2>/dev/null; then
    echo "/dev/mapper/${mapperName} ${mountPoint} ext4 defaults,nofail 0 2" | \
        sudo tee -a /etc/fstab > /dev/null
fi

############################################################################
# Mount device
############################################################################

sudo mountpoint -q "$mountPoint" || \
    sudo mount "/dev/mapper/${mapperName}" "$mountPoint"

sudo chown -R pi:pi "$mountPoint"

mark_done "$FUNC_NAME"

}

################################################################################
# Setup microsd card for mounting
################################################################################
function setMicroSdCard() {
  local FUNC_NAME="setMicroSdCard"
  already_done "$FUNC_NAME" && echo "$FUNC_NAME already done." && return

  sudo apt install -y ntfs-3g

  local usbPartition
  usbPartition=$(blkid -o device -l -t LABEL=PUBLIC)

  if [ -z "$usbPartition" ]; then
      echo "No USB partition labeled PUBLIC found."
      exit 1
  fi

  local mountPoint="/media/PUBLIC"

  sudo mkdir -p "$mountPoint"

  sudo mountpoint -q "$mountPoint" || \
      sudo mount "$usbPartition" "$mountPoint"

  sudo chmod 777 "$mountPoint"

  local uuid
  uuid=$(blkid -s UUID -o value "$usbPartition")

  if ! grep -q "$uuid" /etc/fstab; then
      echo "UUID=$uuid $mountPoint auto defaults,uid=1000,gid=1000,umask=000,nofail 0 0" | \
          sudo tee -a /etc/fstab > /dev/null
  fi

  mark_done "$FUNC_NAME"

}

################################################################################

# Main execution

################################################################################

setUSBDrive
setMicroSdCard
installSamba
installHDParm

echo "Setup complete."
