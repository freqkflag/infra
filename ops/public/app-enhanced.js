// Enhanced Ops Control Plane - JavaScript

let services = [];
let agents = [];
let tasks = [];
let reports = [];
let selectedAgent = null;
let basicAuthCredentials = null;

// Get Basic Auth credentials (prompt if not stored)
function getBasicAuthCredentials() {
    if (basicAuthCredentials) {
        return basicAuthCredentials;
    }
    
    // Try to get from sessionStorage
    const stored = sessionStorage.getItem('ops_basic_auth');
    if (stored) {
        basicAuthCredentials = stored;
        return stored;
    }
    
    return null;
}

// Set Basic Auth credentials
function setBasicAuthCredentials(username, password) {
    const encoded = btoa(`${username}:${password}`);
    basicAuthCredentials = encoded;
    sessionStorage.setItem('ops_basic_auth', encoded);
}

// Tab switching
function switchTab(tabName) {
    document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    
    event.target.classList.add('active');
    document.getElementById(tabName).classList.add('active');
    
    // Load data when switching tabs
    if (tabName === 'agents' && agents.length === 0) loadAgents();
    if (tabName === 'tasks') loadTasks();
    if (tabName === 'orchestrator') {
        if (agents.length === 0) loadAgents();
        loadReports();
    }
    if (tabName === 'dashboard') {
        loadServices();
        loadInfraOverview();
    }
}

// Message display
function showMessage(text, type = 'success') {
    const msgDiv = document.getElementById('message');
    msgDiv.className = type;
    msgDiv.textContent = text;
    msgDiv.style.display = 'block';
    setTimeout(() => {
        msgDiv.style.display = 'none';
    }, 5000);
}

