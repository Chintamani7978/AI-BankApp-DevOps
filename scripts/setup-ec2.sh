#!/bin/bash

set -e

echo "Updating system..."
sudo yum update -y

echo "Installing Docker..."
sudo yum install -y docker

echo "Starting Docker..."
sudo systemctl start docker

echo "Enabling Docker on boot..."
sudo systemctl enable docker

echo "Adding ec2-user to docker group..."
sudo usermod -aG docker ec2-user

echo "Installing Docker Compose..."
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) \
-o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

echo "Docker version:"
docker --version

echo "Docker Compose version:"
docker-compose --version

echo "Server setup completed successfully!"