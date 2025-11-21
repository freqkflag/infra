# Infrastructure Inventory

> Generated during the harvest → ingest cycle. Populated entries will be updated
> once each device has been harvested and normalised into `nodes/<device>/`.

## Overview

| Device | Profile | Services | Compose Sources | Notes |
| ------ | ------- | -------- | ---------------- | ----- |
| vps.host | production | _pending ingestion_ | `nodes/vps.host/compose/` | Harvest scheduled |
| home.macmini | development | _pending ingestion_ | `nodes/home.macmini/compose/` | Harvest scheduled |
| home.linux | homelab | _pending ingestion_ | `nodes/home.linux/compose/` | Harvest scheduled |

## Services

| Service | Device | Image | Ports | Domains | Status |
| ------- | ------ | ----- | ----- | ------- | ------ |
| _tbd_ | _tbd_ | _tbd_ | _tbd_ | _tbd_ | awaiting harvest |

## Networks

| Network | Scope | Nodes | Notes |
| ------- | ----- | ----- | ----- |
| edge | external | vps.host, home.macmini, home.linux | Shared overlay; verify during redeploy |

## Pending Actions

- [ ] Run `scripts/harvest_vps.host.sh --plan` (dry capture) and ingest outputs.
- [ ] Run `scripts/harvest_home.macmini.sh --plan` and ingest outputs.
- [ ] Run `scripts/harvest_home.linux.sh --plan` and ingest outputs.
- [ ] Update service table with image tags, ports, domains after ingestion.
- [ ] Cross-reference domain mappings in `domains/map.yml`.

