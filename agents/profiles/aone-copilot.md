# Agent Profile: Aone Copilot

## 1. Identity
- name: aone-copilot
- vendor: Alibaba / Aone
- mode: Pair-Programming (Single-Agent, IDE-bound)

## 2. Infrastructure Capabilities
- [x] File Read/Write/Patch
- [x] Shell Execution
- [ ] Background Processes        # IDE-scoped, no detachable jobs
- [ ] Parallel Agents
- [x] State Management (workspace files)

## 3. Capability Namespace Support
> All vendor-private bindings resolve through workspace adapters (`.test-workspace/adapters/`).

```yaml
capabilities:
  cap.trigger.rpc:     { binding: cli }       # private RPC CLI in workspace
  cap.trigger.http:    { binding: native }
  cap.trigger.browser: { binding: none }
  cap.trigger.cli:     { binding: native }
  cap.log.query:       { binding: cli }       # logging CLI adapter in workspace
  cap.database.query:  { binding: cli }       # database CLI adapter in workspace
  cap.deploy.async:    { binding: cli }       # deployment CLI adapter in workspace
  cap.deploy.health:   { binding: cli }
  cap.config.read:     { binding: cli }       # config-center CLI adapter in workspace
  cap.diagnose.trace:  { binding: cli }       # diagnose CLI adapter in workspace
```

## 4. Execution Mode
- IDE-anchored single agent; all execution scoped to the open project.
- Background work emulated via blocking shell waits.

## 5. Degradation Rules (Global Default)
```yaml
degradation:
  no_mcp:      SKIP        # No native MCP; rely on CLI bindings
  no_shell:    FAIL        # Shell is the only execution path
  no_deploy:   MANUAL
  no_database: SKIP
```

## 6. Failure Handling
- On CLI adapter failure, surface raw stderr to user; do not retry automatically.
- Max repair iterations: **1** per case (conservative — IDE-scoped).
