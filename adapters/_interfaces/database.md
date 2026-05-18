# Interface: Database

> Contract for any adapter that **inspects data state in a database**.
> Concrete implementations live in `.test-workspace/adapters/database/<tool>.md`.

## Purpose
Query and snapshot data state for L3 validation (before/after diff).

## Required Operations
| Operation | Input | Output | Required |
|---|---|---|---|
| `query` | `{ database: string, sql: string, timeout_ms?: int }` | `Row[]` | ✅ |
| `snapshot` | `{ database: string, tables: string[], where?: string }` | `Snapshot` (opaque, comparable via `diff`) | ✅ |
| `diff` | `{ before: Snapshot, after: Snapshot }` | `Change[]` (added / removed / modified) | ✅ |

## Required Behaviors
- `query` MUST be **read-only**. Adapter MUST reject DML/DDL.
- `snapshot` MUST be deterministic for the same input.
- `diff` output MUST be human-readable AND machine-parseable.

## Safety Constraints
- MUST refuse `DROP`, `TRUNCATE`, `DELETE`, `UPDATE`, `INSERT`, `ALTER` at the SQL parser level.
- MUST log every query in `execution-log.md` BEFORE execution.

## Degradation Behavior
- `no_database` → return structured error; L3 validator should SKIP or FAIL per case rules.
- Connection pool exhausted → retry once, then fail with `DB_POOL_EXHAUSTED`.

## Configuration Contract
```yaml
database:
  <tool>:
    connection: <ref to secret>
    default_database: <name>
    read_only: true   # MUST be true
```

## Used By
- `validation/data-state.md` (L3 validation)
- `cap.database.query`, `cap.database.snapshot`
