# Standard: Test Task Planning

> Quality contract for the `planner` agent.
> Output goes to `.test-workspace/runs/<req-id>/test-task.md` (and optionally `manual-test-guide.md`).

## Purpose
Translate a list of test cases into an **executable plan** with explicit dependencies, resource needs, and degradation injection points.

## Required Sections (MUST)

### 1. Execution Order
- Cases MUST be topologically sorted by data dependency.
- Independent cases MUST be marked `parallel: true` to enable concurrency.
- Cases sharing a resource (e.g., same DB row) MUST be in the same serial group.

### 2. Pre-conditions / Setup
For each case, the plan MUST declare:
- **Environment**: target_env (dev / pre / staging — NEVER prod).
- **Fixtures**: data to seed before run; clean-up policy after.
- **Mock injections**: config-center keys to override (with TTL).
- **Service deployment**: which branch / commit; sync vs async.

### 3. Tool Binding
For each case, declare which **capability** (not implementation) is used:
- `trigger`: e.g., `cap.trigger.rpc`
- `logging`: e.g., `cap.log.query`
- `database`: e.g., `cap.database.query`

The actual binding to a concrete adapter is resolved from `.test-workspace/adaptations.yaml`. The plan MUST NOT hardcode tool names.

### 4. Degradation Overrides (Layer 1)
Per-case degradation overrides go here. See [DESIGN.md §6](../../../DESIGN.md) for the 3-layer inheritance.

```yaml
- case_id: TC-001
  degradation:
    no_database: SKIP    # this case can run without L3 verification
```

### 5. Risk & Blast Radius
- Cases that mutate shared state MUST declare `blast_radius: <table_or_resource>`.
- Cases that inject config MUST declare `injection_scope: session | per-case`.
- Plan MUST flag any case with `blast_radius != isolated` for explicit user review.

### 6. Stop Conditions
The plan MUST specify:
- `fail_fast`: stop on first FAIL (default for P0 cases) vs continue.
- `max_repair_iterations`: how many auto-repair cycles allowed (default 3, see [schema.yaml](../schema.yaml)).
- `total_timeout_minutes`: hard ceiling.

## Forbidden Patterns
- ❌ Cases serialized "just in case" without declared dependency.
- ❌ Cleanup steps relying on next test to "naturally overwrite" state.
- ❌ Hardcoded credentials, IPs, or tool-specific commands in the plan body.
- ❌ Plans without explicit stop condition (would loop forever).

## Manual Mode Output
If `execution_mode: assisted`, the planner MUST also emit `manual-test-guide.md` per [`templates/manual-test-guide.md`](../templates/manual-test-guide.md):
- Steps written for a human reader (no code).
- Each step has expected observation + how to record it.
- Pause points where AI awaits human paste-back.

## Self-Check Before Submitting
- [ ] Every case from `test-cases.md` appears in the plan exactly once.
- [ ] Topological order is acyclic.
- [ ] Every parallel group is truly independent (no shared mutable state).
- [ ] Stop conditions are explicit.
- [ ] No hardcoded tool names; only capabilities.
