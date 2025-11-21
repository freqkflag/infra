# vps.host — Production Node

This node runs the production stack for `freqkflag.co`. It anchors the shared `edge` network, hosts central data services, and exposes ingress through Traefik and Cloudflare Tunnels.

## Services

- Traefik (TLS termination, routing, middlewares)
- Cloudflared tunnel (`cloudflared-vps`)
- Postgres, MariaDB, Redis (shared data stores)
- Infisical (secrets management)
- Kong OSS (API gateway)
- ClamAV (malware scanning)
- Application suite: Gitea, Ghost, WordPress, Discourse, Wiki.js, Linkstack, LocalAI, OpenWebUI, Node-RED

## Domains

Domain mappings are defined in `nodes/vps.host/domains.yml` and provisioned via Cloudflare DNS:

| Service | Env Variable | Hostname |
| ------- | ------------ | -------- |
| Traefik dashboard | `TRAEFIK_DASHBOARD_HOST` | `traefik.freqkflag.co` |
| Kong proxy | `KONG_PROXY_HOST` | `api.freqkflag.co` |
| Kong admin | `KONG_ADMIN_HOST` | `api-admin.freqkflag.co` |
| Infisical UI/API | `INFISICAL_PUBLIC_URL`, `INFISICAL_HOST` | `infisical.freqkflag.co` |
| Gitea web / SSH | `GITEA_DOMAIN`, `GITEA_SSH_DOMAIN` | `git.freqkflag.co` |
| Ghost | `GHOST_DOMAIN` | `ghost.freqkflag.co` |
| WordPress | `WORDPRESS_DOMAIN` | `wp.freqkflag.co` |
| Discourse | `DISCOURSE_DOMAIN` | `forum.freqkflag.co` |
| Wiki.js | `WIKIJS_DOMAIN` | `wiki.freqkflag.co` |
| Linkstack | `LINKSTACK_DOMAIN` | `links.freqkflag.co` |
| LocalAI | `LOCALAI_DOMAIN` | `localai.freqkflag.co` |
| OpenWebUI | `OPENWEBUI_DOMAIN` | `openwebui.freqkflag.co` |
| Node-RED | `NODE_RED_DOMAIN` | `automation.freqkflag.co` |

## Network & Tunnels

- External network: `edge` (must exist on host before deployment)
- Cloudflared tunnel: `cloudflared-vps` using `${CF_TUNNEL_TOKEN_VPS}`
- All containers attach to `edge`; Traefik publishes 80/443 via host networking.

## Deployment

```bash
# Run from repository root
infisical run --env=production -- ./nodes/vps.host/deploy.sh
```

This wraps `scripts/deploy.ah` and automatically runs `scripts/preflight.sh`.

## Health Checks

```bash
# Full node health
infisical run --env=production -- ./nodes/vps.host/health-check.sh

# Targeted commands
docker exec traefik traefik healthcheck
curl -s https://api.freqkflag.co/status --header "Authorization: Kong-Key ${KONG_ADMIN_KEY}"
docker logs --tail 50 cloudflared
```

## Teardown

```bash
infisical run --env=production -- ./nodes/vps.host/teardown.sh <service ...>
```

Omit service arguments to remove the entire bundle. Always capture actions in `server-changelog.md` after teardown.

