#!/usr/bin/env python3
"""
Generate runbooks for all services based on template and existing READMEs
"""

import yaml
import os
import re
from pathlib import Path

INFRA_ROOT = Path("/root/infra")
TEMPLATE = INFRA_ROOT / "runbooks" / "TEMPLATE_SERVICE_RUNBOOK.md"
SERVICES_YML = INFRA_ROOT / "SERVICES.yml"
RUNBOOKS_DIR = INFRA_ROOT / "runbooks"

def read_template():
    """Read the runbook template"""
    with open(TEMPLATE, 'r') as f:
        return f.read()

def get_service_info():
    """Get all services from SERVICES.yml"""
    with open(SERVICES_YML, 'r') as f:
        data = yaml.safe_load(f)
    
    services = []
    for service in data.get('services', []):
        service_id = service.get('id')
        service_dir = service.get('dir')
        
        if not service_dir or service_dir == 'null' or service.get('status') == 'deprecated':
            continue
        
        if service_dir.startswith('/'):
            service_path = Path(service_dir)
            rel_dir = service_dir.replace('/root/infra/', '')
        else:
            service_path = INFRA_ROOT / service_dir
            rel_dir = service_dir
        
        if service_path.exists():
            services.append({
                'id': service_id,
                'name': service.get('name'),
                'dir': rel_dir,
                'path': service_path,
                'url': service.get('url'),
                'domain': service.get('domain') or (service.get('domains', [None])[0] if service.get('domains') else None),
                'status': service.get('status', 'configured'),
                'type': service.get('type'),
                'description': service.get('description', ''),
                'depends_on': service.get('depends_on', [])
            })
    
    return services

def read_existing_readme(service_path):
    """Read existing README.md if it exists"""
    readme_path = service_path / "README.md"
    if readme_path.exists():
        with open(readme_path, 'r') as f:
            return f.read()
    return None

def generate_runbook(service, template):
    """Generate a runbook for a service"""
    runbook = template
    
    # Replace placeholders
    replacements = {
        '[Service Name]': service['name'],
        '[service-id]': service['id'],
        '[running|configured|deprecated]': service['status'],
        '[date]': '2025-11-21',
        '[Brief description...]': service['description'],
        '[primary-domain]': service['domain'] or 'N/A',
        '[service-urls]': service['url'] or 'N/A',
        '[service-dir]': service['dir'],
        '[service-name]': service['id'],
        '[container-name]': service['id'],
        '[networks]': 'traefik-network (external)',
        '[volumes]': 'Service-specific data volumes',
        '[ports]': 'Via Traefik (HTTPS)',
        '[Dependency 1]': ', '.join(service['depends_on']) if service['depends_on'] else 'None',
        '[why needed]': 'Required for service operation',
    }
    
    for placeholder, value in replacements.items():
        runbook = runbook.replace(placeholder, str(value))
    
    # Read existing README for additional context
    existing_readme = read_existing_readme(service['path'])
    if existing_readme:
        # Extract useful sections from existing README
        # This is a simplified version - could be enhanced
        pass
    
    return runbook

def main():
    """Generate runbooks for all services"""
    template = read_template()
    services = get_service_info()
    
    print(f"Generating runbooks for {len(services)} services...")
    
    for service in services:
        runbook_file = RUNBOOKS_DIR / f"{service['id']}-runbook.md"
        
        # Skip if already exists (to preserve manual edits)
        if runbook_file.exists():
            print(f"  ⏭️  Skipping {service['id']} (already exists)")
            continue
        
        runbook = generate_runbook(service, template)
        
        with open(runbook_file, 'w') as f:
            f.write(runbook)
        
        print(f"  ✓ Generated {service['id']}-runbook.md")
    
    print(f"\n✓ Generated {len(services)} runbooks")

if __name__ == '__main__':
    main()

