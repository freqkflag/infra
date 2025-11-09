# home.linux — Homelab Node

The homelab Linux node delivers self-hosted tools for internal use under `cult-of-joey.com`. It connects to the shared `edge` network and depends on production databases and Infisical for configuration.

## Services

- Cloudflared tunnel (`cloudflared-linux`) for Zero Trust ingress
- Vaultwarden password manager
- BookStack knowledge base
- Auxiliary portal (Heimdall landing page)

## Domains

As defined in `nodes/home.linux/domains.yml`:

| Service | Env Variable | Hostname |
| ------- | ------------ | -------- |
| Vaultwarden | `VAULTWARDEN_DOMAIN` | `vault.cult-of-joey.com` |
| BookStack | `BOOKSTACK_DOMAIN` | `notes.cult-of-joey.com` |
| Auxiliary portal | `AUXILIARY_DOMAIN` | `aux.cult-of-joey.com` |

DNS entries must exist in Cloudflare (`${CF_ZONE_CULT_OF_JOEY_COM}`) and route through the `cloudflared-linux` tunnel.

## Network & Dependencies

- External network: `edge` (shared infra network)
- Tunnel: `cloudflared-linux` using `${CF_TUNNEL_TOKEN_LINUX}`
- Consumes centralized Postgres/MariaDB/Redis services hosted on `vps.host`
- Secrets sourced from Infisical (`homelab` environment)

## Deployment

```bash
infisical run --env=homelab -- ./nodes/home.linux/deploy.sh
```

This executes the compose bundle `nodes/home.linux/compose.yml` through `scripts/deploy.ah home.linux`.

## Health Checks

```bash
infisical run --env=homelab -- ./nodes/home.linux/health-check.sh
docker logs --tail 50 cloudflared
```

Validate application availability at `https://${VAULTWARDEN_DOMAIN}`, `https://${BOOKSTACK_DOMAIN}`, and `https://${AUXILIARY_DOMAIN}`.

## Teardown

```bash
infisical run --env=homelab -- ./nodes/home.linux/teardown.sh <service ...>
```

Log any teardown or recovery actions in `server-changelog.md` and coordinate with the production node to prevent orphaned credentials.

