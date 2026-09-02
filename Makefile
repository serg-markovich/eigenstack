# eigenstack Makefile
# Usage: make <target>

.PHONY: up down restart logs status backup setup-local

## Start all services
up:
	docker compose up -d
	@echo "✅ eigenstack is up"
	@make status

## Stop all services
down:
	docker compose down
	@echo "⏹️  eigenstack is down"

## Restart all services
restart:
	docker compose down && docker compose up -d

## Follow logs (all services)
logs:
	docker compose logs -f

## Show running containers
status:
	docker compose ps

## Pull latest images
update:
	docker compose pull
	docker compose up -d

## Local dev setup (run once)
## Requires: mkcert (sudo apt install mkcert)
setup-local:
	@echo "📦 Installing mkcert CA..."
	mkcert -install
	@echo "🔐 Generating local certificates..."
	mkdir -p certs traefik/dynamic
	mkcert -cert-file certs/local.crt -key-file certs/local.key \
		eigenstack.local *.eigenstack.local
	@echo "🌐 Adding /etc/hosts entries..."
	grep -q "eigenstack.local" /etc/hosts || echo "127.0.0.1 eigenstack.local traefik.eigenstack.local vault.eigenstack.local whoami.eigenstack.local" | sudo tee -a /etc/hosts
	@echo "✅ Local setup complete. Run: make up"

## Backup Vaultwarden data
## Keeps the last 7 days of backups.
backup:
	@mkdir -p backups
	@echo "💾 Backing up Vaultwarden..."
	@docker compose stop vaultwarden
	@timestamp=$$(date +%Y%m%d-%H%M%S); \
	docker cp eigenstack-vaultwarden:/data/db.sqlite3 backups/vaultwarden-$$timestamp.sqlite3
	@docker compose up -d vaultwarden
	@echo "🗑️  Removing backups older than 7 days..."
	@find backups -name 'vaultwarden-*.sqlite3' -type f -mtime +7 -delete
	@echo "✅ Backup saved to backups/"
