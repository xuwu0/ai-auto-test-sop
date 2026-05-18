# AI Auto Test SOP

**通用、AI 代理无关、自进化的 AI 测试框架。**

[English README](README.md) | [版本变更记录](CHANGELOG.md)

## 📖 概述

**AI Auto Test SOP** 是一个标准化的、AI 驱动的自动化测试框架。
与依赖特定工具或僵化工作流的传统测试脚本不同，本 SOP 具备以下特点：

*   **规格无关**：可接受来自 OpenSpec、语雀、Markdown 甚至自然语言的规格说明。
*   **代理无关**：根据 AI 代理（Qoder、Cursor、Aone、Claude Code、Hermes 等）的能力自动调整执行策略。
*   **自进化**：从实际执行中沉淀陷阱和参数适应，越用越智能。

## 🏗️ 架构：框架 vs 工作区

本 SOP 严格区分**通用框架**与**项目侧沉淀**：

```
your-project/
├── .test-sop/              ← 通用框架（只读，通过 git pull 升级）
└── .test-workspace/        ← 项目侧所有文件（配置 + 沉淀 + 产物）
    ├── config.yaml         ← 项目配置
    ├── adaptations.yaml    ← Tier-1 进化（自动调参）
    ├── memory.md           ← 团队偏好与项目上下文
    ├── skills/             ← 可复用成功流程（自动沉淀）
    ├── pitfalls/           ← 项目级踩坑记录
    └── runs/<req-id>/      ← 每个需求的测试产物
```

> **关键原则**：框架是一份**规范**。团队的所有沉淀都在 `.test-workspace/` 中，永不污染 `.test-sop/`。

## 🏁 快速开始

### ⚡ 方案 A：自动初始化（推荐）
*最简单的方式，让 AI 处理所有事情。*

1. **安装框架 + 工作区**：
   ```bash
   git clone https://github.com/xuwu0/ai-auto-test-sop.git .test-sop
   bash .test-sop/install.sh
   ```
   这会自动创建 `.test-workspace/`，包含默认配置、adaptations、memory 以及空的 skills/pitfalls/runs 目录。

2. **激活代理**：
   将 `INSTRUCTIONS.md` 复制到项目根目录（或粘贴到 AI 的自定义指令中）：
   ```bash
   cp .test-sop/INSTRUCTIONS.md .
   ```
   现在输入 `/test-sop <需求源>`，AI 会自动启动、自检并运行。

### 🔧 方案 B：手动配置

1. `git clone https://github.com/xuwu0/ai-auto-test-sop.git .test-sop`
2. 编辑 `.test-workspace/config.yaml`（由 install.sh 自动生成）以匹配你的技术栈。
3. 让 AI 执行 `/test-sop <需求源>`。

### 🔌 MCP 配置（全自动模式必需）

编辑 `.test-workspace/config.yaml`：
```yaml
mcp:
  enabled_capabilities:
    - cap.log.query        # 用于 L2 日志验证
    - cap.database.query   # 用于 L3 数据验证
    - cap.deploy.async     # 用于部署
```
> **💡 没有 MCP 工具？** 设置 `execution_mode: assisted`，AI 将为你生成手动指南。

## 🔄 升级框架

框架持续迭代，升级方式：
```bash
cd .test-sop && git pull origin main
```
你的 `.test-workspace/` 不会被影响。

## 📺 监控与透明度

通过以下文件跟踪 AI 工作流进度：

1. **`.test-workspace/runs/<id>/test-status.json`** —— **"仪表盘"**。检查 `current_step` 与 `retry_count`。
2. **`.test-workspace/runs/<id>/execution-log.md`** —— **"黑匣子"**。实时审计每次 RPC 调用、SQL 查询、Shell 命令。

## 📂 框架目录结构

```text
ai-auto-test-sop/        # 框架仓库（克隆为 .test-sop/）
├── schemas/             # 工作流定义（DAG + 模板）
├── adapters/            # 通用技术适配器
├── agents/              # Profile 契约 + 预置画像 + 自检
├── config/              # 工作区初始化模板
├── INSTRUCTIONS.md
├── install.sh
├── DESIGN.md            # 架构与设计原理
└── README.md
```

## 📄 许可证

MIT
