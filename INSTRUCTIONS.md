# AI Test SOP Instructions (Zero-Config)

[中文版](INSTRUCTIONS_CN.md)

> **For the AI Agent**: When the user types `/test-sop`, you MUST follow this protocol strictly.

## 🚀 Trigger Protocol

**Input**: User types `/test-sop [Requirement Source]`

### Step 0: Workspace Bootstrap (Auto-Check)
**Action**:
1. Check if `.test-workspace/` exists in the project root.
2. **IF NOT EXISTS** (fallback if install.sh was not run):
   - Notify user: "⚠️ Workspace not found. Please run `bash .test-sop/install.sh --lang <en|zh>` first."
   - **STOP**: Do not proceed until install.sh has been executed.
3. **IF EXISTS**:
   - Proceed to Step 1.

**Language Lock** (mandatory):
- Read `language` field from `.test-workspace/config.yaml`.
- **ALL subsequent AI outputs** — including chat responses, test cases, task plans, reports, proposals, and pitfall entries — MUST use this language.
- This is a hard constraint. Do NOT switch language based on the user's chat language; always follow `config.language`.

### Step 1: Auto-Bootstrap (Self-Check)
**Action**: Resolve your Agent Profile in this order:
1. **Framework preset**: `.test-sop/agents/profiles/<your-agent-name>.md` (e.g., `profiles/qoder.md`, `profiles/cursor.md`, `profiles/aone-copilot.md`, `profiles/claude-code.md`, `profiles/hermes.md`).
2. **Team-local**: `.test-workspace/agents/<your-agent-name>.md`.
3. **IF NEITHER EXISTS**:
   - Execute `.test-sop/agents/self-check-instructions.md`.
   - Save the resulting profile under `.test-workspace/agents/<your-agent-name>.md` (NEVER write to `.test-sop/`).
   - **Notify User**: "✅ Auto-generated Agent Profile. Capabilities confirmed."
4. Load the resolved profile and apply its `degradation` block as the Layer-3 (Global) default for the inheritance chain.

### Step 2: Load Context
**Action**:
1. Read `.test-sop/schemas/ai-test-workflow/schema.yaml`.
2. Read `.test-sop/schemas/ai-test-workflow/standards/*.md` — these are the **quality contracts** for case-generator / planner / reporter. Apply them as you produce each artifact.
3. Read `.test-sop/adapters/_capabilities.yaml` — this is the abstract capability namespace. Bind capabilities to concrete tools via `.test-workspace/adaptations.yaml`.
4. Read `.test-workspace/config.yaml` to determine:
   - `execution_mode` (full-auto vs assisted).
   - MCP tools availability.
   - Requirement-level `degradation` overrides (if any).
5. Read `.test-workspace/memory.md` and scan `.test-workspace/skills/` for any reusable workflows.
6. **Acknowledge**: "✅ Schema loaded. Mode: [Mode]. Tools: [List]. Skills loaded: [N]."

### Step 3: Workflow Execution
**Action**:
- **Source**: Read `[Requirement Source]` (Read-Only).
- **Destination**: Create `.test-workspace/runs/<req-id>/` directory. **NEVER** write to source.
- **Process**: Follow the `dag` defined in `schema.yaml`.
  1. `spec` (Generate Spec)
  2. `test-cases` (Generate Cases) → **WAIT for User Review** if `user_review: true`.
  3. `test-task` (Plan Strategy) → **WAIT for User Review** if `user_review: true`.
  4. `test-execution` (Run Tests - if `full-auto`).
  5. `test-report` (Summarize).

### Step 4: Self-Evolution
**Action**:
- After completion, check for anomalies and reusable patterns.
- If new patterns/errors found, route them by scope:
  - **Minor parameter tweak**: Append to `.test-workspace/adaptations.yaml`.
  - **Reusable success workflow**: Write a new file under `.test-workspace/skills/<skill-id>.md`.
  - **Project-specific pitfall**: Write a new file under `.test-workspace/pitfalls/<pitfall-id>.md` (use `.test-sop/schemas/ai-test-workflow/templates/pitfall.md` as the template).
  - **Major structural change** (DAG, schema): Create a proposal in `.test-workspace/proposals/<id>/` (do NOT modify `.test-sop/`).

### Step 4.5: Upstream Signal Detection (Promote to SOP)
**Goal**: Lower the cost of feeding generic improvements back to the SOP framework.

**Action**: After Step 4, scan for these signals. If detected, auto-generate a candidate under `.test-workspace/proposals/<auto-id>/` with `target: sop-framework` so the team's SOP liaison can review and submit upstream:

| Signal | Threshold | Likely SOP Gap |
|---|---|---|
| Same `adaptations.yaml` key tweaked manually | ≥ 3 times across runs | Template missing a field |
| New concept appears that has no slot in `schema.yaml` / templates | First occurrence | Protocol missing extension point |
| Same adapter falls back via degradation | ≥ 5 times | Abstraction layer mismatch |
| Same pitfall pattern recorded in ≥ 2 unrelated projects | (cross-team) | Pitfall is universal, not project-specific |
| Agent profile capability gap repeatedly hit | ≥ 3 times | Profile schema incomplete |

**Proposal format** (each candidate):
```
.test-workspace/proposals/<auto-id>/
  ├── README.md          # What & Why (1 paragraph)
  ├── evidence.md        # Run IDs / counts / quotes proving it's generic
  └── suggested-patch.md # Concrete change to .test-sop/ files
```

**Important**: AI only **generates candidates**, never auto-submits. The human SOP liaison reviews and decides whether to file an issue/PR upstream.

> **Important**: All accumulation goes to `.test-workspace/`. The `.test-sop/` framework is read-only and updated only via `git pull`.

---

## 📦 On-Demand Commands

### `/test-sop collect-mcp`

**Purpose**: Re-scan and organize MCP server bindings after initial install.

**Use cases**:
- New MCP servers were added to `.qoder/settings.local.json` / `.cursor/mcp.json` etc.
- Team switched AI tools and wants to re-bind capabilities.
- Need to review/reassign unmapped servers.

**Behavior**:
- Incremental: only adds new bindings; existing ones are preserved unless user confirms override.
- Shows full discovery report with diff preview before applying.
- Allows user to manually assign unmapped servers interactively.

### `/test-sop collect-skill`

**Purpose**: Re-scan and organize skills/pitfalls after initial install.

**Use cases**:
- New skills were added to `.qoder/skills/` since last collection.
- Team wants to deduplicate or re-classify existing workspace skills.
- Manual trigger to consolidate scattered knowledge.

**Behavior**:
- Incremental dedup: only imports candidates not already present in `.test-workspace/skills/` or `pitfalls/`.
- Shows full harvest report; user confirms which candidates to import.
- Supports merge suggestions for near-duplicate skills.
