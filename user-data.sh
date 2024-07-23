#!/bin/bash
#debug to leave a proof to be check via ssh to see if code was executed
echo "log: user-data.sh was executed
" >> thisFileCanBeRemoved_user-data.sh_executions.log
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
# Clone the repository
git clone https://github.com/forkbombeu/ncr
# Run the server with the example folder
ncr -p 8080 -z ./ncr/tests/fixtures --public-directory ./ncr/public &