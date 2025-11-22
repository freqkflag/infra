#!/usr/bin/env python3
"""
Patch existing runbooks to add "Runme & Cursor Automation Hooks" section
"""

import yaml
import re
from pathlib import Path
from datetime import date

INFRA_ROOT = Path("/root/infra")
SERVICES_YML = INFRA_ROOT / "SERVICES.yml"
RUNBOOKS_DIR = INFRA_ROOT / "runbooks"

# Automation hooks section template
AUTOMATION_HOOKS_SECTION = """---

## Runme & Cursor Automation Hooks

- Tag runnable snippets with Runme metadata so Cursor can surface the dispatcher menu:
  ```markdown
  ```bash {{"id":"{service_id}-restart","runme":{{"label":"Restart {service_name}","tags":["runbook","{service_id}"]}}}}
  cd /root/infra/{service_dir}
  docker compose restart
  ```
  ```
- Each Runme cell should ultimately call a dispatcher (see `docs/runbooks/RUNME_INTEGRATION_PLAN.md`) that asks whether to run locally or ship commands to a fresh Cursor agent thread.

### AI Orchestration Prompts (copy/paste ready)

**Full Multi-Agent Sweep**
```
Use the Multi-Agent Orchestrator preset. Scope analysis to /root/infra/{service_dir} ({service_name}) first, then capture upstream dependencies from compose.orchestrator.yml. Return strict JSON with prioritized run actions plus any restart commands needed for {service_name}.
```

**Service Health Check**
```
Act as status_agent. Focus on /root/infra/{service_dir} and the {service_id} containers. Confirm docker compose ps, health checks, and Traefik routing. Return strict JSON with health summary + restart recommendation.
```

**Targeted Operational Command**
```
Act as Deployment Runner. Execute the following commands for {service_name} at /root/infra/{service_dir}:
cd /root/infra/{service_dir}
docker compose up -d
Verify the service at https://{primary_domain} and capture logs if unhealthy.
```

---

"""

def get_service_info():
    """Get all services from SERVICES.yml"""
    with open(SERVICES_YML, 'r') as f:
        data = yaml.safe_load(f)
    
    services = {}
    for service in data.get('services', []):
        service_id = service.get('id')
        service_dir = service.get('dir')
        
        if not service_dir or service_dir == 'null' or service.get('status') == 'deprecated':
            continue
        
        if service_dir.startswith('/'):
            rel_dir = service_dir.replace('/root/infra/', '')
        else:
            rel_dir = service_dir
        
        domain = service.get('domain') or (service.get('domains', [None])[0] if service.get('domains') else None)
        
        services[service_id] = {
            'id': service_id,
            'name': service.get('name'),
            'dir': rel_dir,
            'domain': domain or 'N/A',
            'status': service.get('status', 'configured'),
        }
    
    return services

def extract_service_info_from_runbook(content):
    """Extract service info from runbook content"""
    info = {}
    
    # Extract service ID from "Service ID:" line
    service_id_match = re.search(r'\*\*Service ID:\*\* `([^`]+)`', content)
    if service_id_match:
        info['id'] = service_id_match.group(1)
    
    # Extract service name from title
    title_match = re.search(r'^# (.+) Runbook', content, re.MULTILINE)
    if title_match:
        name = title_match.group(1)
        # Remove "Runbook" if present
        name = name.replace(' Runbook', '').strip()
        info['name'] = name
    
    # Extract domain from "Domain(s):" line
    domain_match = re.search(r'\*\*Domain\(s\):\*\* `([^`]+)`', content)
    if domain_match:
        info['domain'] = domain_match.group(1)
    
    # Extract service dir from code blocks
    dir_match = re.search(r'cd /root/infra/([^\s/]+)', content)
    if dir_match:
        info['dir'] = dir_match.group(1)
    
    return info

def find_insertion_point(content):
    """Find where to insert the automation hooks section"""
    # Look for "## Health Checks" or "## Configuration" after "## Quick Reference"
    quick_ref_match = re.search(r'## Quick Reference.*?\n', content, re.DOTALL)
    if not quick_ref_match:
        return None
    
    quick_ref_end = quick_ref_match.end()
    
    # Find the next section after Quick Reference
    next_section_match = re.search(r'\n## (Health Checks|Configuration|Common Issues)', content[quick_ref_end:])
    if next_section_match:
        insert_pos = quick_ref_end + next_section_match.start()
        # Check if there's already a separator before the next section
        # If so, insert before the separator to avoid duplicates
        before_section = content[quick_ref_end:insert_pos].rstrip()
        if before_section.endswith('---'):
            # Remove trailing separator and newlines, then add our section
            return quick_ref_end + len(before_section.rstrip('-\n '))
        return insert_pos
    
    # If no next section found, insert before the end
    return len(content)

def patch_runbook(runbook_path, services_dict):
    """Patch a single runbook to add automation hooks section"""
    with open(runbook_path, 'r') as f:
        content = f.read()
    
    # Check if section already exists
    if '## Runme & Cursor Automation Hooks' in content:
        print(f"  ⏭️  Skipping {runbook_path.name} (already has automation hooks section)")
        return False
    
    # Extract service info from runbook
    runbook_info = extract_service_info_from_runbook(content)
    service_id = runbook_info.get('id')
    
    # Get service info from SERVICES.yml if available
    if service_id and service_id in services_dict:
        service_info = services_dict[service_id]
    else:
        # Use extracted info, fill in defaults
        service_info = {
            'id': runbook_info.get('id', 'unknown'),
            'name': runbook_info.get('name', 'Service'),
            'dir': runbook_info.get('dir', 'unknown'),
            'domain': runbook_info.get('domain', 'N/A'),
        }
    
    # Find insertion point
    insert_pos = find_insertion_point(content)
    if insert_pos is None:
        print(f"  ⚠️  Could not find insertion point in {runbook_path.name}")
        return False
    
    # Format automation hooks section
    hooks_section = AUTOMATION_HOOKS_SECTION.format(
        service_id=service_info['id'],
        service_name=service_info['name'],
        service_dir=service_info['dir'],
        primary_domain=service_info['domain']
    )
    
    # Insert the section
    new_content = content[:insert_pos] + hooks_section + content[insert_pos:]
    
    # Write back
    with open(runbook_path, 'w') as f:
        f.write(new_content)
    
    print(f"  ✓ Patched {runbook_path.name}")
    return True

def main():
    """Patch all existing runbooks"""
    services_dict = get_service_info()
    
    # Get all runbook files (excluding template and special files)
    runbook_files = [
        f for f in RUNBOOKS_DIR.glob("*-runbook.md")
        if f.name != "TEMPLATE_SERVICE_RUNBOOK.md"
    ]
    
    print(f"Patching {len(runbook_files)} runbooks...")
    
    patched_count = 0
    for runbook_file in sorted(runbook_files):
        if patch_runbook(runbook_file, services_dict):
            patched_count += 1
    
    print(f"\n✓ Patched {patched_count} runbooks")
    print(f"⏭️  Skipped {len(runbook_files) - patched_count} runbooks (already have section)")

if __name__ == '__main__':
    main()

