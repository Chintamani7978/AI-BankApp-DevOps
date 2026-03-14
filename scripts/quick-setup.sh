#!/bin/bash

# AI BankApp - One-Command Auto Setup
# Usage: curl -fsSL https://raw.githubusercontent.com/Chintamani7978/AI-BankApp-DevOps/main/scripts/quick-setup.sh | bash
# Or: bash quick-setup.sh

REPO_URL="https://github.com/Chintamani7978/AI-BankApp-DevOps"
SETUP_DIR="$HOME/ai-bank-setup"
DOCKERHUB_USER="${DOCKERHUB_USER:-chintamani7978}"

echo "🚀 AI BankApp - Automated Setup"
echo "================================"

# Step 1: Install Docker
echo ""
echo "📦 Step 1: Installing Docker & dependencies..."

if command -v apt-get &> /dev/null; then
    sudo apt-get update -y > /dev/null 2>&1
    sudo apt-get install -y docker.io curl git > /dev/null 2>&1
    sudo systemctl start docker
    sudo systemctl enable docker > /dev/null 2>&1
elif command -v yum &> /dev/null; then
    sudo yum update -y > /dev/null 2>&1
    sudo yum install -y docker curl git > /dev/null 2>&1
    sudo systemctl start docker
    sudo systemctl enable docker > /dev/null 2>&1
fi

# Add docker permissions
sudo usermod -aG docker $(whoami) 2>/dev/null || true

# Step 2: Install Docker Compose
echo "📦 Step 2: Installing Docker Compose..."
sudo curl -sL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose > /dev/null 2>&1
sudo chmod +x /usr/local/bin/docker-compose

# Step 3: Clone/Update repo
echo "📂 Step 3: Cloning/updating repository..."
if [ ! -d "$SETUP_DIR" ]; then
    git clone $REPO_URL $SETUP_DIR > /dev/null 2>&1
else
    cd $SETUP_DIR
    git fetch origin main 2>/dev/null || true
    git reset --hard origin/main 2>/dev/null || true
fi

# Apply group changes
newgrp docker 2>/dev/null || sg docker "cd $SETUP_DIR && true"

# Step 4: Run setup script
echo "⚙️  Step 4: Running setup script..."
cd $SETUP_DIR
bash scripts/setup-ec2.sh

echo ""
echo "✅ Setup completed! Your app is running at:"
echo "   🌐 http://$(hostname -I | awk '{print $1}'):8080"
