const express = require('express');
const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const { exec } = require('child_process');
const { promisify } = require('util');
const Docker = require('dockerode');

const execAsync = promisify(exec);
const app = express();
const PORT = 3000;

const INFRA_DIR = '/root/infra';
const SERVICES_FILE = path.join(INFRA_DIR, 'SERVICES.yml');

// Docker client
const docker = new Docker({ socketPath: '/var/run/docker.sock' });

// Basic Auth - Read from environment or use defaults
const AUTH_USER = process.env.OPS_AUTH_USER || 'admin';
const AUTH_PASS = process.env.OPS_AUTH_PASS || 'changeme';

// Basic Auth middleware (skip for health endpoint)
function basicAuth(req, res, next) {
  if (req.path === '/health') {
    return next();
  }
  
  const auth = req.headers.authorization;
  if (!auth || !auth.startsWith('Basic ')) {
    res.setHeader('WWW-Authenticate', 'Basic realm="Infrastructure Control Plane"');
    return res.status(401).send('Authentication required');
  }
  
  const credentials = Buffer.from(auth.substring(6), 'base64').toString('utf8');
  const [username, password] = credentials.split(':');
  
  if (username === AUTH_USER && password === AUTH_PASS) {
    return next();
  }
  
  res.setHeader('WWW-Authenticate', 'Basic realm="Infrastructure Control Plane"');
  res.status(401).send('Authentication failed');
}

app.use(basicAuth);

// Middleware
app.use(express.json());
app.use(express.static('public'));

// Helper: Read SERVICES.yml
function getServices() {
  try {
    const content = fs.readFileSync(SERVICES_FILE, 'utf8');
    return yaml.load(content);
  } catch (error) {
    console.error('Error reading SERVICES.yml:', error);
    return { services: [] };
  }
}

// Helper: Get Docker container status
async function getContainerStatus(serviceId) {
  try {
    const containers = await docker.listContainers({ all: true });
    const serviceDir = path.join(INFRA_DIR, serviceId);
    
    // Try to find containers by service directory or name
    const matching = containers.filter(container => {
      const labels = container.Labels || {};
      const name = container.Names?.[0]?.replace('/', '') || '';
      
      // Check if container name matches service
      if (name.includes(serviceId)) return true;
      
      // Check compose project
      const project = labels['com.docker.compose.project'] || '';
      if (project === serviceId) return true;
      
      return false;
    });
    
    if (matching.length === 0) return 'stopped';
    
    const running = matching.filter(c => c.State === 'running');
    if (running.length === matching.length) return 'running';
    if (running.length > 0) return 'partial';
    return 'stopped';
  } catch (error) {
    console.error(`Error checking status for ${serviceId}:`, error);
    return 'unknown';
  }
}

// API: Get all services with status
app.get('/api/services', async (req, res) => {
  try {
    const data = getServices();
    const services = data.services || [];
    
    // Enrich with Docker status
    const servicesWithStatus = await Promise.all(
      services.map(async (service) => {
        const status = await getContainerStatus(service.id);
        return {
          ...service,
          dockerStatus: status,
          displayStatus: status === 'running' ? 'running' : 
                        status === 'partial' ? 'partial' : 
                        status === 'stopped' ? 'stopped' : 'unknown'
        };
      })
    );
    
    res.json({ services: servicesWithStatus });
  } catch (error) {
    console.error('Error getting services:', error);
    res.status(500).json({ error: error.message });
  }
});

// API: Service action (start/stop/restart)
app.post('/api/services/:id/:action', async (req, res) => {
  const { id, action } = req.params;
  
  if (!['start', 'stop', 'restart'].includes(action)) {
    return res.status(400).json({ error: 'Invalid action' });
  }
  
  try {
    const scriptPath = path.join(INFRA_DIR, 'scripts', 'infra-service.sh');
    const { stdout, stderr } = await execAsync(
      `bash ${scriptPath} ${action} ${id}`
    );
    
    res.json({ 
      success: true, 
      message: `${action} command executed`,
      output: stdout,
      error: stderr || null
    });
  } catch (error) {
    console.error(`Error executing ${action} for ${id}:`, error);
    res.status(500).json({ 
      success: false,
      error: error.message,
      stderr: error.stderr || ''
    });
  }
});

// API: Get service status
app.get('/api/services/:id/status', async (req, res) => {
  const { id } = req.params;
  
  try {
    const status = await getContainerStatus(id);
    res.json({ serviceId: id, status });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Ops Control Plane running on port ${PORT}`);
});

