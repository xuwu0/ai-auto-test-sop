# Agent Profile: Cursor

## 1. Identity
- name: cursor
- vendor: Anysphere / Cursor
- mode: Pair-Programming (Single-Agent)

## 2. Infrastructure Capabilities
- [x] File Read/Write/Patch
- [x] Shell Execution
- [x] Background Processes
- [ ] Parallel Agents
- [x] State Management (workspace files; no native session memory)

## 3. Capability Namespace Support
```yaml
capabilities:
  cap.trigger.rpc:     { binding: mcp }
  cap.trigger.http:    { binding: native }
  cap.trigger.browser: { binding: cli }      # via Playwright/Puppeteer CLI
  cap.trigger.cli:     { binding: native }
  cap.log.query:       { binding: mcp }
  cap.database.query:  { binding: mcp }
  cap.deploy.async:    { binding: cli }
  cap.deploy.health:   { binding: native }
  cap.config.read:     { binding: mcp }
  cap.diagnose.trace:  { binding: cli }
```

## 4. Execution Mode
- Single agent; no native sub-agent fan-out.
- Sequential DAG execution; parallelism only via background shell jobs.

## 5. Degradation Rules (Global Default)
```yaml
degradation:
  no_mcp:      SKIP
  no_shell:    MANUAL
  no_deploy:   MANUAL
  no_database: SKIP
```

## 6. Failure Handling
- No automatic sub-agent recovery. Escalate to user when a tool fails twice in a row.
- Max repair iterations: **2** per case.
