# AI Test SOP Instructions (Zero-Config)

[中文版](INSTRUCTIONS_CN.md)

> **For the AI Agent**: When the user types `/test-sop`, you MUST follow this protocol strictly.

## 🚀 Trigger Protocol

**Input**: User types `/test-sop [Requirement Source]`

### Step 0: Workspace Bootstrap (Auto-Check)
**Action**:
1. Check if `.test-workspace/` exists in the project root.
2. **IF NOT EXISTS**:
   - Create directory structure:
     ```
     .test-workspace/
     ├── skills/
     ├── pitfalls/
     └── runs/
     ```
   - Copy `.test-sop/config/test-config-template.yaml` → `.test-workspace/config.yaml`
   - Copy `.test-sop/config/adaptations-template.yaml` → `.test-workspace/adaptations.yaml`
   - Copy `.test-sop/config/workspace-gitignore-template` → `.test-workspace/.gitignore`
   - Seed `.test-workspace/memory.md` with placeholder sections (Project Context / Team Preferences / Lessons Learned).
   - **Notify**: "🆕 Workspace initialized at .test-workspace/. Default config applied."
   - **PAUSE**: Ask user to review `.test-workspace/config.yaml` (especially `language`, `capabilities`, and `mcp.enabled_capabilities`) before proceeding.
3. **IF EXISTS**:
   - Skip bootstrap; proceed to Step 1.

**Language Lock** (mandatory):
- Read `language` field from `.test-workspace/config.yaml`.
- **ALL subsequent AI outputs** — including chat responses, test cases, task plans, reports, proposals, and pitfall entries — MUST use this language.
- This is a hard constraint. Do NOT switch language based on the user's chat language; always follow `config.language`.

### Step 0.5: MCP Auto-Discovery (First Install Only)
**Goal**: Most AI-tool projects already ship MCP server configs. Auto-detect and bind them to capability namespaces, so users don't fill `capabilities`/`mcp.enabled_capabilities` by hand.

**Trigger**: This step runs **only during first install** (i.e., when Step 0 creates `.test-workspace/`). For subsequent re-scans, use `/test-sop collect-mcp`.

**Action**:
1. **Scan** project root for the first existing MCP config file, in this priority order (defined in `.test-sop/adapters/_mcp-discovery.yaml:scan_paths`):
   - `.qoder/settings.local.json`
   - `.cursor/mcp.json`
   - `.vscode/mcp.json`
   - `mcp.json`
   - `config/mcporter.json`
   - `.claude/claude_desktop_config.json`
2. **Parse** the JSON and extract all keys under `mcpServers` (e.g., `sls-mcp`, `dms-mcp-server`, `arthas`, `playwright-mcp`).
3. **Map** each server name to a capability using the substring rules in `.test-sop/adapters/_mcp-discovery.yaml:mappings` (case-insensitive, first match wins).
4. **Apply** to the workspace:
   - For each matched `<server> → <capability>`:
     - Append `<capability>` to `.test-workspace/config.yaml:mcp.enabled_capabilities` (skip if already present).
     - Set `.test-workspace/config.yaml:capabilities.<capability>` to the server key.
     - Record the binding under `.test-workspace/adaptations.yaml:mcp_bindings.<capability> = <server-key>`.
   - Unmapped servers: list them in the discovery report as `⚠️ unmapped (please assign manually)`. **NEVER guess.**
   - Conflicts (multiple servers → same capability): keep the first as primary; list others as `fallback_candidates` in `adaptations.yaml`.
   - No config file found: skip silently; leave `mcp.enabled_capabilities = []`.
5. **Report** to the user, e.g.:
   ```
   🔍 MCP Auto-Discovery (.qoder/settings.local.json):
     ✅ sls-mcp           → cap.log.query
     ✅ dms-mcp-server    → cap.database.query
     ✅ arthas            → cap.diagnose.trace
     ⚠️  yuque             → unmapped (please assign in adaptations.yaml)
   ```
