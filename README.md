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
