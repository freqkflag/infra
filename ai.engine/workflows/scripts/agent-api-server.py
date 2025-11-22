#!/usr/bin/env python3
"""
Simple API server for executing AI Engine agent scripts
Called by n8n workflows to trigger agents
"""
from flask import Flask, request, jsonify
import subprocess
import json
import os
from datetime import datetime

app = Flask(__name__)

AGENT_SCRIPT = "/root/infra/ai.engine/workflows/scripts/trigger-agent.sh"
ORCHESTRATION_DIR = "/root/infra/orchestration"

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "service": "agent-api-server"}), 200

@app.route('/api/v1/agents/invoke', methods=['POST'])
def invoke_agent():
    """Invoke an AI Engine agent script"""
    try:
        data = request.json or {}
        agent = data.get('agent')
        output_file = data.get('output_file')
        trigger = data.get('trigger', 'webhook')
        
        if not agent:
            return jsonify({
                'status': 'error',
                'message': 'agent parameter is required'
            }), 400
        
        # Generate output file if not provided
        if not output_file:
            timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
            output_file = f"{ORCHESTRATION_DIR}/{agent}-{timestamp}.json"
        
        # Ensure orchestration directory exists
        os.makedirs(ORCHESTRATION_DIR, exist_ok=True)
        
        # Execute agent script
        script_args = [AGENT_SCRIPT, agent, output_file, trigger]
        
        result = subprocess.run(
            script_args,
            capture_output=True,
            text=True,
            timeout=300,
            cwd="/root/infra"
        )
        
        response = {
            'status': 'success' if result.returncode == 0 else 'error',
            'agent': agent,
            'output_file': output_file,
            'trigger': trigger,
            'returncode': result.returncode,
            'stdout': result.stdout,
            'stderr': result.stderr
        }
        
        status_code = 200 if result.returncode == 0 else 500
        return jsonify(response), status_code
        
    except subprocess.TimeoutExpired:
        return jsonify({
            'status': 'error',
            'message': 'Agent execution timeout (exceeded 300 seconds)'
        }), 500
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/v1/agents/list', methods=['GET'])
def list_agents():
    """List available agents"""
    agents = [
        'status', 'bug-hunter', 'performance', 'security', 'architecture',
        'docs', 'tests', 'refactor', 'release', 'development', 'ops',
        'backstage', 'mcp', 'orchestrator'
    ]
    return jsonify({'agents': agents}), 200

if __name__ == '__main__':
    # Run on all interfaces, port 8081
    # Accessible from Docker containers via host.docker.internal:8081
    app.run(host='0.0.0.0', port=8081, debug=False)

