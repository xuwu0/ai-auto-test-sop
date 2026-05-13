# Test Task Plan - {{Requirement_Name}}

## 1. Task Overview
| TC-ID | Scenario | Priority | Type | Data Construction | Validation |
|-------|----------|----------|------|-------------------|------------|
| TC-001 | Normal | P0 | HSF | Existing Data | L1+L2+L3 |
| TC-002 | Edge | P1 | Mock | 📋 SQL | L1 |

## 2. Data Construction Details
### 🆕 New HSF Interface
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
| TC-ID | Expected Nodes | SLS Query | Time Window |
|-------|----------------|-----------|-------------|
| TC-001 | Start -> End | * \| traceId... | 0-5s |

## 4. User Confirmation Checklist
- [ ] Test strategy approved?
- [ ] SQL data verified?
- [ ] Mock values correct?
