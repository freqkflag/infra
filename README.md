# Cult of Joey Infra  
Self-hosted multi-node infrastructure managed with FOSS tools and zero-trust edge.

## Description  
This repository defines the deployment, orchestration, and governance framework for the Cult of Joey ecosystem. With this stack you will operate across a VPS, Mac mini dev node, and homelab node — using Docker Compose, Traefik, Cloudflare Tunnels, Infisical, Kong OSS, and ClamAV.

## Architecture Overview  
- Rolling unified ingress via Cloudflare Tunnels + Traefik  
- Centralised secrets and configuration via Infisical  
- Centralised databases/caches on the VPS (Postgres, MariaDB, Redis)  
- API gateway with Kong OSS  
- Malware scanning with ClamAV  
- Automation with n8n / Node-RED  
- Full observability, backups, and change-tracking on all nodes  

## Getting Started  
1. Clone repo to `~/infra` on your local dev machine.  
2. Ensure `.env` exists at `/Users/freqkflag/Projects/.workspace/.env`.  
3. Ensure Docker Compose, Traefik, Cloudflared, and required tooling are installed on each host.  
4. Run:  
   ```bash  
   cd ~/infra  
   ./cursor deploy vps.host  
   ```
   or
   ```bash
   ./cursor deploy home.macmini
   ```
   (depending on target host)

Project Structure
```
~/infra/
├─ agents.md          — behavioural config for Cursor and agents  
├─ project-plan.yml   — declarative plan of services & hosts  
├─ services/          — sub-folders for each service (Compose files)  
├─ scripts/           — helper scripts (backup, scan, etc)  
└─ docs/              — runbooks, network templates, etc
```
Contributing & Maintenance
	•	All changes must append ~/server-changelog.md on the host (see “Logging & Change Tracking”).
	•	Use Infisical to manage secrets — never commit them to Git.
	•	Services should run only via Docker Compose + labels; no other orchestrator unless explicitly approved.

License

MIT License – safe use of community-driven FOSS tools.
