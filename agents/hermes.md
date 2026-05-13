# Agent Profile: Hermes

## 1. Capabilities
- [x] File Read/Write/Patch
- [x] Shell Execution
- [x] Background Processes
- [x] **Parallel Agents** (`delegate_task` support)
- [x] State Management (`test-status.json`)

## 2. Execution Mode: **Multi-Agent Orchestration**
- **Supervisor**: Acts as the main orchestrator.
- **Delegation**: Spawns `case-generator`, `planner`, etc., as independent sub-agents using `delegate_task`.
- **Parallelism**: Can run independent validation tasks in parallel.

## 3. Degradation
- If a sub-agent fails, Supervisor captures error and decides to retry or repair.
