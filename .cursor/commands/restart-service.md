# restart-service

Restart (recreate) a service for the detected host.

**Usage:**
```
restart-service service=<service-name>
```
Example:
```
restart-service service=n8n
```

**What it does:**
- Detects the running host (VPS/homelab/maclab) by public IP, hostname, or local IP.
- Switches to the correct compose service path under `infra/<host>/<service>/docker-compose.yml`.
- Runs `docker compose up -d --force-recreate` for the provided service to restart the containers.
- Logs summary with timestamp, exit code, host, and service to `.cursor/ops-log.txt`.
- Exits non-zero if restart fails, otherwise prints confirmation.

**Restart steps:**
1. Ensure `.env` and secrets are already sourced.
2. Run the above command, providing the desired service.
3. Check `.cursor/ops-log.txt` for result and troubleshooting info.

**Service Compose Path Example:**
```
infra/vps-server/n8n/docker-compose.yml
infra/homelab-server/n8n/docker-compose.yml
infra/maclab-server/n8n/docker-compose.yml
```

**Note:**  
- Compose files must exist at the expected paths or the command will fail fast.
- Never prints secrets, logs only basic status info.

**Command logic (simplified):**
- Detect environment and resolve service path
- Validate service argument and Compose file
- Run:  
  ```
  docker compose -f ./infra/${HOST_FOLDER}/${SERVICE}/docker-compose.yml up -d --force-recreate
  ```
- Log summary to `.cursor/ops-log.txt`

**For infra standards and safety see:** `.cursor/rules/infra-ops.mdc`


This command will be available in chat with /restart-service
