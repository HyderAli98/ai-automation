#!/bin/bash
# COMPLETE CLEANUP SCRIPT FOR Z440
# Run this FIRST to delete everything

echo "=========================================="
echo "WARNING: This will DELETE ALL n8n data!"
echo "=========================================="
echo ""
echo "Stopping all containers..."
docker-compose down -v 2>/dev/null || true

echo "Removing n8n containers..."
docker stop n8n-app n8n-postgres 2>/dev/null || true
docker rm n8n-app n8n-postgres 2>/dev/null || true

echo "Removing n8n volumes..."
docker volume rm projects_n8n_data 2>/dev/null || true
docker volume rm projects_postgres_data 2>/dev/null || true
docker volume rm projects_n8n-net 2>/dev/null || true

echo "Removing old images (optional)..."
docker rmi docker.n8n.io/n8nio/n8n:latest 2>/dev/null || true
docker rmi postgres:15-alpine 2>/dev/null || true

echo "Removing old project files..."
rm -rf .git 2>/dev/null || true
rm -f docker-compose.yml 2>/dev/null || true
rm -f Dockerfile 2>/dev/null || true
rm -f main.py 2>/dev/null || true
rm -f requirements.txt 2>/dev/null || true
rm -f backup-n8n.sh 2>/dev/null || true
rm -f n8n-backup*.sql 2>/dev/null || true
rm -f setup-linux.sh 2>/dev/null || true
rm -f commands.sh 2>/dev/null || true
rm -f LAPTOP-SETUP.txt 2>/dev/null || true
rm -f .dockerignore 2>/dev/null || true
rm -f README.md 2>/dev/null || true
rm -f .gitignore 2>/dev/null || true

echo "Cleaning Docker system..."
docker system prune -f 2>/dev/null || true

echo ""
echo "=========================================="
echo "CLEANUP COMPLETE!"
echo "All n8n data and old files deleted."
echo "=========================================="
