#!/usr/bin/env python3
"""
DNS Records Audit Script for freqkflag.co
Audits expected DNS records against infrastructure configuration
"""

import os
import sys
import yaml
from pathlib import Path
from typing import Dict, List, Set

INFRA_ROOT = Path("/root/infra")
SERVER_IP = "62.72.26.113"  # From hostname -I

def load_services_yml() -> List[Dict]:
    """Load SERVICES.yml"""
    services_file = INFRA_ROOT / "SERVICES.yml"
    if not services_file.exists():
        return []
    with services_file.open() as f:
        return yaml.safe_load(f).get('services', [])

def extract_traefik_domains() -> Set[str]:
    """Extract all domains from Traefik labels in compose files"""
    domains = set()
    
    # Search for Host(`...`) patterns in compose files
    compose_files = list(INFRA_ROOT.rglob("docker-compose.yml")) + \
                   list(INFRA_ROOT.rglob("compose.yml"))
    
    for compose_file in compose_files:
        try:
            with compose_file.open() as f:
                content = f.read()
                # Find all Host(`domain`) patterns
                import re
                pattern = r"Host\(`([^`]+)`\)"
                matches = re.findall(pattern, content)
                for match in matches:
                    # Skip variable substitutions like ${VAR:-default}
                    if '${' in match or '$' in match:
                        # Try to extract default value
                        default_match = re.search(r':-([^}]+)', match)
                        if default_match:
                            match = default_match.group(1)
                        else:
                            continue
                    if 'freqkflag.co' in match:
                        domains.add(match)
        except Exception as e:
            continue
    
    return domains

def get_expected_domains() -> Dict[str, Dict]:
    """Get expected DNS records from SERVICES.yml and Traefik configs"""
    expected = {}
    
    # From SERVICES.yml
    services = load_services_yml()
    for service in services:
        # Single domain
        if 'domain' in service and service['domain'] and 'freqkflag.co' in service['domain']:
            expected[service['domain']] = {
                'type': 'A',
                'service': service.get('name', service.get('id')),
                'source': 'SERVICES.yml'
            }
        
        # Multiple domains
        if 'domains' in service:
            for domain in service['domains']:
                if 'freqkflag.co' in domain:
                    expected[domain] = {
                        'type': 'A',
                        'service': service.get('name', service.get('id')),
                        'source': 'SERVICES.yml'
                    }
    
    # From Traefik labels
    traefik_domains = extract_traefik_domains()
    for domain in traefik_domains:
        if domain not in expected:
            expected[domain] = {
                'type': 'A',
                'service': 'Traefik label',
                'source': 'docker-compose.yml'
            }
    
    # Add root domain
    expected['freqkflag.co'] = {
        'type': 'A',
        'service': 'Root domain',
        'source': 'Infrastructure'
    }
    
    # Add explicit domains from AGENTS.md
    explicit_domains = {
        'backstage.freqkflag.co': {
            'type': 'A',
            'service': 'Backstage',
            'source': 'AGENTS.md'
        },
        'traefik.freqkflag.co': {
            'type': 'A',
            'service': 'Traefik Dashboard',
            'source': 'env template'
        }
    }
    
    for domain, info in explicit_domains.items():
        if domain not in expected:
            expected[domain] = info
    
    return expected

def generate_report():
    """Generate DNS audit report"""
    expected = get_expected_domains()
    
    print("=" * 80)
    print("DNS Records Audit Report for freqkflag.co")
    print("=" * 80)
    print(f"\nServer IP: {SERVER_IP}")
    print(f"\nExpected DNS Records ({len(expected)}):")
    print("-" * 80)
    
    # Sort by domain
    sorted_domains = sorted(expected.items())
    
    for domain, info in sorted_domains:
        print(f"{domain:40} {info['type']:6} -> {SERVER_IP:15} ({info['service']})")
    
    print("\n" + "=" * 80)
    print("Summary:")
    print(f"  Total expected records: {len(expected)}")
    print(f"  Target IP: {SERVER_IP}")
    print(f"  All records should be A records pointing to {SERVER_IP}")
    print("  Records can be proxied (orange cloud) or DNS-only (grey cloud)")
    print("=" * 80)
    
    # Generate update commands
    print("\n" + "=" * 80)
    print("Cloudflare DNS Update Commands:")
    print("=" * 80)
    print("\n# Using cloudflare-dns-manager.py:")
    print(f"export CLOUDFLARE_API_TOKEN='<your-token>'")
    print()
    
    print("# Note: For A records pointing to IP addresses, use Cloudflare API or dashboard")
    print("# The cloudflare-dns-manager.py script uses CNAME which is for domain targets")
    print("# For IP addresses, create A records directly")
    print()
    print("# Example using curl (requires CF_API_TOKEN and zone ID):")
    print("# curl -X POST \"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records\" \\")
    print("#   -H \"Authorization: Bearer $CF_API_TOKEN\" \\")
    print("#   -H \"Content-Type: application/json\" \\")
    print("#   --data '{\"type\":\"A\",\"name\":\"subdomain\",\"content\":\"" + SERVER_IP + "\",\"ttl\":3600,\"proxied\":true}'")
    print()
    
    for domain, info in sorted_domains:
        if domain == 'freqkflag.co':
            # Root domain
            print(f"# Root domain: {domain} -> {SERVER_IP} (A record)")
        else:
            subdomain = domain.replace('.freqkflag.co', '')
            # Handle nested subdomains like api.supabase
            if '.' in subdomain:
                print(f"# Nested subdomain: {domain} -> {SERVER_IP} (A record)")
            else:
                print(f"# {domain} -> {SERVER_IP} (A record, subdomain: {subdomain})")
        print()
    
    print("=" * 80)
    print("\nNote: For A records, use Cloudflare dashboard or API directly.")
    print("CNAME records can be used for subdomains pointing to root domain.")

if __name__ == '__main__':
    generate_report()

