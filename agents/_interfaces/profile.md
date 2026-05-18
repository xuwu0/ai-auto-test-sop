# Interface Contract: Agent Profile

> Every Agent Profile under `agents/profiles/` (framework presets) or `.test-workspace/agents/` (team-local) MUST conform to this schema. The framework reads only fields defined here; unknown fields are ignored.

## Purpose
Declare the identity, runtime capabilities, and global degradation defaults of the AI executing this SOP.

## Required Sections

### 1. Identity
- `name` — canonical agent name (e.g., `hermes`, `qoder`, `cursor`).
- `vendor` — distributor (e.g., `Anthropic`, `Qoder`, `Cursor`, `Alibaba`, `OpenAI`).
- `mode` — execution model: `Multi-Agent Orchestration` | `Single-Agent` | `Pair-Programming`.
- `language` — `inherit-from-config` (default) | explicit override (`en` | `zh`). When set to `inherit-from-config`, the agent uses `.test-workspace/config.yaml:language`.

### 2. Infrastructure Capabilities
Required boolean flags (`[x]` or `[ ]`):

| Flag | Meaning |
|---|---|
| File Read/Write/Patch | Can mutate workspace files |
| Shell Execution | Can run shell commands |
| Background Processes | Can spawn long-running async jobs |
| Parallel Agents | Supports `delegate_task` / `Task` / equivalent fan-out |
| State Management | Can persist `test-status.json` across turns |

### 3. Capability Namespace Support
Declare which capabilities from `adapters/_capabilities.yaml` this agent can fulfill, and via what binding:

```yaml
capabilities:
  cap.trigger.rpc:     { binding: mcp | cli | native | none }
  cap.trigger.http:    { binding: mcp | cli | native | none }
  cap.trigger.browser: { binding: mcp | cli | native | none }
  cap.trigger.cli:     { binding: mcp | cli | native | none }
  cap.log.query:       { binding: mcp | cli | native | none }
  cap.database.query:  { binding: mcp | cli | native | none }
  cap.deploy.async:    { binding: mcp | cli | native | none }
  cap.deploy.health:   { binding: mcp | cli | native | none }
  cap.config.read:     { binding: mcp | cli | native | none }
  cap.diagnose.trace:  { binding: mcp | cli | native | none }
```

Binding semantics:
- `mcp`    — MCP server provides this capability natively.
- `cli`    — A workspace CLI adapter (`.test-workspace/adapters/`) provides it.
- `native` — Doable via plain shell / HTTP from the current agent.
- `none`   — Unreachable; triggers degradation.

### 4. Degradation Rules (Global Default)
Lowest-priority defaults. Overridable at Requirement (`test-config.yaml`) or Case (`test-task.md`) level.

```yaml
degradation:
  no_mcp:      SKIP | MANUAL | FAIL
  no_shell:    SKIP | MANUAL | FAIL
  no_deploy:   SKIP | MANUAL | FAIL
  no_database: SKIP | MANUAL | FAIL
```

Action set: `SKIP | FAIL | MANUAL | FALLBACK:<adapter>`.

### 5. Failure Handling
Describe how this agent recovers from sub-task failure:
- Retry policy
- Repair budget (max iterations per case)
- Escalation rule (when to surface to user)

## Validation Rules
- Profile MUST declare ALL infrastructure flags (no omissions).
- Profile MUST declare every `cap.*` it intends to fulfill; missing keys are treated as `binding: none`.
- Degradation values MUST come from the action set above.
- A profile failing validation is rejected; AI falls back to `template.md` + self-check.

## Resolution Order (used by INSTRUCTIONS Step 1)
1. `agents/profiles/<agent-name>.md` (framework preset)
2. `.test-workspace/agents/<agent-name>.md` (team-local)
3. If neither exists → run `agents/self-check-instructions.md` and write to `.test-workspace/agents/<agent-name>.md`.
