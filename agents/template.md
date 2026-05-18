# Agent Profile: [Agent Name]

## 1. Capabilities
- [ ] File Read/Write
- [ ] Shell Execution
- [ ] Background Processes
- [ ] Parallel Agents

## 2. MCP Support
- [ ] Native MCP
- [ ] CLI (mcporter)

## 3. Running Mode
- Deployment: [Async / Sync / Manual]
- Memory: [Persistent / Session-only]

## 4. Degradation Rules (Global Default)

> These are the **lowest-priority defaults**. They can be overridden at Requirement level (`test-config.yaml`) or Case level (in `test-task.md`).

```yaml
degradation:
  no_mcp: SKIP          # No MCP tools → skip L2/L3 validation
  no_shell: MANUAL      # No shell access → degrade to manual guide
  no_deploy: MANUAL     # No deploy capability → manual deployment
  no_database: SKIP     # No DB access → skip L3 data validation
```

**Action Reference**:
| Action | Behavior |
|--------|----------|
| `SKIP` | Skip the validation layer, mark as SKIPPED |
| `FAIL` | Mark the case as FAIL immediately |
| `MANUAL` | Degrade to assisted mode, generate manual guide |
| `FALLBACK:<adapter>` | Use an alternative adapter (e.g., `FALLBACK:arthas`) |
