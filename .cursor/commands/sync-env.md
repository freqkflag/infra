# sync-env

Sync repository state for the detected host.

**Usage:**

```
sync-env service=<service-name>
```

Example:

```
sync-env service=n8n
```

**What it does:**

- Detects the running host (VPS/homelab/maclab) by public IP, hostname, or local IP.
- On servers (vps, homelab): Performs a hard fast-forward reset to `origin/<current-branch>` (no local commits allowed).
- On maclab: Performs `git pull --rebase` (developer may have local work).
- Logs summary with timestamp, exit code, current branch, host, and optional service to `.cursor/ops-log.txt`.
- Continues even if no `service=` argument is provided (service is context only for logs).
- Exits non-zero if sync fails, otherwise prints confirmation.

**Sync steps:**

1. Ensure the repo and git are available.
2. Run the above command; `service` is optional and only logs context.
3. The action will leave the repo up-to-date with the remote for the appropriate branch.
4. Check `.cursor/ops-log.txt` for result and troubleshooting info.

**Command logic (simplified):**

- Detect environment (same logic as other infra commands)
- Determine current branch:  

  ```
  BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
  ```

- If `maclab`:
  - `git fetch origin <branch>` (quiet)
  - `git pull --rebase origin <branch>`
- If server:
  - `git fetch origin <branch>` (quiet)
  - `git reset --hard origin/<branch>`
- Log summary to `.cursor/ops-log.txt`

**Note:**  

- No secrets are printed or logged—sync only logs status and metadata.
- This command will overwrite uncommitted changes on servers!

**For infra standards and safety see:** `.cursor/rules/infra-ops.mdc`

This command will be available in chat with /sync-env
