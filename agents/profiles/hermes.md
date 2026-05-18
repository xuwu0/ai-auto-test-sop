# Agent Profile: Hermes

## 1. Identity
- name: hermes
- vendor: Anthropic / Generic Reference
- mode: Multi-Agent Orchestration

## 2. Infrastructure Capabilities
- [x] File Read/Write/Patch
- [x] Shell Execution
- [x] Background Processes
- [x] Parallel Agents (`delegate_task`)
- [x] State Management (`test-status.json`)

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
  cap.deploy.health:   { binding: mcp }
  cap.config.read:     { binding: mcp }
  cap.diagnose.trace:  { binding: mcp }
```

## 4. Execution Mode
- **Supervisor**: orchestrates the full DAG.
- **Delegation**: spawns `case-generator`, `planner`, `executor`, `reporter` as independent sub-agents.
- **Parallelism**: independent L1/L2/L3 validations may run concurrently.

## 5. Degradation Rules (Global Default)
```yaml
degradation:
  no_mcp:      SKIP        # Skip L2/L3 if MCP unavailable
  no_shell:    MANUAL      # Degrade to manual guide
  no_deploy:   MANUAL      # Manual deployment
  no_database: SKIP        # Skip L3 data validation
```
> Override at Requirement level in `test-config.yaml`, or at Case level in `test-task.md`.

## 6. Failure Handling
- Sub-agent failure → Supervisor captures stderr/exit-code → decides retry / repair / escalate.
- Max repair iterations: **3** per case.
