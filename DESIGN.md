# System Design & Architecture

## 1. Core Philosophy

This project is built on three core principles to solve the fragmentation in AI-driven testing:

*   **🚫 Spec-Agnostic**: Requirements can come from OpenSpec, Yuque, Jira, or plain text. The SOP normalizes everything into a standard `spec.md` before processing.
*   **🤖 Agent-Agnostic**: Whether you use Hermes, Aone Copilot, Qoder, or Claude Code, the SOP adapts. It defines **what** needs to be done (Schema) separately from **who** is doing it (Agent Profile).
*   **🔄 Self-Evolving**: Unlike traditional scripts, this SOP learns. It captures runtime feedback into `knowledge/` and adapts parameters into `.test-adaptations.yaml`, ensuring the next run is smarter than the last.

## 2. Architecture Layers

The system is composed of four decoupled layers:

### 2.1 Schema Layer (`schemas/`)
*   **Role**: The Brain. Defines the workflow, artifacts, roles, and constraints.
*   **Key Component**: `schema.yaml`. It defines the DAG (Directed Acyclic Graph) of artifacts (Spec → Cases → Task → Results → Report) and the **Roles** (Supervisor, Generator, Planner, etc.).
*   **Why**: By defining the workflow declaratively, we can change the process without changing code.

### 2.2 Adapter Layer (`adapters/`)
*   **Role**: The Hands. Encapsulates technical implementations.
*   **Key Component**: `adapters/`. Contains markdown files defining how to perform specific actions (e.g., `trigger/hsf.md`, `logging/sls.md`).
*   **Why**: Decouples logic from tools. Switching from SLS to ELK only requires changing the adapter file, not the core workflow.

### 2.3 Agent Layer (`agents/`)
*   **Role**: The Identity. Defines the capabilities of the AI executor.
*   **Key Component**: `agents/<profile>.md`. Describes what the Agent can do (e.g., background processes, parallel tasks, file access).
*   **Why**: Enables **Adaptive Execution**. If an Agent lacks "Background Process" capability, the Schema logic automatically degrades from Async Deployment to Sync Wait.

### 2.4 Knowledge Layer (`knowledge/`)
*   **Role**: The Memory. Stores historical data, pitfalls, and best practices.
*   **Key Component**: `knowledge/index.yaml` & `pitfalls/*.md`.
*   **Why**: Prevents rework. The Agent consults this layer before running tests to avoid known issues.

## 3. Communication Protocol

Agents communicate via a shared file-based state machine, not through ephemeral chat history.

*   **State File**: `test-status.json`
*   **Rules**:
    1.  **Read-Before-Write**: Every Agent must read the current state before acting.
    2.  **Skip-If-Done**: If a step is already marked complete in state, the Agent skips it (supports resume).
    3.  **Loop Control**: Defined in `schema.yaml`. E.g., `repair-cycle` triggers if `test-results.json` contains failures, allowing up to 3 retry loops.

## 4. Execution Modes

The SOP supports two modes based on Agent capabilities:

| Feature | Mode A: Orchestrator (e.g., Hermes) | Mode B: Serial (e.g., Basic Copilots) |
| :--- | :--- | :--- |
| **Logic** | Supervisor spawns sub-agents via `delegate_task` | Supervisor acts as all roles sequentially |
| **Context** | Clean context per sub-agent | Shared context, risk of window pollution |
| **Deployment** | Async (Fire & Forget) | Sync (Wait & Block) |
| **Resilience** | High (Sub-agents fail independently) | Low (One error blocks all) |

## 5. Self-Evolution Loop

The SOP improves itself automatically after every run:

1.  **Runtime Adaptation**: If a test fails due to a threshold (e.g., timeout), the Agent records a new rule in `.test-adaptations.yaml`.
2.  **Knowledge Capture**: If a novel bug or tool issue is encountered, the Agent creates a new entry in `knowledge/pitfalls/`.
3.  **Structural Proposal**: If the workflow itself is flawed, the Agent generates a `proposal.md` for human review.

This ensures that **Day 2 is always better than Day 1**.
