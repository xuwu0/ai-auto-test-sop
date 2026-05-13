# Adapter: SLS Log Validation

## Execution
Query via `mcporter`:
```bash
mcporter call sls-mcp.query_sls_logs \
  projectName=${project} logstoreName=${logstore} \
  query="* | where traceId = '<traceId>'"
```
