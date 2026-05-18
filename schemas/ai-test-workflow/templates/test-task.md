# Test Task Plan - {{Requirement_Name}}

## 1. Task Overview
| TC-ID | Scenario | Priority | Type | Data Construction | Validation | Degradation |
|-------|----------|----------|------|-------------------|------------|-------------|
| TC-001 | Normal | P0 | RPC | Existing Data | L1+L2+L3 | *(default)* |
| TC-002 | Edge | P1 | Mock | 📋 SQL | L1 | `no_mcp: FAIL` |

## 2. Data Construction Details
### 🆕 New RPC Interface
(If needed)

### 📋 SQL Data Prep
```sql
-- Pre-setup SQL
INSERT INTO ...

-- Cleanup SQL
DELETE FROM ...
```

## 3. Validation Planning
### Data State Validation
| TC-ID | Table | Field | Method |
|-------|-------|-------|--------|
| TC-001 | table_a | status | SQL Query |

### Log Observation Points
| TC-ID | Expected Nodes | Log Query | Time Window |
|-------|----------------|-----------|-------------|
| TC-001 | Start -> End | * \| traceId... | 0-5s |

## 4. Degradation Overrides (Case Level)

> Only list cases that need to override the Requirement/Global defaults. Omitted cases inherit automatically.

```yaml
# Example: TC-002 requires MCP for log validation, fail if unavailable
TC-002:
  degradation:
    no_mcp: FAIL

# Example: TC-003 can skip deployment entirely
# TC-003:
#   degradation:
#     no_deploy: SKIP
```

## 5. User Confirmation Checklist
- [ ] Test strategy approved?
- [ ] SQL data verified?
- [ ] Mock values correct?
