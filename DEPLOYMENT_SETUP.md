# GitHub Secrets & Variables Setup Guide

To deploy your AI BankApp to AWS EC2, you need to configure GitHub Secrets and Variables.

## GitHub Secrets (Encrypted)

Go to: **Settings → Secrets and variables → Actions**

### Required Secrets:

1. **EC2_SSH_KEY** (Secret)
   - Your EC2 private SSH key content
   - How to get it:
     ```bash
     cat ~/.ssh/your-ec2-key.pem
     ```
   - Copy the entire content including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`

2. **EC2_HOST** (Secret)
   - Your EC2 public IP or domain
   - Example: `54.123.45.67` or `my-server.example.com`

3. **EC2_USER** (Secret)
   - EC2 username (usually `ubuntu` for Ubuntu instances)
   - Example: `ubuntu`

4. **DOCKERHUB_TOKEN** (Secret)
   - Your Docker Hub access token
   - Get it from: https://hub.docker.com/settings/security
   - Create a new access token with `read,write` permissions

## GitHub Variables (Public)

Go to: **Settings → Secrets and variables → Actions**

### Required Variables:

1. **DOCKERHUB_USER** (Variable)
   - Your Docker Hub username
   - Example: `chintamani7978`

## How to Create Secrets/Variables:

1. Click **"New repository secret"** or **"New repository variable"**
2. Enter the **Name** (from above)
3. Enter the **Value** (your actual data)
4. Click **"Add secret"** or **"Add variable"**

## Verification:

Once configured, your workflows will:
- ✅ Build the Docker image
- ✅ Push to Docker Hub
- ✅ SSH into EC2
- ✅ Deploy with docker-compose
- ✅ Start MySQL + App containers

## AWS EC2 Security Group Setup:

Ensure these ports are open:
- **Port 22** (SSH) - For GitHub Actions to connect
- **Port 8080** (HTTP) - For accessing the web application  
- **Port 3306** (MySQL) - Optional, for local MySQL access

**Modify Security Group:**
```bash
# Add your IP for SSH
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --protocol tcp \
  --port 22 \
  --cidr YOUR_IP/32

# Allow port 8080
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --protocol tcp \
  --port 8080 \
  --cidr 0.0.0.0/0
```

## Troubleshooting:

**Workflow fails with "Host key verification failed"?**
- SSH key format issue. Ensure it's in OpenSSH format (not PuTTY format)

**Docker-compose command not found?**
- Setup script hasn't run yet. Manually run Setup Server workflow

**Can't access app at http://IP:8080?**
- Check EC2 security group allows port 8080
- Verify docker-compose containers are running: `docker-compose ps`
- Check logs: `docker-compose logs app`

## Application URLs After Deployment:

- **Main App:** `http://<EC2_PUBLIC_IP>:8080`
- **Health Check:** `http://<EC2_PUBLIC_IP>:8080/actuator/health`
- **Metrics:** `http://<EC2_PUBLIC_IP>:8080/actuator/prometheus`
