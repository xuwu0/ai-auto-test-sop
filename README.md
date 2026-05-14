# AI Auto Test SOP

**Universal, Agent-Agnostic, Self-Evolving AI Testing Framework.**

## 📖 Overview

**AI Auto Test SOP** is a standardized, AI-driven automated testing framework.
Unlike traditional testing scripts that rely on specific tools or rigid workflows, this SOP is:

*   **Spec-Agnostic**: Accepts specs from OpenSpec, Yuque, Markdown, or even natural language.
*   **Agent-Agnostic**: Automatically adjusts its execution strategy based on the AI Agent's capabilities.
*   **Self-Evolving**: Builds a knowledge base of pitfalls and adaptations from real execution.

## 🏁 Quick Start

### ⚡ Option A: Zero-Config (Recommended for AI Agents)
*The simplest way to let the AI handle everything.*

1. **Clone Framework**:
   ```bash
   git clone https://github.com/xuwu0/ai-auto-test-sop.git .test-sop
   cp .test-sop/config/test-config-template.yaml ./test-config.yaml
   ```

2. **Activate Agent**:
   Copy the `INSTRUCTIONS.md` to your project root (or paste it into your AI's Custom Instructions):
   ```bash
   cp .test-sop/INSTRUCTIONS.md .
   ```
   *Now, just type `/test-sop` and the AI will auto-boot, self-check, and run!*

### 🔧 Option B: Manual Setup (For Developers)

1. **Clone**: `git clone https://github.com/xuwu0/ai-auto-test-sop.git .test-sop`
2. **Configure**: `cp .test-sop/config/test-config-template.yaml ./test-config.yaml`
3. **Edit Config**: Define your MCP tools and execution mode in `test-config.yaml`.
4. **Start**: Ask your AI to execute based on the schema in `.test-sop/`.

### 🔌 MCP Configuration (Required for Full-Auto Mode)
**To enable automated testing (L2 Logs, L3 Data, Deployment), you must configure your MCP tools.**

Edit `test-config.yaml`:
```yaml
mcp:
  tools:
    sls-mcp: { enabled: true }   # For Log Validation
    dms-mcp-server: { enabled: true } # For Data Validation
    group-env: { enabled: true } # For Deployment
  fallback:
    sls-mcp: "Skip L2, report as SKIPPED"
```
> **💡 No MCP tools?** Set `execution_mode: assisted` in config. The AI will generate a Manual Guide for you.

## 🔄 Updating

The SOP framework is under active development. To update:
```bash
cd .test-sop && git pull origin main
```

## 📂 Project Structure

```text
ai-auto-test-sop/
├── schemas/                  # Workflow definition (DAG + Templates)
├── adapters/                 # Technical implementations
├── agents/                   # AI Agent profiles & Self-Check
├── knowledge/                # Self-evolving knowledge base
├── config/                   # Project configuration templates
├── INSTRUCTIONS.md           # <--- Paste this to AI to enable /test-sop trigger
├── install.sh
├── DESIGN.md
└── README.md
```

## 📄 License

MIT
