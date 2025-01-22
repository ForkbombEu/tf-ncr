#!/bin/bash

# Update the package repository
apt-get update -y
# Install required packages
apt-get install -y wget git
# Set up automatic security upgrades
apt-get install unattended-upgrades
dpkg-reconfigure unattended-upgrades

# Create directories for persistent configuration and binaries
INSTALL_DIR="/opt/ncr"
BIN_DIR="$INSTALL_DIR/bin"
REPO_DIR="$INSTALL_DIR/repos"

mkdir -p $BIN_DIR $REPO_DIR
chown -R nobody:nogroup $INSTALL_DIR

# Download the NCR binary as root and make it executable
wget https://github.com/forkbombeu/ncr/releases/latest/download/ncr -O $BIN_DIR/ncr
chmod +x $BIN_DIR/ncr
chown nobody:nogroup $BIN_DIR/ncr

# Clone NCR repo and pqcrypto scripts into the repository directory
git clone https://github.com/forkbombeu/ncr $REPO_DIR/ncr
chown -R nobody:nogroup $REPO_DIR/ncr
git clone https://github.com/ForkbombEu/tf-pqcrypto-scripts $REPO_DIR/tf-pqcrypto-scripts
chown -R nobody:nogroup $REPO_DIR/tf-pqcrypto-scripts

# Create a systemd service file for NCR
SERVICE_FILE="/etc/systemd/system/ncr.service"
echo "[Unit]
Description=Run NCR program at startup
After=network.target

[Service]
ExecStart=$BIN_DIR/ncr -p 8080 --openapi-info $REPO_DIR/tf-pqcrypto-scripts/openapi_info.json -z $REPO_DIR/tf-pqcrypto-scripts/contracts
Restart=always
User=nobody
WorkingDirectory=$REPO_DIR
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Environment=FILES_DIR=/opt/ncr/repos/tf-pqcrypto-scripts/contracts

[Install]
WantedBy=multi-user.target" > $SERVICE_FILE

# Set proper permissions on the service file
chmod 644 $SERVICE_FILE

# Reload systemd, enable, and start the NCR service
systemctl daemon-reload
systemctl enable ncr.service
systemctl start ncr.service

# Log success message
echo "NCR has been installed and configured to run as 'nobody' at startup." > /tmp/awsMachine_NCR_ConfigDebug.log

