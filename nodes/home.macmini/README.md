# home.macmini — Development Node

The Mac mini node hosts developer-facing tooling and frontend previews under `twist3dkink.online`. It relies on shared data services from the production VPS while keeping workloads isolated in the `edge` network.

## Services

- Cloudflared tunnel (`cloudflared-mac`) for secure ingress
- Frontend preview container (`frontend`)
- Developer workspace (`dev-tools`, code-server)

## Domains

Defined in `nodes/home.macmini/domains.yml`:

| Service | Env Variable | Hostname |
| ------- | ------------ | -------- |
| Frontend preview | `FRONTEND_DOMAIN` | `dev.twist3dkink.online` |
| Developer tools | `DEVTOOLS_DOMAIN` | `tools.twist3dkink.online` |

Ensure DNS records exist in Cloudflare and that the tunnel service account has access to `${CF_ZONE_TWIST3DKINK_ONLINE}`.

## Network & Dependencies

- External network: `edge` (shared with production services)
- Tunnel: `cloudflared-mac` using `${CF_TUNNEL_TOKEN_MAC}`
- Consumes Postgres, MariaDB, and Redis from `vps.host` through environment variables populated by Infisical.

## Deployment

```bash
infisical run --env=development -- ./nodes/home.macmini/deploy.sh
```

The wrapper calls `scripts/deploy.ah home.macmini`, which performs a preflight check and applies the compose bundle at `nodes/home.macmini/compose.yml`.

## Health Checks

```bash
infisical run --env=development -- ./nodes/home.macmini/health-check.sh
docker logs --tail 50 cloudflared
```

Confirm frontend availability by visiting `https://${FRONTEND_DOMAIN}` and code-server at `https://${DEVTOOLS_DOMAIN}` through Cloudflare Access.

## Teardown

```bash
infisical run --env=development -- ./nodes/home.macmini/teardown.sh <service ...>
```

If no services are specified, the entire bundle is stopped. Record significant actions in `server-changelog.md`.

