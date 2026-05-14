# Agent Self-Check Instructions (Auto-Run by AI)

**Trigger**: Run this ONLY if `agents/<current-agent>.md` does not exist.

**Goal**: Determine your capabilities and generate a profile file.

## Step-by-Step Execution

1. **File I/O Test**: Create a temp file, write text, read it back, then delete.
   - *If successful*, record: `[x] File Read/Write`
2. **Shell Test**: Run `echo "test"`
   - *If output matches*, record: `[x] Shell Execution`
3. **Background Test**: Run `sleep 2 &` (or equivalent)
   - *If immediate return*, record: `[x] Background Processes`
4. **MCP Test**: Run `which mcporter` or equivalent check.
   - *If found*, record: `[x] MCP/CLI Support`
5. **Parallel Test**: Check if `delegate_task` (or equivalent parallel execution) is available.
   - *If yes*, record: `[x] Parallel Agents`

## Output Generation
Copy `agents/template.md` and fill in the results from Step 1-5.
Save as `agents/<your-current-agent-name>.md`.

> **Note**: Use the agent name you know yourself by (e.g., 'hermes', 'claude-code', 'aone-copilot').
