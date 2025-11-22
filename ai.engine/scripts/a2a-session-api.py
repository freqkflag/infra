#!/usr/bin/env python3
#
# A2A Session Management API Server
# HTTP API wrapper for a2a-session.sh
#
# Usage:
#   python3 a2a-session-api.py
#   Listens on http://0.0.0.0:8082
#

import json
import subprocess
import sys
from flask import Flask, request, jsonify
from pathlib import Path

app = Flask(__name__)

SCRIPT_DIR = Path(__file__).parent
A2A_SESSION_SCRIPT = SCRIPT_DIR / "a2a-session.sh"

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "healthy", "service": "a2a-session-api"})

@app.route('/api/v1/sessions/create', methods=['POST'])
def create_session():
    """Create a new A2A session"""
    try:
        data = request.get_json() or {}
        task_id = data.get('task_id', f'task-{int(__import__("time").time())}')
        task_metadata = json.dumps(data.get('task_metadata', {
            'type': data.get('task_type', 'single-agent'),
            'priority': data.get('priority', 'normal'),
            'timeout': data.get('timeout', 3600),
            'agents': data.get('agents', [])
        }))
        
        # Call a2a-session.sh create
        result = subprocess.run(
            [str(A2A_SESSION_SCRIPT), 'create', task_id, task_metadata],
            capture_output=True,
            text=True,
            check=True
        )
        
        session_id = result.stdout.strip()
        
        return jsonify({
            "status": "success",
            "session_id": session_id,
            "task_id": task_id
        })
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
        result = subprocess.run(
            [str(A2A_SESSION_SCRIPT), 'get', session_id],
            capture_output=True,
            text=True,
            check=True
        )
        
        session_data = json.loads(result.stdout)
        return jsonify({
            "status": "success",
            "session": session_data
        })
    except subprocess.CalledProcessError as e:
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
        
        # Call a2a-session.sh update
        cmd = [str(A2A_SESSION_SCRIPT), 'update', session_id, agent_id, status]
        if output_file:
            cmd.append(output_file)
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True
        )
        
        return jsonify({
            "status": "success",
            "message": result.stdout.strip(),
            "session_id": session_id,
            "agent_id": agent_id
        })
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

@app.route('/api/v1/sessions/<session_id>', methods=['DELETE'])
def delete_session(session_id):
    """Delete a session"""
    try:
        result = subprocess.run(
            [str(A2A_SESSION_SCRIPT), 'delete', session_id],
            capture_output=True,
            text=True,
            check=True
        )
        
        return jsonify({
            "status": "success",
            "message": result.stdout.strip()
        })
    except subprocess.CalledProcessError:
        return jsonify({
            "status": "error",
            "message": "Session not found"
        }), 404
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

if __name__ == '__main__':
    # Check if script exists
    if not A2A_SESSION_SCRIPT.exists():
        print(f"Error: a2a-session.sh not found at {A2A_SESSION_SCRIPT}", file=sys.stderr)
        sys.exit(1)
    
    # Make script executable
    A2A_SESSION_SCRIPT.chmod(0o755)
    
    print(f"A2A Session API Server starting on http://0.0.0.0:8082")
    print(f"Using script: {A2A_SESSION_SCRIPT}")
    app.run(host='0.0.0.0', port=8082, debug=False)

