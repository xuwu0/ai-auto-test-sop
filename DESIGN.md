# System Design & Architecture

## 1. Core Philosophy

This project is built on three core principles to solve the fragmentation in AI-driven testing:

*   **🚫 Spec-Agnostic**: Requirements can come from OpenSpec, Yuque, Jira, or plain text. The SOP normalizes everything into a standard `spec.md` before processing.
*   **🤖 Agent-Agnostic**: Whether you use Hermes, Aone Copilot, Qoder, or Claude Code, the SOP adapts. It defines **what** needs to be done (Schema) separately from **who** is doing it (Agent Profile).
*   **🔄 Self-Evolving**: Unlike traditional scripts, this SOP learns. It captures runtime feedback into `knowledge/` and adapts parameters into `.test-adaptations.yaml`, ensuring the next run is smarter than the last.
*   **🤝 Human-in-the-Loop (Assisted Mode)**: The SOP supports "AI Plans, Human Runs" workflows. When tools or permissions are limited, AI generates a structured `manual-test-guide.md` and waits for human input to proceed with validation.

## 2. Architecture Layers

The system is composed of four decoupled layers:

### 2.1 Schema Layer (`schemas/`)
*   **Role**: The Brain. Defines the workflow, artifacts, roles, and constraints.
*   **Key Component**: `schema.yaml`. It defines:
    *   **Roles** (Supervisor, Generator, Planner, Executor, Reporter).
    *   **Execution Modes** (Full-Auto vs Assisted).
    *   **Communication Protocol** (`test-status.json` state machine).
*   **Why**: Declarative definitions allow changing the process logic without code changes.

### 2.2 Adapter Layer (`adapters/`)
*   **Role**: The Hands. Encapsulates technical implementations.
*   **Key Component**: `adapters/`. Contains markdown files defining how to perform specific actions (e.g., `trigger/hsf.md`, `logging/sls.md`).
*   **Why**: Decouples logic from tools. Switching from SLS to ELK only requires changing the adapter file.

### 2.3 Agent Layer (`agents/`)
*   **Role**: The Identity. Defines the capabilities of the AI executor.
*   **Key Component**: `agents/<profile>.md`. Describes what the Agent can do (e.g., background processes, parallel tasks, file access).
*   **Why**: Enables **Adaptive Execution**. If an Agent lacks "Background Process" capability, the Schema logic automatically degrades from Async Deployment to Sync Wait.

### 2.4 Knowledge Layer (`knowledge/`)
*   **Role**: The Memory. Stores historical data, pitfalls, and best practices.
*   **Key Component**: `knowledge/index.yaml` & `pitfalls/*.md`.
*   **Why**: Prevents rework. The Agent consults this layer before running tests to avoid known issues.

## 3. Execution Routing (Routing Logic)

The Schema routes tasks based on the configuration in `test-config.yaml`:

### Scenario A: Full-Auto Mode (Default)
1.  **Input**: `execution_mode: full-auto`.
2.  **Flow**: Spec → Test Cases → Test Task → **AI Executor** → Test Results → Report.
3.  **Behavior**: The `executor` Agent automatically deploys code, calls HSF/HTTP, and performs L1-L4 validation using MCP tools.

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
*   **Location**: `test-runs/<requirement-id>/execution-log.md`
*   **Purpose**: Black box-style audit record
*   **Content**:
    *   Detailed information and parameters for every HSF call
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
- **SLS Log Query**: Queries SLS logs via MCP tools
- **Validation Rules**:
  - **Completeness**: All expected nodes are present
  - **Order**: Nodes appear in correct sequence
  - **Clean**: No ERROR/WARN logs

#### L3: Data State Validation
- Validates data state changes in database
- Checks expected data persistence and consistency

### 4.3 Log Adapter System
Implements a pluggable design for the logging system through the Adapter layer:

*   **adapters/logging/sls.md**: SLS log query adapter
*   **adapters/validation/log-path.md**: Log path validation rules
*   **Switching Support**: Easy switching from SLS to other log systems like ELK

### 4.4 Log Exclusion Rules
Supports dynamic log exclusion via `.test-adaptations.yaml`:
```yaml
- id: sls-exclude-patterns
  triggered_by: "L2 Log validation false positive (3rd party logs)"
  rule: "L2 Log Validation Exclusion"
  change:
    add: ["com.thirdparty.*", "external-gateway.*"]
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
(test-task.md)   (test-config.yaml)    (agents/<profile>.md)
```

**Merge Algorithm**: Later layers override earlier layers. Unspecified keys pass through (inherit from parent).

### 6.2 Layer Definitions

| Layer | File | Scope | Who Writes |
|-------|------|-------|------------|
| Global | `agents/<profile>.md` | All requirements, all cases | Once during setup |
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
| `FALLBACK:<adapter>` | Use alternative adapter (e.g., `FALLBACK:arthas`) |

### 6.4 Example

```yaml
# Global (agents/hermes.md) - defaults
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
*   **File**: `.test-adaptations.yaml`
*   **Trigger**: Minor parameter adjustments (e.g., timeout thresholds, log exclusions).
*   **Action**: AI modifies the file and applies the new rules in the next run immediately.
*   **Risk**: Low (Scoped to parameters only).

### 7.2 Structural Proposal (Human-in-the-Loop)
*   **Folder**: `proposals/`
*   **Trigger**: Significant logic, workflow, or schema changes (e.g., adding a new validation layer L5, changing the DAG flow).
*   **Action**:
    1.  AI detects the need for structural change.
    2.  AI generates a directory `proposals/<proposal-id>/` containing `proposal.md` and a `schema-diff.patch`.
    3.  **Pause**: AI pauses the evolution and prompts the user to review.
    4.  **Decision**:
        *   **Approve**: AI merges the patch into `schemas/` and cleans up `proposals/`.
        *   **Reject**: AI deletes the proposal and logs the reason.
*   **Risk**: High (Changes the SOP structure).

### 7.3 Knowledge Capture
*   **File**: `knowledge/pitfalls/*.md` & `knowledge/index.yaml`
*   **Trigger**: Encountering a novel bug, tool issue, or environment quirk.
*   **Action**: AI records the solution to prevent rework in future runs.

This ensures that **Day 2 is always better than Day 1**, balancing speed (Tier 1) with safety (Tier 2).