// API helper with auth
async function apiCall(endpoint, options = {}) {
    const defaultOptions = {
        credentials: 'include', // Include cookies for OAuth sessions
        headers: {
            'Content-Type': 'application/json',
        }
    };
    
    // Add Basic Auth if credentials are available
    const authCreds = getBasicAuthCredentials();
    if (authCreds) {
        defaultOptions.headers['Authorization'] = `Basic ${authCreds}`;
    }
    
    const mergedOptions = { ...defaultOptions, ...options };
    
    try {
        const response = await fetch(endpoint, mergedOptions);
        if (!response.ok) {
            if (response.status === 401) {
                // Prompt for Basic Auth credentials
                const username = prompt('Enter username:');
                if (username) {
                    const password = prompt('Enter password:');
                    if (password) {
                        setBasicAuthCredentials(username, password);
                        // Retry the request with new credentials
                        mergedOptions.headers['Authorization'] = `Basic ${btoa(`${username}:${password}`)}`;
                        const retryResponse = await fetch(endpoint, mergedOptions);
                        if (retryResponse.ok) {
                            return await retryResponse.json();
                        }
                    }
                }
                
                // If OAuth is enabled, try redirecting to login
                if (window.location.pathname !== '/auth/github') {
                    window.location.href = '/auth/github';
                } else {
                    showMessage('Authentication required. Please log in.', 'error');
                }
                return null;
            }
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        return await response.json();
    } catch (error) {
        console.error('API call error:', error);
        showMessage(`Error: ${error.message}`, 'error');
        return null;
    }
}

// Dashboard functions
async function loadServices() {
    const loading = document.getElementById('loading');
    const table = document.getElementById('servicesTable');
    const body = document.getElementById('servicesBody');
    
    loading.style.display = 'block';
    table.style.display = 'none';
    
    const data = await apiCall('/api/services');
    if (!data) return;
    
    services = data.services || [];
    
    body.innerHTML = services.map(service => `
        <tr>
            <td><strong>${service.name || service.id}</strong><br><small>${service.id}</small></td>
            <td>${service.type || 'N/A'}</td>
            <td><span class="status-badge status-${service.dockerStatus || service.status}">${(service.dockerStatus || service.status || 'unknown').toUpperCase()}</span></td>
            <td>${service.url ? `<a href="${service.url}" target="_blank" style="color: #00ffff;">${service.url}</a>` : 'N/A'}</td>
            <td>
                <div class="action-buttons">
                    <button class="action-btn" onclick="serviceAction('${service.id}', 'start')">Start</button>
                    <button class="action-btn" onclick="serviceAction('${service.id}', 'stop')">Stop</button>
                    <button class="action-btn" onclick="serviceAction('${service.id}', 'restart')">Restart</button>
                </div>
            </td>
            <td>
                <div class="action-buttons">
                    ${service.url ? `<a href="${service.url}" target="_blank" class="action-btn" style="border-color: #ff00ff; color: #ff00ff;">🌐 Open</a>` : ''}
                    <a href="https://wiki.freqkflag.co/projects/infra/${service.id}" target="_blank" class="action-btn" style="border-color: #ff00ff; color: #ff00ff;">📖 Docs</a>
                </div>
            </td>
        </tr>
    `).join('');
    
    updateHealthMetrics();
    updateIncidents();
    
    document.getElementById('lastUpdate').textContent = `Last updated: ${new Date().toLocaleTimeString()}`;
    loading.style.display = 'none';
    table.style.display = 'table';
}

function updateHealthMetrics() {
    const running = services.filter(s => s.dockerStatus === 'running').length;
    const stopped = services.filter(s => s.dockerStatus === 'stopped').length;
    const total = services.length;
    const healthScore = total > 0 ? Math.round((running / total) * 100) : 0;
    
    document.getElementById('runningCount').textContent = running;
    document.getElementById('stoppedCount').textContent = stopped;
    document.getElementById('totalCount').textContent = total;
    document.getElementById('healthScore').textContent = healthScore + '%';
    
    const scoreEl = document.getElementById('healthScore').parentElement;
    scoreEl.className = 'health-metric ' + 
        (healthScore >= 90 ? 'good' : healthScore >= 70 ? 'warning' : 'critical');
}

function updateIncidents() {
    const incidentsDiv = document.getElementById('incidents');
    const stopped = services.filter(s => s.dockerStatus === 'stopped' && s.status !== 'deprecated');
    
    if (stopped.length === 0) {
        incidentsDiv.innerHTML = '<div class="empty-state">No recent incidents</div>';
        return;
    }
    
    incidentsDiv.innerHTML = stopped.map(service => `
        <div class="incident critical">
            <strong>${service.name || service.id}</strong> is stopped<br>
            <small>Service ID: ${service.id}</small>
        </div>
    `).join('');
}

async function loadInfraOverview() {
    const overviewDiv = document.getElementById('infraOverview');
    const data = await apiCall('/api/infra/overview');
    if (!data) {
        overviewDiv.innerHTML = '<div class="error">Error loading overview</div>';
        return;
    }
    
    overviewDiv.innerHTML = `
        <div class="health-metric">
            <span>Containers Total</span>
            <span>${data.containers?.total || 0}</span>
        </div>
        <div class="health-metric ${data.containers?.running > 0 ? 'good' : 'warning'}">
            <span>Containers Running</span>
            <span>${data.containers?.running || 0}</span>
        </div>
        <div class="health-metric">
            <span>Services Running</span>
            <span>${data.services?.running || 0} / ${data.services?.total || 0}</span>
        </div>
        <div class="health-metric">
            <span>Disk Usage</span>
            <span>${data.system?.disk || 'N/A'}</span>
        </div>
        <div class="health-metric">
            <span>Memory</span>
            <span>${data.system?.memory || 'N/A'}</span>
        </div>
    `;
}

async function serviceAction(serviceId, action) {
    if (!confirm(`Are you sure you want to ${action} ${serviceId}?`)) return;
    
    const data = await apiCall(`/api/services/${serviceId}/${action}`, { method: 'POST' });
    if (!data) return;
    
    if (data.success) {
        showMessage(`${action} command executed for ${serviceId}`, 'success');
        setTimeout(loadServices, 2000);
    } else {
        showMessage(`Error: ${data.error}`, 'error');
    }
}

// Agent functions
async function loadAgents() {
    const data = await apiCall('/api/agents');
    if (!data) return;
    
    agents = data.agents || [];
    
    const agentSelector = document.getElementById('agentSelector');
    const agentSelect = document.getElementById('agentSelect');
    const taskAgentFilter = document.getElementById('taskAgentFilter');
    
    agentSelector.innerHTML = '<option value="">Select an agent...</option>' +
        agents.map(a => `<option value="${a.id}">${a.name}</option>`).join('');
    
    agentSelect.innerHTML = '<option value="">Select agent to run...</option>' +
        agents.map(a => `<option value="${a.id}">${a.name}</option>`).join('');
    
    taskAgentFilter.innerHTML = '<option value="">All Agents</option>' +
        agents.map(a => `<option value="${a.id}">${a.name}</option>`).join('');
}

async function sendAgentMessage() {
    const agentId = document.getElementById('agentSelector').value;
    const input = document.getElementById('chatInput');
    const message = input.value.trim();
    
    if (!agentId || !message) {
        showMessage('Please select an agent and enter a message', 'error');
        return;
    }
    
    // Add user message to chat
    const chatMessages = document.getElementById('chatMessages');
    chatMessages.innerHTML += `
        <div class="chat-message user">
            <strong>You:</strong> ${message}
        </div>
    `;
    chatMessages.scrollTop = chatMessages.scrollHeight;
    input.value = '';
    
    const data = await apiCall(`/api/agents/${agentId}/chat`, {
        method: 'POST',
        body: JSON.stringify({ message })
    });
    
    if (data && data.chat) {
        chatMessages.innerHTML += `
            <div class="chat-message agent">
                <strong>${data.chat.agent}:</strong> ${JSON.stringify(data.chat.response, null, 2)}
            </div>
        `;
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }
}

async function loadAgentHistory() {
    const agentId = document.getElementById('agentSelector').value;
    const params = agentId ? `?agent=${agentId}` : '';
    const data = await apiCall(`/api/chat/history${params}`);
    if (!data) return;
    
    const chatMessages = document.getElementById('chatMessages');
    chatMessages.innerHTML = data.chats?.map(chat => `
        <div class="chat-message ${chat.message.includes('You:') ? 'user' : 'agent'}">
            <strong>${chat.agent}:</strong> ${chat.message}
            ${chat.response ? `<br><small>Response: ${JSON.stringify(chat.response)}</small>` : ''}
        </div>
    `).join('') || '<div class="empty-state">No chat history</div>';
}

// Task functions
async function loadTasks() {
    const statusFilter = document.getElementById('taskFilter')?.value || '';
    const agentFilter = document.getElementById('taskAgentFilter')?.value || '';
    let url = '/api/tasks';
    const params = [];
    if (statusFilter) params.push(`status=${statusFilter}`);
    if (agentFilter) params.push(`agent=${agentFilter}`);
    if (params.length > 0) url += '?' + params.join('&');
    
    const data = await apiCall(url);
    if (!data) return;
    
    tasks = data.tasks || [];
    
    const taskList = document.getElementById('taskList');
    taskList.innerHTML = tasks.map(task => `
        <div class="task-item ${task.status}">
            <div class="task-header">
                <strong>${task.type} - ${task.description}</strong>
                <span class="task-status status-${task.status}">${task.status.toUpperCase()}</span>
            </div>
            <div style="font-size: 0.9em; color: #888; margin-top: 5px;">
                Agent: ${task.agent || 'N/A'} | Created: ${new Date(task.created_at).toLocaleString()}
            </div>
            ${task.result ? `<pre style="margin-top: 10px; font-size: 0.85em; overflow-x: auto;">${JSON.stringify(task.result, null, 2)}</pre>` : ''}
            ${task.error ? `<div style="color: #ff6666; margin-top: 10px;">Error: ${task.error}</div>` : ''}
        </div>
    `).join('') || '<div class="empty-state">No tasks found</div>';
}

// Orchestrator functions
async function runOrchestrator() {
    if (!confirm('Run full orchestrator analysis? This may take several minutes.')) return;
    
    const output = document.getElementById('orchestratorOutput');
    output.textContent = 'Running orchestrator analysis... Please wait...';
    
    const data = await apiCall('/api/orchestrator/execute', {
        method: 'POST',
        body: JSON.stringify({ command: 'analyze' })
    });
    
    if (data && data.task) {
        output.textContent = `Task created: ${data.task.id}\nStatus: ${data.task.status}\n\nChecking task status...`;
        
        // Poll for task completion
        const pollInterval = setInterval(async () => {
            const taskData = await apiCall(`/api/tasks/${data.task.id}`);
            if (taskData && taskData.task) {
                const task = taskData.task;
                if (task.status === 'completed' || task.status === 'failed') {
                    clearInterval(pollInterval);
                    output.textContent = JSON.stringify(task, null, 2);
                    if (task.result && task.result.outputFile) {
                        output.textContent += `\n\nReport saved to: ${task.result.outputFile}`;
                    }
                    loadReports();
                    loadTasks();
                } else {
                    output.textContent = `Task ${task.id}\nStatus: ${task.status}\nStill running...`;
                }
            }
        }, 2000);
        
        setTimeout(() => clearInterval(pollInterval), 300000); // 5 minute timeout
    }
}

async function runAgent() {
    const agentId = document.getElementById('agentSelect').value;
    if (!agentId) {
        showMessage('Please select an agent', 'error');
        return;
    }
    
    if (!confirm(`Run ${agentId} agent?`)) return;
    
    const output = document.getElementById('orchestratorOutput');
    output.textContent = `Running ${agentId} agent... Please wait...`;
    
    const data = await apiCall('/api/orchestrator/execute', {
        method: 'POST',
        body: JSON.stringify({ command: 'agent', args: [agentId] })
    });
    
    if (data && data.task) {
        output.textContent = `Task created: ${data.task.id}\nStatus: ${data.task.status}\n\n${JSON.stringify(data.result, null, 2)}`;
        loadTasks();
    }
}

async function loadReports() {
    const data = await apiCall('/api/orchestrator/reports');
    if (!data) return;
    
    reports = data.reports || [];
    
    const reportsDiv = document.getElementById('reports');
    reportsDiv.innerHTML = reports.map(report => `
        <div class="report-item" onclick="loadReport('${report.name}')">
            <strong>${report.name}</strong><br>
            <small>${new Date(report.modified).toLocaleString()} | ${(report.size / 1024).toFixed(2)} KB</small>
        </div>
    `).join('') || '<div class="empty-state">No reports found</div>';
}

async function loadReport(reportName) {
    const data = await apiCall(`/api/orchestrator/reports/${reportName}`);
    if (!data) return;
    
    const output = document.getElementById('orchestratorOutput');
    output.textContent = JSON.stringify(data.report, null, 2);
}

// Command functions
async function executeCommand() {
    const input = document.getElementById('commandInput');
    const command = input.value.trim();
    
    if (!command) {
        showMessage('Please enter a command', 'error');
        return;
    }
    
    const output = document.getElementById('commandOutput');
    output.textContent = 'Executing command... Please wait...';
    
    const data = await apiCall('/api/infra/command', {
        method: 'POST',
        body: JSON.stringify({ command, timeout: 30000 })
    });
    
    if (data && data.task) {
        output.textContent = `Task: ${data.task.id}\nStatus: ${data.task.status}\n\n`;
        
        if (data.stdout) output.textContent += `STDOUT:\n${data.stdout}\n\n`;
        if (data.stderr) output.textContent += `STDERR:\n${data.stderr}\n\n`;
        
        if (data.task.result) {
            if (data.task.result.stdout) output.textContent += `Result STDOUT:\n${data.task.result.stdout}\n\n`;
            if (data.task.result.stderr) output.textContent += `Result STDERR:\n${data.task.result.stderr}\n\n`;
        }
        
        loadTasks();
    }
}

function executeQuickCommand(command) {
    document.getElementById('commandInput').value = command;
    executeCommand();
}

// Auto-refresh
setInterval(() => {
    if (document.getElementById('dashboard').classList.contains('active')) {
        loadServices();
        loadInfraOverview();
    }
    if (document.getElementById('tasks').classList.contains('active')) {
        loadTasks();
    }
}, 30000); // Every 30 seconds

// Initial load
loadServices();
loadInfraOverview();

