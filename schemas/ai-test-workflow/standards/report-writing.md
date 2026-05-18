# Standard: Test Report Writing

> Quality contract for the `reporter` agent.
> Output goes to `.test-workspace/runs/<req-id>/test-report.md`.

## Principle: Conclusion First, Evidence Linked

A reader who only reads the first 30 seconds of the report MUST be able to answer:
1. Did this requirement pass? (PASS / PARTIAL / FAIL)
2. Is it safe to ship? (RECOMMEND / BLOCK)
3. What's the next action? (concrete action item or "ship it")

## Required Sections (in order)

### 1. Verdict (1-3 lines)
```
Verdict: PARTIAL (12/15 PASS, 1 FAIL P0, 2 SKIP)
Recommendation: BLOCK shipping until TC-007 fixed
Next Action: Fix null-pointer in OrderService.cancel() (line 142)
```

### 2. Summary Table
| Priority | Total | PASS | FAIL | SKIP | MANUAL |
|---|---|---|---|---|---|
| P0 | 5 | 4 | 1 | 0 | 0 |
| P1 | 8 | 7 | 0 | 1 | 0 |
| P2 | 2 | 1 | 0 | 1 | 0 |

### 3. FAIL Cases (one block each)
For each FAIL, MUST include:
- **Case ID & link** back to test-cases.md
- **Symptom**: exact failing assertion
- **Root cause hypothesis**: ranked by likelihood (do not guess if unsure → say "needs investigation")
- **Evidence**: link to log entries, SQL diffs, screenshots in `runs/<id>/artifacts/`
- **Suggested fix**: file path + line number if known, otherwise "needs human triage"

### 4. SKIP / MANUAL Cases
For each, MUST state **why** it was skipped (degradation rule? missing tool? out of scope?) and what's needed to un-skip.

### 5. Self-Evolution Outputs
Per [INSTRUCTIONS Step 4](../../../INSTRUCTIONS.md):
- New `adaptations.yaml` entries appended (link)
- New `skills/<id>.md` files created (link)
- New `pitfalls/<id>.md` files created (link)
- Upstream `proposals/<id>/` candidates generated (link, if any — Step 4.5)

### 6. Performance Snapshot (if applicable)
Median / P95 / P99 latency per case; flag regressions > 20% vs last run baseline.

## Traceability (MUST)
Every claim in the report MUST link to one of:
- A specific case in `test-cases.md`
- A specific log line / DB row / screenshot under `runs/<id>/artifacts/`
- A specific `execution-log.md` entry

**No anonymous claims**. If you cannot link evidence, do not make the claim.

## Tone Rules
- ✅ Factual: "TC-007 failed: assertion `status == APPROVED` got `DRAFT`"
- ❌ Hedged: "There seems to be some issue with the approval flow"
- ❌ Hyperbolic: "Critical catastrophic failure"
- Use SHIP / BLOCK / NEEDS-REVIEW as discrete recommendations.

## Forbidden Patterns
- ❌ Hiding FAILs in a "minor issues" section (P0 FAIL must be top-of-fold)
- ❌ Reporting raw tool output dumps without summarization
- ❌ Conclusions without evidence links
- ❌ Recommending `SHIP` while any P0 is FAIL/SKIP

## Self-Check Before Submitting
- [ ] Verdict is one of PASS / PARTIAL / FAIL with explicit recommendation.
- [ ] Every FAIL has root-cause hypothesis + evidence link + suggested fix.
- [ ] Every SKIP has a reason and unblock condition.
- [ ] No P0 FAIL paired with `RECOMMEND: SHIP`.
- [ ] All evidence links resolve (no broken `runs/<id>/artifacts/...` references).
