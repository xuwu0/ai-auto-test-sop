# Interface: Deployment

> Contract for any adapter that **deploys code to a test environment**.
> Concrete implementations live in `.test-workspace/adapters/deployment/<tool>.md`.

## Purpose
Build, deploy, and verify the SUT is ready for testing.

## Required Operations
| Operation | Input | Output | Required |
|---|---|---|---|
| `deploy` | `{ branch: string, target_env: string, async?: bool }` | `{ deploy_id: string, status: "PENDING" \| "RUNNING" \| "SUCCESS" \| "FAILED" }` | ✅ |
| `status` | `{ deploy_id: string }` | `DeploymentStatus` | ✅ |
| `health_check` | `{ target_env: string }` | `{ healthy: bool, checks: [{name, ok, msg}] }` | ✅ |
| `rollback` | `{ deploy_id: string }` | `{ success: bool }` | optional |

## Required Behaviors
- `deploy` MUST support both async and sync modes; check Agent Profile for capability.
- `health_check` MUST verify: (1) port, (2) interface/endpoint, (3) clean startup logs.
- After SUCCESS, MUST wait a configurable cool-down before declaring ready.

## Degradation Behavior
- `no_deploy` → fail-fast with `DEPLOY_DISABLED`; case should fall back to MANUAL or SKIP.
- Async timeout → mark as FAILED, do NOT silently retry.

## Configuration Contract
```yaml
deployment:
  <tool>:
    project: <required>
    cool_down_seconds: 30
    health_check_timeout_seconds: 60
    max_polling_minutes: 15
```

## Used By
- `cap.deploy.async`, `cap.deploy.health`
- `executor` agent (in full-auto mode)
