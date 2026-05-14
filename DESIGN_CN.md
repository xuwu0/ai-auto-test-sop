# 系统设计与架构

## 1. 核心理念

本项目基于三个核心原则构建，旨在解决AI驱动测试中的碎片化问题：

*   **🚫 规格无关**：需求可以来自OpenSpec、语雀、Jira或纯文本。SOP在处理前将所有内容标准化为统一的 `spec.md`。
*   **🤖 代理无关**：无论你使用Hermes、Aone Copilot、Qoder还是Claude Code，SOP都能适应。它将**需要做什么**（Schema）与**谁来做**（Agent Profile）分开定义。
*   **🔄 自进化**：与传统脚本不同，这个SOP会学习。它将运行时反馈捕获到 `knowledge/` 中，并将参数调整到 `.test-adaptations.yaml` 中，确保下次运行比上次更智能。
*   **🤝 人工协同（辅助模式）**：SOP支持"AI规划，人工执行"的工作流程。当工具或权限有限时，AI生成结构化的 `manual-test-guide.md` 并等待人工输入以继续验证。

## 2. 架构分层

系统由四个解耦的层次组成：

### 2.1 Schema层（`schemas/`）
*   **角色**：大脑。定义工作流、产物、角色和约束。
*   **核心组件**：`schema.yaml`。它定义了：
    *   **角色**（Supervisor、Generator、Planner、Executor、Reporter）
    *   **执行模式**（Full-Auto vs Assisted）
    *   **通信协议**（`test-status.json` 状态机）
*   **为什么**：声明式定义允许在不更改代码的情况下更改流程逻辑。

### 2.2 Adapter层（`adapters/`）
*   **角色**：双手。封装技术实现。
*   **核心组件**：`adapters/`。包含定义如何执行特定操作的markdown文件（例如 `trigger/hsf.md`、`logging/sls.md`）。
*   **为什么**：将逻辑与工具解耦。从SLS切换到ELK只需要更改adapter文件。

### 2.3 Agent层（`agents/`）
*   **角色**：身份。定义AI执行者的能力。
*   **核心组件**：`agents/<profile>.md`。描述Agent可以做什么（例如后台进程、并行任务、文件访问）。
*   **为什么**：实现**自适应执行**。如果Agent缺乏"后台进程"能力，Schema逻辑会自动从异步部署降级为同步等待。

### 2.4 Knowledge层（`knowledge/`）
*   **角色**：记忆。存储历史数据、陷阱和最佳实践。
*   **核心组件**：`knowledge/index.yaml` & `pitfalls/*.md`。
*   **为什么**：防止重复工作。Agent在运行测试前会查询此层以避免已知问题。

## 3. 执行路由（路由逻辑）

Schema根据 `test-config.yaml` 中的配置路由任务：

### 场景A：全自动模式（默认）
1.  **输入**：`execution_mode: full-auto`。
2.  **流程**：Spec → Test Cases → Test Task → **AI Executor** → Test Results → Report。
3.  **行为**：`executor` Agent自动部署代码，调用HSF/HTTP，并使用MCP工具执行L1-L4验证。

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
*   **位置**：`test-runs/<requirement-id>/execution-log.md`
*   **作用**：黑匣子式审计记录
*   **记录内容**：
    *   每个HSF调用的详细信息和参数
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
- **提取traceId**：从响应中提取分布式追踪ID
- **SLS日志查询**：通过MCP工具查询SLS日志
- **验证规则**：
  - **完整性**：所有预期节点都存在
  - **顺序性**：节点按正确顺序出现
  - **清洁度**：无ERROR/WARN日志

#### L3: 数据状态验证
- 验证数据库中的数据状态变化
- 检查预期的数据持久化和一致性

### 4.3 日志适配器系统
通过Adapter层实现日志系统的可插拔设计：

*   **adapters/logging/sls.md**：SLS日志查询适配器
*   **adapters/validation/log-path.md**：日志路径验证规则
*   **切换支持**：可轻松从SLS切换到ELK等其他日志系统

### 4.4 日志排除规则
通过 `.test-adaptations.yaml` 支持动态日志排除：
```yaml
- id: sls-exclude-patterns
  triggered_by: "L2 Log validation false positive (3rd party logs)"
  rule: "L2 Log Validation Exclusion"
  change:
    add: ["com.thirdparty.*", "external-gateway.*"]
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
*   **文件**：`.test-adaptations.yaml`
*   **触发**：次要参数调整（例如超时阈值、日志排除）。
*   **动作**：AI修改文件并在下次运行中立即应用新规则。
*   **风险**：低（仅限于参数）。

### 第2层：结构提案（人工协同）
*   **文件夹**：`proposals/`
*   **触发**：重大逻辑、工作流或schema更改（例如添加新的验证层L5、更改DAG流程）。
*   **动作**：
    1.  AI检测到结构更改的需求。
    2.  AI生成一个目录 `proposals/<proposal-id>/`，包含 `proposal.md` 和 `schema-diff.patch`。
    3.  **暂停**：AI暂停进化并提示用户审查。
    4.  **决定**：
        *   **批准**：AI将补丁合并到 `schemas/` 并清理 `proposals/`。
        *   **拒绝**：AI删除提案并记录原因。
*   **风险**：高（更改SOP结构）。

### 3. 知识捕获
*   **文件**：`knowledge/pitfalls/*.md` & `knowledge/index.yaml`
*   **触发**：遇到新bug、工具问题或环境怪癖。
*   **动作**：AI记录解决方案以防止未来运行中的重复工作。

这确保了**第2天总是比第1天更好**，平衡速度（第1层）与安全（第2层）。