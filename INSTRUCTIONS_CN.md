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
   - **暂停**：请用户审阅 `.test-workspace/config.yaml`（重点关注 `adapters` 与 `mcp.tools`）后再继续。
3. **若已存在**：
   - 跳过初始化，直接进入 Step 1。

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
