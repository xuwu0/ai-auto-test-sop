# Interface: Diagnose

> Contract for any adapter that performs **runtime diagnosis on a live process**.
> Concrete implementations live in `.test-workspace/adapters/diagnose/<tool>.md`.

## Purpose
When a test fails with insufficient evidence, diagnose adapters provide call traces, stacks, and (optionally) hot-fix capability.

## Required Operations
| Operation | Input | Output | Required |
|---|---|---|---|
| `trace` | `{ class_or_module: string, method: string, duration_seconds?: int }` | `TraceResult[]` | ✅ |
| `stack` | `{ class_or_module: string, method?: string }` | `StackFrame[]` | ✅ |
| `hotfix` | `{ class_or_module: string, patch_path: string }` | `{ success: bool, restored_at?: ISO8601 }` | optional |

## Required Behaviors
- `trace` and `stack` MUST be **non-intrusive**: never alter SUT behavior.
- `hotfix` MUST be **opt-in**, gated by an explicit `--allow-hotfix` flag in the test session.
- `hotfix` MUST record original state for restoration.

## Safety Constraints
- MUST refuse to attach to PIDs not owned by the configured user.
- MUST refuse to operate on production environments (env tag check).

## Degradation Behavior
- `no_diagnose` → SKIP; emit structured note to test-report so user knows diagnosis was unavailable.

## Configuration Contract
```yaml
diagnose:
  <tool>:
    enabled_envs: [pre, dev]   # NEVER [prod]
    allow_hotfix: false        # opt-in per session
```

## Used By
- `cap.diagnose.trace`, `cap.diagnose.hotfix`
- `executor` (during repair-cycle)
