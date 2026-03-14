#!/bin/bash

set -e

echo "Updating system..."

# Detect OS and install packages accordingly
if command -v apt-get &> /dev/null; then
    # Ubuntu/Debian
    echo "Detected Ubuntu/Debian system"
    sudo apt-get update -y
    sudo apt-get install -y \
        docker.io \
        curl \
        git
    
    echo "Starting Docker..."
    sudo systemctl start docker
    
    echo "Enabling Docker on boot..."
    sudo systemctl enable docker
    
    # Get current user
    CURRENT_USER=$(whoami)
    echo "Adding $CURRENT_USER to docker group..."
    sudo usermod -aG docker $CURRENT_USER
    
elif command -v yum &> /dev/null; then
    # Amazon Linux/CentOS
    echo "Detected Amazon Linux/CentOS system"
    sudo yum update -y
    sudo yum install -y \
        docker \
        curl \
        git
    
    echo "Starting Docker..."
    sudo systemctl start docker
    
    echo "Enabling Docker on boot..."
    sudo systemctl enable docker
    
    echo "Adding ec2-user to docker group..."
    sudo usermod -aG docker ec2-user
else
    echo "Unsupported OS"
    exit 1
fi

echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

echo "Docker version:"
docker --version

echo "Docker Compose version:"
docker-compose --version

echo "Server setup completed successfully!"