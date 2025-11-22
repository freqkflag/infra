#!/usr/bin/env python3
"""
Cloudflare DNS Manager
Manages DNS records across multiple Cloudflare zones via API
"""

import os
import sys
import json
import requests
from typing import Dict, List, Optional

class CloudflareDNSManager:
    def __init__(self, api_token: Optional[str] = None, api_key: Optional[str] = None, email: Optional[str] = None):
        """Initialize Cloudflare API client"""
        self.api_token = api_token or os.getenv('CLOUDFLARE_API_TOKEN')
        self.api_key = api_key or os.getenv('CLOUDFLARE_API_KEY')
        self.email = email or os.getenv('CLOUDFLARE_EMAIL')
        
        if not self.api_token and not (self.api_key and self.email):
            raise ValueError("Need either CLOUDFLARE_API_TOKEN or (CLOUDFLARE_API_KEY + CLOUDFLARE_EMAIL)")
        
        self.base_url = "https://api.cloudflare.com/client/v4"
        self.headers = {}
        
        if self.api_token:
            self.headers["Authorization"] = f"Bearer {self.api_token}"
        else:
            self.headers["X-Auth-Key"] = self.api_key
            self.headers["X-Auth-Email"] = self.email
    
    def _request(self, method: str, endpoint: str, data: Optional[Dict] = None) -> Dict:
        """Make API request"""
        url = f"{self.base_url}/{endpoint}"
        response = requests.request(method, url, headers=self.headers, json=data)
        response.raise_for_status()
        result = response.json()
        
        if not result.get('success'):
            raise Exception(f"API Error: {result.get('errors', [])}")
        
        return result
    
    def get_zones(self) -> List[Dict]:
        """Get all zones"""
        result = self._request('GET', 'zones')
        return result.get('result', [])
    
    def get_zone_by_name(self, zone_name: str) -> Optional[Dict]:
        """Get zone by domain name"""
        zones = self.get_zones()
        for zone in zones:
            if zone['name'] == zone_name:
                return zone
        return None
    
    def get_dns_records(self, zone_id: str, record_type: Optional[str] = None, name: Optional[str] = None) -> List[Dict]:
        """Get DNS records for a zone"""
        params = {}
        if record_type:
            params['type'] = record_type
        if name:
            params['name'] = name
        
        endpoint = f"zones/{zone_id}/dns_records"
        if params:
            endpoint += "?" + "&".join([f"{k}={v}" for k, v in params.items()])
        
        result = self._request('GET', endpoint)
        return result.get('result', [])
    
    def create_dns_record(self, zone_id: str, record_type: str, name: str, content: str, ttl: int = 3600, proxied: bool = True) -> Dict:
        """Create a DNS record"""
        data = {
            'type': record_type,
            'name': name,
            'content': content,
            'ttl': ttl,
        }
        # Only set proxied for A, AAAA, and CNAME records
        if record_type in ['A', 'AAAA', 'CNAME']:
            data['proxied'] = proxied
        
        result = self._request('POST', f"zones/{zone_id}/dns_records", data)
        return result.get('result', {})
    
    def update_dns_record(self, zone_id: str, record_id: str, record_type: str, name: str, content: str, ttl: int = 3600, proxied: bool = True) -> Dict:
        """Update a DNS record"""
        data = {
            'type': record_type,
            'name': name,
            'content': content,
            'ttl': ttl,
        }
        # Only set proxied for A, AAAA, and CNAME records
        if record_type in ['A', 'AAAA', 'CNAME']:
            data['proxied'] = proxied
        
        result = self._request('PUT', f"zones/{zone_id}/dns_records/{record_id}", data)
        return result.get('result', {})
    
    def delete_dns_record(self, zone_id: str, record_id: str) -> bool:
        """Delete a DNS record"""
        result = self._request('DELETE', f"zones/{zone_id}/dns_records/{record_id}")
        return result.get('success', False)
    
    def upsert_cname(self, zone_name: str, subdomain: str, target: str, proxied: bool = True) -> Dict:
        """Create or update a CNAME record"""
        zone = self.get_zone_by_name(zone_name)
        if not zone:
            raise ValueError(f"Zone not found: {zone_name}")
        
        zone_id = zone['id']
        record_name = f"{subdomain}.{zone_name}" if subdomain else zone_name
        
        # Check if record exists
        records = self.get_dns_records(zone_id, 'CNAME', record_name)
        
        if records:
            # Update existing
            record = records[0]
            return self.update_dns_record(zone_id, record['id'], 'CNAME', record_name, target, proxied=proxied)
        else:
            # Create new
            return self.create_dns_record(zone_id, 'CNAME', record_name, target, proxied=proxied)
    
    def upsert_a_record(self, zone_name: str, subdomain: str, ip_address: str, proxied: bool = True) -> Dict:
        """Create or update an A record"""
        zone = self.get_zone_by_name(zone_name)
        if not zone:
            raise ValueError(f"Zone not found: {zone_name}")
        
        zone_id = zone['id']
        record_name = f"{subdomain}.{zone_name}" if subdomain else zone_name
        
        # Check if record exists (A or CNAME)
        records = self.get_dns_records(zone_id, name=record_name)
        a_records = [r for r in records if r['type'] == 'A']
        
        if a_records:
            # Update existing A record
            record = a_records[0]
            return self.update_dns_record(zone_id, record['id'], 'A', record_name, ip_address, proxied=proxied)
        else:
            # Create new A record
            return self.create_dns_record(zone_id, 'A', record_name, ip_address, proxied=proxied)

