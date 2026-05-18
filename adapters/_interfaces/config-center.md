# Interface: Config Center

> Contract for any adapter that **reads or injects dynamic configuration**.
> Concrete implementations live in `.test-workspace/adapters/config-center/<tool>.md`.

## Purpose
Inspect runtime config and inject mock values to drive specific test branches without code changes.

## Required Operations
| Operation | Input | Output | Required |
|---|---|---|---|
| `read` | `{ data_id: string, group?: string }` | `{ value: string, version: string, last_modified: ISO8601 }` | ✅ |
| `inject` | `{ data_id: string, group?: string, value: string, ttl_seconds?: int }` | `{ injection_id: string, expires_at: ISO8601 }` | ✅ |
| `revoke` | `{ injection_id: string }` | `{ success: bool }` | ✅ |

## Required Behaviors
- `inject` MUST be **scoped to the test session** (TTL-bound or session-bound), NEVER permanent.
- `inject` MUST log the original value to `execution-log.md` for restoration.
- `revoke` MUST be called in case cleanup; if missed, the TTL provides a safety net.

## Safety Constraints
- MUST refuse to inject into config keys matching a deny-list (defined per team in adaptations.yaml).
- MUST emit a warning if `ttl_seconds > 3600`.

## Degradation Behavior
- If dynamic injection is unavailable → fall back to MANUAL (guide user to console update) per case rules.

## Configuration Contract
```yaml
config_center:
  <tool>:
    endpoint: <required>
    default_group: DEFAULT_GROUP
    inject_ttl_default: 600
    deny_list_keys: []
```

## Used By
- `cap.config.read`, `cap.config.inject`
- `case-generator` (mock-driven branch coverage)
