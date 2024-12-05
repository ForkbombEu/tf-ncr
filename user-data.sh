#!/bin/bash
#enable ncr as a program at startup 
echo "[Unit]
Description=Run NCR program at startup
After=network.target

[Service]
ExecStart=/root/.local/bin/ncr -p 8080 -z /tf-pqcrypto-scripts/contracts
Restart=always
User=root
WorkingDirectory=/root
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/ncr.service
sudo systemctl daemon-reload
sudo systemctl enable ncr.service

# Update the package repository
apt-get update -y
# Install required packages
apt-get install -y wget git
# Create the directory for local binaries if it doesn't exist
mkdir -p ~/.local/bin
# Download the binary
wget https://github.com/forkbombeu/ncr/releases/latest/download/ncr -O ~/.local/bin/ncr && chmod +x ~/.local/bin/ncr
# Add ~/.local/bin to PATH
export PATH=$PATH:~/.local/bin

# Clone NCR repo
git clone https://github.com/forkbombeu/ncr

# Clone the pqcrypto scripts
git clone https://github.com/ForkbombEu/tf-pqcrypto-scripts

# Run the server with the example folder
ncr -p 8080 -z ./tf-pqcrypto-scripts/contracts &
