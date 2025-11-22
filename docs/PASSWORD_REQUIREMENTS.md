# Password Requirements and Complexity Rules

**Created:** 2025-11-22  
**Status:** Active  
**Owner:** Security Team / Infrastructure Lead

---

## Overview

This document defines password requirements, complexity rules, and generation guidelines for all infrastructure secrets. All passwords must meet these requirements to ensure security compliance.

---

## Password Requirements

### Minimum Requirements

- **Length:** Minimum 32 characters (recommended: 40+ characters)
- **Character Set:** Must include:
  - Uppercase letters (A-Z)
  - Lowercase letters (a-z)
  - Numbers (0-9)
  - Special characters (!@#$%^&*()_+-=[]{}|;:,.<>?)
- **Uniqueness:** Each password must be unique across all services
- **Storage:** Never store passwords in plaintext; use Infisical exclusively

### Generation Method

**Recommended:** Use cryptographically secure random generator

```bash
# Generate 32-character base64 password
openssl rand -base64 32

# Generate 40-character base64 password (recommended)
openssl rand -base64 40

# Generate 32-character hex password
openssl rand -hex 32
```

**Alternative:** Use `/dev/urandom` for password generation

```bash
# Generate 32-character password
tr -dc 'A-Za-z0-9!@#$%^&*()_+-=[]{}|;:,.<>?' < /dev/urandom | head -c 32
```

---

## Password Categories

### Database Passwords

**Scope:** PostgreSQL, MySQL/MariaDB, Redis

**Requirements:**
- Minimum 32 characters
- Must include mixed case, numbers, and special characters
- Unique per database instance
- Stored in Infisical `/prod` path

**Examples:**
- `POSTGRES_PASSWORD`
- `MARIADB_PASSWORD`
- `MARIADB_ROOT_PASSWORD`
- `REDIS_PASSWORD`
- Service-specific passwords (e.g., `WIKIJS_DB_PASSWORD`, `WORDPRESS_DB_PASSWORD`)

### API Keys and Tokens

**Scope:** Cloudflare, Infisical, Kong, Ghost, etc.

**Requirements:**
- Minimum 32 characters (or as specified by service)
- Generated via service-specific methods when possible
- Stored in Infisical `/prod` path

**Examples:**
- `CF_DNS_API_TOKEN` - Generated via Cloudflare Dashboard
- `INFISICAL_CLIENT_ID` / `INFISICAL_CLIENT_SECRET` - Generated via Infisical Machine Identity
- `KONG_ADMIN_KEY` - Generated via Kong admin API
- `GHOST_API_KEY` - Generated via Ghost admin panel

### Application Secrets

**Scope:** JWT secrets, session keys, encryption keys

**Requirements:**
- Minimum 32 characters
- Cryptographically secure random generation
- Unique per application instance
- Stored in Infisical `/prod` path

**Examples:**
- `JWT_SECRET` - Supabase JWT secret
- `OPENWEBUI_SECRET_KEY` - OpenWebUI session encryption key
- `VAULTWARDEN_ADMIN_TOKEN` - Vaultwarden admin access token

### SMTP Passwords

**Scope:** Mailgun, SMTP services

**Requirements:**
- Use actual service-provided passwords (from Mailgun dashboard, etc.)
- Never use placeholder passwords in production
- Stored in Infisical `/prod` path

**Examples:**
- `DISCOURSE_SMTP_PASSWORD` - Mailgun SMTP password
- `GITEA_MAILER_PASS` - Mailgun SMTP password

---

## Password Storage

### Infisical Integration

**Primary Storage:** All passwords must be stored in Infisical `/prod` environment

**Access Methods:**
1. **Infisical Agent** - Automatically syncs secrets to `.workspace/.env` every 60 seconds
2. **Infisical CLI** - Direct access via `infisical secrets` commands
3. **Infisical Web UI** - Manual access at `https://infisical.freqkflag.co`

**Storage Path:** `/prod` (production environment)

### Template Files

**Purpose:** Template files (`env/templates/*.env.example`) contain placeholders only

**Placeholder Format:** `CHANGE_ME_STRONG_PASSWORD`

**Important:**
- Never commit actual passwords to template files
- Templates are for documentation and onboarding only
- Production services must use Infisical secrets exclusively

---

## Password Rotation

### Rotation Schedule

- **Database Passwords:** Quarterly (every 3 months)
- **API Keys/Tokens:** Annually or when compromised
- **Application Secrets:** Annually or when compromised
- **SMTP Passwords:** As needed (when service provider rotates)

### Rotation Procedure

1. **Generate New Password:**
   ```bash
   openssl rand -base64 32
   ```

2. **Store in Infisical:**
   ```bash
   infisical secrets set --env prod --path /prod SECRET_NAME="new_password_value"
   ```

3. **Verify Secret Injection:**
   ```bash
   # Check .workspace/.env (Infisical Agent syncs every 60s)
   grep "SECRET_NAME" .workspace/.env
   ```

4. **Update Service Configuration:**
   - Restart service to load new password
   - Verify service starts successfully
   - Verify service health check passes

5. **Document Rotation:**
   - Update `docs/CREDENTIAL_ROTATION.md` with rotation date
   - Document any issues or changes

**Reference:** See `docs/CREDENTIAL_ROTATION.md` for detailed rotation procedures

---

## Password Validation

### Pre-Deployment Checks

Before deploying services, verify:

- [ ] All required passwords are stored in Infisical `/prod`
- [ ] No passwords are hardcoded in compose files
- [ ] Template files contain placeholders only
- [ ] Services use `env_file: ../.workspace/.env` to load secrets
- [ ] Password length meets minimum requirements (32+ characters)

### Validation Script

```bash
# Check for hardcoded passwords in compose files
cd /root/infra
grep -r "password.*=" services/*/compose.yml | grep -v "CHANGE_ME\|POSTGRES_PASSWORD\|MARIADB_PASSWORD" | grep -v "#"

# Check template files for weak passwords
grep -r "password\|secret\|token" env/templates/*.env.example | grep -v "CHANGE_ME\|CHANGE_ME_STRONG"
```

---

## Security Best Practices

### Do's

✅ **DO:**
- Generate passwords using cryptographically secure methods
- Use unique passwords for each service
- Store all passwords in Infisical
- Use Infisical Agent for automatic secret injection
- Rotate passwords regularly
- Document password requirements and procedures
- Use strong passwords (32+ characters)

### Don'ts

❌ **DON'T:**
- Use weak or default passwords
- Reuse passwords across services
- Store passwords in plaintext files
- Commit passwords to git repositories
- Share passwords via insecure channels
- Use placeholder passwords in production
- Skip password rotation

---

## Compliance

### Security Standards

- **NIST Guidelines:** Follows NIST SP 800-63B password guidelines
- **OWASP:** Complies with OWASP password storage recommendations
- **Infrastructure Policy:** Aligns with infrastructure security policies

### Audit Requirements

- **Quarterly Audits:** Review all passwords for compliance
- **Rotation Tracking:** Document all password rotations
- **Access Logging:** Monitor Infisical access logs for password access

---

## References

- **Infisical Documentation:** `infisical/README.md`
- **Credential Rotation:** `docs/CREDENTIAL_ROTATION.md`
- **Secrets Audit:** `docs/INFISICAL_SECRETS_AUDIT.md`
- **Remediation Plan:** `REMEDIATION_PLAN.md` Phase 1.3

---

**Last Updated:** 2025-11-22  
**Next Review:** 2026-02-22 (Quarterly)

