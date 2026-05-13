# Adapter: DMS Database Validation

## Execution
Execute SQL via `mcporter`:
```bash
mcporter call dms-mcp-server.query_sql \
  database=${db_name} \
  sql="SELECT * FROM table WHERE id=1"
```
