# eigenstack

A self‑hosted personal cloud built with Docker Compose. The stack consists of Traefik as a reverse proxy, a Docker socket proxy, and Vaultwarden for password management. All services are defined once and configured via a single `.env` file.

## Stack

| Service | Role |
|---------|------|
| Traefik | Reverse proxy with automatic TLS (ACME – staging by default) |
| docker‑socket‑proxy | Secure read‑only access to the Docker daemon |
| Vaultwarden | Self‑hosted Bitwarden‑compatible password manager |
| Whoami *(optional)* | Simple service to verify routing – disabled in production |

## Quick start (local)

**Prerequisites**
- Ubuntu 24.04 (or similar)
- Docker + Docker Compose v2
- `mkcert` (for local TLS)

```bash
# 1. Install mkcert
sudo apt install mkcert

# 2. Clone the repository
git clone https://github.com/serg-markovich/eigen-stack.git
cd eigen-stack

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
# (whoami is disabled; enable it in docker‑compose.yml if needed)
```

## Project layout

```
eigen-stack/
├─ docker-compose.yml
├─ .env.example
├─ .env.prod          # template for production deployment
├─ Makefile
├─ traefik/
│  ├─ traefik.yml
│  └─ dynamic/
├─ certs/             # local mkcert certificates (git‑ignored)
└─ docs/              # architecture notes
```

## Security highlights

- Docker socket is never exposed directly; access is via `socket‑proxy`.
- TLS is enforced for all services. In production replace the ACME staging endpoint with the live Let’s Encrypt server.
- Vaultwarden sign‑ups are disabled; admin access is protected by a token.
- All containers run with `no-new-privileges:true`.

## Production notes

Use the `.env.prod` template, replace placeholders with real values, and switch Traefik to the Let’s Encrypt production ACME server. Deploy the stack on your server (e.g., Hetzner) and remove the `whoami` service.

## License

MIT