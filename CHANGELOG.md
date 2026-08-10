# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]
- Added production environment template (`.env.prod`).
- Switched Traefik to ACME (staging) configuration.
- Secured Traefik dashboard with bcrypt hash.
- Disabled optional `whoami` service for production mode.
- Added GitHub Actions CI workflow with linting, container startup and Trivy security scan.
- Added `Self‑Maintenance` section to `claude.md`.
- Updated `.gitignore` to exclude `traefik/certs/`.

## [1.0.0] - 2026-04-21
- First stable release with production‑ready configuration and CI.
