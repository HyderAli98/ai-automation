#!/bin/bash
# COMPLETE LINUX SETUP WITH FULL VERIFICATION
# For E5450 Laptop - Creates everything from scratch with checks

echo "=========================================="
echo "n8n Setup for Linux (E5450)"
echo "=========================================="
echo ""

# STEP 1: Check if Git is installed
echo "[STEP 1] Checking Git installation..."
if ! command -v git &> /dev/null; then
    echo "❌ Git not found. Installing..."
    sudo apt update
    sudo apt install -y git
else
    echo "✓ Git is installed: $(git --version)"
fi

# STEP 2: Check if Docker is installed
echo ""
echo "[STEP 2] Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Installing..."
    sudo apt update
    sudo apt install -y docker.io docker-compose
    sudo usermod -aG docker $USER
else
    echo "✓ Docker is installed: $(docker --version)"
fi

# STEP 3: Create project directory
echo ""
echo "[STEP 3] Creating project directory..."
PROJECT_DIR="$HOME/ai-automation"

if [ -d "$PROJECT_DIR" ]; then
    echo "⚠️  Directory $PROJECT_DIR already exists!"
    read -p "Do you want to DELETE it and start fresh? (type 'YES' to confirm): " confirm
    if [ "$confirm" == "YES" ]; then
        echo "Deleting $PROJECT_DIR..."
        rm -rf "$PROJECT_DIR"
        mkdir -p "$PROJECT_DIR"
        echo "✓ Directory recreated"
    else
        echo "Using existing directory"
    fi
else
    mkdir -p "$PROJECT_DIR"
    echo "✓ Created directory: $PROJECT_DIR"
fi

# STEP 4: Clone from GitHub
echo ""
echo "[STEP 4] Cloning from GitHub..."
cd "$PROJECT_DIR"

if [ -d ".git" ]; then
    echo "Git repository already exists. Pulling latest..."
    git pull origin main
else
    echo "Cloning repository..."
    git clone https://github.com/HyderAli98/ai-automation.git . || exit 1
fi

echo "✓ Repository ready"

# STEP 5: Verify essential files exist
echo ""
echo "[STEP 5] Verifying essential files..."
FILES=("docker-compose.yml" "README.md" ".gitignore")
MISSING_FILES=0

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "❌ $file MISSING!"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

if [ $MISSING_FILES -gt 0 ]; then
    echo ""
    echo "⚠️  Missing files detected. Please check GitHub repository."
    exit 1
fi

# STEP 6: Check Docker volumes
echo ""
echo "[STEP 6] Checking Docker volumes..."
docker volume ls | grep "n8n" > /dev/null
if [ $? -eq 0 ]; then
    echo "✓ n8n volumes found"
    docker volume ls | grep "n8n"
else
    echo "⚠️  No n8n volumes yet (will be created on first start)"
fi

# STEP 7: Check for backup file
echo ""
echo "[STEP 7] Checking for backup file..."
if [ -f "n8n-backup.sql" ]; then
    echo "✓ Backup file found: n8n-backup.sql"
    FILE_SIZE=$(du -h n8n-backup.sql | cut -f1)
    echo "  Size: $FILE_SIZE"
    
    read -p "Do you want to restore this backup? (type 'YES' to confirm): " restore_confirm
    if [ "$restore_confirm" == "YES" ]; then
        echo "Note: Restore will happen after containers start"
    fi
else
    echo "ℹ️  No backup file found (this is OK for first setup)"
fi

# STEP 8: Stop existing containers
echo ""
echo "[STEP 8] Checking for existing containers..."
EXISTING=$(docker ps -a -f name=n8n 2>/dev/null | wc -l)
if [ $EXISTING -gt 1 ]; then
    echo "Found existing n8n containers. Stopping..."
    docker-compose down 2>/dev/null || true
    echo "✓ Containers stopped"
else
    echo "✓ No existing containers"
fi

# STEP 9: Start containers
echo ""
echo "[STEP 9] Starting Docker containers..."
docker-compose up -d

if [ $? -ne 0 ]; then
    echo "❌ Failed to start containers!"
    exit 1
fi

echo "✓ Containers started"

# STEP 10: Wait for services
echo ""
echo "[STEP 10] Waiting for services to be ready (30 seconds)..."
sleep 30

# STEP 11: Verify containers are running
echo ""
echo "[STEP 11] Verifying containers..."
docker ps | grep n8n-postgres > /dev/null
if [ $? -eq 0 ]; then
    echo "✓ PostgreSQL container running"
else
    echo "❌ PostgreSQL container NOT running!"
fi

docker ps | grep n8n-app > /dev/null
if [ $? -eq 0 ]; then
    echo "✓ n8n container running"
else
    echo "❌ n8n container NOT running!"
fi

# STEP 12: Test PostgreSQL connection
echo ""
echo "[STEP 12] Testing PostgreSQL connection..."
docker exec n8n-postgres psql -U n8n -d n8n -c "SELECT 1" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ PostgreSQL connection successful"
else
    echo "❌ PostgreSQL connection failed!"
fi

# STEP 13: Restore backup if requested
echo ""
if [ -f "n8n-backup.sql" ] && [ "$restore_confirm" == "YES" ]; then
    echo "[STEP 13] Restoring backup..."
    docker exec -i n8n-postgres psql -U n8n n8n < n8n-backup.sql
    if [ $? -eq 0 ]; then
        echo "✓ Backup restored successfully"
        docker-compose restart n8n
        echo "Waiting 10 seconds for n8n to restart..."
        sleep 10
    else
        echo "❌ Backup restore failed!"
    fi
else
    echo "[STEP 13] Skipping backup restore (not needed)"
fi

# STEP 14: Verify directories
echo ""
echo "[STEP 14] Verifying project structure..."
echo "Project directory: $PROJECT_DIR"
ls -la

# STEP 15: Final verification
echo ""
echo "=========================================="
echo "✓ SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "Access n8n: http://localhost:5678"
echo ""
echo "Project location: $PROJECT_DIR"
echo ""
echo "Next steps:"
echo "1. Open browser: http://localhost:5678"
echo "2. Create admin account"
echo "3. Start creating workflows!"
echo ""
echo "To view logs:"
echo "  cd $PROJECT_DIR"
echo "  docker-compose logs -f n8n"
echo ""
echo "=========================================="
