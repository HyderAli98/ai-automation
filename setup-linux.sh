#!/bin/bash
# n8n Setup Script for Linux (E5450)
# Copy and paste all commands from this file

# Step 1: Clone repository
echo "Step 1: Cloning repository..."
cd ~
git clone https://github.com/HyderAli98/ai-automation.git
cd ai-automation

# Step 2: Start containers
echo "Step 2: Starting n8n and PostgreSQL..."
docker-compose up -d

# Step 3: Wait for containers to be ready
echo "Step 3: Waiting for services to start (30 seconds)..."
sleep 30

# Step 4: Check status
echo "Step 4: Checking container status..."
docker ps

# Step 5: Display access URL
echo ""
echo "=========================================="
echo "n8n is now running!"
echo "Access: http://localhost:5678"
echo "=========================================="
echo ""

# Step 6: Show logs (optional)
echo "Showing n8n logs (Ctrl+C to stop):"
docker logs n8n-app --tail 20
