# Infisical API Credentials

**Created:** 2025-11-22  
**Status:** Active  
**Location:** `.workspace/.env` (not in git)

---

## Storage Location

Infisical API credentials are stored in:
- **File:** `/root/infra/.workspace/.env`
- **Git Status:** ✅ Ignored (in `.gitignore`)
- **Permissions:** 600 (owner read/write only)
- **Purpose:** Used for `infisical run --env=production` commands

---

## Usage

These credentials allow you to use the Infisical CLI to inject secrets into Docker Compose commands:

```bash
# Example usage
cd /root/infra
infisical run --env=production -- docker compose -f compose.orchestrator.yml up -d

# Or with a specific service
infisical run --env=production -- docker compose -f services/traefik/compose.yml up -d
```

---

## Credentials Stored

- **INFISICAL_CLIENT_ID:** OAuth client ID for API authentication
- **INFISICAL_CLIENT_SECRET:** OAuth client secret for API authentication  
- **INFISICAL_SERVICE_TOKEN:** Service token for automated API access

---

## Security Notes

- ✅ Credentials stored in `.workspace/.env` (gitignored)
- ✅ File permissions set to 600 (owner read/write only)
- ✅ Never committed to git
- ✅ Used for local development and deployment automation

---

## Verification

To verify credentials are working:

```bash
cd /root/infra
infisical run --env=production -- infisical secrets list
```

---

## Troubleshooting

If credentials stop working:
1. Verify `.workspace/.env` exists and has correct permissions (600)
2. Check credentials are still valid in Infisical dashboard
3. Regenerate credentials in Infisical if needed
4. Update `.workspace/.env` with new credentials

---

**Last Updated:** 2025-11-22  
**Owner:** Infrastructure Team

