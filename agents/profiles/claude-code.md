# Agent Profile: Claude Code

## 1. Identity
- name: claude-code
- vendor: Anthropic
- mode: Multi-Agent Orchestration (Terminal-native)

## 2. Infrastructure Capabilities
- [x] File Read/Write/Patch
- [x] Shell Execution
- [x] Background Processes
- [x] Parallel Agents (`Task` tool)
- [x] State Management (turn + workspace + memory files)

## 3. Capability Namespace Support
```yaml
capabilities:
  cap.trigger.rpc:     { binding: mcp }
  cap.trigger.http:    { binding: native }
  cap.trigger.browser: { binding: mcp }
  cap.trigger.cli:     { binding: native }
  cap.log.query:       { binding: mcp }
  cap.database.query:  { binding: mcp }
  cap.deploy.async:    { binding: mcp }
  cap.deploy.health:   { binding: native }
  cap.config.read:     { binding: mcp }
  cap.diagnose.trace:  { binding: mcp }
```

## 4. Execution Mode
- Supervisor + on-demand `Task` sub-agents.
- Native parallelism for read-only investigation; sequential for mutation.

## 5. Degradation Rules (Global Default)
```yaml
degradation:
  no_mcp:      SKIP
  no_shell:    MANUAL
  no_deploy:   MANUAL
  no_database: SKIP
```

## 6. Failure Handling
- Sub-agent failure → Supervisor diagnoses → retry / repair / escalate.
- Max repair iterations: **3** per case.
