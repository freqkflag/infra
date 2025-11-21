# Domain Architecture

## Overview

This document defines the domain structure and purpose for all infrastructure services and applications.

## Central Infrastructure Domain (SPINE)

### `freqkflag.co`

**Purpose:** The central infrastructure domain - the SPINE of the infrastructure system.

**Use Cases:**
- Automation tools and systems
- AI services and applications
- Internal web apps and tools
- Infrastructure management interfaces
- Development and staging environments
- Internal-only services

**Examples:**
- `wiki.freqkflag.co` - WikiJS documentation
- `vault.freqkflag.co` - HashiCorp Vault (if needed)
- `traefik.freqkflag.co` - Traefik dashboard (if exposed)
- `dev.freqkflag.co` - Development environments
- `staging.freqkflag.co` - Staging environments
- `monitoring.freqkflag.co` - Monitoring dashboards
- `automation.freqkflag.co` - Automation tools

**Characteristics:**
- Internal-facing (not public marketing)
- Infrastructure and operations focus
- Tools and utilities
- Automation and AI services

---

## Public-Facing Domains

### 1. `cultofjoey.com`

**Purpose:** Personal creative space and brand

**Use Cases:**
- Personal portfolio
- Creative projects
- Brand presence
- Personal blog/content
- Creative work showcase

**Examples:**
- `cultofjoey.com` - Main site (WordPress)
- `link.cultofjoey.com` - LinkStack (link-in-bio)

**Characteristics:**
- Public-facing
- Personal brand
- Creative/artistic focus
- Professional presence

---

### 2. `twist3dkink.com`

**Purpose:** Kink-affirming LGBTQIA+ trauma-informed mental health peer support specialist/coaching side business

**Use Cases:**
- Business website
- Client resources
- Booking/appointments
- Educational content
- Peer support tools
- Trauma-informed resources

**Examples:**
- `twist3dkink.com` - Main business site
- `app.twist3dkink.com` - Client portal/app
- `resources.twist3dkink.com` - Resource library
- `booking.twist3dkink.com` - Appointment booking

**Characteristics:**
- Public-facing
- Professional business
- Mental health/coaching focus
- LGBTQIA+ and kink-affirming
- Trauma-informed approach
- Peer support emphasis

---

### 3. `twist3dkinkst3r.com`

**Purpose:** PNP-friendly LGBT+ KINK PWA Community/Hook-UP web app

**Use Cases:**
- Progressive Web App (PWA)
- Community platform
- Social networking
- Hook-up/dating features
- Event listings
- Community resources

**Examples:**
- `twist3dkinkst3r.com` - Main PWA app
- `api.twist3dkinkst3r.com` - API backend
- `files.twist3dkinkst3r.com` - File storage/CDN
- `mastodon.twist3dkinkst3r.com` - Mastodon instance (if applicable)

**Characteristics:**
- Public-facing
- PWA (Progressive Web App)
- Community-focused
- Social networking
- PNP-friendly
- LGBT+ KINK community

---

## Domain Assignment Summary

| Domain | Purpose | Type | Focus |
|--------|---------|------|-------|
| `freqkflag.co` | Infrastructure SPINE | Internal | Automation, AI, Tools |
| `cultofjoey.com` | Personal Brand | Public | Creative, Personal |
| `twist3dkink.com` | Mental Health Business | Public | Professional, Coaching |
| `twist3dkinkst3r.com` | Community PWA | Public | Social, Community |

## Current Service Assignments

### Infrastructure (`freqkflag.co`)
- ✅ `wiki.freqkflag.co` - WikiJS

### Personal Brand (`cultofjoey.com`)
- ✅ `cultofjoey.com` - WordPress
- ✅ `link.cultofjoey.com` - LinkStack

### Mental Health Business (`twist3dkink.com`)
- ⚠️ `vault.twist3dkink.com` - Currently Vault (consider moving to freqkflag.co)

### Community PWA (`twist3dkinkst3r.com`)
- ⚠️ Mastodon instance (if applicable)

## DNS Configuration Guidelines

### Infrastructure Subdomains (`*.freqkflag.co`)
- Use for internal tools and automation
- Not for public marketing
- Focus on operational tools

### Public Subdomains
- Use appropriate parent domain based on purpose
- Keep business domains separate from personal
- Maintain clear brand separation

## Security Considerations

- **Infrastructure domains** (`freqkflag.co`): May require VPN or internal access
- **Public domains**: Standard public access with SSL
- **Business domains**: May need additional security/compliance considerations
- **Community domains**: Standard web app security practices

## Notes

- Vault is currently at `vault.twist3dkink.com` but should likely be moved to `vault.freqkflag.co` or kept internal-only
- All domains should use Traefik for SSL/TLS termination
- Let's Encrypt certificates for all public-facing domains
- Internal infrastructure may use self-signed or internal CA

---

**Last Updated:** 2025-11-20
**Maintained By:** Infrastructure Team

