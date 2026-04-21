# eigenstack — Project Context

## Stack
- Docker Compose: Traefik v3 + socket-proxy + Vaultwarden + Fail2ban
- Networks: `eigen-web` (external) · `eigen-docker-proxy` (internal only)
- Routing: static → `traefik/traefik.yml` · dynamic → `traefik/dynamic/`
- Domain: `${BASE_DOMAIN}` substitution in all Traefik labels

## Key Commands
make up            # start stack
make down          # stop stack
make status        # container health
make logs          # follow logs
make backup        # snapshot Vaultwarden DB → backups/ (git-ignored)
make setup-local   # mkcert certs + /etc/hosts (run once per machine)

## Rules (non-negotiable)
- NEVER commit `.env` — use `.env.example` for new vars
- NEVER expose Docker socket directly — socket-proxy only
- Every container: `security_opt: - no-new-privileges:true`
- Every new service: attach to correct network + Traefik labels + docs/ entry
- Vaultwarden: SIGNUPS_ALLOWED=false always

## Conventions
- Branches: `feat/`, `fix/`, `docs/` off main
- Commits: imperative, purpose-focused ("add backup hook for vaultwarden")
- PR description: what · why · env-var changes · validation steps