6. **PAUSE** and ask the user to confirm bindings before Step 1, especially if any unmapped server may carry a capability.

**Important**: AI only **proposes** bindings; user has final say. Edits to `config.yaml` / `adaptations.yaml` MUST be diff-shown before applied if `execution_mode: assisted`.

### Step 0.6: Skill & Pitfall Harvest (First Install Only)
**Goal**: Most AI-tool projects already have testing skills scattered across `.qoder/skills/`, `.cursor/rules/`, etc. Auto-discover, classify, deduplicate, and consolidate them into `.test-workspace/skills/` and `.test-workspace/pitfalls/`.

**Trigger**: This step runs **only during first install** (i.e., when Step 0 creates `.test-workspace/`). For subsequent harvests, use `/test-sop collect-skill`.

**Action**:
1. **Scan** all directories listed in `.test-sop/adapters/_skill-discovery.yaml:scan_paths` that exist in the project.
2. **Filter** for test-related files: a file is relevant if its filename OR content contains at least one keyword from `_skill-discovery.yaml:relevance_keywords`.
3. **Classify** each candidate:
   - Contains pitfall signals (symptom, root cause, error, workaround, known issue...) → **Pitfall**.
   - Contains skill signals (step, workflow, procedure, checklist...) → **Skill**.
   - Contains both → split into one skill + one pitfall, cross-linked via `Related:`.
4. **Deduplicate**: Compare against existing `.test-workspace/skills/` & `pitfalls/`. If intent overlaps ≥70% with an existing file, mark as DUPLICATE (suggest merge if extra info).
5. **Report** to the user, e.g.:
   ```
   🌾 Skill & Pitfall Harvest:
     ✅ .qoder/skills/deploy-verify-loop/  → skill: deploy-verify-loop.md
     ✅ .qoder/skills/auto-test-reviewer/   → skill: auto-test-reviewer.md
     ⚠️  .qoder/skills/prd-review/           → skipped (not test-related)
     ✅ .cursor/rules/test-pitfalls.md       → pitfall: cursor-test-pitfalls.md
     🔄 .qoder/skills/e2e-verify/           → DUPLICATE of deploy-verify-loop.md (suggest merge)
   ```
6. **PAUSE** — ask user to confirm which candidates to import.
7. For confirmed candidates:
   - **Normalize** format (skill → Trigger/Steps/Output structure; pitfall → Symptom/Root Cause/Solution template).
   - **Write** to `.test-workspace/skills/<id>.md` or `.test-workspace/pitfalls/<id>.md`.
   - Add `> Source: <original-path> | Harvested: <date>` header for traceability.
8. **Summary**: "Imported N skills + M pitfalls, skipped K duplicates."

**Important**: AI only proposes imports; user decides. Original files are NEVER modified or deleted.

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

### `/test-sop collect-skill`

**Purpose**: Re-run the Skill & Pitfall Harvest (Step 0.6 logic) at any time after initial install.

**Use cases**:
- New skills were added to `.qoder/skills/` since the last collection.
- Team wants to re-scan after switching AI tools.
- Manual trigger to consolidate scattered knowledge.

**Behavior**: Same as Step 0.6, but with **incremental dedup** — only imports candidates not already present in `.test-workspace/skills/` or `pitfalls/`.

### `/test-sop collect-mcp`

**Purpose**: Re-run the MCP Auto-Discovery (Step 0.5 logic) at any time after initial install.

**Use cases**:
- New MCP servers were added to `.qoder/settings.local.json` / `.cursor/mcp.json` etc.
- Team switched AI tools and wants to re-bind capabilities.
- An unmapped server got renamed and now matches a known pattern.

**Behavior**: Same as Step 0.5, but **incremental** — only adds new bindings to `config.yaml:mcp.enabled_capabilities` / `adaptations.yaml:mcp_bindings`; existing bindings are preserved unless the user explicitly confirms an override.
