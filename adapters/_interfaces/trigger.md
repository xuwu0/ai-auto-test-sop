# Interface: Trigger

> Contract for any adapter that **invokes the System Under Test (SUT)**.
> Concrete implementations live in `.test-workspace/adapters/trigger/<tool>.md`.

## Purpose
Drive the SUT and obtain a primary response that can be validated downstream.

## Required Operations
| Operation | Input | Output | Required |
|---|---|---|---|
| `invoke` | `params: object`, `context: object` | `{ success: bool, result: any, traceId: string, duration_ms: int }` | ✅ |
| `prepare` | `{ fixtures: object }` | `void` | optional |
| `cleanup` | `{ artifacts: object }` | `void` | optional |

## Required Outputs
- **`traceId`** (REQUIRED) — for L2 log-path validation correlation. If the underlying tool does not emit one, the adapter MUST synthesize a UUID.
- **raw response** (REQUIRED) — for L1 response validation.
- **`duration_ms`** (RECOMMENDED) — performance baseline.

## Degradation Behavior
Adapters MUST react to these triggers (per agent profile rules):
- `no_mcp` → return structured error if the tool depends on MCP.
- `no_shell` → return structured error if the tool depends on shell exec.
- `no_network` → return structured error if SUT is remote.

Errors MUST be returned, never thrown.

## Configuration Contract
Implementations MUST document required keys under `triggers.<name>` in `.test-workspace/adaptations.yaml`. Example:
```yaml
triggers:
  <trigger-name>:
    proxy_url: <required>
    interface_class: <required>
    timeout_ms: 5000
```

## Failure Mode
- Connection failure → `{ success: false, error_code: "TRIGGER_CONNECT_FAILED", retryable: true }`
- Auth failure → `{ success: false, error_code: "TRIGGER_AUTH_FAILED", retryable: false }`
- SUT-level error → `success: false` but include the SUT's response for L1 inspection.
