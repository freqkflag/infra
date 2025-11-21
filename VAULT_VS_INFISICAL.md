# Vault vs Infisical Comparison

**Date:** 2025-11-20  
**Context:** Evaluating Infisical as alternative to Vault due to restart issues

## Quick Comparison

| Feature | HashiCorp Vault | Infisical |
|---------|----------------|-----------|
| **Ease of Use** | Complex, steep learning curve | Developer-friendly, intuitive UI |
| **Docker Deployment** | ⚠️ Restart loop issues | ✅ Smooth Docker deployment |
| **Setup Complexity** | High (unsealing, initialization) | Low (simpler setup) |
| **UI/UX** | Basic web UI | Modern, polished interface |
| **API/CLI** | Comprehensive but complex | Simple, developer-focused |
| **Features** | Enterprise-grade, extensive | Modern, focused feature set |
| **Community** | Large, established | Growing, active |
| **License** | MPL 2.0 | MIT (more permissive) |
| **Migration** | N/A | ✅ Migration tools from Vault |

## Why Consider Infisical?

### 1. **Docker Deployment Issues**
- **Vault:** Currently experiencing restart loop issues in Docker Compose
- **Infisical:** Designed with Docker-first approach, smoother deployment

### 2. **Developer Experience**
- **Vault:** Requires understanding of unsealing, policies, auth methods
- **Infisical:** Simpler API, better CLI, intuitive UI

### 3. **Modern Features**
- **Vault:** Comprehensive but can be overwhelming
- **Infisical:** Focused on modern workflows, better integrations

### 4. **Ease of Management**
- **Vault:** Manual unsealing after restarts, complex configuration
- **Infisical:** Simpler operational model, less maintenance overhead

## Your Current Vault Usage

Based on codebase analysis:
- **Purpose:** Secrets management for infrastructure
- **Usage:** API keys, tokens, credentials storage
- **Integration:** Used by Mastodon, potentially other services
- **Access:** Via `vault.freqkflag.co` through Traefik
- **Features Used:**
  - Key-value secret storage
  - Encrypted storage
  - API access
  - Audit logging

## Infisical Feature Match

✅ **All your current Vault features are available in Infisical:**
- Encrypted secret storage
- Version-controlled secrets
- API access
- Audit logging
- Web UI
- CLI tools
- Docker deployment
- Self-hosted option

## Migration Path

Infisical provides migration tools:
- Import secrets from Vault
- Translate access control policies
- Kubernetes auth configuration migration

## Recommendation

**Yes, Infisical would be a better alternative for your use case:**

### Pros:
1. ✅ **Solves Docker restart issue** - Better Docker integration
2. ✅ **Simpler operations** - No unsealing required
3. ✅ **Better developer experience** - Modern UI and API
4. ✅ **Easier maintenance** - Less operational overhead
5. ✅ **Migration support** - Tools to migrate from Vault

### Cons:
1. ⚠️ **Smaller ecosystem** - Less third-party integrations (but growing)
2. ⚠️ **Newer project** - Less battle-tested than Vault (but actively maintained)
3. ⚠️ **Learning curve** - Need to learn new tool (but simpler than Vault)

## Next Steps

If you want to proceed with Infisical:

1. **Set up Infisical** in `/root/infra/infisical/`
2. **Migrate secrets** from Vault (if any exist)
3. **Update integrations** (Mastodon, etc.)
4. **Update documentation** (AGENTS.md, SERVICES.yml)
5. **Decommission Vault** once migration is complete

## Decision

**Recommendation:** ✅ **Switch to Infisical**

Given:
- Current Vault restart issues
- Simpler operational model
- Better Docker integration
- Modern developer experience
- Migration path available

The benefits outweigh the migration effort, especially since you're already having operational issues with Vault.