def main():
    """CLI interface"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Cloudflare DNS Manager')
    parser.add_argument('action', choices=['list-zones', 'list-records', 'create-cname', 'update-cname', 'upsert-cname', 'upsert-a'], help='Action to perform')
    parser.add_argument('--zone', help='Zone name (domain)')
    parser.add_argument('--subdomain', help='Subdomain (e.g., "infisical" for infisical.example.com, or "" for root)')
    parser.add_argument('--target', help='Target for CNAME record')
    parser.add_argument('--ip', help='IP address for A record')
    parser.add_argument('--proxied', action='store_true', default=True, help='Enable Cloudflare proxy')
    parser.add_argument('--no-proxied', dest='proxied', action='store_false', help='Disable Cloudflare proxy')
    
    args = parser.parse_args()
    
    try:
        manager = CloudflareDNSManager()
        
        if args.action == 'list-zones':
            zones = manager.get_zones()
            print(f"Found {len(zones)} zones:")
            for zone in zones:
                print(f"  - {zone['name']} (ID: {zone['id']})")
        
        elif args.action == 'list-records':
            if not args.zone:
                print("Error: --zone required")
                sys.exit(1)
            zone = manager.get_zone_by_name(args.zone)
            if not zone:
                print(f"Error: Zone not found: {args.zone}")
                sys.exit(1)
            records = manager.get_dns_records(zone['id'])
            print(f"DNS records for {args.zone}:")
            for record in records:
                print(f"  {record['type']:6} {record['name']:40} -> {record['content']}")
        
        elif args.action in ['create-cname', 'update-cname', 'upsert-cname']:
            if not all([args.zone, args.subdomain, args.target]):
                print("Error: --zone, --subdomain, and --target required")
                sys.exit(1)
            result = manager.upsert_cname(args.zone, args.subdomain, args.target, proxied=args.proxied)
            print(f"✓ {'Updated' if 'id' in result else 'Created'} CNAME: {args.subdomain}.{args.zone} -> {args.target}")
        
        elif args.action == 'upsert-a':
            if not all([args.zone, args.ip]):
                print("Error: --zone and --ip required")
                sys.exit(1)
            subdomain = args.subdomain if args.subdomain else ""
            result = manager.upsert_a_record(args.zone, subdomain, args.ip, proxied=args.proxied)
            record_name = f"{subdomain}.{args.zone}" if subdomain else args.zone
            print(f"✓ {'Updated' if 'id' in result else 'Created'} A: {record_name} -> {args.ip}")
        
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()

