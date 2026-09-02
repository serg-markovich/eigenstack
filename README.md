# eigenstack

A self-hosted personal cloud built with Docker Compose. The stack consists of Traefik as a reverse proxy, a Docker socket proxy, and Vaultwarden for password management. All services are defined once and configured via a single `.env` file.

## Stack

| Service | Role |
|---------|------|
| Traefik | Reverse proxy with automatic TLS via Let's Encrypt |
| docker-socket-proxy | Secure read-only access to the Docker daemon |
| Vaultwarden | Self-hosted Bitwarden-compatible password manager |
| Whoami *(optional)* | Simple service to verify routing – disabled in production |

## Quick start (production)

**Prerequisites**
- Ubuntu 24.04 (or similar)
- Docker + Docker Compose v2
- A public domain pointing to your server
- Ports 80 and 443 open to the internet

```bash
# 1. Clone the repository
git clone https://github.com/serg-markovich/eigenstack.git
cd eigenstack

# 2. Create environment file from the production template
cp .env.prod .env
# edit .env:
#   BASE_DOMAIN=yourdomain.de
#   ACME_EMAIL=admin@yourdomain.de
#   VAULTWARDEN_HOST=vault.yourdomain.de
#   TRAEFIK_DASHBOARD_HOST=traefik.yourdomain.de
#   TRAEFIK_DASHBOARD_AUTH=<htpasswd hash with $$ escaped>
#   VAULTWARDEN_ADMIN_TOKEN=<secure random token>

# 3. Start the stack
make up
```

### Verification

```bash
make status
curl -v https://vault.yourdomain.de
curl -v -u admin:yourpassword https://traefik.yourdomain.de
```

## Quick start (local)

**Prerequisites**
- Ubuntu 24.04 (or similar)
- Docker + Docker Compose v2
- `mkcert` (for local TLS)

```bash
# 1. Install mkcert
sudo apt install mkcert

# 2. Clone the repository
git clone https://github.com/serg-markovich/eigenstack.git
cd eigenstack

# 3. Create a local environment file
cp .env.example .env
# edit .env as needed (BASE_DOMAIN, tokens, etc.)

# 4. Initialise TLS certificates and host entries
make setup-local

# 5. Start the stack
make up
```

### Verification

```bash
make status                # containers should be up
curl -k https://vault.eigenstack.local   # Vaultwarden UI
curl -k https://traefik.eigenstack.local # Traefik dashboard
# (whoami is disabled; enable it in docker-compose.yml if needed)
```

## Project layout

```
eigenstack/
├─ docker-compose.yml
├─ .env.example
├─ .env.prod          # template for production deployment
├─ Makefile
├─ traefik/
│  ├─ traefik.yml
│  └─ dynamic/
├─ certs/             # local mkcert / ACME certificates (git-ignored)
└─ CHANGELOG.md
```

## Backup

Vaultwarden data can be backed up manually or automatically.

### Manual backup

```bash
make backup
```

Backups are saved to `backups/vaultwarden-YYYYMMDD-HHMMSS.sqlite3`.

### Automated backup

Add a cron job to run the backup daily at 03:00:

```bash
crontab -e
```

```cron
0 3 * * * cd ~/eigenstack && make backup >> ~/eigenstack/backups/backup.log 2>&1
```

Backups older than 7 days are removed automatically.

## Brute-force protection

The Traefik dashboard is exposed to the internet, so it should be protected from brute-force attacks with fail2ban.

### Install fail2ban

```bash
sudo apt update
sudo apt install fail2ban
```

### Copy the provided configs

```bash
cd ~/eigenstack
sudo cp fail2ban/filter.d/traefik-dashboard.conf /etc/fail2ban/filter.d/
sudo cp fail2ban/jail.d/traefik-dashboard.conf /etc/fail2ban/jail.d/
```

Edit the jail config and set the correct `logpath` and `backend`:

```bash
sudo nano /etc/fail2ban/jail.d/traefik-dashboard.conf
```

Set:

```text
logpath = /path/to/eigenstack/logs/traefik/access.log
backend = auto
```

Replace `/path/to/eigenstack` with the real path on your host. `backend = auto` tells fail2ban to poll the log file; on Ubuntu the default is `systemd`, which only works with journald.

### Start fail2ban

```bash
sudo systemctl enable fail2ban
sudo systemctl restart fail2ban
sudo fail2ban-client status traefik-dashboard
```

The default jail bans an IP for 1 hour after 5 failed login attempts against the `dashboard@docker` router within 10 minutes.

To avoid accidental self-lockout, add your admin IP to the jail:

```text
[traefik-dashboard]
ignoreip = 127.0.0.1/8 ::1 <your-ip>
```

## Security highlights

- Docker socket is never exposed directly; access is via `socket-proxy`.
- TLS is enforced for all services using Let's Encrypt production certificates.
- Vaultwarden sign-ups are disabled; admin access is protected by a token.
- Traefik dashboard is protected by HTTP basic authentication.
- All containers run with `no-new-privileges:true`.

## Production notes

Use the `.env.prod` template, replace placeholders with real values, and deploy the stack on your server (e.g., Hetzner). Remove or keep disabled the optional `whoami` service. Ensure that ports 80 and 443 are reachable from the internet so Let's Encrypt HTTP challenges succeed.

## License

MIT
