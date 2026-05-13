# Adapter: Aone Deployment

## Execution Strategy
- **Async Deployment**: Trigger via `mcporter call group-env.apre_deploy id=<apre_id>` in background.
- **Polling**: Every 30s check status `mcporter call group-env.apre_get id=<apre_id>`.
- **Cool Down**: Wait 30s after SUCCESS for service startup.

## Health Check
1. Port check: `nc -z <IP> 12200`
2. Interface check: Call `/health` or read-only HSF.
3. Log check: No `ERROR` in SLS last 1 min.
