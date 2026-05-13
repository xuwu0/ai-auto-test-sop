# AI Auto Test SOP

**Universal, Agent-Agnostic, Self-Evolving AI Testing Framework.**

## 📖 Overview

**AI Auto Test SOP** is a standardized, AI-driven automated testing framework.
Unlike traditional testing scripts that rely on specific tools or rigid workflows, this SOP is:

*   **Spec-Agnostic**: Accepts specs from OpenSpec, Yuque, Markdown, or even natural language.
*   **Agent-Adaptable**: Automatically adjusts its execution strategy based on the AI Agent's capabilities.
*   **Self-Evolving**: Builds a knowledge base of pitfalls and adaptations from real execution.

## 🚀 Key Features

*   **🧩 Schema-Driven Workflow**: Defines artifacts (Test Cases, Tasks, Reports) and their dependencies.
*   **🔌 Pluggable Adapters**: Decouples logic from technology. Switch between HSF/HTTP, SLS/ELK, or Playwright/Selenium just by changing config.
*   **🧠 Self-Check Mechanism**: Not sure if your AI Agent supports a feature? Run the self-check script to generate its own capability profile.
*   **🔄 Knowledge Loop**: Automatically captures failures and "lessons learned" into a structured knowledge base.

## 📂 Project Structure

```text
ai-auto-test-sop/
├── schemas/                  # Workflow definition (DAG + Templates)
├── adapters/                 # Technical implementations (Trigger, Validation, etc.)
├── agents/                   # AI Agent capability profiles & Self-Check
├── knowledge/                # Self-evolving knowledge base (Pitfalls, Best Practices)
├── config/                   # Project configuration templates
├── install.sh                # One-click installation script
└── README.md
```

## 🏁 Quick Start

### 1. Installation

```bash
curl -sSL https://raw.githubusercontent.com/xuwu0/ai-auto-test-sop/main/install.sh | bash
```

### 2. Configure

Edit `test-config.yaml` to declare your project's stack (e.g., Java/Go, HSF/HTTP).

### 3. Agent Self-Check (Optional)

If using a new AI Copilot, ask it to run the self-check:

> "Please execute `ai-auto-test-sop/agents/self-check-instructions.md` and generate your agent profile."

### 4. Start Testing

Provide your spec source (OpenSpec, URL, or text) and let the AI drive the workflow.

## 📄 License

MIT
