# Mailu Mail Server

Lightweight IMAP/SMTP mail server for all domains.

**Location:** `/root/infra/mailu/`

**Admin Interface:** `mail.freqkflag.co`
**Webmail:** `webmail.freqkflag.co`

## Overview

Mailu provides a complete mail server solution with:
- **SMTP** (ports 25, 587, 465) - Sending emails
- **IMAP** (ports 143, 993) - Receiving emails
- **Webmail** - Roundcube web interface
- **Admin Panel** - Domain and user management
- **Multi-domain support** - Manage multiple domains from one interface

## Quick Start

1. **Configure Environment:**
   ```bash
   cd /root/infra/mailu
   nano .env
   ```
   
   Update `DOMAIN` if needed (default: freqkflag.co)

2. **Deploy:**
   ```bash
   docker compose up -d
   ```

3. **Access Admin Panel:**
   - Visit `https://mail.freqkflag.co` (once DNS is configured)
   - Default admin credentials:
     - Username: `admin`
     - Password: `changeme` (change immediately!)

4. **Configure Domains:**
   - Log into admin panel
   - Go to "Mail domains"
   - Add domains: `cultofjoey.com`, `twist3dkink.com`, `twist3dkinkst3r.com`

## Architecture

- **Admin**: Web-based administration interface
- **IMAP**: Dovecot IMAP server
- **SMTP**: Postfix SMTP server
- **Webmail**: Roundcube webmail interface
- **Front**: Nginx reverse proxy
- **Redis**: Caching and session storage

## Ports

### Exposed Ports (Direct Access)
- **25**: SMTP (may be blocked by ISP)
- **587**: SMTP Submission (recommended)
- **465**: SMTPS (SSL/TLS)
- **143**: IMAP
- **993**: IMAPS (SSL/TLS)

### Traefik Routes
- **mail.freqkflag.co**: Admin panel
- **webmail.freqkflag.co**: Webmail interface

## Configuration

### Environment Variables

Key variables in `.env`:

- `DOMAIN`: Primary domain for admin interface (freqkflag.co)
- `SECRET_KEY`: Secret key for Mailu (auto-generated, don't change!)
- `DB_FLAVOR`: Database type (sqlite for simplicity)
- `LOG_LEVEL`: Logging level (INFO, DEBUG, etc.)

### Adding Domains

1. Log into admin panel at `https://mail.freqkflag.co`
2. Navigate to "Mail domains"
3. Click "Add domain"
4. Enter domain name (e.g., `cultofjoey.com`)
5. Configure DNS records (see DNS Configuration below)

### Creating Mailboxes

1. Log into admin panel
2. Navigate to "Mailboxes"
3. Click "Add mailbox"
4. Enter:
   - Email address (e.g., `admin@cultofjoey.com`)
   - Password
   - Display name
5. Select domain
6. Save

## DNS Configuration

For each domain you want to use, add these DNS records:

### MX Record (Mail Exchange)
```
Type: MX
Name: @
Value: mail.freqkflag.co
Priority: 10
```

### A Record (Mail Server)
```
Type: A
Name: mail
Value: [Your Server IP]
```

### SPF Record (Sender Policy Framework)
```
Type: TXT
Name: @
Value: v=spf1 mx a:mail.freqkflag.co ~all
```

### DKIM Record (DomainKeys Identified Mail)
Get DKIM key from Mailu admin panel → Domains → [Your Domain] → DKIM key

```
Type: TXT
Name: mail._domainkey
Value: [DKIM key from admin panel]
```

### DMARC Record (Domain-based Message Authentication)
```
Type: TXT
Name: _dmarc
Value: v=DMARC1; p=none; rua=mailto:admin@freqkflag.co
```

## Management

### Start Services
```bash
docker compose up -d
```

### Stop Services
```bash
docker compose down
```

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f admin
docker compose logs -f smtp
docker compose logs -f imap
```

### Restart Services
```bash
docker compose restart
```

### Access Admin CLI
```bash
docker compose exec admin flask mailu admin admin freqkflag.co <command>
```

## Email Client Configuration

### SMTP Settings (Outgoing)
- **Server**: `mail.freqkflag.co` or `smtp.freqkflag.co`
- **Port**: `587` (TLS/STARTTLS) or `465` (SSL)
- **Security**: TLS/SSL
- **Authentication**: Required
- **Username**: Full email address (e.g., `user@cultofjoey.com`)
- **Password**: Mailbox password

### IMAP Settings (Incoming)
- **Server**: `mail.freqkflag.co` or `imap.freqkflag.co`
- **Port**: `993` (SSL) or `143` (STARTTLS)
- **Security**: SSL/TLS
- **Authentication**: Required
- **Username**: Full email address (e.g., `user@cultofjoey.com`)
- **Password**: Mailbox password

## Service Integration

### For Mastodon (twist3dkinkst3r.com)
Update Mastodon `.env`:
```bash
SMTP_SERVER=mail.freqkflag.co
SMTP_PORT=587
SMTP_LOGIN=noreply@twist3dkinkst3r.com
SMTP_PASSWORD=<mailbox_password>
SMTP_FROM_ADDRESS=noreply@twist3dkinkst3r.com
```

### For WordPress
Use SMTP plugin with:
- SMTP Host: `mail.freqkflag.co`
- SMTP Port: `587`
- Encryption: TLS
- Authentication: Yes

### For Other Services
Use the same SMTP settings:
- Server: `mail.freqkflag.co`
- Port: `587` (TLS) or `465` (SSL)
- Authentication required

## Backup

### Backup Mail Data
```bash
# Backup all mail data
tar -czf mailu_backup_$(date +%Y%m%d).tar.gz ./data/mail
```

### Backup Configuration
```bash
# Backup database and config
cp ./data/mail/mailu.db ./data/mail/mailu.db.backup
```

## Troubleshooting

### Check Service Status
```bash
docker compose ps
```

### Test SMTP Connection
```bash
telnet mail.freqkflag.co 587
# Or
openssl s_client -connect mail.freqkflag.co:465
```

### Test IMAP Connection
```bash
openssl s_client -connect mail.freqkflag.co:993
```

### View Mail Logs
```bash
docker compose logs smtp
docker compose logs imap
```

### Common Issues

1. **Port 25 Blocked**: Use port 587 or 465 instead
2. **Emails Not Received**: Check MX records and firewall
3. **Emails Marked as Spam**: Configure SPF, DKIM, DMARC records
4. **Can't Connect**: Verify DNS and firewall rules

## Security Notes

- **Change default admin password** immediately
- **Use strong passwords** for mailboxes
- **Configure SPF/DKIM/DMARC** to prevent spam
- **Keep Mailu updated**: `docker compose pull && docker compose up -d`
- **Monitor logs** for suspicious activity
- **Use TLS/SSL** for all connections
- **Restrict admin access** via firewall if possible

## Updates

```bash
cd /root/infra/mailu
docker compose pull
docker compose up -d
```

## Domain Configuration

1. Point `mail.freqkflag.co` DNS A record to your server IP
2. Point `webmail.freqkflag.co` DNS A record to your server IP
3. Configure MX records for each domain you want to use
4. Wait for DNS propagation
5. Traefik will automatically obtain SSL certificates

## Additional Resources

- [Mailu Documentation](https://mailu.io/)
- [Mailu GitHub](https://github.com/Mailu/Mailu)
- [DNS Records Guide](https://mailu.io/master/faq.html#dns-records)

---

**Last Updated:** 2025-11-20

