# Mailu Quick Setup Guide

## Initial Setup Steps

1. **Start Mailu:**
   ```bash
   cd /root/infra/mailu
   docker compose up -d
   ```

2. **Wait for services to start** (about 30-60 seconds)

3. **Access Admin Panel:**
   - URL: `https://mail.freqkflag.co` (after DNS is configured)
   - Default credentials:
     - Username: `admin`
     - Password: `changeme`

4. **Change Admin Password:**
   - Log in → Settings → Change password

5. **Add Domains:**
   - Go to "Mail domains" → "Add domain"
   - Add each domain:
     - `cultofjoey.com`
     - `twist3dkink.com`
     - `twist3dkinkst3r.com`
     - `freqkflag.co` (if needed)

6. **Configure DNS Records:**
   For each domain, add:
   - **MX Record**: `mail.freqkflag.co` (priority 10)
   - **A Record**: `mail` → [Your Server IP]
   - **SPF Record**: `v=spf1 mx a:mail.freqkflag.co ~all`
   - **DKIM Record**: Get from Mailu admin panel
   - **DMARC Record**: `v=DMARC1; p=none; rua=mailto:admin@freqkflag.co`

7. **Create Mailboxes:**
   - Go to "Mailboxes" → "Add mailbox"
   - Create mailboxes for each domain as needed
   - Example: `admin@cultofjoey.com`, `noreply@twist3dkinkst3r.com`

## Service Integration

### Update Mastodon SMTP Settings
Edit `/root/infra/mastadon/.env`:
```bash
SMTP_SERVER=mail.freqkflag.co
SMTP_PORT=587
SMTP_LOGIN=noreply@twist3dkinkst3r.com
SMTP_PASSWORD=<mailbox_password>
SMTP_FROM_ADDRESS=noreply@twist3dkinkst3r.com
```

Then restart Mastodon:
```bash
cd /root/infra/mastadon
docker compose restart mastodon-web
```

## Testing

### Test SMTP
```bash
telnet mail.freqkflag.co 587
# Should see: 220 mail.freqkflag.co ESMTP
```

### Test IMAP
```bash
openssl s_client -connect mail.freqkflag.co:993
# Should connect successfully
```

### Send Test Email
Use webmail at `https://webmail.freqkflag.co` or configure an email client.

## Troubleshooting

If services don't start:
```bash
docker compose logs
```

Check if ports are available:
```bash
netstat -tuln | grep -E ':(25|143|465|587|993)'
```

