# Infisical Admin Access

**Created:** 2025-11-22  
**Status:** Active Admin Account Exists

---

## Existing Admin Account

**Email:** `admin@freqkflag.co`  
**Type:** Super Admin  
**Status:** Accepted and Active  
**Created:** 2025-11-22 00:39:08

---

## Access Options

### Option 1: Log In with Existing Account

1. Visit: https://infisical.freqkflag.co
2. Click "Sign In" or "Log In"
3. Enter email: `admin@freqkflag.co`
4. Enter your password
5. If you don't remember the password, use Option 2 or 3 below

### Option 2: Reset Password (If SMTP Configured)

If SMTP email is properly configured:

1. Click "Forgot Password" on the login page
2. Enter email: `admin@freqkflag.co`
3. Check your email for password reset link

**⚠️ Note:** SMTP is currently timing out when trying to connect to `mail.freqkflag.co:587`. This will prevent password reset emails from being sent.

### Option 3: Reset Password via Database

If you don't have access to the email or SMTP is not working:

```bash
# Connect to Infisical database
docker exec -it infisical-db psql -U infisical -d infisical

# Note: You'll need to generate a password hash. See below for password reset options.
```

**⚠️ Warning:** This requires database access and password hash generation.

### Option 4: Reset Database (Start Fresh)

**⚠️ DANGER:** This will delete all data including secrets!

If you need to completely reset and create a new admin:

```bash
cd /root/infra/infisical

# Backup data first (optional)
docker compose exec infisical-db pg_dump -U infisical infisical > backup_$(date +%Y%m%d_%H%M%S).sql

# Stop Infisical
docker compose down

# Remove database data
rm -rf data/postgres/*

# Restart Infisical
docker compose up -d

# Wait for migration to complete, then create new admin via UI
```

---

## SMTP Configuration Issue

**Current Issue:** SMTP connection timeout to `mail.freqkflag.co:587`

**Impact:**
- Password reset emails won't work
- Email notifications won't work
- User invitations won't work

**Options:**
1. **Fix SMTP:** Configure Mailu service and ensure it's accessible
2. **Disable Email Features:** Use Infisical without email (local admin access only)
3. **Use External SMTP:** Configure with Gmail, SendGrid, etc.

**To disable SMTP temporarily:**
- Comment out SMTP environment variables in `docker-compose.yml`
- Restart Infisical: `docker compose restart infisical`

---

## Troubleshooting

### "Admin account has already been set up" Error

This error means an admin account already exists. You cannot create a new admin via the signup page. Use the existing admin account to log in or reset the database.

### "undefined" Error in UI

The UI may show "undefined" for errors, but check the browser console (F12) or server logs for the actual error:

```bash
docker logs infisical --tail 50 | grep ERROR
```

### Can't Log In

1. **Verify email:** Make sure you're using `admin@freqkflag.co`
2. **Check password:** If you forgot, reset via database or reset the entire database
3. **Check logs:** `docker logs infisical --tail 100`

---

## Security Notes

- Never commit passwords or secrets to git
- Use Infisical to store all secrets securely
- Regularly rotate admin passwords
- Enable 2FA once logged in
- Use SSH keys instead of passwords where possible

---

**Last Updated:** 2025-11-22  
**Contact:** Infrastructure Team

