const express = require('express');
const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const { exec, spawn } = require('child_process');
const { promisify } = require('util');
const Docker = require('dockerode');
const { v4: uuidv4 } = require('uuid');

const execAsync = promisify(exec);
const app = express();
const PORT = 3000;

const INFRA_DIR = '/root/infra';
const SERVICES_FILE = path.join(INFRA_DIR, 'SERVICES.yml');
const AI_ENGINE_DIR = path.join(INFRA_DIR, 'ai.engine');
const ORCHESTRATION_DIR = path.join(INFRA_DIR, 'orchestration');

// Docker client
const docker = new Docker({ socketPath: '/var/run/docker.sock' });

// Authentication Configuration
const AUTH_USER = process.env.OPS_AUTH_USER || 'admin';
const AUTH_PASS = process.env.OPS_AUTH_PASS || 'changeme';
const OAUTH_ENABLED = process.env.OPS_OAUTH_ENABLED === 'true';
const OAUTH_PROVIDER = process.env.OPS_OAUTH_PROVIDER || 'github';
const SESSION_SECRET = process.env.OPS_SESSION_SECRET || 'change-this-secret-in-production-' + Date.now();

// OAuth Passport (optional - only if enabled)
let passport = null;
let session = null;
if (OAUTH_ENABLED) {
  try {
    session = require('express-session');
    passport = require('passport');
    const GitHubStrategy = require('passport-github2').Strategy;
    
    passport.use(new GitHubStrategy({
      clientID: process.env.OPS_OAUTH_CLIENT_ID,
      clientSecret: process.env.OPS_OAUTH_CLIENT_SECRET,
      callbackURL: process.env.OPS_OAUTH_CALLBACK_URL || 'https://ops.freqkflag.co/auth/callback'
    }, (accessToken, refreshToken, profile, done) => {
      // Store user in session
      return done(null, profile);
    }));
    
    passport.serializeUser((user, done) => done(null, user));
    passport.deserializeUser((user, done) => done(null, user));
    
    console.log('OAuth authentication enabled with', OAUTH_PROVIDER);
  } catch (error) {
    console.warn('OAuth packages not installed, falling back to Basic Auth:', error.message);
  }
}

// Task storage (in-memory, could be persisted to file)
const tasks = new Map();
const agentChats = new Map();
const agentChatHistory = [];

// Ensure orchestration directory exists
if (!fs.existsSync(ORCHESTRATION_DIR)) {
  fs.mkdirSync(ORCHESTRATION_DIR, { recursive: true });
}

