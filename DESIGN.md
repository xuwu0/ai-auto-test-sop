# System Design & Architecture

## 0. Framework Boundaries (Critical)

This repository is a **specification (framework)**, not a team's knowledge base. It strictly enforces:

```
your-project/
├── .test-sop/             ← Universal framework (READ-ONLY, updated via `git pull`)
└── .test-workspace/       ← ALL project-side files
    ├── config.yaml        ← project config
    ├── adaptations.yaml   ← Tier-1 evolution
    ├── memory.md          ← team preferences & context
    ├── skills/            ← reusable workflows
    ├── pitfalls/          ← project-specific pitfalls
    └── runs/<req-id>/     ← per-requirement artifacts
```

**Rules**:
*   ✅ DO put in `.test-sop/` (framework): cross-team / cross-language primitives, generic adapters, public AI profiles, format protocols.
*   ❌ DO NOT put in `.test-sop/`: team-specific skills, project pitfalls, local config.
*   ✅ DO put in `.test-workspace/` (downstream): EVERYTHING the team accumulates.
*   The framework upgrades non-destructively: `cd .test-sop && git pull` never touches `.test-workspace/`.

## 1. Core Philosophy

This project is built on three core principles to solve the fragmentation in AI-driven testing:

*   **🚫 Spec-Agnostic**: Requirements can come from OpenSpec, Yuque, Jira, or plain text. The SOP normalizes everything into a standard `spec.md` before processing.
*   **🤖 Agent-Agnostic**: Whether you use Hermes, Aone Copilot, Qoder, or Claude Code, the SOP adapts. It defines **what** needs to be done (Schema) separately from **who** is doing it (Agent Profile).
*   **🔄 Self-Evolving**: Unlike traditional scripts, this SOP learns. It captures runtime feedback into `.test-workspace/` (skills/pitfalls/memory) and adapts parameters into `.test-workspace/adaptations.yaml`, ensuring the next run is smarter than the last.
*   **🤝 Human-in-the-Loop (Assisted Mode)**: The SOP supports "AI Plans, Human Runs" workflows. When tools or permissions are limited, AI generates a structured `manual-test-guide.md` and waits for human input to proceed with validation.

## 2. Architecture Layers

The system is composed of three decoupled layers (framework side). All runtime memory lives in the workspace side (`.test-workspace/`), see §0.

### 2.1 Schema Layer (`schemas/`)
*   **Role**: The Brain. Defines the workflow, artifacts, roles, constraints, and **quality contracts**.
*   **Key Components**:
    *   `schema.yaml` — declares roles, execution modes, communication protocol.
    *   `standards/` — quality contracts for case generation, task planning, and report writing (MUST-rules + self-check lists).
    *   `templates/` — markdown skeletons for every artifact (test-cases, test-task, manual-test-guide, test-report, pitfall).
*   **Why**: Declarative definitions allow changing the process logic and quality bar without code changes.

### 2.2 Adapter Layer (`adapters/`)
*   **Role**: The Hands. Defines **what tools must do**, not how a specific tool does it.
*   **Key Components**:
    *   `_interfaces/` — contracts for each adapter category (trigger / logging / database / deployment / config-center / diagnose). Concrete implementations live in `.test-workspace/adapters/`.
    *   `_capabilities.yaml` — the abstract capability namespace (`cap.trigger.rpc`, `cap.log.query`, ...). Tasks reference capabilities, not tools.
    *   `validation/` — universal L1–L4 validation rules (response / log-path / data-state).
    *   `domains.yaml` — registry mapping each test domain to required capabilities.
*   **Why**: Decouples logic from tools. Swapping logging or RPC backends only requires updating the team's `.test-workspace/adapters/` and `adaptations.yaml`. The framework itself never carries vendor-specific implementations.

### 2.3 Agent Layer (`agents/`)
*   **Role**: The Identity. Defines the capabilities of the AI executor.
*   **Key Components**:
    *   `_interfaces/profile.md` — Profile schema contract every profile MUST satisfy.
    *   `profiles/` — Preset profiles for common agents (`hermes`, `qoder`, `cursor`, `aone-copilot`, `claude-code`).
    *   `template.md` — Blank template for new agents.
    *   `self-check-instructions.md` — Auto-detection protocol (Phase A: 5 infra probes, Phase B: capability namespace probes, Phase C: degradation defaults).
