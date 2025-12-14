# Use a common Debian/Ubuntu base. Ubuntu 22.04 is a good modern choice.
FROM ubuntu:22.04

# Set non-interactive mode for APT
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install necessary packages (replicates the Ansible apt task)
# The rpi-chromium-mods package is specific to Raspberry Pi OS. It may fail on a non-Pi base
# but is included for completeness. If it fails, remove it and adjust the base image.
RUN apt-get update && \
    apt-get install -y \
    vim screen python3-serial python3-dev ppp libjpeg-dev \
    python3-pil python3-rpi.gpio python3-smbus python3-pip python3-websocket git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Application Setup
# Create necessary directory for PPP configuration
RUN mkdir -p /etc/ppp/chat

# Copy the resolved configuration files (from Ansible template tasks)
# Destination paths mirror those in the Ansible playbook.
COPY dreampi.conf /etc/dreampi.conf
COPY dreampi-chat /etc/ppp/chat/dreampi-chat
COPY dreampi-ppp /etc/ppp/peers/dreampi-ppp

# Copy and make execution scripts executable (mode: 0755)
COPY dreampi /usr/local/bin/dreampi
COPY dialup /usr/local/bin/dialup

# Ensure scripts are executable
RUN chmod +x /usr/local/bin/dreampi /usr/local/bin/dialup

# 3. Command/Entrypoint
# The command replaces the systemd service's execution of the main script.
CMD ["/usr/local/bin/dreampi"]