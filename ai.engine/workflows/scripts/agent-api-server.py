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
from pathlib import Path

app = Flask(__name__)

AGENT_SCRIPT = "/root/infra/ai.engine/workflows/scripts/trigger-agent.sh"
ORCHESTRATION_DIR = "/root/infra/orchestration"
A2A_SESSION_SCRIPT = Path("/root/infra/ai.engine/scripts/a2a-session.sh")

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

# A2A Session Management Endpoints

@app.route('/api/v1/sessions/create', methods=['POST'])
def create_session():
    """Create a new A2A session"""
    try:
        data = request.get_json() or {}
        task_id = data.get('task_id', f'task-{int(datetime.now().timestamp())}')
        task_metadata = json.dumps(data.get('task_metadata', {
            'type': data.get('task_type', 'single-agent'),
            'priority': data.get('priority', 'normal'),
            'timeout': data.get('timeout', 3600),
            'agents': data.get('agents', [])
        }))
        
        if not A2A_SESSION_SCRIPT.exists():
            # Fallback: generate session ID client-side
            timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
            import random
            random_str = ''.join(random.choices('abcdef0123456789', k=8))
            session_id = f'a2a-{timestamp}-{random_str}'
            return jsonify({
                "status": "success",
                "session_id": session_id,
                "task_id": task_id,
                "note": "a2a-session.sh not found, using client-side generation"
            })
        
        # Call a2a-session.sh create
        result = subprocess.run(
            [str(A2A_SESSION_SCRIPT), 'create', task_id, task_metadata],
            capture_output=True,
            text=True,
            check=True,
            timeout=10
        )
        
        session_id = result.stdout.strip()
        
        return jsonify({
            "status": "success",
            "session_id": session_id,
            "task_id": task_id
        })
    except subprocess.TimeoutExpired:
        return jsonify({
            "status": "error",
            "message": "Session creation timeout"
        }), 500
    except subprocess.CalledProcessError as e:
        return jsonify({
            "status": "error",
            "message": f"Failed to create session: {e.stderr}"
        }), 500
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route('/api/v1/sessions/<session_id>', methods=['GET'])
def get_session(session_id):
    """Get session data"""
    try:
        if not A2A_SESSION_SCRIPT.exists():
            return jsonify({
                "status": "error",
                "message": "a2a-session.sh not found"
            }), 503
        
        result = subprocess.run(
            [str(A2A_SESSION_SCRIPT), 'get', session_id],
            capture_output=True,
            text=True,
            check=True,
            timeout=10
        )
        
        session_data = json.loads(result.stdout)
        return jsonify({
            "status": "success",
            "session": session_data
        })
    except subprocess.CalledProcessError:
        return jsonify({
            "status": "error",
            "message": f"Session not found: {session_id}"
        }), 404
    except json.JSONDecodeError:
        return jsonify({
            "status": "error",
            "message": "Invalid session data"
        }), 500
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route('/api/v1/sessions/<session_id>/update', methods=['POST'])
def update_session(session_id):
    """Update session with agent result"""
    try:
        data = request.get_json() or {}
        agent_id = data.get('agent_id')
        status = data.get('status', 'completed')
        output_file = data.get('output_file', '')
        
        if not agent_id:
            return jsonify({
                "status": "error",
                "message": "agent_id required"
            }), 400
        
        if not A2A_SESSION_SCRIPT.exists():
            return jsonify({
                "status": "success",
                "message": "Session update logged (a2a-session.sh not available)",
                "session_id": session_id,
                "agent_id": agent_id
            })
        
        # Call a2a-session.sh update
        cmd = [str(A2A_SESSION_SCRIPT), 'update', session_id, agent_id, status]
        if output_file:
            cmd.append(output_file)
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True,
            timeout=10
        )
        
        return jsonify({
            "status": "success",
            "message": result.stdout.strip(),
            "session_id": session_id,
            "agent_id": agent_id
        })
    except subprocess.TimeoutExpired:
        return jsonify({
            "status": "error",
            "message": "Session update timeout"
        }), 500
    except subprocess.CalledProcessError as e:
        return jsonify({
            "status": "error",
            "message": f"Failed to update session: {e.stderr}"
        }), 500
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

if __name__ == '__main__':
    # Run on all interfaces, port 8081
    # Accessible from Docker containers via host.docker.internal:8081
    # Includes both agent invocation and A2A session management
    app.run(host='0.0.0.0', port=8081, debug=False)

