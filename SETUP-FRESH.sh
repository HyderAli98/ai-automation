#!/bin/bash
# FRESH n8n SETUP FOR Z440 (WITHOUT CLEANUP)
# This creates fresh n8n but keeps existing data safe
# Run CLEANUP-FIRST.sh separately if you want to delete data

echo "=========================================="
echo "Starting fresh n8n setup..."
echo "=========================================="
echo ""

# Create fresh docker-compose.yml
echo "Creating docker-compose.yml..."
cat > docker-compose.yml << 'EOF'
services:
  postgres:
    image: postgres:15-alpine
    container_name: n8n-postgres
    environment:
      POSTGRES_USER: n8n
      POSTGRES_PASSWORD: n8n_secure_password_123
      POSTGRES_DB: n8n
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U n8n"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - n8n-net
    restart: unless-stopped

  n8n:
    image: docker.n8n.io/n8nio/n8n:latest
    container_name: n8n-app
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=n8n_secure_password_123
      - N8N_SECURE_COOKIE=false
      - N8N_ENCRYPTION_KEY=n8n-key-2024
      - WEBHOOK_URL=http://localhost:5678
    ports:
      - "5678:5678"
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - n8n-net
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5678/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 15s

volumes:
  postgres_data:
  n8n_data:

networks:
  n8n-net:
    driver: bridge
EOF

# Create README.md
echo "Creating README.md..."
cat > README.md << 'EOF'
# n8n Workflow Automation

Self-hosted n8n with PostgreSQL.

## Start

```bash
docker-compose up -d
```

Access: http://localhost:5678

## Backup n8n

```bash
docker exec n8n-postgres pg_dump -U n8n n8n > n8n-backup.sql
```

## Restore n8n

```bash
docker exec -i n8n-postgres psql -U n8n n8n < n8n-backup.sql
docker-compose restart n8n
```

## Sync between Z440 and E5450

### Z440: Backup and push
```bash
docker exec n8n-postgres pg_dump -U n8n n8n > n8n-backup.sql
git add n8n-backup.sql
git commit -m "Backup workflows"
git push origin main
```

### E5450: Pull and restore
```bash
git pull origin main
docker exec -i n8n-postgres psql -U n8n n8n < n8n-backup.sql
docker-compose restart n8n
```
EOF

# Create .gitignore
echo "Creating .gitignore..."
cat > .gitignore << 'EOF'
n8n-backup*.sql
.DS_Store
*.log
__pycache__
.venv
EOF

# Initialize Git (only if not already initialized)
if [ ! -d .git ]; then
    echo "Initializing Git..."
    git init
    git config user.name "Hyder Ali"
    git config user.email "hyderali.bitsquare@gmail.com"
    git add .
    git commit -m "Fresh n8n setup - clean start"
    git branch -M main
    git remote add origin https://github.com/HyderAli98/ai-automation.git
    git push --force -u origin main
else
    echo "Git already initialized. Updating files..."
    git add docker-compose.yml README.md .gitignore
    git commit -m "Update n8n setup" || true
    git push origin main
fi

echo ""
echo "Checking if containers exist..."
if [ "$(docker ps -a -q -f name=n8n-app)" ]; then
    echo "Stopping existing containers..."
    docker-compose down
fi

echo ""
echo "Starting Docker containers..."
docker-compose up -d

echo ""
echo "Waiting 30 seconds for services to start..."
sleep 30

echo ""
docker ps

echo ""
echo "=========================================="
echo "✓ FRESH n8n SETUP COMPLETE!"
echo "Access: http://localhost:5678"
echo "=========================================="
echo ""
echo "Your data is safe. To reset everything:"
echo "  1. Run: bash CLEANUP-FIRST.sh"
echo "  2. Then: bash SETUP-FRESH.sh"
