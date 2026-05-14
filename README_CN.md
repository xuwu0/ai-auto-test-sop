# AI Auto Test SOP

**通用、AI代理无关、自进化的AI测试框架。**

## 📖 概述

**AI Auto Test SOP** 是一个标准化的、AI驱动的自动化测试框架。
与依赖特定工具或僵化工作流的传统测试脚本不同，该SOP具有以下特点：

*   **规格无关**：可接受来自OpenSpec、语雀、Markdown甚至自然语言的规格说明。
*   **代理无关**：根据AI代理的能力自动调整执行策略。
*   **自进化**：从实际执行中构建陷阱和适应性的知识库。

## 🏁 快速开始

### ⚡ 方案A：零配置（推荐给AI代理）
*让AI处理所有事情的最简单方式。*

1. **克隆框架**：
   ```bash
   git clone https://github.com/xuwu0/ai-auto-test-sop.git .test-sop
   cp .test-sop/config/test-config-template.yaml ./test-config.yaml
   ```

2. **激活代理**：
   将 `INSTRUCTIONS.md` 复制到项目根目录（或粘贴到AI的自定义指令中）：
   ```bash
   cp .test-sop/INSTRUCTIONS.md .
   ```
   *现在，只需输入 `/test-sop`，AI就会自动启动、自检并运行！*

### 🔧 方案B：手动配置（适合开发者）

1. **克隆**：`git clone https://github.com/xuwu0/ai-auto-test-sop.git .test-sop`
2. **配置**：`cp .test-sop/config/test-config-template.yaml ./test-config.yaml`
3. **编辑配置**：在 `test-config.yaml` 中定义你的MCP工具和执行模式。
4. **开始**：让AI基于 `.test-sop/` 中的schema执行。

### 🔌 MCP配置（全自动模式必需）
**要启用自动化测试（L2日志、L3数据、部署），必须配置你的MCP工具。**

编辑 `test-config.yaml`：
```yaml
mcp:
  tools:
    sls-mcp: { enabled: true }   # 用于日志验证
    dms-mcp-server: { enabled: true } # 用于数据验证
    group-env: { enabled: true } # 用于部署
  fallback:
    sls-mcp: "跳过L2，标记为SKIPPED"
```
> **💡 没有MCP工具？** 在配置中设置 `execution_mode: assisted`。AI将为你生成手动指南。

## 🔄 更新

SOP框架正在积极开发中。更新方法：
```bash
cd .test-sop && git pull origin main
```

## 📺 监控与透明度

由于AI工作流可能较长，请使用以下工具跟踪进度：

1.  **`test-runs/<id>/test-status.json`**：
    *   **"仪表盘"**。检查 `current_step` 和 `retry_count`。
2.  **`test-runs/<id>/execution-log.md`**：
    *   **"黑匣子"**。包含每个HSF调用、SQL查询和Shell命令的实时审计记录，带有时间戳和参数。
    *   *注意：AI被要求在每次操作前写入此文件。*

## 📂 项目结构

```text
ai-auto-test-sop/
├── schemas/                  # 工作流定义（DAG + 模板）
├── adapters/                 # 技术实现
├── agents/                   # AI代理配置文件与自检
├── knowledge/                # 自进化知识库
├── config/                   # 项目配置模板
├── INSTRUCTIONS.md           # <--- 将此粘贴给AI以启用 /test-sop 触发器
├── install.sh
├── DESIGN.md
└── README.md
```

## 📄 许可证

MIT