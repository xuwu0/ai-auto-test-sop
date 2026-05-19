# 系统设计与架构

## 0. 框架边界（核心约定）

本仓库是一份**通用规范（框架）**，不是某个团队的知识库。它严格区分两层：

```
your-project/
├── .test-sop/             ← 通用框架（只读，通过 `git pull` 升级）
└── .test-workspace/       ← 项目侧所有文件
    ├── config.yaml        ← 项目配置
    ├── adaptations.yaml   ← Tier-1 进化
    ├── memory.md          ← 团队偏好与上下文
    ├── skills/            ← 可复用流程
    ├── pitfalls/          ← 项目级踩坑
    └── runs/<req-id>/     ← 每个需求的产物
```

**规则**：
*   ✅ 框架 `.test-sop/` 中应放：跨团队/跨语言的原语、通用 adapter、公共 AI profile、格式协议。
*   ❌ 框架 `.test-sop/` 中不应放：团队私有 skill、项目踩坑、本地配置。
*   ✅ 工作区 `.test-workspace/` 中应放：团队的所有沉淀。
*   框架升级是**非破坏式**的：`cd .test-sop && git pull` 永不影响 `.test-workspace/`。

## 1. 核心理念

本项目基于三个核心原则构建，旨在解决AI驱动测试中的碎片化问题：

*   **🚫 规格无关**：需求可以来自OpenSpec、语雀、Jira或纯文本。SOP在处理前将所有内容标准化为统一的 `spec.md`。
*   **🤖 代理无关**：无论你使用Hermes、Aone Copilot、Qoder还是Claude Code，SOP都能适应。它将**需要做什么**（Schema）与**谁来做**（Agent Profile）分开定义。
*   **🔄 自进化**：与传统脚本不同，这个SOP会学习。它将运行时反馈沉淀到 `.test-workspace/`（skills/pitfalls/memory），并将参数调整到 `.test-workspace/adaptations.yaml` 中，确保下次运行比上次更智能。
*   **🤝 人工协同（辅助模式）**：SOP支持"AI规划，人工执行"的工作流程。当工具或权限有限时，AI生成结构化的 `manual-test-guide.md` 并等待人工输入以继续验证。

## 2. 架构分层

框架侧由三个解耦的层次组成；所有运行时记忆都落在工作区侧（`.test-workspace/`），参见 §0。

### 2.1 Schema层（`schemas/`）
*   **角色**：大脑。定义工作流、产物、角色、约束以及**质量契约**。
*   **核心组件**：
    *   `schema.yaml` — 声明角色、执行模式、通信协议。
    *   `standards/` — 测试用例生成、任务规划、报告撰写的质量契约（MUST 规则 + 自检清单）。
    *   `templates/` — 所有 artifact 的 markdown 骨架（test-cases、test-task、manual-test-guide、test-report、pitfall）。
*   **为什么**：声明式定义允许在不更改代码的情况下改变流程逻辑与质量基线。

### 2.2 Adapter层（`adapters/`）
*   **角色**：双手。定义**工具必须做什么**，而不是某个具体工具怎么做。
*   **核心组件**：
    *   `_interfaces/` — 各类 adapter 的接口契约（trigger / logging / database / deployment / config-center / diagnose）。具体实现落在 `.test-workspace/adapters/` 下。
    *   `_capabilities.yaml` — 抽象能力命名空间（`cap.trigger.rpc`、`cap.log.query` 等）。任务计划引用能力名，不引用具体工具。
    *   `_mcp-discovery.yaml` — MCP 自动发现规则（扫描路径 + 子串→能力映射）。由 `install.sh` 在首次安装时使用。
    *   `_skill-discovery.yaml` — Skill & Pitfall 收割规则（扫描路径 + 相关性关键词 + 分类信号）。由 `install.sh` 在首次安装时使用。
    *   `validation/` — 通用 L1–L4 校验规则（response / log-path / data-state）。
    *   `domains.yaml` — 测试领域到所需能力的注册表。
*   **为什么**：将逻辑与工具解耦。替换日志后端或 RPC 后端只需更新团队的 `.test-workspace/adapters/` 与 `adaptations.yaml`。框架本身从不携带任何厂商专有实现。

### 2.3 Agent 层（`agents/`）
*   **角色**：身份。定义 AI 执行者的能力。
*   **核心组件**：
    *   `_interfaces/profile.md` —— 所有 profile 必须满足的 schema 契约。
    *   `profiles/` —— 常见 AI 的预置画像（`hermes`、`qoder`、`cursor`、`aone-copilot`、`claude-code`）。
    *   `template.md` —— 新 agent 的空白模板。
    *   `self-check-instructions.md` —— 自检协议（Phase A：5 项基础设施探测；Phase B：能力命名空间探测；Phase C：默认降级）。
*   **解析顺序**（见 INSTRUCTIONS Step 1）：`agents/profiles/<name>.md` → `.test-workspace/agents/<name>.md` → 自检。
*   **为什么**：实现**自适应执行**。框架只保留契约 + 预置；团队差异沉淀在 `.test-workspace/agents/`。Agent 缺能力时 Schema 自动降级（如异步部署 → 同步等待、MCP 查询 → SKIP）。

## 3. 执行路由（路由逻辑）

Schema根据 `test-config.yaml` 中的配置路由任务：

### 场景A：全自动模式（默认）
1.  **输入**：`execution_mode: full-auto`。
2.  **流程**：Spec → Test Cases → Test Task → **AI Executor** → Test Results → Report。
3.  **行为**：`executor` Agent自动部署代码，调用RPC/HTTP，并使用MCP工具执行L1-L4验证。

