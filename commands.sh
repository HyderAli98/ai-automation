#!/bin/bash
# Quick Commands for n8n Management

# VIEW STATUS
echo "=== VIEW CONTAINERS ==="
docker ps

echo ""
echo "=== VIEW LOGS ==="
docker-compose logs -f n8n

echo ""
echo "=== VERIFY POSTGRESQL ==="
docker exec n8n-postgres psql -U n8n -d n8n -c "SELECT 1"

# BACKUP N8N
echo ""
echo "=== BACKUP N8N DATA ==="
docker exec n8n-postgres pg_dump -U n8n n8n > n8n-backup-$(date +%Y%m%d_%H%M%S).sql
echo "Backup created!"

# RESTORE N8N
echo ""
echo "=== RESTORE N8N DATA ==="
echo "Run this to restore from backup file:"
echo "docker exec -i n8n-postgres psql -U n8n n8n < n8n-backup.sql"
echo "docker-compose restart n8n"

# STOP CONTAINERS
echo ""
echo "=== STOP ALL CONTAINERS ==="
docker-compose down

# START CONTAINERS
echo ""
echo "=== START ALL CONTAINERS ==="
docker-compose up -d

# REMOVE EVERYTHING (CAREFUL!)
echo ""
echo "=== DELETE ALL DATA (WARNING!) ==="
echo "docker-compose down -v"
echo "This will delete ALL n8n data permanently!"
