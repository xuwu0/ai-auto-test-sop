# AI 测试 SOP 触发协议（零配置）

[English Version](INSTRUCTIONS.md)

> **致 AI Agent**：当用户输入 `/test-sop` 时，你必须严格遵循本协议。

## 🚀 触发协议

**输入**：用户输入 `/test-sop [需求来源]`

### Step 0：工作区初始化（自动检查）
**动作**：
1. 检查项目根目录下是否存在 `.test-workspace/`。
2. **若不存在**：
   - 创建目录结构：
     ```
     .test-workspace/
     ├── skills/
     ├── pitfalls/
     └── runs/
     ```
   - 拷贝 `.test-sop/config/test-config-template.yaml` → `.test-workspace/config.yaml`
   - 拷贝 `.test-sop/config/adaptations-template.yaml` → `.test-workspace/adaptations.yaml`
   - 拷贝 `.test-sop/config/workspace-gitignore-template` → `.test-workspace/.gitignore`
   - 用占位段落初始化 `.test-workspace/memory.md`（项目背景 / 团队偏好 / 经验教训）。
   - **通知用户**："🆕 工作区已在 .test-workspace/ 初始化，已应用默认配置。"
   - **暂停**：请用户审阅 `.test-workspace/config.yaml`（重点关注 `language`、`capabilities` 与 `mcp.enabled_capabilities`）后再继续。
3. **若已存在**：
   - 跳过初始化，直接进入 Step 1。

**语言锁定**（强制）：
- 读取 `.test-workspace/config.yaml` 中的 `language` 字段。
- 后续 **所有 AI 输出** —— 包括对话回复、测试用例、任务计划、报告、提案、陷阱沉淀 —— 必须使用该语言。
- 这是硬约束。不得根据用户聊天语言自动切换，始终遵守 `config.language`。

### Step 0.5：MCP 自动发现（仅首次安装）
**目标**：大多数 AI 工具项目已自带 MCP server 配置。自动检测并绑定到能力命名空间，免去用户手动填写 `capabilities`/`mcp.enabled_capabilities`。

**触发条件**：此步骤**仅在首次安装时执行**（即 Step 0 创建 `.test-workspace/` 时）。后续可用 `/test-sop collect-mcp` 手动重新扫描。

**动作**：
1. **扫描** 项目根目录，按以下优先级查找第一个存在的 MCP 配置文件（定义在 `.test-sop/adapters/_mcp-discovery.yaml:scan_paths`）：
   - `.qoder/settings.local.json`
   - `.cursor/mcp.json`
   - `.vscode/mcp.json`
   - `mcp.json`
   - `config/mcporter.json`
   - `.claude/claude_desktop_config.json`
2. **解析** JSON，提取 `mcpServers` 下的所有 key（如 `sls-mcp`、`dms-mcp-server`、`arthas`、`playwright-mcp`）。
3. **映射** 每个 server 名称到对应能力，使用 `.test-sop/adapters/_mcp-discovery.yaml:mappings` 中的子串匹配规则（不区分大小写，先匹配者优先）。
4. **应用** 到工作区：
   - 对每个匹配的 `<server> → <capability>`：
     - 将 `<capability>` 追加到 `.test-workspace/config.yaml:mcp.enabled_capabilities`（已存在则跳过）。
     - 设置 `.test-workspace/config.yaml:capabilities.<capability>` 为该 server key。
     - 在 `.test-workspace/adaptations.yaml:mcp_bindings.<capability> = <server-key>` 下记录绑定关系。
   - 未映射的 server：列在发现报告中，标记为 `⚠️ 未映射（请手动分配）`。**绝不猜测。**
   - 冲突（多个 server → 同一能力）：保留第一个作为主绑定，其余列为 `fallback_candidates` 写入 `adaptations.yaml` 注释。
   - 未找到配置文件：静默跳过，`mcp.enabled_capabilities = []` 留待手动配置。
5. **报告** 给用户，例如：
   ```
   🔍 MCP 自动发现 (.qoder/settings.local.json)：
     ✅ sls-mcp           → cap.log.query
     ✅ dms-mcp-server    → cap.database.query
     ✅ arthas            → cap.diagnose.trace
     ⚠️  yuque             → 未映射（请在 adaptations.yaml 中手动分配）
   ```
6. **暂停**，请用户确认绑定结果后再进入 Step 1，尤其当存在未映射 server 时。

