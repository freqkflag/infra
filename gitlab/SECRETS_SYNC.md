# GitLab Secrets Sync Configuration

**Date:** 2025-11-22  
**Status:** ✅ Infisical Agent configured to sync from `/prod` path

## Current Situation

✅ **Infisical Agent is configured** - Secrets are stored in Infisical at path `/prod` and automatically sync to `.workspace/.env` via the Infisical Agent.

The agent configuration (`infisical-agent.yml`) is set up to:
- Use template file `prod.template` which fetches secrets from `/prod` path
- Poll for changes every 60 seconds
- Write synced secrets to `/root/infra/.workspace/.env`
- Execute `reload-app.sh` when secrets are updated

## Secrets Required

The following secrets must be present in `.workspace/.env`:

```
GITLAB_DOMAIN=gitlab.freqkflag.co
GITLAB_DB_USER=gitlab
GITLAB_DB_PASSWORD=<database_password>
GITLAB_DB_NAME=gitlab
GITLAB_ROOT_PASSWORD=<root_password_min_8_chars>
GITLAB_SSH_PORT=2224
```

## Infisical Agent Configuration

The `prod.template` has been updated to fetch from `/prod` path:

```yaml
{{- with secret "8c430744-1a5b-4426-af87-e96d6b9c91e3" "prod" "/prod" }}
{{- range . }}
{{ .Key }}={{ .Value }}
{{- end }}
{{- end }}
```

## Manual Sync (Temporary)

Until the Infisical Agent automatically syncs, manually add secrets to `.workspace/.env`:

```bash
cd /root/infra
# Add GitLab secrets to .workspace/.env
cat >> .workspace/.env << 'EOF'
GITLAB_DOMAIN=gitlab.freqkflag.co
GITLAB_DB_USER=gitlab
GITLAB_DB_PASSWORD=<your_password>
GITLAB_DB_NAME=gitlab
GITLAB_ROOT_PASSWORD=<your_root_password>
GITLAB_SSH_PORT=2224
EOF

# Restart GitLab to pick up new secrets
cd gitlab
docker compose restart gitlab
```

## Verify Secrets Are Loaded

```bash
# Check .env file
cat .workspace/.env | grep GITLAB

# Check GitLab container environment
docker exec gitlab env | grep GITLAB

# Check Traefik routing (should show domain)
docker inspect gitlab --format '{{range $key, $value := .Config.Labels}}{{$key}}={{$value}}{{"\n"}}{{end}}' | grep "traefik.http.routers.gitlab.rule"
```

## Next Steps

1. ✅ **Configure Infisical Agent** - Completed: Agent configured to sync from `/prod` path
2. **Install/Run Infisical Agent** - Install the agent binary and run it with the config:
   ```bash
   # Install Infisical Agent (if not already installed)
   # See: https://infisical.com/docs/documentation/platform/agent/overview
   
   # Run the agent with the configuration
   infisical-agent --config /root/infra/infisical-agent.yml
   ```
3. **Verify Agent is Running** - Check if `infisical-agent` process is active:
   ```bash
   ps aux | grep infisical-agent
   # OR if running as systemd service:
   systemctl status infisical-agent
   ```
4. **Test Auto-Sync** - Make a change in Infisical at `/prod` path and verify it appears in `.workspace/.env` within 60 seconds

## Troubleshooting

### Secrets Not Syncing

1. Check Infisical Agent status:
   ```bash
   systemctl status infisical-agent
   # OR
   ps aux | grep infisical-agent
   ```

2. Check agent token:
   ```bash
   cat .workspace/.infisical-agent-token
   ```

3. Verify template path:
   ```bash
   cat prod.template
   # Should show: "/prod" not "/"
   ```

4. Manually trigger sync (if agent supports it):
   ```bash
   # Restart agent or trigger reload
   systemctl restart infisical-agent
   ```

---

**Note:** Once Infisical Agent is properly configured and syncing, this manual process will no longer be needed.
