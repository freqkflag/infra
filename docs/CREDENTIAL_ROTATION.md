# Credential Rotation Guide

**Created:** 2025-11-21  
**Status:** CRITICAL - Action Required  
**Priority:** HIGH

---

## Overview

This document outlines the rotation of exposed SSH credentials that were previously stored in plaintext in the git repository.

**Exposed Credentials:**
- `Warren7882??` - VPS root access (62.72.26.113)
- `7882` - Homelab and Mac Mini access

**Exposure Details:**
- Found in git history (commits: c3b3763f, 1062007524)
- Removed from repository in commit 12b7f17
- **⚠️ CRITICAL:** Must be rotated immediately on all systems

---

## New Credentials

**Generated:** 2025-11-21  
**Strength:** 32-character base64-encoded random strings

### VPS Root Access
- **Host:** vps.freqkflag.co (62.72.26.113)
- **User:** root
- **Old Password:** `Warren7882??`
- **New Password:** `CeC2Hc6ihkbaEXA3GW22J3E+lxmwRBgg`
- **Rotation Status:** ⚠️ **PENDING MANUAL UPDATE REQUIRED**

### Homelab & Mac Mini Access
- **Host:** homelab (192.168.12.102), maclab (maclab.twist3dkink.online)
- **User:** freqkflag
- **Old Password:** `7882`
- **New Password:** `2vQaux7w1PrkhvfKQjifsd/L17a0imfd`
- **Rotation Status:** ⚠️ **PENDING MANUAL UPDATE REQUIRED**

---

## Rotation Procedure

### Step 1: Store New Passwords Securely

**IMPORTANT:** Before rotating, store the new passwords in Infisical:

```bash
# Access Infisical
cd /root/infra
infisical run --env=production -- infisical secrets set VPS_ROOT_PASSWORD=CeC2Hc6ihkbaEXA3GW22J3E+lxmwRBgg --path vps/ssh
infisical run --env=production -- infisical secrets set HOMELAB_SSH_PASSWORD=2vQaux7w1PrkhvfKQjifsd/L17a0imfd --path homelab/ssh
infisical run --env=production -- infisical secrets set MACLAB_SSH_PASSWORD=2vQaux7w1PrkhvfKQjifsd/L17a0imfd --path maclab/ssh
```

### Step 2: Rotate VPS Root Password

**⚠️ CRITICAL:** Ensure you have console access or alternative authentication method before proceeding.

```bash
# Connect to VPS
ssh root@62.72.26.113
# Use old password: Warren7882??

# Change password
passwd root
# Enter new password: CeC2Hc6ihkbaEXA3GW22J3E+lxmwRBgg

# Verify new password works
exit
ssh root@62.72.26.113
# Use new password: CeC2Hc6ihkbaEXA3GW22J3E+lxmwRBgg
```

**Verification:**
- [ ] New password stored in Infisical
- [ ] Old password no longer works
- [ ] New password works for SSH access
- [ ] Can authenticate successfully

### Step 3: Rotate Homelab Password

```bash
# Connect to Homelab
ssh freqkflag@192.168.12.102
# Use old password: 7882

# Change password
passwd
# Enter new password: 2vQaux7w1PrkhvfKQjifsd/L17a0imfd

# Verify new password works
exit
ssh freqkflag@192.168.12.102
# Use new password: 2vQaux7w1PrkhvfKQjifsd/L17a0imfd
```

**Verification:**
- [ ] New password stored in Infisical
- [ ] Old password no longer works
- [ ] New password works for SSH access
- [ ] Can authenticate successfully

### Step 4: Rotate Mac Mini Password

```bash
# Connect to Mac Mini
ssh freqkflag@maclab.twist3dkink.online
# Use old password: 7882

# Change password (macOS)
passwd
# Enter new password: 2vQaux7w1PrkhvfKQjifsd/L17a0imfd

# Verify new password works
exit
ssh freqkflag@maclab.twist3dkink.online
# Use new password: 2vQaux7w1PrkhvfKQjifsd/L17a0imfd
```

**Verification:**
- [ ] New password stored in Infisical
- [ ] Old password no longer works
- [ ] New password works for SSH access
- [ ] Can authenticate successfully

---

## Post-Rotation Tasks

### 1. Update SSH Key Authentication (Recommended)

**Best Practice:** Use SSH keys instead of passwords for all authentication.

```bash
# Generate SSH key pair (if not already done)
ssh-keygen -t ed25519 -C "infrastructure-access" -f ~/.ssh/infra_ed25519

# Copy public key to VPS
ssh-copy-id -i ~/.ssh/infra_ed25519.pub root@62.72.26.113

# Copy public key to Homelab
ssh-copy-id -i ~/.ssh/infra_ed25519.pub freqkflag@192.168.12.102

# Copy public key to Mac Mini
ssh-copy-id -i ~/.ssh/infra_ed25519.pub freqkflag@maclab.twist3dkink.online
```

### 2. Disable Password Authentication (Optional, Recommended)

After SSH keys are configured and verified:

```bash
# On each system, edit /etc/ssh/sshd_config
# Set: PasswordAuthentication no
# Set: PubkeyAuthentication yes

# Restart SSH service
# Linux: systemctl restart sshd
# macOS: sudo launchctl unload -w /System/Library/LaunchDaemons/ssh.plist
#        sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
```

### 3. Update Scripts and Documentation

- [x] Updated `reset-ghost-password.js` to require password as argument
- [ ] Verify no other scripts reference old passwords
- [ ] Update any automation scripts to use Infisical secrets

### 4. Audit Access Logs

```bash
# Check for unauthorized access attempts
# VPS
lastlog | grep -E "Warren7882|7882|root"

# Homelab
lastlog | grep -E "7882|freqkflag"

# Mac Mini
last | grep -E "7882|freqkflag"
```

---

## Security Recommendations

1. **Use SSH Keys:** Prefer SSH key authentication over passwords
2. **Enable 2FA:** If supported, enable two-factor authentication
3. **Regular Rotation:** Rotate passwords quarterly or after any security incident
4. **Password Complexity:** Use strong, randomly generated passwords (32+ characters)
5. **Secret Management:** Store all credentials in Infisical, never in code
6. **Audit Access:** Regularly review access logs for suspicious activity

---

## Status Tracking

**Rotation Status:** ⚠️ IN PROGRESS (2025-11-21)

- [x] New passwords generated
- [x] Documentation created
- [x] Scripts updated
- [ ] Passwords stored in Infisical
- [ ] VPS root password rotated
- [ ] Homelab password rotated
- [ ] Mac Mini password rotated
- [ ] All verifications completed
- [ ] Access logs audited
- [ ] SSH keys configured (recommended)
- [ ] REMEDIATION_PLAN.md updated

---

## Rollback Procedure

If rotation fails or causes access issues:

1. **Use Console Access:** If available, use console/VNC access to regain entry
2. **SSH Keys:** If SSH keys are configured, use those to access
3. **Recovery Mode:** Use system recovery mode if console access unavailable
4. **Restore from Backup:** If credentials are backed up in Infisical, restore previous values temporarily

**⚠️ Never commit passwords to git or store in plaintext files.**

---

**Last Updated:** 2025-11-21  
**Owner:** Infrastructure Team / Security Team  
**Review Required:** Before rotation execution

