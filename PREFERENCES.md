# AI Interaction Preferences

**Last Updated:** 2025-11-20  
**Reference:** Use alongside [AGENTS.md](./AGENTS.md) for complete infrastructure context

This document defines how AI assistants should interact with the infrastructure maintainer and approach technical tasks.

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
- **Report issues** - if something can't be fixed, explain why

### Communication

- **Be concise** - but complete
- **Use code references** - cite existing code with line numbers
- **Show changes** - demonstrate what was modified
- **Explain reasoning** - when making non-obvious choices

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

### Never Do
- ❌ Provide high-level guidance without implementation
- ❌ Add unnecessary complexity
- ❌ Skip reading existing files
- ❌ Break existing patterns
- ❌ Leave documentation outdated
- ❌ Assume basic knowledge needed

---

**Remember:** K.I.S.S. - Keep It Simple, Stupid. Complexity is the enemy.

