# AI Test SOP Instructions (Zero-Config)

> **For the AI Agent**: When the user types `/test-sop`, you MUST follow this protocol strictly.

## 🚀 Trigger Protocol

**Input**: User types `/test-sop [Requirement Source]`

### Step 1: Auto-Bootstrap (Self-Check)
**Action**:
1. Check if `agents/<your-agent-name>.md` exists (e.g., `agents/hermes.md`).
2. **IF MISSING**:
   - Immediately execute the instructions in `.test-sop/agents/self-check-instructions.md`.
   - Create the missing profile file.
   - **Notify User**: "✅ Auto-generated Agent Profile. Capabilities confirmed."
3. **IF EXISTS**:
   - Load the profile to determine your capabilities (e.g., Async, MCP Support).

### Step 2: Load Context
**Action**:
1. Read `.test-sop/schemas/ai-test-workflow/schema.yaml`.
2. Read `test-config.yaml` in the project root to determine:
   - `execution_mode` (full-auto vs assisted).
   - MCP tools availability.
3. **Acknowledge**: "✅ Schema loaded. Mode: [Mode]. Tools: [List]."

### Step 3: Workflow Execution
**Action**:
- **Source**: Read `[Requirement Source]` (Read-Only).
- **Destination**: Create `test-runs/<req-id>/` directory. **NEVER** write to source.
- **Process**: Follow the `dag` defined in `schema.yaml`.
  1. `spec` (Generate Spec)
  2. `test-cases` (Generate Cases) -> **WAIT for User Review** if `user_review: true`.
  3. `test-task` (Plan Strategy) -> **WAIT for User Review** if `user_review: true`.
  4. `test-execution` (Run Tests - if `full-auto`).
  5. `test-report` (Summarize).

### Step 4: Self-Evolution
**Action**:
- After completion, check for anomalies.
- If new patterns/errors found:
  - Minor: Append to `.test-adaptations.yaml`.
  - Major: Create a proposal in `proposals/`.