### 场景B：辅助模式（人工协同）
1.  **输入**：`execution_mode: assisted`。
2.  **流程**：Spec → Test Cases → Test Task → **Manual Test Guide** → (人工操作) → Test Results → Report。
3.  **行为**：
    *   `planner` Agent生成 `manual-test-guide.md`（为人工提供的逐步检查清单）。
    *   **等待状态**：AI暂停并等待人工执行步骤（例如在IDE或Postman中）并粘贴结果/日志。
    *   **验证**：`reporter` Agent然后根据schema中定义的L1-L4规则分析粘贴的结果。

## 4. 日志记录系统

日志记录是SOP框架的核心透明度机制，确保AI工作流的可审计性和可追踪性。

### 4.1 执行日志（execution-log.md）
*   **位置**：`.test-workspace/runs/<requirement-id>/execution-log.md`
*   **作用**：黑匣子式审计记录
*   **记录内容**：
    *   每个 RPC / HTTP 调用的详细信息和参数
    *   所有SQL查询语句和结果
    *   Shell命令的执行记录
    *   时间戳和参数的实时记录
*   **要求**：AI必须在每次工具调用前写入此文件

### 4.2 日志验证层级
SOP支持多层级日志验证机制：

#### L1: 响应验证
- 检查API响应的基本结构
- 验证success字段、code值、data结构

#### L2: 日志路径验证（Log Path Validation）
- **提取 traceId**：从响应中提取分布式追踪ID
- **日志查询**：通过配置的 logging adapter（能力 `cap.log.query`）查询日志
- **验证规则**：
  - **完整性**：所有预期节点都存在
  - **顺序性**：节点按正确顺序出现
  - **清洁度**：无ERROR/WARN日志

#### L3: 数据状态验证
- 验证数据库中的数据状态变化
- 检查预期的数据持久化和一致性

### 4.3 日志适配器系统
通过 Adapter 层实现日志系统的可插拔设计：

*   `adapters/_interfaces/logging.md` —— 通用 logging adapter 契约。
*   `adapters/validation/log-path.md` —— 通用日志路径验证规则。
*   **切换支持**：任何满足 `cap.log.query` 的后端可通过 `.test-workspace/adapters/logging/<name>.md` 接入。

### 4.4 日志排除规则
通过 `.test-workspace/adaptations.yaml` 支持动态日志排除：
```yaml
- id: log-exclude-patterns
  triggered_by: "L2 Log validation false positive (third-party logs)"
  rule: "L2 Log Validation Exclusion"
  change:
    add: ["<noisy-log-pattern-1>", "<noisy-log-pattern-2>"]
```

## 5. 通信协议

Agent通过基于共享文件的状态机进行通信，而不是通过临时的聊天历史。

*   **状态文件**：`test-status.json`
*   **规则**：
    1.  **先读后写**：每个Agent在行动前必须读取当前状态。
    2.  **已完成则跳过**：如果步骤已被标记为完成，Agent跳过它（支持恢复）。
    3.  **循环控制**：在 `schema.yaml` 中定义（例如 `repair-cycle` 在失败时触发，允许最多3次重试循环）。

## 5. Agent能力 vs 执行模式

SOP支持两个维度的灵活性：

| 特性 | 模式A：编排器（例如Hermes） | 模式B：串行（例如基础Copilots） |
| :--- | :--- | :--- |
| **逻辑** | Supervisor通过`delegate_task`生成子代理 | Supervisor顺序扮演所有角色 |
| **上下文** | 每个子代理的独立上下文 | 共享上下文，有窗口污染风险 |
| **部署** | 异步（启动后不管） | 同步（等待并阻塞） |
| **韧性** | 高（子代理独立失败） | 低（一个错误阻塞所有） |

## 6. 自进化循环

SOP通过双层机制在每次运行后自动改进：

### 第1层：运行时适应（自动）
*   **文件**：`.test-workspace/adaptations.yaml`
*   **触发**：次要参数调整（例如超时阈值、日志排除）。
*   **动作**：AI修改文件并在下次运行中立即应用新规则。
*   **风险**：低（仅限于参数）。

### 第2层：结构提案（人工协同）
*   **文件夹**：`.test-workspace/proposals/`
*   **触发**：重大逻辑、工作流或schema更改（例如添加新的验证层L5、更改DAG流程）。
*   **动作**：
    1.  AI检测到结构更改的需求。
    2.  AI生成一个目录 `.test-workspace/proposals/<proposal-id>/`，包含 `proposal.md` 和 `schema-diff.patch`。
    3.  **暂停**：AI暂停进化并提示用户审查。
    4.  **决定**：
        *   **批准**：用户手动应用补丁（框架 `.test-sop/` 是上游，可能需要 PR）。
        *   **拒绝**：AI删除提案并记录原因。
*   **风险**：高（更改SOP结构）。

### 第3层：知识捕获
*   **文件**：
    *   `.test-workspace/skills/*.md` —— 可复用的成功流程（自动沉淀）
    *   `.test-workspace/pitfalls/*.md` —— 项目级踩坑
    *   `.test-workspace/memory.md` —— 团队偏好与项目上下文
*   **初始播种**：`install.sh` 在首次安装时自动从已知 AI 工具目录（`.qoder/skills/`、`.cursor/rules/` 等）收集已有技能和踩坑。提供 Day-0 知识库，无需手动迁移。
*   **运行时触发**：遇到新bug、工具问题、环境怪癖，或成功可复用的模式。
*   **动作**：AI记录解决方案以防止未来运行中的重复工作。
*   **按需重新扫描**：`/test-sop collect-skill` 提供 AI 驱动的增量收割，包含语义去重和格式归一化。

这确保了**第2天总是比第1天更好**，平衡速度（第1层）与安全（第2层）。