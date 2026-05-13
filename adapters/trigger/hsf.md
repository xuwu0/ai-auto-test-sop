# Adapter: HSF Trigger

## Execution
Call via HSF HTTP Proxy:
```bash
curl -s -X POST "${HSF_PROXY_URL}" \
  -H "Content-Type: application/json" \
  -d '{"interface": "...", "method": "...", "args": [...]}'
```

## Validation
- Check `success` field.
- Extract `traceId` for log validation.