**重要**：AI 只是**提议**绑定，用户有最终决定权。在 `execution_mode: assisted` 下，对 `config.yaml` / `adaptations.yaml` 的修改必须先展示 diff。

### Step 0.6：Skill & Pitfall 收割（仅首次安装）
**目标**：大多数 AI 工具项目已有测试相关的 skill 散落在 `.qoder/skills/`、`.cursor/rules/` 等处。自动发现、分类、去重，并归集到 `.test-workspace/skills/` 和 `.test-workspace/pitfalls/`。

**触发条件**：此步骤**仅在首次安装时执行**（即 Step 0 创建 `.test-workspace/` 时）。后续可用 `/test-sop collect-skill` 手动触发。

**动作**：
1. **扫描** 项目中 `.test-sop/adapters/_skill-discovery.yaml:scan_paths` 列出的所有存在的目录。
2. **筛选** 测试相关文件：文件名或内容包含 `_skill-discovery.yaml:relevance_keywords` 中至少一个关键词即视为相关。
3. **分类** 每个候选文件：
   - 包含 pitfall 信号（symptom、root cause、error、workaround、known issue...）→ **踩坑记录**。
   - 包含 skill 信号（step、workflow、procedure、checklist...）→ **技能**。
   - 两者都包含 → 拆分为一个 skill + 一个 pitfall，通过 `Related:` 互链。
4. **去重**：将候选与 `.test-workspace/skills/` 和 `pitfalls/` 现有文件对比。意图重叠 ≥70% 的标记为 DUPLICATE（若有额外信息则建议合并）。
5. **报告** 给用户，例如：
   ```
   🌾 Skill & Pitfall 收割：
     ✅ .qoder/skills/deploy-verify-loop/  → skill: deploy-verify-loop.md
     ✅ .qoder/skills/auto-test-reviewer/   → skill: auto-test-reviewer.md
     ⚠️  .qoder/skills/prd-review/           → 跳过（非测试相关）
     ✅ .cursor/rules/test-pitfalls.md       → pitfall: cursor-test-pitfalls.md
     🔄 .qoder/skills/e2e-verify/           → 重复（与 deploy-verify-loop.md 意图重叠，建议合并）
   ```
6. **暂停** —— 请用户确认哪些候选需要导入。
7. 对确认的候选：
   - **格式归一化**（skill → Trigger/Steps/Output 结构；pitfall → Symptom/Root Cause/Solution 模板）。
   - **写入** `.test-workspace/skills/<id>.md` 或 `.test-workspace/pitfalls/<id>.md`。
   - 添加 `> Source: <原始路径> | Harvested: <日期>` 头部，确保可追溯。
8. **汇总**："已导入 N 个技能 + M 个踩坑记录，跳过 K 个重复项。"

**重要**：AI 只提议导入，用户决定。原始文件**绝不**修改或删除。

### Step 1：Agent 自检引导
**动作**：按以下顺序解析 Agent Profile：
1. **框架预置**：`.test-sop/agents/profiles/<your-agent-name>.md`（如 `profiles/qoder.md`、`profiles/cursor.md`、`profiles/aone-copilot.md`、`profiles/claude-code.md`、`profiles/hermes.md`）。
2. **团队本地**：`.test-workspace/agents/<your-agent-name>.md`。
3. **若都不存在**：
   - 执行 `.test-sop/agents/self-check-instructions.md`。
   - 将生成的 profile 保存到 `.test-workspace/agents/<your-agent-name>.md`（**禁止**写入 `.test-sop/`）。
   - **通知用户**："✅ 已自动生成 Agent Profile，能力已确认。"
4. 加载解析出的 profile，将其 `degradation` 块作为三层继承链的 Layer-3（全局）默认。

### Step 2：加载上下文
**动作**：
1. 读取 `.test-sop/schemas/ai-test-workflow/schema.yaml`。
2. 读取 `.test-sop/schemas/ai-test-workflow/standards/*.md` —— 这是 case-generator / planner / reporter 的**质量契约**，产出对应 artifact 时必须遵守。
3. 读取 `.test-sop/adapters/_capabilities.yaml` —— 这是抽象能力命名空间。具体工具的绑定在 `.test-workspace/adaptations.yaml` 中。
4. 读取 `.test-workspace/config.yaml`，确定：
   - `execution_mode`（full-auto vs assisted）。
   - MCP 工具可用性。
   - 需求级 `degradation` 覆盖（如有）。
