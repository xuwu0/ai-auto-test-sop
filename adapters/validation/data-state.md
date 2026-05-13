# Adapter: L3 Data State Validation

## Rules
- **Baseline**: Snapshot data BEFORE execution.
- **Assertion**: Query data AFTER execution.
- **Diff**: Compare fields (e.g., status change DRAFT -> APPROVED).
- **Side Effects**: Check related tables for unexpected changes.
