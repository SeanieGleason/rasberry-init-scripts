# Start from a suitable Debian-based image (buster-slim aligns with the history)
FROM debian:buster-slim

# Set environment variables
ENV DREAMP_HOME=/home/pi/dreampi
ENV PI_USER=pi

# Create the user and home directory (following the /home/pi/dreampi structure)
RUN groupadd --gid 1000 $PI_USER \
    && useradd --uid 1000 --gid $PI_USER --shell /bin/bash --create-home $PI_USER \
    && mkdir -p $DREAMP_HOME \
    && chown -R $PI_USER:$PI_USER /home/$PI_USER

# Set the working directory
WORKDIR $DREAMP_HOME

# -----------------------------------------------------------
# Initial Setup and Dependencies (Steps 9, 11, 15, 25, 26, 41, 43, 47, 50, 60, 65, 89)
# -----------------------------------------------------------
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        openssh-server \
        wvdial \
        dnsmasq \
        python-serial \
        python-sh \
        python-pip \
        python-iptables \
        iptables \
        libxtables12 \
        python-miniupnpc \
        arping \
        wget \
        g++ \
        less \
        vim \
        python-requests \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install python-iptables dependency via pip (Steps 56, 57)
RUN pip install python-iptables

# -----------------------------------------------------------
# Dreampi Clone and Configuration (Steps 16, 19, 33)
# The 'arm' packages are included here by the clone.
# -----------------------------------------------------------
RUN git clone https://github.com/Kazade/dreampi.git . \
    && chown -R $PI_USER:$PI_USER . \
    && rm -f /etc/dnsmasq.d/dnsmasq.conf \
    && ln -s $DREAMP_HOME/etc/dnsmasq.conf /etc/dnsmasq.d/dreampi.conf

# Create systemd service structure and link service file (Steps 168-170)
RUN mkdir -p /etc/systemd/system/ \
    && ln -s $DREAMP_HOME/etc/systemd/system/dreampi.service /etc/systemd/system/dreampi.service

# Link dreampi.py to /usr/local/bin (Step 81)
RUN ln -s $DREAMP_HOME/dreampi.py /usr/local/bin/dreampi

# -----------------------------------------------------------
# Custom Packages Installation (Steps 72, 74, 186, 187, 264, 349)
# Accessing DEB files directly from the cloned 'arm' directory.
# -----------------------------------------------------------
RUN dpkg -i $DREAMP_HOME/arm/dcgamespy_1.0-1.deb \
    && dpkg -i $DREAMP_HOME/arm/dcvoip_1.0-1.deb \
    && dpkg -i $DREAMP_HOME/arm/dc2k2_1.0.deb \
    && dpkg -i $DREAMP_HOME/arm/dcdaytona_1.1.deb

# Fix broken dependencies after custom dpkg installs (Step 281)
RUN apt-get update && apt-get install -y -f

# Install BBA Mode installer (Steps 355, 356)
RUN wget --no-check-certificate https://dreamcastlive.net/files/installer-bba-mode.deb \
    && dpkg -i installer-bba-mode.deb

# -----------------------------------------------------------
# Wificonfig Compilation (Steps 271-274, 279)
# -----------------------------------------------------------
RUN g++ -o $DREAMP_HOME/local/bin/wificonfig $DREAMP_HOME/local/bin/wificonfig.cpp -std=c++11 \
    && chmod +x $DREAMP_HOME/local/bin/wificonfig \
    && ln -s $DREAMP_HOME/local/bin/wificonfig /usr/local/bin/wificonfig

# -----------------------------------------------------------
# Final Setup & Entrypoint
# -----------------------------------------------------------
# Set correct ownership for the user
RUN chown -R $PI_USER:$PI_USER /home/$PI_USER

# Run the dreampi application (using --no-daemon for foreground process)
CMD ["/usr/local/bin/dreampi", "--no-daemon"]