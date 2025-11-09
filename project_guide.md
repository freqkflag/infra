# **Cursor Deployment Framework**

## Unified FOSS Infrastructure — Joey (v2025‑11‑08)

> A comprehensive guide for deploying, securing, and maintaining a distributed
> self‑hosted ecosystem. This document formalizes the architecture, automation,
> and governance model across all nodes using open‑source tooling — Docker,
> Traefik, Cloudflare Tunnels, Infisical, Kong OSS, and ClamAV.

---

## I. Role and Function

The orchestration framework provides a standardized methodology for deploying
and managing multi‑node environments. It unifies configuration, automates
workflows, and enforces reproducibility and compliance across both
**VPS (Hostinger)** and **Homelab** nodes (Mac mini and Linux).

The **Deployment Orchestrator** functions as the central automation controller.
It analyzes workspace structure, generates Docker Compose manifests, manages
secret injection, and enforces security boundaries through Cloudflare Tunnels
and Traefik. All changes are validated and logged to maintain deterministic,
auditable builds.

---

## II. Primary Objectives

1. **System Discovery and Normalization** — Catalog all hosts, networks, and
   repositories. Apply consistent directory and configuration standards.
2. **Ingress and Orchestration Architecture** — Deploy **Cloudflare Tunnels**
   and **Traefik** for authenticated ingress, DNS‑01 TLS issuance, and
   zero‑trust segmentation.
3. **Application Lifecycle and Resilience** — Deploy, monitor, and maintain
   services with persistent volumes, health probes, and rollback policies.
4. **Governance and Documentation** — Integrate observability, backups, and
   change management under a unified documentation and audit framework.

---

## III. Operational Constraints

* **Idempotency:** All processes are safe to re‑execute without state drift.
* **Orchestration:** Limited to **Docker Compose** and **Traefik**; no additional schedulers unless approved.
* **Isolation:** Each service maintains its own Compose definition for clarity.
* **Secret Management:** All credentials originate from Infisical; static secrets are prohibited.
* **DNS Governance:** Domain mappings must remain within approved Cloudflare zones.

---

## IV. Source of Truth

* **Root Repository:** `~/infra` (workspace root)
* **Secrets Authority:** Infisical on VPS
* **Primary Environment File:** `.workspace/.env`

  * Used for bootstrap and mirrored remotely.
  * Contains project metadata and Infisical credentials.

---

## V. Workspace Integration Protocol

When invoked through Cursor:

1. Mount `.env` into containers.
2. Export variables for subprocesses.
3. Validate `.env` visibility; prompt on absence.
4. Substitute undefined variables with placeholders.
5. Embed `env_file` references across all Compose manifests.

---

## VI. Host Topology

All nodes participate in Cloudflare’s Zero‑Trust network through dedicated tokens:

| Host             | Role                                      | Token                      |
| ---------------- | ----------------------------------------- | -------------------------- |
| **vps.host**     | Hostinger VPS (production ingress & apps) | `${CF_TUNNEL_TOKEN_VPS}`   |
| **home.macmini** | macOS development environment             | `${CF_TUNNEL_TOKEN_MAC}`   |
| **home.linux**   | Local homelab (LAN services)              | `${CF_TUNNEL_TOKEN_LINUX}` |

Each validates Docker, plugin availability, and the `edge` network before orchestration.

---

## VII. Networking and Domain Strategy

### Network Security and Defense

Each node enforces firewall rules, ingress filtering, and DDoS mitigation
through Cloudflare’s Zero‑Trust gateway. Only ports 80/443 and 22 are
accessible. Cloudflare’s WAF and rate‑limiting reinforce protection against
volumetric and application‑layer threats.

### Unified Domain and Service Map

| Host                        | Domains                                                                                                                                                                                                                     | Key Services                                                                                                                                                                        | Tunnel Token               |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| **VPS (vps.host)**          | `cultofjoey.com`, `freqkflag.co`, `twist3dkink.com`, `twist3dkinkst3r.com`, `wiki.cultofjoey.com`, `infisical.freqkflag.co`, `api.freqkflag.co`, `api-admin.freqkflag.co`, `scan.freqkflag.co`, `clamav-admin.freqkflag.co` | Ghost, WordPress, Discourse, Wiki.js, Infisical, LinkStack, Gitea, LocalAI, OpenWebUI, n8n/Node‑RED, Kong OSS, PostgreSQL, MariaDB, Redis, Adminer/pgAdmin, Redis Commander, ClamAV | `${CF_TUNNEL_TOKEN_VPS}`   |
| **Mac mini (home.macmini)** | `twist3dkink.online`, `dev.twist3dkink.online`                                                                                                                                                                              | Front‑end & experimental tools                                                                                                                                                      | `${CF_TUNNEL_TOKEN_MAC}`   |
| **Homelab (home.linux)**    | `cult‑of‑joey.com`, `notes.cult‑of‑joey.com`                                                                                                                                                                                | Vaultwarden, BookStack, auxiliary services                                                                                                                                          | `${CF_TUNNEL_TOKEN_LINUX}` |