5. 读取 `.test-workspace/memory.md` 并扫描 `.test-workspace/skills/` 中可复用的工作流。
6. **确认**："✅ Schema 已加载。模式：[Mode]。工具：[List]。已加载技能：[N] 个。"

### Step 3：工作流执行
**动作**：
- **来源**：读取 `[需求来源]`（只读）。
- **目的地**：创建 `.test-workspace/runs/<req-id>/` 目录。**绝不**写入来源路径。
- **流程**：按照 `schema.yaml` 中定义的 `dag` 执行。
  1. `spec`（生成规格）
  2. `test-cases`（生成测试用例）→ 若 `user_review: true` 则 **等待用户审阅**。
  3. `test-task`（规划策略）→ 若 `user_review: true` 则 **等待用户审阅**。
  4. `test-execution`（执行测试 - 仅 `full-auto` 模式）。
  5. `test-report`（汇总报告）。

### Step 4：自我进化
**动作**：
- 完成后检查异常和可复用模式。
- 若发现新的模式 / 错误，按作用域分流：
  - **细微参数调整**：追加到 `.test-workspace/adaptations.yaml`。
  - **可复用的成功流程**：在 `.test-workspace/skills/<skill-id>.md` 下创建新文件。
  - **项目级踩坑记录**：在 `.test-workspace/pitfalls/<pitfall-id>.md` 下创建新文件，参考 `.test-sop/schemas/ai-test-workflow/templates/pitfall.md` 模板格式。
  - **重大结构变更**（DAG、schema）：在 `.test-workspace/proposals/<id>/` 创建提案（**不要**修改 `.test-sop/`）。

### Step 4.5：上推信号识别（向 SOP 反馈）
**目标**：降低通用改进反馈给 SOP 框架的成本。

**动作**：在 Step 4 之后扫描以下信号，若命中，自动在 `.test-workspace/proposals/<auto-id>/` 下生成候选提案（标记 `target: sop-framework`），供团队的 SOP 联络人定期 review 后决定是否上推：

| 信号 | 阈值 | 可能的 SOP 缺陷 |
|---|---|---|
| 同一个 `adaptations.yaml` 键被手动调整 | ≥ 3 次 | 模板缺字段 |
| 出现 `schema.yaml` / templates 中未定义的新概念 | 首次出现 | 协议缺扩展点 |
| 同一个 adapter 被降级 fallback | ≥ 5 次 | 抽象层不匹配 |
| 同一踩坑模式在 ≥ 2 个不相关项目中出现 | （跨团队） | 这个 pitfall 其实是通用的 |
| Agent profile 能力缺口反复命中 | ≥ 3 次 | profile 协议不完备 |

**提案格式**（每个候选）：
```
.test-workspace/proposals/<auto-id>/
  ├── README.md          # 说明是什么 / 为什么应该上推（1 段）
  ├── evidence.md        # Run ID / 计数 / 引用，证明其通用性
  └── suggested-patch.md # 针对 .test-sop/ 文件的具体修改建议
```

**重要**：AI 只生成候选，**从不自动提交**。是否 issue / PR 到上游，由人类 SOP 联络人 review 决定。

> **重要**：所有沉淀都进入 `.test-workspace/`。`.test-sop/` 框架是只读的，仅通过 `git pull` 更新。

---

## 📦 按需命令

### `/test-sop collect-skill`

**用途**：在初始安装后的任何时间，重新执行 Skill & Pitfall 收割（Step 0.6 逻辑）。

**使用场景**：
- 上次收割后 `.qoder/skills/` 新增了新技能。
- 团队切换了 AI 工具后想重新扫描。
- 手动触发以归集散落的知识。

**行为**：与 Step 0.6 相同，但为**增量去重** —— 仅导入 `.test-workspace/skills/` 和 `pitfalls/` 中尚不存在的候选。

### `/test-sop collect-mcp`

**用途**：在初始安装后的任何时间，重新执行 MCP 自动发现（Step 0.5 逻辑）。

**使用场景**：
- `.qoder/settings.local.json` / `.cursor/mcp.json` 等新增了 MCP server。
- 团队切换了 AI 工具，需要重新绑定能力。
- 某个未映射的 server 重命名后现在能匹配到已知规则。

**行为**：与 Step 0.5 相同，但为**增量模式** —— 仅追加新绑定到 `config.yaml:mcp.enabled_capabilities` / `adaptations.yaml:mcp_bindings`；现有绑定除非用户明确确认覆盖，否则保留。
