# Test Cases - {{Requirement_Name}}

## 1. Generation Strategy
- Complexity: [Simple/Normal/Complex]
- Scope: [Description of what was covered]

## 2. Test Case Overview
| TC-ID | Scenario (Condition → Result) | Expected Behavior | Priority | Degradation |
|-------|-------------------------------|-------------------|----------|-------------|
| TC-001 | Normal path ... | success=true, data non-empty | P0 | *(default)* |
| TC-002 | Edge case ... | success=false, code=ERR_X | P1 | `no_mcp: FAIL` |

> **Degradation column**: Leave empty or write `(default)` to inherit from Requirement/Global level. Only specify overrides when this case has special requirements. Format: `key: ACTION`.

## 3. Test Case Details
### TC-001: [Scenario Name]
**Trigger**: HSF call `service.method(args)`
**Interface Expectation**: `success=true`, `code="0"`
**Data State Assertion**:
| Table | Condition | Field Assertion |
|-------|-----------|-----------------|
| `table_a` | `id=1` | `status="ACTIVE"` |

**Log Path Assertion**:
| Order | Node | Keyword | Time Window |
|-------|------|---------|-------------|
| 1 | Activity.start | "Start" | 0-2s |

## 4. Coverage Matrix
| Requirement Point | TC-001 | TC-002 |
|-------------------|--------|--------|
| R1: Normal Flow   | ✅      |        |
