# Standard: Test Case Generation

> Quality contract for the `case-generator` agent.
> Output goes to `.test-workspace/runs/<req-id>/test-cases.md`.

## Coverage Requirements (MUST)

Every requirement MUST yield cases covering these dimensions. Skipped dimensions MUST be justified inline.

| Dimension | What to cover |
|---|---|
| **Happy Path** | At least one case per primary user story / API contract |
| **Boundary** | Min/max values, empty input, max length, zero, negative, overflow |
| **Equivalence Classes** | One representative per input partition (don't enumerate within a class) |
| **Error / Negative** | Each documented error code; auth failures; malformed input |
| **State Transitions** | Each documented state edge (DRAFT→APPROVED, etc.); illegal transitions |
| **Concurrency** | If requirement implies shared state: race conditions, idempotency |
| **Permission** | If multi-role: each role's allow/deny matrix |

## Atomicity (MUST)
- **One case = one assertion target**. If a case has > 3 assertions across unrelated dimensions, split it.
- **No hidden setup**. Pre-conditions MUST be declared in the case, not inherited from prior cases.
- **No inter-case dependency**. Reordering or running a single case in isolation MUST work.

## Traceability (MUST)
Every case MUST include:
- `id`: Stable, e.g. `TC-<req-id>-<NNN>`
- `requirement_anchor`: Pointer back to the spec (heading / line / section ID)
- `priority`: P0 (blocker) / P1 (high) / P2 (nice-to-have)
- `degradation`: Inherited from req/global; only override when needed (see Layer 1 in [DESIGN.md §6](../../../DESIGN.md))

## Validation Layers (MUST declare)
For each case, declare which validation layers apply:
- L1 Response — almost always
- L2 Log Path — required for backend flows with side effects
- L3 Data State — required if case mutates persistent data
- L4 Visual / DOM — required for UI cases

If a layer is not applicable, write `N/A` with a one-line reason.

## Forbidden Patterns
- ❌ Cases that only check "no exception thrown" (too weak)
- ❌ Cases coupled to specific tool output formats (e.g., asserting on log message wording verbatim)
- ❌ Cases that mutate prod-like environments without explicit `target_env` declaration
- ❌ Cases without `requirement_anchor` (untraceable)

## Output Skeleton
Cases MUST conform to [`templates/test-cases.md`](../templates/test-cases.md).

## Self-Check Before Submitting
The agent MUST verify ALL of the following before marking case generation complete:
- [ ] Every coverage dimension addressed or justified.
- [ ] No case violates atomicity.
- [ ] Every case has `id`, `requirement_anchor`, `priority`, validation layers.
- [ ] No two cases are duplicates (same input + same assertion).
- [ ] Total case count is reasonable (warn user if > 50 for a single requirement).
