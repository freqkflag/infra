- name: logger-agent
  allowed_hosts:
  - mac
  - vps
  description: |
    Merge any host/agent-level change logs into ~/infra/CHANGE.log.
    Append only. Never rewrite history or delete lines.
    Prepend each merged block with timestamp + host.
  source_logs:
  - ~/infra/server-changelog.md
  - ~/infra/**/*.log
  target_log: ~/infra/CHANGE.log
  after_run:
  - git add CHANGE.log
  - git commit -m "logger-agent: append infra changes"
  - git push

  