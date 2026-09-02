# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

## [1.1.0] - 2026-09-02
- Switched Traefik ACME from Let's Encrypt staging to production CA.
- Wired Traefik Docker provider through `socket-proxy` instead of direct `/var/run/docker.sock` access.
- Fixed automatic TLS certificate issuance for production subdomains.
- Removed invalid `defaultCertificate` pointing at `acme.json`.
- Explicitly bound Docker routers to the `le` certificate resolver.
- Passed ACME email via `TRAEFIK_CERTIFICATESRESOLVERS_LE_ACME_EMAIL` environment variable.
- Added production environment template (`.env.prod`).
- Secured Traefik dashboard with bcrypt hash.
- Disabled optional `whoami` service for production mode.
- Added GitHub Actions CI workflow with linting, container startup and Trivy security scan.
- Added `Self-Maintenance` section to `claude.md`.
- Updated `.gitignore` to exclude `traefik/certs/`.
- Updated README with production quick-start and backup instructions.
- Added automatic backup rotation (keeps 7 days).
- Deployed and verified the stack on a VPS.

## [1.0.0] - 2026-04-21
- First stable release with production-ready configuration and CI.
