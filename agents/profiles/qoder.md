# Agent Profile: Qoder

## 1. Identity
- name: qoder
- vendor: Qoder (Alibaba)
- mode: Pair-Programming (Single-Agent + on-demand Sub-Agents)

## 2. Infrastructure Capabilities
- [x] File Read/Write/Patch
- [x] Shell Execution
- [x] Background Processes
- [x] Parallel Agents (Sub-Agents via `Agent` tool: Search / Browser / custom)
- [x] State Management (turn-scoped + workspace files)

## 3. Capability Namespace Support
```yaml
capabilities:
  cap.trigger.rpc:     { binding: mcp }
  cap.trigger.http:    { binding: native }   # via shell
  cap.trigger.browser: { binding: mcp }      # Browser sub-agent
  cap.trigger.cli:     { binding: native }
  cap.log.query:       { binding: mcp }
  cap.database.query:  { binding: mcp }
  cap.deploy.async:    { binding: mcp }
  cap.deploy.health:   { binding: native }
  cap.config.read:     { binding: mcp }
  cap.diagnose.trace:  { binding: mcp }
```

## 4. Execution Mode
- Single primary agent driving the DAG sequentially.
- Sub-agents (`Search`, `Browser`, custom) launched on demand for read-only investigation or browser automation.
- Long tasks streamed back to user inline; background terminals supported.

## 5. Degradation Rules (Global Default)
```yaml
degradation:
  no_mcp:      SKIP
  no_shell:    MANUAL
  no_deploy:   MANUAL
  no_database: SKIP
```

## 6. Failure Handling
- On tool failure, retry once with adjusted parameters; otherwise surface to user with diagnosis.
- Max repair iterations: **2** per case.