*   **Resolution order** (per INSTRUCTIONS Step 1): `agents/profiles/<name>.md` → `.test-workspace/agents/<name>.md` → self-check.
*   **Why**: Enables **Adaptive Execution**. The framework keeps only the contract + presets; team-specific deviations live in `.test-workspace/agents/`. If an agent lacks a capability, the Schema logic auto-degrades (e.g., Async Deployment → Sync Wait, MCP query → SKIP).

## 3. Execution Routing (Routing Logic)

The Schema routes tasks based on the configuration in `test-config.yaml`:

### Scenario A: Full-Auto Mode (Default)
1.  **Input**: `execution_mode: full-auto`.
2.  **Flow**: Spec → Test Cases → Test Task → **AI Executor** → Test Results → Report.
3.  **Behavior**: The `executor` Agent automatically deploys code, calls RPC/HTTP via the bound trigger adapter, and performs L1-L4 validation using MCP tools.

### Scenario B: Assisted Mode (Human-in-the-Loop)
1.  **Input**: `execution_mode: assisted`.
2.  **Flow**: Spec → Test Cases → Test Task → **Manual Test Guide** → (Human Action) → Test Results → Report.
3.  **Behavior**:
    *   The `planner` Agent generates `manual-test-guide.md` (a step-by-step checklist for the human).
    *   **Wait State**: The AI pauses and waits for the human to execute the steps (e.g., in IDE or Postman) and paste the results/logs.
    *   **Validation**: The `reporter` Agent then analyzes the pasted results against the L1-L4 rules defined in the schema.

## 4. Logging System

The logging system is a core transparency mechanism in the SOP framework, ensuring auditability and traceability of AI workflows.

### 4.1 Execution Log (execution-log.md)
*   **Location**: `.test-workspace/runs/<requirement-id>/execution-log.md`
*   **Purpose**: Black box-style audit record
*   **Content**:
    *   Detailed information and parameters for every RPC / HTTP call
    *   All SQL query statements and results
    *   Shell command execution records
    *   Real-time records with timestamps and parameters
*   **Requirement**: AI must write to this file before every tool call

### 4.2 Log Validation Tiers
The SOP supports a multi-tiered log validation mechanism:

#### L1: Response Validation
- Checks basic API response structure
- Validates success field, code value, data structure

#### L2: Log Path Validation
- **Extract traceId**: Extracts distributed tracing ID from responses
- **Log Query**: Queries logs via the configured logging adapter (capability `cap.log.query`)
- **Validation Rules**:
  - **Completeness**: All expected nodes are present
  - **Order**: Nodes appear in correct sequence
  - **Clean**: No ERROR/WARN logs

#### L3: Data State Validation
- Validates data state changes in database
- Checks expected data persistence and consistency

### 4.3 Log Adapter System
Implements a pluggable design for the logging system through the Adapter layer:

*   `adapters/_interfaces/logging.md` — universal logging adapter contract.
*   `adapters/validation/log-path.md` — universal log-path validation rules.
*   **Switching support**: any backend satisfying `cap.log.query` can be plugged in via `.test-workspace/adapters/logging/<name>.md`.

### 4.4 Log Exclusion Rules
Dynamic log exclusion is supported via `.test-workspace/adaptations.yaml`:
```yaml
- id: log-exclude-patterns
  triggered_by: "L2 Log validation false positive (third-party logs)"
  rule: "L2 Log Validation Exclusion"
  change:
    add: ["<noisy-log-pattern-1>", "<noisy-log-pattern-2>"]
```

## 5. Communication Protocol

Agents communicate via a shared file-based state machine, not through ephemeral chat history.

*   **State File**: `test-status.json`
*   **Rules**:
    1.  **Read-Before-Write**: Every Agent must read the current state before acting.
    2.  **Skip-If-Done**: If a step is already marked complete, the Agent skips it (supports resume).
    3.  **Loop Control**: Defined in `schema.yaml` (e.g., `repair-cycle` triggers on failure, allowing up to 3 retry loops).

## 5. Agent Capabilities vs Execution Modes

The SOP supports two dimensions of flexibility:

| Feature | Mode A: Orchestrator (e.g., Hermes) | Mode B: Serial (e.g., Basic Copilots) |
| :--- | :--- | :--- |
| **Logic** | Supervisor spawns sub-agents via `delegate_task` | Supervisor acts as all roles sequentially |
| **Context** | Clean context per sub-agent | Shared context, risk of window pollution |
| **Deployment** | Async (Fire & Forget) | Sync (Wait & Block) |
| **Resilience** | High (Sub-agents fail independently) | Low (One error blocks all) |

