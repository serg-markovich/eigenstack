# eigenstack

> A sovereign, self-hosted personal cloud for IT professionals in Germany.
> Built on IaC principles — deploy with a single command.

**Philosophy:** `IaC = DRY + TRIZ`
Every service is defined once, configured through a single `.env`,
and contradictions (privacy vs convenience, security vs simplicity)
are resolved at the architectural level — not patched.

## Stack

| Service | Role | Image |
|---|---|---|
| Traefik v3 | Reverse proxy, auto-TLS, routing | `traefik:v3.0` |
| docker-socket-proxy | Secure Docker API access (no direct socket) | `tecnativa/docker-socket-proxy` |
| Vaultwarden | Self-hosted Bitwarden-compatible passwords | `vaultwarden/server` |
| Whoami | Routing validation (remove after setup) | `traefik/whoami` |

**Coming next:** Nextcloud AIO, Paperless-ngx, Prometheus + Alertmanager

## Quick Start (local)

### Prerequisites
- Ubuntu 24.04
- Docker + Docker Compose v2
- `mkcert` for local TLS

```bash
# 1. Install mkcert
sudo apt install mkcert

# 2. Clone
git clone https://github.com/serg-markovich/eigen-stack.git
cd eigen-stack

# 3. Configure
cp .env.example .env
nano .env  # set BASE_DOMAIN, tokens

# 4. Local setup (certs + /etc/hosts)
make setup-local

# 5. Launch
make up
```

### Verify

```bash
make status                          # all containers running?
curl -k https://whoami.eigenstack.local  # Traefik routing works?
```

Open in browser:
- `https://whoami.eigenstack.local` — routing test
- `https://vault.eigenstack.local` — Vaultwarden
- `https://traefik.eigenstack.local` — Traefik dashboard

## Project Structure

```
eigen-stack/
├── docker-compose.yml       # service definitions
├── .env.example             # all variables documented
├── Makefile                 # make up / down / logs / backup / setup-local
├── traefik/
│   ├── traefik.yml          # static config (entrypoints, providers)
│   └── dynamic/
│       └── tls.yml          # TLS options
├── certs/                   # local mkcert certs (gitignored)
├── backups/                 # local backups (gitignored)
└── docs/                    # architecture notes
```

## Security Model

- **No direct Docker socket** — all Traefik → Docker communication via `socket-proxy`
- **TLS everywhere** — HTTP redirects to HTTPS, TLS 1.2+ enforced
- **Vaultwarden signups disabled** — admin-only access
- **Dashboard behind basic auth** — not publicly accessible
- **`no-new-privileges`** on all containers

## Production Deployment

For production on Hetzner VPS — see `docs/deployment.md` *(coming soon)*

Switch from mkcert to Let's Encrypt: replace `tls:` block in `traefik/traefik.yml`
with ACME configuration and set `ACME_EMAIL` in `.env`.

## License

MIT — built with ☕ and a strong opinion about data sovereignty.
