# --help

**Service ID:** `--help`  
**Type:** app  
**Status:** configured

## Quick Start

1. **Configure Environment:**
   ```bash
   cd /root/infra/--help
   cp .env.example .env
   nano .env
   ```

2. **Deploy:**
   ```bash
   docker compose up -d
   ```

3. **Verify:**
   ```bash
   docker compose ps
   docker compose logs -f
   ```

## Management

### Start/Stop/Restart
```bash
./scripts/infra-service.sh start --help
./scripts/infra-service.sh stop --help
./scripts/infra-service.sh restart --help
```

## Configuration

See runbook for detailed configuration and troubleshooting:
- [Runbook](../runbooks/--help-runbook.md)

## Links

- **Service URL:** null
- **Documentation:** [WikiJS](https://wiki.freqkflag.co)
- **Metrics:** [Grafana](https://grafana.freqkflag.co)
- **Logs:** [Loki](https://grafana.freqkflag.co/explore)