// Authentication middleware - supports both Basic Auth and OAuth
function authenticate(req, res, next) {
  // Skip auth for health endpoint and SSE
  if (req.path === '/health' || req.path.startsWith('/api/chat/sse')) {
    return next();
  }
  
  // OAuth routes (if enabled)
  if (OAUTH_ENABLED && passport) {
    if (req.path === '/auth/github' || req.path === '/auth/callback' || req.path === '/auth/logout') {
      return next();
    }
    // Check if user is authenticated via OAuth
    if (req.isAuthenticated && req.isAuthenticated()) {
      return next();
    }
  }
  
  // Basic Auth fallback
  const auth = req.headers.authorization;
  if (!auth || !auth.startsWith('Basic ')) {
    if (OAUTH_ENABLED && passport) {
      // Redirect to OAuth login if enabled
      if (!req.path.startsWith('/api/')) {
        return res.redirect('/auth/github');
      }
    }
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

// Middleware (must be before authentication and OAuth routes)
app.use(express.json());
app.use(express.static('public'));

// Session middleware (if OAuth enabled) - must be before passport
if (OAUTH_ENABLED && session) {
  app.use(session({
    secret: SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: { secure: true, httpOnly: true, maxAge: 24 * 60 * 60 * 1000 } // 24 hours
  }));
  app.use(passport.initialize());
  app.use(passport.session());
}

// OAuth routes (if enabled) - must be before authenticate middleware
if (OAUTH_ENABLED && passport) {
  app.get('/auth/github', passport.authenticate('github', { scope: ['user:email'] }));
  app.get('/auth/callback', passport.authenticate('github', { failureRedirect: '/' }), (req, res) => {
    res.redirect('/');
  });
  app.get('/auth/logout', (req, res) => {
    if (req.logout) {
      req.logout((err) => {
        if (err) {
          console.error('Logout error:', err);
        }
        res.redirect('/');
      });
    } else {
      res.redirect('/');
    }
  });
}

// Apply authentication middleware (after OAuth routes and session setup)
app.use(authenticate);

// CORS for SSE
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  next();
});

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
    
    const matching = containers.filter(container => {
      const labels = container.Labels || {};
      const name = container.Names?.[0]?.replace('/', '') || '';
      
      if (name.includes(serviceId)) return true;
      
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

// Helper: List available agents
function getAvailableAgents() {
  const agentsDir = path.join(AI_ENGINE_DIR, 'agents');
  const agents = [];
  
  try {
    const files = fs.readdirSync(agentsDir);
    files.forEach(file => {
      if (file.endsWith('-agent.md') && file !== 'orchestrator-agent.md') {
        const agentName = file.replace('-agent.md', '');
        agents.push({
          id: agentName,
          name: agentName.replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase()),
          file: path.join(agentsDir, file)
        });
      }
    });
  } catch (error) {
    console.error('Error reading agents:', error);
  }
  
  return agents;
}

// Helper: Create task
function createTask(type, description, agent = null) {
  const task = {
    id: uuidv4(),
    type,
    description,
    agent,
    status: 'pending',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    result: null,
    error: null
  };
  
  tasks.set(task.id, task);
  return task;
}

// Helper: Update task
function updateTask(taskId, updates) {
  const task = tasks.get(taskId);
  if (task) {
    Object.assign(task, updates);
    task.updated_at = new Date().toISOString();
    tasks.set(taskId, task);
  }
  return task;
}

// ============================================
// EXISTING API ENDPOINTS
// ============================================

// API: Get all services with status
app.get('/api/services', async (req, res) => {
  try {
    const data = getServices();
    const services = data.services || [];
    
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

// ============================================
// NEW AGENT COMMUNICATION API ENDPOINTS
// ============================================

// API: List available agents
app.get('/api/agents', (req, res) => {
  try {
    const agents = getAvailableAgents();
    res.json({ agents });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// API: Get agent definition
app.get('/api/agents/:id', (req, res) => {
  const { id } = req.params;
  const agentFile = path.join(AI_ENGINE_DIR, 'agents', `${id}-agent.md`);
  
  try {
    if (!fs.existsSync(agentFile)) {
      return res.status(404).json({ error: 'Agent not found' });
    }
    
    const content = fs.readFileSync(agentFile, 'utf8');
    res.json({ id, content });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// API: Send message to agent (chat)
app.post('/api/agents/:id/chat', async (req, res) => {
  const { id } = req.params;
  const { message } = req.body;
  
  if (!message) {
    return res.status(400).json({ error: 'Message is required' });
  }
  
  try {
    const chatId = `chat_${id}_${Date.now()}`;
    const chatEntry = {
      id: chatId,
      agent: id,
      message,
      timestamp: new Date().toISOString(),
      response: null
    };
    
    // Add to chat history
    agentChatHistory.push(chatEntry);
    
    // For now, return a placeholder response
    // In production, this would call the actual agent or Cursor AI
    chatEntry.response = {
      status: 'queued',
      message: `Message queued for ${id} agent. Agent communication would be implemented here.`
    };
    
    res.json({ chat: chatEntry });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// API: Get chat history
app.get('/api/chat/history', (req, res) => {
  const { agent, limit = 50 } = req.query;
  
  let history = agentChatHistory;
  if (agent) {
    history = history.filter(chat => chat.agent === agent);
  }
  
  res.json({ 
    chats: history.slice(-limit),
    total: history.length
  });
});

// SSE: Real-time chat updates
app.get('/api/chat/sse', (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  
  const sendUpdate = (data) => {
    res.write(`data: ${JSON.stringify(data)}\n\n`);
  };
  
  // Send initial connection message
  sendUpdate({ type: 'connected', timestamp: new Date().toISOString() });
  
  // Keep connection alive
  const keepAlive = setInterval(() => {
    res.write(': keepalive\n\n');
  }, 30000);
  
  req.on('close', () => {
    clearInterval(keepAlive);
    res.end();
  });
});

// ============================================
// TASK MANAGEMENT API ENDPOINTS
// ============================================

// API: Get all tasks
app.get('/api/tasks', (req, res) => {
  const { status, agent } = req.query;
  
  let taskList = Array.from(tasks.values());
  
  if (status) {
    taskList = taskList.filter(t => t.status === status);
  }
  
  if (agent) {
    taskList = taskList.filter(t => t.agent === agent);
  }
  
  // Sort by created_at descending
  taskList.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  
  res.json({ tasks: taskList, total: taskList.length });
});

// API: Get task by ID
app.get('/api/tasks/:id', (req, res) => {
  const { id } = req.params;
  const task = tasks.get(id);
  
  if (!task) {
    return res.status(404).json({ error: 'Task not found' });
  }
  
  res.json({ task });
});

// API: Create task
app.post('/api/tasks', (req, res) => {
  const { type, description, agent } = req.body;
  
  if (!type || !description) {
    return res.status(400).json({ error: 'Type and description are required' });
  }
  
  const task = createTask(type, description, agent);
  res.status(201).json({ task });
});

// API: Update task
app.put('/api/tasks/:id', (req, res) => {
  const { id } = req.params;
  const updates = req.body;
  
  const task = updateTask(id, updates);
  
  if (!task) {
    return res.status(404).json({ error: 'Task not found' });
  }
  
  res.json({ task });
});

// API: Cancel task
app.delete('/api/tasks/:id', (req, res) => {
  const { id } = req.params;
  const task = tasks.get(id);
  
  if (!task) {
    return res.status(404).json({ error: 'Task not found' });
  }
  
  updateTask(id, { status: 'cancelled' });
  res.json({ task: tasks.get(id) });
});

// ============================================
// ORCHESTRATOR COMMAND EXECUTION
// ============================================

// API: Execute orchestrator command
app.post('/api/orchestrator/execute', async (req, res) => {
  const { command, args = [] } = req.body;
  
  if (!command) {
    return res.status(400).json({ error: 'Command is required' });
  }
  
  const task = createTask('orchestrator', `Execute orchestrator command: ${command}`, 'orchestrator');
  
  try {
    updateTask(task.id, { status: 'running' });
    
    let result;
    
    switch (command) {
      case 'analyze':
        // Execute orchestrator analysis
        const scriptPath = path.join(AI_ENGINE_DIR, 'scripts', 'invoke-agent.sh');
        const outputFile = path.join(ORCHESTRATION_DIR, `orchestration-${Date.now()}.json`);
        
        const { stdout, stderr } = await execAsync(
          `bash ${scriptPath} orchestrator ${outputFile}`,
          { cwd: INFRA_DIR, timeout: 300000 } // 5 minute timeout
        );
        
        result = {
          success: true,
          output: stdout,
          outputFile: outputFile,
          error: stderr || null
        };
        break;
        
      case 'agent':
        // Execute specific agent
        const agentName = args[0];
        if (!agentName) {
          throw new Error('Agent name is required');
        }
        
        const agentScriptPath = path.join(AI_ENGINE_DIR, 'scripts', 'invoke-agent.sh');
        const agentOutputFile = path.join(ORCHESTRATION_DIR, `${agentName}-${Date.now()}.json`);
        
        const agentResult = await execAsync(
          `bash ${agentScriptPath} ${agentName} ${agentOutputFile}`,
          { cwd: INFRA_DIR, timeout: 60000 } // 1 minute timeout
        );
        
        result = {
          success: true,
          output: agentResult.stdout,
          outputFile: agentOutputFile,
          error: agentResult.stderr || null
        };
        break;
        
      default:
        throw new Error(`Unknown command: ${command}`);
    }
    
    updateTask(task.id, { 
      status: 'completed', 
      result 
    });
    
    res.json({ task, result });
  } catch (error) {
    updateTask(task.id, { 
      status: 'failed', 
      error: error.message,
      result: { stderr: error.stderr || error.message }
    });
    
    res.status(500).json({ 
      task: tasks.get(task.id),
      error: error.message 
    });
  }
});

// API: Get orchestrator reports
app.get('/api/orchestrator/reports', (req, res) => {
  try {
    const files = fs.readdirSync(ORCHESTRATION_DIR)
      .filter(f => f.endsWith('.json'))
      .map(f => {
        const filePath = path.join(ORCHESTRATION_DIR, f);
        const stats = fs.statSync(filePath);
        return {
          name: f,
          path: filePath,
          size: stats.size,
          created: stats.birthtime.toISOString(),
          modified: stats.mtime.toISOString()
        };
      })
      .sort((a, b) => new Date(b.modified) - new Date(a.modified));
    
    res.json({ reports: files });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// API: Get orchestrator report content
app.get('/api/orchestrator/reports/:name', (req, res) => {
  const { name } = req.params;
  const filePath = path.join(ORCHESTRATION_DIR, name);
  
  try {
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ error: 'Report not found' });
    }
    
    const content = fs.readFileSync(filePath, 'utf8');
    const data = JSON.parse(content);
    
    res.json({ report: data, name });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// INFRASTRUCTURE COMMAND EXECUTION
// ============================================

// API: Execute shell command (with restrictions)
app.post('/api/infra/command', async (req, res) => {
  const { command, timeout = 30000 } = req.body;
  
  if (!command) {
    return res.status(400).json({ error: 'Command is required' });
  }
  
  // Security: Only allow safe commands in /root/infra
  const allowedPrefixes = [
    'cd /root/infra && ',
    'cd /root/infra/',
    '/root/infra/'
  ];
  
  const isAllowed = allowedPrefixes.some(prefix => command.startsWith(prefix));
  
  // Also allow docker commands
  const dockerCommands = ['docker ps', 'docker logs', 'docker inspect', 'docker stats'];
  const isDockerCommand = dockerCommands.some(cmd => command.startsWith(cmd));
  
  if (!isAllowed && !isDockerCommand) {
    return res.status(403).json({ error: 'Command not allowed. Only infra and docker commands are permitted.' });
  }
  
  // Block dangerous commands
  const dangerous = ['rm -rf', 'mkfs', 'dd if=', 'shutdown', 'reboot', 'format'];
  if (dangerous.some(cmd => command.includes(cmd))) {
    return res.status(403).json({ error: 'Dangerous command blocked' });
  }
  
  const task = createTask('command', `Execute command: ${command}`, 'ops');
  
  try {
    updateTask(task.id, { status: 'running' });
    
    const { stdout, stderr } = await execAsync(command, {
      cwd: INFRA_DIR,
      timeout: timeout,
      maxBuffer: 10 * 1024 * 1024 // 10MB
    });
    
    updateTask(task.id, { 
      status: 'completed', 
      result: { stdout, stderr: stderr || null }
    });
    
    res.json({ 
      task: tasks.get(task.id),
      stdout,
      stderr: stderr || null
    });
  } catch (error) {
    updateTask(task.id, { 
      status: 'failed', 
      error: error.message,
      result: { stderr: error.stderr || error.message }
    });
    
    res.status(500).json({ 
      task: tasks.get(task.id),
      error: error.message,
      stderr: error.stderr || ''
    });
  }
});

// API: Get infrastructure overview
app.get('/api/infra/overview', async (req, res) => {
  try {
    // Get container stats
    const containers = await docker.listContainers({ all: true });
    const running = containers.filter(c => c.State === 'running').length;
    
    // Get services
    const data = getServices();
    const services = data.services || [];
    
    // Get disk usage
    const diskUsage = await execAsync('df -h /root/infra | tail -1').catch(() => ({ stdout: 'N/A' }));
    
    // Get memory usage
    const memUsage = await execAsync('free -h | grep Mem').catch(() => ({ stdout: 'N/A' }));
    
    res.json({
      containers: {
        total: containers.length,
        running,
        stopped: containers.length - running
      },
      services: {
        total: services.length,
        running: await Promise.all(services.map(s => getContainerStatus(s.id)))
          .then(statuses => statuses.filter(s => s === 'running').length)
      },
      system: {
        disk: diskUsage.stdout.trim(),
        memory: memUsage.stdout.trim()
      },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Ops Control Plane (Enhanced) running on port ${PORT}`);
  console.log(`Available endpoints:`);
  console.log(`  - GET  /api/services`);
  console.log(`  - GET  /api/agents`);
  console.log(`  - GET  /api/tasks`);
  console.log(`  - POST /api/orchestrator/execute`);
  console.log(`  - POST /api/infra/command`);
  console.log(`  - GET  /api/infra/overview`);
});

