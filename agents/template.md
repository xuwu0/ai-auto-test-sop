# Agent Profile: <agent-name>

> Copy this template to either:
> - `agents/profiles/<name>.md` — if contributing a reusable preset.
> - `.test-workspace/agents/<name>.md` — if specific to your team/setup.

## 1. Identity
- name: <agent-name>
- vendor: <vendor>
- mode: Multi-Agent Orchestration | Single-Agent | Pair-Programming
- language: inherit-from-config

## 2. Infrastructure Capabilities
- [ ] File Read/Write/Patch
- [ ] Shell Execution
- [ ] Background Processes
- [ ] Parallel Agents
- [ ] State Management

## 3. Capability Namespace Support
> Map every `cap.*` from `adapters/_capabilities.yaml` to a binding.
> `binding`: `mcp` | `cli` | `native` | `none`. `none` triggers degradation.

```yaml
capabilities:
  cap.trigger.rpc:     { binding: none }
  cap.trigger.http:    { binding: none }
  cap.trigger.browser: { binding: none }
  cap.trigger.cli:     { binding: none }
  cap.log.query:       { binding: none }
  cap.database.query:  { binding: none }
  cap.deploy.async:    { binding: none }
  cap.deploy.health:   { binding: none }
  cap.config.read:     { binding: none }
  cap.diagnose.trace:  { binding: none }
```

## 4. Degradation Rules (Global Default)
> Lowest-priority defaults. Overridable at Requirement (`test-config.yaml`) or Case (`test-task.md`) level.

```yaml
degradation:
  no_mcp:      SKIP
  no_shell:    MANUAL
  no_deploy:   MANUAL
  no_database: SKIP
```

**Action Reference**:
| Action | Behavior |
|--------|----------|
| `SKIP` | Skip the validation layer, mark as SKIPPED |
| `FAIL` | Mark the case as FAIL immediately |
| `MANUAL` | Degrade to assisted mode, generate manual guide |
| `FALLBACK:<adapter>` | Use an alternative adapter |

## 5. Failure Handling
- <Retry policy>
- <Max repair iterations per case>
- <Escalation rule>
