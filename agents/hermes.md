# Agent Profile: Hermes

## 1. Capabilities
- [x] File Read/Write/Patch
- [x] Shell Execution
- [x] Background Processes
- [x] **Parallel Agents** (`delegate_task` support)
- [x] State Management (`test-status.json`)

## 2. Execution Mode: **Multi-Agent Orchestration**
- **Supervisor**: Acts as the main orchestrator.
- **Delegation**: Spawns `case-generator`, `planner`, etc., as independent sub-agents using `delegate_task`.
- **Parallelism**: Can run independent validation tasks in parallel.

## 3. Degradation Rules (Global Default)

```yaml
degradation:
  no_mcp: SKIP          # Skip L2/L3 if MCP unavailable
  no_shell: MANUAL      # Degrade to manual guide
  no_deploy: MANUAL     # Manual deployment
  no_database: SKIP     # Skip L3 data validation
```

> Override at Requirement level in `test-config.yaml`, or at Case level in `test-task.md`.

## 4. Failure Handling
- If a sub-agent fails, Supervisor captures error and decides to retry or repair.
