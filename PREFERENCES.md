# AI Interaction Preferences

**Last Updated:** 2025-11-21  
**Reference:** Use alongside [AGENTS.md](./AGENTS.md) for complete infrastructure context

This document defines how AI assistants should interact with the infrastructure maintainer and approach technical tasks.

---

## Mandatory Workflow Requirements

**CRITICAL: These requirements must be followed for EVERY request.**

### Before Completing Any Request

1. **ALWAYS read and reference [AGENTS.md](./AGENTS.md)**
   - Check all available services and their status
   - Review agent responsibilities (starting features, testing operational functions, validation)
   - Understand infrastructure context and dependencies
   - Verify service locations and configurations

2. **ALWAYS read and reference [PREFERENCES.md](./PREFERENCES.md)**
   - Follow interaction guidelines and communication style
   - Adhere to technical preferences and code quality standards
   - Apply K.I.S.S. principles
   - Use standardized service structures

3. **Ensure compliance** with all guidelines specified in both documents

### After Completing Any Request

1. **Update [AGENTS.md](./AGENTS.md)**
   - Add any new services or features created
   - Update service status (Running/Configured)
   - Document new capabilities or changes
   - Update domain assignments if applicable
   - Add to service catalog and quick reference sections

2. **Update [PREFERENCES.md](./PREFERENCES.md)**
   - Add any new patterns or preferences discovered
   - Document new guidelines or best practices
   - Update technical preferences if patterns emerge
   - Keep interaction guidelines current

3. **Keep documentation synchronized**
   - Ensure both files reflect the current state of the infrastructure
   - Maintain consistency across all documentation
   - These files are the source of truth for infrastructure operations

4. **Provide Next Steps as AI Agent Prompt Instructions**
   - **MANDATORY:** All next steps must be formatted as clear, actionable AI Agent prompt instructions
   - Next steps should be copy-paste ready prompts that another AI agent can execute
   - Include all necessary context, file paths, and specific actions required
   - Format: Clear, direct instructions that can be given to an AI agent to continue the work
   - Example: "Act as [agent role]. [Specific action]. [Context]. [Expected outcome]."

**These files must be maintained and followed for every request - no exceptions.**

---

## Core Principles

### K.I.S.S. (Keep It Simple, Stupid)

**PRIMARY PRINCIPLE:** Always prioritize simplicity above all else.

- When considering solutions, **ALWAYS** choose the simplest approach
- Unnecessary complexity compounds quickly and leads to problems
- Make extra efforts to find simple and elegant solutions
- If multiple solutions exist, choose the simplest one that works

### Direct Communication

**DO NOT GIVE HIGH-LEVEL GUIDANCE - PROVIDE ACTUAL CODE/EXPLANATIONS**

- **Bad:** "Here's how you can configure the service..."
- **Good:** Provide actual code, configuration files, or step-by-step commands
- When asked for fixes or explanations, provide **actual implementation**
- Skip theoretical explanations - go straight to practical solutions

### Expert-Level Treatment

- Treat the maintainer as an expert engineer
- Assume technical competence
- Skip basic explanations unless specifically requested
- Use technical terminology appropriately
- Consider new technologies and contrarian ideas, not just conventional wisdom

### Communication Style

- **Be casual** unless otherwise specified
- **Be terse** - get to the point quickly
- **Be accurate and thorough** when providing solutions
- **Anticipate needs** - suggest solutions that weren't explicitly asked for
- **Flag speculation** - if making predictions or assumptions, clearly mark them

---

## Technical Preferences

### Code Quality

- **Clean programming** and elegant design patterns
- **Compliance** with basic principles and nomenclature
- **Generate code, corrections, and refactorings** that follow best practices
- **Split into multiple responses** if one response isn't enough

### Infrastructure Approach

