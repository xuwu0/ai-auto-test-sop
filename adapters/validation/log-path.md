# Adapter: L2 Log Path Validation

## Rules
- Extract `traceId`.
- Query SLS logs sorted by time.
- **Verify**:
  - **Completeness**: All expected nodes present.
  - **Order**: Nodes appear in correct sequence.
  - **Clean**: No ERROR/WARN logs.
