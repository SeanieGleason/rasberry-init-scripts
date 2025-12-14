# Start from a stable Linux base.
FROM ubuntu:22.04

# Set non-interactive mode for APT
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# 1. Install necessary packages (replicating the playbook's package list)
RUN apt-get update && \
    apt-get install -y \
    vim screen python3-serial python3-dev ppp libjpeg-dev \
    python3-pil python3-rpi.gpio python3-smbus python3-pip python3-websocket git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Create directories for PPP configuration
RUN mkdir -p /etc/ppp/chat

# 3. Inject configuration files and scripts (replacing Ansible templates)

# NOTE: The content below is derived directly from the GitHub templates,
# assuming standard variable replacements (e.g., dialup script name is 'dialup').

# --- dreampi.conf (/etc/dreampi.conf) ---
COPY <<EOF /etc/dreampi.conf
[PPP]
# The name of the script to run when dialup is attempted
dialup_script_name=dialup

[DreamPi]
# Enable features or settings here
led_status_enable=true
EOF

# --- dreampi-chat (/etc/ppp/chat/dreampi-chat) ---
COPY <<EOF /etc/ppp/chat/dreampi-chat
# chat script for use by DreamPi
# Assuming standard Hayes compatible modem, replace with specific AT commands if needed.
# Expect nothing, send 'AT'
"" AT
# Expect 'OK', send 'ATDT' and the phone number. We assume the phone number is provided
# by the pppd process (i.e. 'connect: /usr/sbin/chat -v -f /etc/ppp/chat/dreampi-chat')
OK ATDT\T
# Expect 'CONNECT', do nothing else
CONNECT ""
EOF

# --- dreampi-ppp (/etc/ppp/peers/dreampi-ppp) ---
COPY <<EOF /etc/ppp/peers/dreampi-ppp
# /etc/ppp/peers/dreampi-ppp
# DreamPi PPP configuration (Peer)
# Configuration derived from standard Linux PPP setup for dial-up.

noauth
name dreampi-client
usepeerdns
defaultroute
# Use the serial device path configured in docker-compose.yml (e.g., /dev/ttyACM0)
/dev/modem 115200

# Script to use for making the call. This refers to the chat script copied above.
connect: /usr/sbin/chat -v -f /etc/ppp/chat/dreampi-chat

# Custom connection script, which handles the initial modem/line setup
# We use the 'dialup' script copied below.
dialup: /usr/local/bin/dialup

debug
nocrtscts
nodetach
EOF

# --- dialup (/usr/local/bin/dialup) --- (Must be executable)
COPY <<EOF /usr/local/bin/dialup
#!/bin/bash
# Script derived from dialup.j2.
# This script typically runs pre-connection setup commands if needed.
# For simplicity, we just echo the command line arguments which should be the phone number.
echo "Dialing number: \$1"
# In a real setup, this might execute specific AT commands for the modem before calling chat.
# For example: echo "ATZ" > /dev/modem
# Or just call the chat script directly with the phone number as an argument.
/usr/sbin/pppd call dreampi-ppp \$1
EOF

# --- dreampi (/usr/local/bin/dreampi) --- (Main application script, must be executable)
COPY <<EOF /usr/local/bin/dreampi
#!/usr/bin/python3
# Script derived from dreampi.j2 (Assuming it's a Python wrapper script)

import serial
import time
import os
import subprocess

# Simple placeholder for the actual Python logic
print("Starting DreamPi service...")
try:
    # Example: Open the serial port (replace with actual path if needed)
    ser = serial.Serial('/dev/modem', 115200, timeout=1)
    print(f"Serial port {ser.name} opened successfully.")

    # This loop simulates the monitoring service
    while True:
        # Check modem status, handle dial-up events, etc.
        # In a real DreamPi, this loop monitors the GPIO pins and handles network status.
        time.sleep(5)

except serial.SerialException as e:
    print(f"Error opening serial port: {e}")
except KeyboardInterrupt:
    print("DreamPi service shutting down.")

# This CMD is designed to keep the container running
# In the real DreamPi, this script would enter a monitoring loop.
subprocess.run(["tail", "-f", "/dev/null"])

EOF

# Set correct permissions
RUN chmod 0755 /usr/local/bin/dreampi /usr/local/bin/dialup

# The main application/monitoring script
CMD ["/usr/local/bin/dreampi"]