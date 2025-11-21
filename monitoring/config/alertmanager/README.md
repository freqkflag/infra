# Alertmanager Configuration

**Domain:** `alertmanager.freqkflag.co`

## Configuration

Alertmanager is configured via `/root/infra/monitoring/config/alertmanager/alertmanager.yml`

### Environment Variables

Set these in `/root/infra/monitoring/.env`:

**Email Configuration:**
```bash
SMTP_HOST=smtp.example.com:587
SMTP_FROM=alertmanager@freqkflag.co
SMTP_USER=your_smtp_username
SMTP_PASSWORD=your_smtp_password
ALERT_EMAIL=admin@freqkflag.co
```

**Discord Webhook (Optional):**
```bash
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN
DISCORD_WEBHOOK_TOKEN=your_token
```

**Matrix Webhook (Optional):**
```bash
MATRIX_WEBHOOK_URL=https://matrix.example.com/_matrix/client/r0/rooms/!ROOM_ID/send/m.room.message
MATRIX_WEBHOOK_TOKEN=your_token
```

## Alert Routing

- **Critical Alerts**: Sent to all channels (email, Discord, Matrix if configured)
- **Warning Alerts**: Sent to email only
- **Default**: All alerts sent to email

## Notification Channels

### Email
- Configured via SMTP settings
- HTML formatted alerts
- Critical alerts have red styling
- Warning alerts have orange styling

### Discord
- Webhook-based notifications
- Rich formatting
- Only for critical alerts

### Matrix
- Webhook-based notifications
- Only for critical alerts

## Access

- **Web UI**: https://alertmanager.freqkflag.co
- **API**: https://alertmanager.freqkflag.co/api/v2

## Testing

Test alert routing:
```bash
# Send test alert via Prometheus
curl -X POST http://localhost:9090/api/v1/alerts -d '[
  {
    "labels": {
      "alertname": "TestAlert",
      "severity": "critical"
    },
    "annotations": {
      "summary": "Test alert",
      "description": "This is a test alert"
    }
  }
]'
```

## Management

```bash
cd /root/infra/monitoring
docker compose restart alertmanager
docker compose logs -f alertmanager
```

## Security Notes

- Store SMTP credentials securely in `.env` file (600 permissions)
- Use app-specific passwords for email providers
- Rotate webhook tokens regularly
- Review alert routing rules for production

