# Agent Self-Check Instructions (Auto-Run by AI)

**Trigger**: Run this ONLY if no profile matches your current agent name in either:
1. `agents/profiles/<your-name>.md` (framework preset), OR
2. `.test-workspace/agents/<your-name>.md` (team-local).

**Goal**: Determine your capabilities and generate a profile file at `.test-workspace/agents/<your-name>.md`.

---

## Phase A — Infrastructure Capability Probes

1. **File I/O Test**: Create a temp file, write text, read it back, then delete.
   → If successful, record: `[x] File Read/Write/Patch`
2. **Shell Test**: Run `echo "test"`.
   → If output matches, record: `[x] Shell Execution`
3. **Background Test**: Run `sleep 2 &` (or equivalent).
   → If immediate return, record: `[x] Background Processes`
4. **Parallel Test**: Check if `delegate_task` / `Task` / equivalent fan-out is available.
   → If yes, record: `[x] Parallel Agents`
5. **State Test**: Verify ability to persist `test-status.json` across turns.
   → If yes, record: `[x] State Management`

## Phase B — Capability Namespace Probes

For each `cap.*` declared in `adapters/_capabilities.yaml`, decide its binding:

| Binding | Means |
|---|---|
| `mcp`    | An MCP server provides this capability natively. |
| `cli`    | A workspace CLI adapter (`.test-workspace/adapters/`) provides it. |
| `native` | Doable via plain shell / HTTP from the current agent. |
| `none`   | Unreachable; will trigger degradation. |

Probe order (cheap → expensive):
1. `cap.trigger.cli`, `cap.trigger.http` — usually `native` if shell + net are available.
2. `cap.trigger.rpc`, `cap.log.query`, `cap.database.query`, `cap.deploy.*`, `cap.config.*`, `cap.diagnose.*` — check MCP server list, then workspace CLI adapters.
3. `cap.trigger.browser` — only `mcp` or `cli`; `none` if neither is present.

## Phase C — Pick Sensible Defaults

Default degradation (override only if your environment demands):
```yaml
no_mcp:      SKIP
no_shell:    MANUAL
no_deploy:   MANUAL
no_database: SKIP
```

---

## Output Generation
1. Copy `agents/template.md`.
2. Fill Sections 1–5 with results from Phase A / B / C.
3. Save as `.test-workspace/agents/<your-name>.md`.

> Use the agent name you know yourself by (e.g., `hermes`, `qoder`, `cursor`, `aone-copilot`, `claude-code`).
> If a matching preset exists in `agents/profiles/`, prefer copying it as the starting point and only modify deviating fields.