## 6. Degradation Rules: 3-Layer Inheritance

The SOP uses a cascading override model for degradation rules, ensuring flexibility without added complexity for users.

### 6.1 Inheritance Chain (Priority: High → Low)

```
Case Level  →  Requirement Level  →  Global (Agent Profile)
(test-task.md)   (test-config.yaml)    (.test-workspace/agents/<profile>.md)
```

**Merge Algorithm**: Later layers override earlier layers. Unspecified keys pass through (inherit from parent).

### 6.2 Layer Definitions

| Layer | File | Scope | Who Writes |
|-------|------|-------|------------|
| Global | `.test-workspace/agents/<profile>.md` (resolved from `agents/profiles/`) | All requirements, all cases | Once during setup |
| Requirement | `test-config.yaml` | All cases in this requirement | User per requirement |
| Case | `test-task.md` (Section 4) | Single test case only | AI/User per case |

### 6.3 Available Triggers & Actions

**Triggers** (conditions that activate degradation):
| Trigger | Meaning |
|---------|----------|
| `no_mcp` | MCP tools unavailable |
| `no_shell` | Shell execution not supported |
| `no_deploy` | Deployment capability missing |
| `no_database` | Database access unavailable |

**Actions** (what to do when trigger is active):
| Action | Behavior |
|--------|----------|
| `SKIP` | Skip the validation layer, mark as SKIPPED |
| `FAIL` | Mark the case as FAIL immediately |
| `MANUAL` | Degrade to assisted mode, generate manual guide |
| `FALLBACK:<adapter>` | Use alternative adapter (e.g., `FALLBACK:<another-adapter-name>`) |

### 6.4 Example

```yaml
# Global (agents/profiles/hermes.md) - defaults
degradation:
  no_mcp: SKIP
  no_shell: MANUAL
  no_deploy: MANUAL
  no_database: SKIP

# Requirement (test-config.yaml) - override for this requirement
degradation:
  no_mcp: FAIL         # This requirement MUST have L2 log validation

# Case (test-task.md) - TC-003 is special
TC-003:
  degradation:
    no_shell: SKIP     # This offline case doesn't need shell at all
```

**Effective rules for TC-003**: `no_mcp=FAIL`, `no_shell=SKIP`, `no_deploy=MANUAL`, `no_database=SKIP`

### 6.5 User Experience

| Scenario | User Action |
|----------|-------------|
| Defaults are fine | Write nothing (90% of cases) |
| Requirement has special needs | Add 1-2 lines in `test-config.yaml` |
| One case is exceptional | AI adds override in `test-task.md` Section 4 |

## 7. Self-Evolution Loop

The SOP improves itself automatically after every run via a two-tier mechanism:

### 7.1 Runtime Adaptation (Automatic)
*   **File**: `.test-workspace/adaptations.yaml`
*   **Trigger**: Minor parameter adjustments (e.g., timeout thresholds, log exclusions).
*   **Action**: AI modifies the file and applies the new rules in the next run immediately.
*   **Risk**: Low (Scoped to parameters only).

### 7.2 Structural Proposal (Human-in-the-Loop)
*   **Folder**: `.test-workspace/proposals/`
*   **Trigger**: Significant logic, workflow, or schema changes (e.g., adding a new validation layer L5, changing the DAG flow).
*   **Action**:
    1.  AI detects the need for structural change.
    2.  AI generates a directory `.test-workspace/proposals/<proposal-id>/` containing `proposal.md` and a `schema-diff.patch`.
    3.  **Pause**: AI pauses the evolution and prompts the user to review.
    4.  **Decision**:
        *   **Approve**: User manually applies the patch (the framework `.test-sop/` is upstream and may need a PR).
        *   **Reject**: AI deletes the proposal and logs the reason.
*   **Risk**: High (Changes the SOP structure).

### 7.3 Knowledge Capture
*   **Files**:
    *   `.test-workspace/skills/*.md` — reusable success workflows (auto-accumulated)
    *   `.test-workspace/pitfalls/*.md` — project-specific pitfalls
    *   `.test-workspace/memory.md` — team preferences & project context
*   **Trigger**: Encountering a novel bug, tool issue, environment quirk, or a successful reusable pattern.
*   **Action**: AI records the solution to prevent rework in future runs.

This ensures that **Day 2 is always better than Day 1**, balancing speed (Tier 1) with safety (Tier 2).
