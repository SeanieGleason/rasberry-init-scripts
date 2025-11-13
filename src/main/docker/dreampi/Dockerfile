# Python 3.11 base image
FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt install -y --no-install-recommends \
        git curl ppp dnsmasq \
        libnfnetlink-dev libmnl-dev libnetfilter-conntrack-dev \
        iptables libxtables-dev gcc python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone Python3-compatible branch
RUN git clone --branch 1.9-dle-py3 https://github.com/sairuk/dreampi.git /opt/dreampi

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r /opt/dreampi/requirements.txt

WORKDIR /opt/dreampi

# Fix any invalid escape sequences (optional cleanup)
RUN sed -i 's/\\V/\\\\V/g; s/\\N/\\\\N/g' dreampi.py

# Expose required ports
EXPOSE 80 53/tcp 53/udp 67/udp

# Run Dreampi with 'start' argument
CMD ["python", "dreampi.py", "start"]