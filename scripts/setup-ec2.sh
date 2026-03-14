#!/bin/bash

set -e

DOCKERHUB_USER=${DOCKERHUB_USER:-chintamani7978}
REPO_URL=${REPO_URL:-https://github.com/Chintamani7978/AI-BankApp-DevOps}
SETUP_DIR=${SETUP_DIR:-~/ai-bank-setup}

echo "================================"
echo "AI BankApp Automated Setup"
echo "================================"

# 1. Update system and install dependencies
echo ""
echo "[STEP 1/6] Installing dependencies..."

if command -v apt-get &> /dev/null; then
    echo "  Detected: Ubuntu/Debian"
    sudo apt-get update -y > /dev/null 2>&1
    sudo apt-get install -y docker.io curl git net-tools > /dev/null 2>&1
    CURRENT_USER=$(whoami)
    sudo systemctl start docker
    sudo systemctl enable docker > /dev/null 2>&1
    echo "  Adding $CURRENT_USER to docker group..."
    sudo usermod -aG docker $CURRENT_USER
    
elif command -v yum &> /dev/null; then
    echo "  Detected: Amazon Linux/CentOS"
    sudo yum update -y > /dev/null 2>&1
    sudo yum install -y docker curl git net-tools > /dev/null 2>&1
    sudo systemctl start docker
    sudo systemctl enable docker > /dev/null 2>&1
    echo "  Adding ec2-user to docker group..."
    sudo usermod -aG docker ec2-user
else
    echo "  ❌ Unsupported OS"
    exit 1
fi

# 2. Install Docker Compose
echo ""
echo "[STEP 2/6] Installing Docker Compose..."
sudo curl -sL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose > /dev/null 2>&1
sudo chmod +x /usr/local/bin/docker-compose > /dev/null 2>&1
echo "  ✅ Docker Compose $(docker-compose --version | awk '{print $3}')"

# 3. Clone or update repository
echo ""
echo "[STEP 3/6] Setting up repository..."
if [ ! -d "$SETUP_DIR" ]; then
    echo "  Cloning repository..."
    git clone $REPO_URL $SETUP_DIR > /dev/null 2>&1
else
    echo "  Updating repository..."
    cd $SETUP_DIR
    git fetch origin main > /dev/null 2>&1
    git reset --hard origin/main > /dev/null 2>&1
fi
cd $SETUP_DIR

# 4. Verify docker-compose.yml exists
echo ""
echo "[STEP 4/6] Verifying configuration..."
if [ ! -f "docker-compose.yml" ]; then
    echo "  ⚠️  docker-compose.yml not found, downloading..."
    curl -sL https://raw.githubusercontent.com/$REPO_URL#main/docker-compose.yml \
    -o docker-compose.yml
fi

if [ -f "docker-compose.yml" ]; then
    echo "  ✅ docker-compose.yml found"
else
    echo "  ❌ Failed to get docker-compose.yml"
    exit 1
fi

# 5. Start services
echo ""
echo "[STEP 5/6] Starting services..."
echo "  Pulling images..."
docker-compose pull > /dev/null 2>&1

echo "  Starting containers..."
docker-compose down > /dev/null 2>&1 || true
docker-compose up -d > /dev/null 2>&1

echo "  Waiting for services to be healthy (60 seconds)..."
sleep 60

# 6. Verify deployment
echo ""
echo "[STEP 6/6] Verifying deployment..."

# Check docker-compose status
STATUS=$(docker-compose ps --format json 2>/dev/null | grep -o '"State":"[^"]*"' | head -1 || echo '"State":"unknown"')

if docker-compose ps | grep -q "Up"; then
    echo "  ✅ Services are running"
    docker-compose ps
    
    # Test health
    if curl -sf http://localhost:8080/actuator/health > /dev/null 2>&1; then
        echo "  ✅ Application health check passed"
    else
        echo "  ⚠️  Application still starting, may take 30 more seconds..."
    fi
else
    echo "  ❌ Services failed to start"
    echo ""
    echo "Debug logs:"
    docker-compose logs
    exit 1
fi

# Get IP address
IP_ADDRESS=$(hostname -I | awk '{print $1}')

echo ""
echo "================================"
echo "✅ DEPLOYMENT SUCCESSFUL!"
echo "================================"
echo ""
echo "📍 Access your application:"
echo "   Web App:     http://$IP_ADDRESS:8080"
echo "   Health:      http://$IP_ADDRESS:8080/actuator/health"
echo "   Prometheus:  http://$IP_ADDRESS:8080/actuator/prometheus"
echo ""
echo "📊 Database:"
echo "   Host:        $IP_ADDRESS"
echo "   Port:        3306"
echo "   Database:    bankappdb"
echo "   User:        bankapp"
echo "   Password:    Test@123"
echo ""
echo "🐳 Docker Status:"
docker-compose ps
echo ""
echo "📝 Useful Commands:"
echo "   View logs:      docker-compose logs -f app"
echo "   Restart:        docker-compose restart"
echo "   Stop:           docker-compose down"
echo "   Update code:    cd $SETUP_DIR && git pull && docker-compose pull && docker-compose up -d"
echo ""
echo "================================"