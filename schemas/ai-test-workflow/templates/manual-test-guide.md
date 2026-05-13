# Manual Test Guide - {{Requirement_Name}}

**Generated for Assisted Mode**. Please execute the following steps manually and paste the results back to the AI.

## 1. Pre-check
- [ ] Environment is ready (Daily/Pre).
- [ ] Code is deployed (Commit Hash: {{Hash}}).

## 2. Test Cases to Run

### TC-001: Normal Scenario
- **Action**: Call HSF `service.method(args)` or Open URL `http://...`
- **Input Data**:
  ```json
  {"bizMode": "LR_SUPERLINK", ...}
  ```
- **Expected Result**: `success=true`, `code="0"`
- **Observation Point**:
  - Check logs in SLS (Keyword: "...").
  - Check DB table `status` field.

> **⬇️ User Input Required**:
> Paste the actual response/screenshot/logs here for AI analysis.

---

### TC-002: Edge Case
...

## 3. Submission
Once you have executed the cases, reply with the results. The AI will proceed to Validation (L1-L4) and Report generation.
