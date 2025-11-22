#!/bin/bash
source ../.workspace/.env
cat << EOC
external_url 'https://${GITLAB_DOMAIN}'
gitlab_rails['gitlab_shell_ssh_port'] = ${GITLAB_SSH_PORT:-2224}

# PostgreSQL configuration
postgresql['enable'] = false
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'unicode'
gitlab_rails['db_host'] = 'postgres-postgres-1'
gitlab_rails['db_port'] = 5432
gitlab_rails['db_username'] = '${GITLAB_DB_USER}'
gitlab_rails['db_password'] = '${GITLAB_DB_PASSWORD}'
gitlab_rails['db_database'] = '${GITLAB_DB_NAME}'

# Redis configuration
redis['enable'] = false
gitlab_rails['redis_host'] = 'redis'
gitlab_rails['redis_port'] = 6379
gitlab_rails['redis_password'] = ''

# Email configuration (optional, can be configured later)
gitlab_rails['smtp_enable'] = false

# Security settings
gitlab_rails['initial_root_password'] = '${GITLAB_ROOT_PASSWORD}'

# Performance tuning
puma['worker_processes'] = 2
sidekiq['max_concurrency'] = 10

# Logging
logging['svlog'] = {
  size: '200M',
  rotate: 30,
  compress: 'gzip'
}
EOC
