# Adapter: L2 Log Path Validation

> Universal L2 validation rules. The actual log retrieval is delegated to any adapter satisfying `cap.log.query` (see `_interfaces/logging.md`).

## Rules
- Extract `traceId` from the trigger output.
- Query logs via the configured logging adapter (sorted by timestamp asc).
- **Verify**:
  - **Completeness**: All expected nodes/services present in the trace.
  - **Order**: Nodes appear in the correct sequence.
  - **Cleanliness**: No unexpected ERROR/WARN logs (allow-list configurable per case).
  - **Boundary**: Trace starts at the expected entry node and ends at the expected sink.
