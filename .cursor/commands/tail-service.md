# tail-service

Follow logs for a service for the detected host.

**Usage:**
```
tail-service service=<service-name>
```
Example:
```
tail-service service=n8n
```

**What it does:**
- Detects the running host (VPS/homelab/maclab) by public IP, hostname, or local IP.
- Switches to the correct compose service path under `infra/<host>/<service>/docker-compose.yml`.
- Follows logs (`docker compose logs -f --tail=200 <service>`) for the provided service using the modern Docker Compose CLI.
- Logs summary with timestamp, exit code, host, and service to `.cursor/ops-log.txt`.

**Tail steps:**
1. Ensure `.env` and secrets are already sourced.
2. Run the above command, providing the desired service.
3. Logs will stream for the selected service. Press ctrl-c to exit.

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
  docker compose -f ./infra/${HOST_FOLDER}/${SERVICE}/docker-compose.yml logs -f --tail=200 $SERVICE
  ```
- Log summary to `.cursor/ops-log.txt`

**For infra standards and safety see:** `.cursor/rules/infra-ops.mdc`


This command will be available in chat with /tail-service
