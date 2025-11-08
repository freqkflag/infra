```markdown
# Cursor Agent Context — Cult of Joey Infra

## Objective  
Execute the deployment framework described in README and project-plan. Automate consistent, secure, and auditable infrastructure operations across all nodes.

## Primary Agents  
- infra-architect — generates service manifests, labels, networks  
- secrets-keeper — injects secrets via Infisical and validates no statics remain  
- dev-orchestrator — executes the host-specific deployment plan, verifies tunnel/edge network  
- security-sentinel — manages ClamAV, firewall policies, WAF/Zero-Trust monitoring  
- api-gatekeeper — defines Kong gateway services, keys, rate-limits  
- automator — drives n8n/Node-RED workflows: backups, logs, scans  

## Environments & Hosts  
- Host: vps.host — domain: freqkflag.co — token: `${CF_TUNNEL_TOKEN_VPS}`  
- Host: home.macmini — domain: twist3dkink.online — token: `${CF_TUNNEL_TOKEN_MAC}`  
- Host: home.linux — domain: cult-of-joey.com — token: `${CF_TUNNEL_TOKEN_LINUX}`  
- Edge Docker network: `edge`

## Standard Protocol  
1. Confirm presence of `.env` and valid Infisical connection  
2. Load secrets: `infisical run --env=production`  
3. Generate Compose files under `services/`  
4. Deploy: `docker compose up -d`  
5. Confirm service health probes pass  
6. Append entries to `~/server-changelog.md`  

## Error Handling  
If any deployment step fails:  
- Abort further tasks  
- Log error in `~/server-changelog.md`  
- Notify via automation (n8n webhook)  