- **Simplicity first** - simplest solution that works
- **Docker Compose** for all services
- **Traefik** for reverse proxy and SSL
- **Infisical CLI (v0.43.30)** is installed globally (`infisical --version`) and should be used for secrets exports, workflow triggers, and automation touchpoints; document version changes here.
- When invoking `docker compose` against the full orchestrator bundle, explicitly set `DEVTOOLS_WORKSPACE` (for example `/root/infra`) so the dev-tools bind mount does not resolve to an empty volume spec.
- **Local data directories** (`./data/`) instead of named volumes when possible
- **Environment variables** in `.env` files
- **Standardized structure** for all services

### File Organization

- **Centralized secrets** in `~/.env` (when applicable)
- **Service-specific configs** in each service's `.env`
- **Documentation** in `README.md` for each service
- **Projects** in `/root/infra/projects/`
- **Build plans** in `~/dev/docs/build_plans/` (if applicable)

### Task Completion

- **Use API calls or tools** when possible instead of manual steps
- **Look for API tokens** and use them to complete tasks
- **SSH tunneling** when appropriate
- **Complete tasks directly** rather than providing instructions
- **Visual verification** - Always verify visually using browser tools before confirming resolutions

---

## Infrastructure Context

### Domain Architecture

**Reference:** [DOMAIN_ARCHITECTURE.md](./DOMAIN_ARCHITECTURE.md)

- **`freqkflag.co`** - Infrastructure SPINE (automation, AI, tools, internal)
- **`cultofjoey.com`** - Personal creative space and brand
- **`twist3dkink.com`** - Mental health peer support/coaching business
- **`twist3dkinkst3r.com`** - PNP-friendly LGBT+ KINK PWA Community

### Service Management

**Reference:** [AGENTS.md](./AGENTS.md)

- All services follow standardized structure
- Use `docker compose` commands (not `docker-compose`)
- Services connect to `traefik-network` for routing
- Each service has its own internal network
- Data persisted in `./data/` directories

### Standard Service Structure

```
<service-name>/
├── docker-compose.yml    # Service definition
├── .env                  # Environment variables
├── data/                 # Persistent data
│   ├── <service-data>/   # Application data
│   └── <db-data>/        # Database data (if applicable)
└── README.md            # Service documentation
```

---

## Interaction Guidelines

### When Making Changes

1. **Read existing files first** - understand current structure
2. **Maintain consistency** - follow existing patterns
3. **Update documentation** - keep README files current
4. **Test configurations** - verify docker-compose.yml syntax
5. **Consider dependencies** - check service relationships

### When Providing Solutions

1. **Show actual code** - not just descriptions
2. **Include context** - reference related files/services
3. **Provide complete solutions** - not partial implementations
4. **Consider edge cases** - but keep solutions simple
5. **Update related docs** - if changes affect other services

### When Answering Questions

1. **Be direct** - answer the question asked
2. **Provide examples** - show actual usage
3. **Reference documentation** - point to relevant files
4. **Consider implications** - how does this affect other services?
5. **Suggest improvements** - if you see better approaches

---

## Code Style Preferences

### Docker Compose

- Use `docker compose` (v2 syntax, no `version:` field)
- Use bind mounts (`./data`) instead of named volumes when possible
- Include health checks for databases
- Use `depends_on` with `condition: service_healthy`
- External networks: `traefik-network`

### Configuration Files

- **YAML:** Consistent indentation, clear structure
- **Environment files:** Commented sections, clear variable names
- **Shell scripts:** `#!/bin/bash`, `set -e` for error handling
- **Documentation:** Markdown with clear sections

### Naming Conventions

- **Services:** Lowercase, descriptive names
- **Containers:** Match service name
- **Networks:** `<service>-network` for internal, `traefik-network` for external
- **Directories:** Lowercase, no spaces
- **Files:** Descriptive names, appropriate extensions

---

## Workflow Preferences

### Task Execution

- **Proactive:** Anticipate next steps
- **Thorough:** Complete tasks fully
- **Efficient:** Use tools/APIs when available
- **Documented:** Update relevant documentation