> **TLS & Routing:** Traefik provisions certificates via ACME with Cloudflare
> DNS‑01 validation. Cloudflared handles secure ingress. Port 443 remains
> reserved for admin testing.

---

## VIII. Infisical Deployment

Infisical functions as the authoritative secrets management layer. It adheres
to ISO/IEC 27001 and SOC 2 Type II controls for encryption, access, and audit.

### Component Topology

| Component     | Role                  | Port | Dependencies      |
| ------------- | --------------------- | ---- | ----------------- |
| PostgreSQL    | Metadata store        | 5432 | —                 |
| Redis         | Ephemeral cache/queue | 6379 | —                 |
| Infisical‑API | Secret/config API     | 8080 | PostgreSQL, Redis |
| Dashboard     | Admin web UI          | 80   | Infisical‑API     |

**Ingress:** Traefik routes traffic for `infisical.freqkflag.co`.
**Bootstrap:** Credentials established once; subsequent access occurs via CLI
injection.

**Security Directives:**

* Disable open registration; enforce 2FA.
* Use least‑privilege tokens per service.
* Automate encrypted backups (7/30/180 day cycles).

---

## IX. Universal Secret Policy (Infisical‑First)

* Install **Infisical CLI** on all hosts.
* Deploy with: `infisical run --env=<environment> -- docker compose up -d`.
* Store tokens securely (`INFISICAL_TOKEN` or `~/.infisical.json`).
* Maintain hierarchical structure (`vps/`, `mac‑mini/`, `homelab/`) for isolation.

---

## X. Logging, Backups, and Change Management

### Log Aggregation

All nodes log to `~/.logs/` and optionally forward to a Loki or syslog endpoint.

### Backup Management

Data resides in `~/.backup/` under `daily`, `weekly`, `monthly`, and `manual`
folders. Cron/systemd enforce encryption, rotation, and checksum validation.

### Automation and Synchronization

**n8n** or **Node‑RED** (`automation.freqkflag.co`) handles backup scheduling,
changelog updates, and notifications. Workflows preserve parity across nodes.

### Change Tracking

Each host keeps `server‑changelog.md` documenting deployments and config
changes. Infisical‑authenticated webhooks can centralize these records.

---

## XI. Execution Safety Check

Before each orchestration:

```bash
if [ ! -f .workspace/.env ]; then
  echo "❌ Environment file not found."; exit 1;
else
  echo "✅ Environment context verified.";
fi
```

Ensures environment integrity and prevents undefined‑variable faults.

---

## XII. API Gateway — Kong OSS

**Purpose:** Provide a unified, secure API entry point for agents and services.
Handles authentication, rate‑limiting, routing, and observability.

**Domains:** `api.freqkflag.co` (proxy) and `api-admin.freqkflag.co` (admin
interface behind CF Access).

**Baseline Policy:** Enable `key‑auth`, `rate‑limiting`, and `cors` globally.
Restrict admin access via IP and CF Access.

**Declarative Example (kong.yml):**

```yaml
_format_version: "3.0"
_services:
  - name: localai
    url: http://localai:8081
    routes:
      - name: localai-route
        paths: [/ai]
  - name: openwebui
    url: http://openwebui:8080
    routes:
      - name: openwebui-route
        paths: [/ui]
_plugins:
  - name: key-auth
  - name: rate-limiting
    config:
      minute: 120
```

Automation tools may rotate keys via Infisical, sync configurations to
`~/infra`, and log updates to `server‑changelog.md`.

---

## XIII. Malware Scanning — ClamAV (FOSS)

**Purpose:** Centralized malware protection for uploads and shared volumes
across WordPress, Discourse, Ghost, and Wiki.js.

**Domains:**

* `scan.freqkflag.co` — internal clamd endpoint (non‑public)
* `clamav-admin.freqkflag.co` — REST/UI secured by Cloudflare Access

**Integration:**

* **Sidecar Scans:** Triggered via n8n/Node‑RED on file write; quarantines to
  `~/.backup/quarantine/`.
* **Inline Checks:** REST API call before upload acceptance (key‑auth via Kong).
* **Nightly Sweeps:** Full-volume scans; results logged to `~/.logs/clamav/`
  and the changelog.

**Security:**
Expose only via Traefik within CF Access.
Enable automatic signature updates (`freshclam`).
Redact sensitive paths in shared reports.

---

### **End of Document — Version 2025‑11‑08**
