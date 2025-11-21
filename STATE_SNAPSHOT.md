# State Snapshot Log

Each entry captures a timestamped summary of harvested infrastructure state.
Populate after running `scripts/harvest_<device>.sh` and during post-redeploy
verification.

## Template

```
## 2025-11-09T12:00:00Z — vps.host harvest
- Harvest artifact: harvest/vps.host/20251109T120000Z/harvest_20251109T120000Z.tar.gz
- Compose projects discovered: traefik, infisical, kong, app-suite
- Systemd units collected: docker.service, traefik.service, cloudflared.service
- Reverse proxy configs: /etc/traefik/traefik.yml, dynamic/middlewares.yml
- Notes: Secrets redacted; requires Infisical mapping audit.
```

## Pending Entries

- _Awaiting harvest for vps.host._
- _Awaiting harvest for home.macmini._
- _Awaiting harvest for home.linux._