### Error Handling

- **Fix errors immediately** if introduced
- **Don't loop** - max 3 attempts to fix linter errors
- **Verify changes** - test configurations before marking complete
- **Visual verification required** - Always verify visually using browser tools before confirming resolutions
- **Report issues** - if something can't be fixed, explain why

### Communication

- **Be concise** - but complete
- **Use code references** - cite existing code with line numbers
- **Show changes** - demonstrate what was modified
- **Explain reasoning** - when making non-obvious choices

### Next Steps Format

**MANDATORY:** All next steps must be formatted as AI Agent prompt instructions.

- **Format:** Clear, actionable prompts that can be copy-pasted to another AI agent
- **Include:** All necessary context, file paths, specific actions, and expected outcomes
- **Structure:** "Act as [agent role]. [Specific action]. [Context]. [Expected outcome]."
- **Purpose:** Enable seamless handoff between AI agents without requiring human interpretation
- **Example:**
  ```
  Act as Deployment Runner. Start the newly configured n8n service at /root/infra/n8n/ 
  using docker compose up -d. Verify it's running and accessible at n8n.freqkflag.co. 
  Update AGENTS.md with running status. Expected: n8n service operational and documented.
  ```

---

## Infrastructure-Specific Guidelines

### Adding New Services

1. Create directory in `/root/infra/<service-name>/`
2. Create `docker-compose.yml` with Traefik integration
3. Create `.env` template with required variables
4. Create `README.md` with documentation
5. Add to `AGENTS.md` service catalog
6. Use `traefik-network` for routing
7. Use local `./data/` directories for persistence

### Modifying Existing Services

1. Read current configuration
2. Understand dependencies
3. Make minimal necessary changes
4. Update documentation if behavior changes
5. Test configuration syntax
6. Consider impact on other services

### Domain Assignments

- **Infrastructure tools** → `*.freqkflag.co`
- **Personal brand** → `*.cultofjoey.com`
- **Business** → `*.twist3dkink.com`
- **Community** → `*.twist3dkinkst3r.com`

---

## Documentation Standards

### README Files

Each service README should include:
- Quick Start section
- Architecture overview
- Configuration details
- Management commands
- Troubleshooting
- Security notes

### Code Comments

- **Explain why**, not what (code should be self-documenting)
- **Document non-obvious decisions**
- **Include context** for complex logic
- **Keep comments current** with code changes

---

## Security Considerations

- **Change default passwords** - always update `.env` templates
- **Use Vault** for sensitive credentials when appropriate
- **File permissions** - `.env` files should be 600
- **Secrets management** - never commit secrets to git
- **Regular updates** - keep Docker images updated

---

## Reference Documents

When working with this infrastructure, always reference:

1. **[AGENTS.md](./AGENTS.md)** - Complete service catalog
2. **[DOMAIN_ARCHITECTURE.md](./DOMAIN_ARCHITECTURE.md)** - Domain structure
3. **[PREFERENCES.md](./PREFERENCES.md)** - This file (AI interaction guidelines)
4. **Service-specific README.md** - Individual service documentation

---

## Quick Reference

### Always Do
- ✅ Prioritize simplicity
- ✅ Provide actual code/commands
- ✅ Treat as expert
- ✅ Be direct and terse
- ✅ Maintain consistency
- ✅ Update documentation
- ✅ Format next steps as AI Agent prompt instructions

### Never Do
- ❌ Provide high-level guidance without implementation
- ❌ Add unnecessary complexity
- ❌ Skip reading existing files
- ❌ Break existing patterns
- ❌ Leave documentation outdated
- ❌ Assume basic knowledge needed
- ❌ Provide next steps as vague suggestions (must be AI Agent prompt instructions)

---

**Remember:** K.I.S.S. - Keep It Simple, Stupid. Complexity is the enemy.
