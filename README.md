# AI Auto Test SOP

**Universal, Agent-Agnostic, Self-Evolving AI Testing Framework.**

## 📖 Overview

**AI Auto Test SOP** is a standardized, AI-driven automated testing framework.
Unlike traditional testing scripts that rely on specific tools or rigid workflows, this SOP is:

*   **Spec-Agnostic**: Accepts specs from OpenSpec, Yuque, Markdown, or even natural language.
*   **Agent-Agnostic**: Automatically adjusts its execution strategy based on the AI Agent's capabilities.
*   **Self-Evolving**: Builds a knowledge base of pitfalls and adaptations from real execution.

## 🚀 Key Features

*   **🧩 Schema-Driven Workflow**: Defines artifacts (Test Cases, Tasks, Reports) and their dependencies.
*   **🔌 Pluggable Adapters**: Decouples logic from technology. Switch between HSF/HTTP, SLS/ELK, or Playwright/Selenium just by changing config.
*   **🧠 Self-Check Mechanism**: Not sure if your AI Agent supports a feature? Run the self-check script to generate its own capability profile.
*   **🔄 Knowledge Loop**: Automatically captures failures and "lessons learned" into a structured knowledge base.

## 🏁 Quick Start

### 1. Installation

```bash
curl -sSL https://raw.githubusercontent.com/xuwu0/ai-auto-test-sop/main/install.sh | bash
```

### 2. MCP Configuration (⚠️ Crucial Step)

**To enable automated testing (L2 Logs, L3Data, Deployment), you must configure your MCP tools.**

Edit `test-config.yaml` to declare which tools are available in your environment.

```yaml
# test-config.yaml

mcp:
  tools:
    # Logging Tool (Required for L2 Validation)
    sls-mcp:
      enabled: true
    
    # Database Tool (Required for L3 Validation)
    dms-mcp-server:
      enabled: true
      
    # Deployment Tool (Required for Auto-Deploy)
    group-env:
      enabled: true

  # Fallback: What to do if tools are unavailable
  fallback:
    sls-mcp: "Skip L2, report as SKIPPED"
```

> **💡 Don't have MCP tools?** Set `execution_mode: assisted` in your config. The SOP will generate a **Manual Guide** for you to run tests yourself.

### 3. Agent Self-Check (Optional)

If using a new AI Copilot, ask it to run the self-check:

> "Please execute `.test-sop/agents/self-check-instructions.md` and generate your agent profile."

### 4. Start Testing

Provide your spec source (OpenSpec, URL, or text) and let the AI drive the workflow.

## 🔄 Updating

The SOP framework is under active development. To update your project to the latest version:

```bash
cd .test-sop && git pull origin main
```

> **Note**: Always pull before starting a new test cycle to ensure you have the latest Schema definitions and Adapters.

## 📂 Project Structure

```text
ai-auto-test-sop/
├── schemas/                  # Workflow definition (DAG + Templates)
├── adapters/                 # Technical implementations (Trigger, Validation, etc.)
├── agents/                   # AI Agent capability profiles & Self-Check
├── knowledge/                # Self-evolving knowledge base (Pitfalls, Best Practices)
├── config/                   # Project configuration templates (inc. MCP setup)
├── install.sh                # One-click installation script
├── DESIGN.md                 # Architecture and design explanation
└── README.md
```

## 📄 License

MIT
