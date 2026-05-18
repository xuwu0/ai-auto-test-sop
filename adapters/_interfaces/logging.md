# Interface: Logging

> Contract for any adapter that **queries runtime logs of the SUT**.
> Concrete implementations live in `.test-workspace/adapters/logging/<tool>.md`.

## Purpose
Retrieve logs by `traceId` (or other correlation key) to validate the execution path (L2).

## Required Operations
| Operation | Input | Output | Required |
|---|---|---|---|
| `query` | `{ traceId: string, time_range?: {start, end}, level_filter?: string[] }` | `LogEntry[]` ordered by timestamp asc | ✅ |
| `tail` | `{ filter: object, follow: bool }` | `Stream<LogEntry>` | optional |

## LogEntry Schema (Required Fields)
```yaml
timestamp: ISO8601
level: DEBUG | INFO | WARN | ERROR | FATAL
service: string
message: string
traceId: string
extras: object  # tool-specific fields preserved here
```

## Required Behaviors
- MUST return logs **sorted by timestamp ascending**.
- MUST preserve original `level` semantics; do NOT downgrade ERROR to WARN.
- MUST handle pagination internally; consumer sees a single ordered list.

## Degradation Behavior
- `no_mcp` → if the tool requires an MCP server, fail-fast with `LOG_MCP_UNAVAILABLE`.
- Empty result is **not** an error; return `[]` so L2 validator can decide SKIP/FAIL.

## Configuration Contract
```yaml
logging:
  <tool>:
    project: <required>
    logstore: <required>
    auth: <ref to secret>
```

## Used By
- `validation/log-path.md` (L2 validation)
- `cap.log.query` capability
