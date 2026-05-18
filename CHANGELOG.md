# Changelog

本文档记录 AI Auto Test SOP **框架协议**的版本演进。遵循 [Keep a Changelog](https://keepachangelog.com) 与 [Semantic Versioning](https://semver.org) 规范。

> 框架是只读的。下游团队通过 `cd .test-sop && git pull` 升级，不修改框架自身。
> 团队工作区（`.test-workspace/`）的沉淀**不**记录在此文件。

---

## 升级指引

```bash
# 在你的项目根目录执行
cd .test-sop
git pull origin main
# 检查是否有不兼容变更（见下方 BREAKING 标记）
```

升级时 AI Agent 应自动检测 `schema.yaml` 的 `version` 变化，并提示用户新增能力。

---

## [Unreleased]

### Planned
- `schema.yaml` 增加 `review-cycle` 阶段，落地 KEPA 反向传播
- 各 profile 在 `cap.*` 维度增加 `confidence` 标签（声明 vs 实测）

---

## [1.9] - 2026-05-15

### Added
- **Language Lock 机制**：安装时选择语言（`--lang zh|en`），写入 `config.yaml:language`，AI 启动后强制锁定所有输出语言
- **install.sh** 支持 `--lang|-l` CLI 参数 + 交互式问询（默认 en）
- **config/test-config-template.yaml** 顶部新增 `language: en` 字段
- **agents/_interfaces/profile.md** Identity 段新增 `language` 字段（默认 `inherit-from-config`）
- **agents/template.md** 同步新增 `language` 字段
- **MCP Auto-Discovery**：新增 `adapters/_mcp-discovery.yaml`（扫描路径 + 语义映射规则 + 行为定义）
- **INSTRUCTIONS Step 0.5**（中英）：AI 启动时自动扫描项目已有 MCP 配置文件，子串匹配映射到 capability namespace，绑定结果写入工作区 config/adaptations
- **`/test-sop collect-mcp` 命令**（中英）：后续可随时手动触发增量 MCP 扫描，补充新增的 server 绑定
- **Skill & Pitfall Harvest**：新增 `adapters/_skill-discovery.yaml`（扫描路径 + 相关性关键词 + 分类规则 + 去重策略 + 格式归一化）
- **INSTRUCTIONS Step 0.6**（中英）：首次安装时自动扫描项目已有 AI 技能，筛选测试相关、分类 skill/pitfall、去重后归集到工作区
- **`/test-sop collect-skill` 命令**（中英）：后续可随时手动触发增量收割，补充新增的散落技能

### Changed
- **Step 0.5 / 0.6 触发模式调整**：两个自动发现步骤统一为「仅首次安装时执行」，后续通过按需命令 `/test-sop collect-mcp` `/test-sop collect-skill` 手动触发，避免重复扫描干扰正常流程
- **schema.yaml**：`initialization` 阶段调整为 4 步，第 1 步加载 config 并提取 language
- **INSTRUCTIONS.md / INSTRUCTIONS_CN.md**：Step 0 增加「Language Lock」强制约束块；审阅提示更新为 `language, capabilities, mcp.enabled_capabilities`
- **install.sh**：`sed` 注入 language 到 config.yaml（替代简单 `cp`）；新增 Step 5：根据 `--lang` 自动拷贝 INSTRUCTIONS_CN.md 或 INSTRUCTIONS.md 到项目根 `./INSTRUCTIONS.md`
- **README.md / README_CN.md**：同步说明 `--lang` 参数与自动复制逻辑，目录树增加 `proposals/`

### BREAKING
- 下游已存在的 `.test-workspace/config.yaml` 无 `language` 字段时，AI 应视为缺省 `en`

---

## [1.8] - 2026-05-15

### Changed
- **config/test-config-template.yaml**：全面改为能力命名空间。原有 `adapters: { trigger: hsf, logging: sls, ... }` 改为 `capabilities: { cap.trigger.rpc: <adapter-name>, ... }`；原 `mcp.tools` 具体服务列表改为 `mcp.enabled_capabilities: []`
- **config/.test-adaptations-template.yaml → config/adaptations-template.yaml**：去隐藏点前缀，与拷贝后的 `adaptations.yaml` 命名一致
- **install.sh / INSTRUCTIONS（中英）**：同步拷贝路径与新名
- **install.sh**：Bootstrap workspace 时显式 `mkdir -p $WORKSPACE_DIR/proposals`，与 `skills/` `pitfalls/` `runs/` 对齐

### Removed
- **config/test-config-adaptations-template.yaml**：无任何引用的孤儿文件，与 `.test-adaptations-template.yaml` 重复
- **框架文档全局去厢商私货**（详见 `Documentation` 块）
- **proposals/**（框架根目录）：历史残留的孤儿空目录，与 v1.5「框架只读」边界冲突。所有提案必须写入 `.test-workspace/proposals/<id>/`

### Documentation
- **README / DESIGN 中英**：清除 HSF / SLS / DMS / Aone / Diamond / Arthas / dms-mcp-server / sls-mcp / group-env / Java+Spring Boot / com.thirdparty.* 等带厂商色彩的例子；统一改为能力命名空间与 `<placeholder>` 占位符
- **schemas/ai-test-workflow/templates/pitfall.md**：Tech stack 示例去 Java/Maven 字眼
- **agents/profiles/aone-copilot.md**：能力绑定注释从“SLS / DMS / Aone / Diamond / Arthas adapter”改为中性描述

### BREAKING
- 下游 `.test-workspace/config.yaml` 中的 `adapters:` 字段需迁移为 `capabilities:`字段；`mcp.tools` 具体服务列表需迁移为 `mcp.enabled_capabilities` 并在 `.test-workspace/adaptations.yaml` 中描述具体服务绑定
- 依赖 `config/.test-adaptations-template.yaml` 路径的外部脚本需改为 `config/adaptations-template.yaml`

### Audit — Zero-Vendor-Lock-In Verification (2026-05-15)

全项目厂商私有词扫描已完成，确认框架达成「零厂商私货」状态。

**扫描覆盖词表**：
- 第一轮：`hsf`、`sls`、`dms`、`aone`、`diamond`、`arthas`、`nacos`、`alibaba`、`playwright`、`dubbo`、`tair`、`odps`、`hippo`
- 第二轮：`dms-mcp`、`sls-mcp`、`group-env`、`com.thirdparty`、`spring-boot`、`pandora`、`antx`、`diamondx`、`tddl`、`metaq`、`notify4`

**扫描结果**：25 处匹配项全部经人工判定，**无新增需要清理的残留**。各分类如下：

| 分类 | 位置 | 判定理由 |
|---|---|---|
| 历史记录 | `CHANGELOG.md`（本文件） | 必须保留（记录"清理过什么"） |
| vendor 标识字段 | `agents/profiles/aone-copilot.md`、`agents/profiles/qoder.md` | 保留（profile 身份字段必需） |
| 预置 profile 名举例 | `INSTRUCTIONS{,_CN}.md`、`DESIGN{,_CN}.md`、`README{,_CN}.md`、`agents/_interfaces/profile.md`、`agents/self-check-instructions.md` | 保留（与 `agents/profiles/*.md` 文件实体一一对应，属于事实陈述而非夹带能力） |
| 行业中性举例 | `adapters/_capabilities.yaml`：`examples: [HSF, gRPC, Dubbo, Thrift]`、`[Playwright, Puppeteer, Selenium]` | 保留（并列形式作为协议示意，非偏向单一厂商） |
| 通用开源工具 | `agents/profiles/cursor.md`：`Playwright/Puppeteer CLI` | 保留（开源行业标准，非阿里私有） |

**框架现状**：
- 协议层（`schemas/` + `adapters/_interfaces/` + `agents/_interfaces/`）完全中性
- 模板层（`config/*-template.yaml` + `schemas/ai-test-workflow/templates/*.md`）全部使用 `<placeholder>` 占位
- 文档层（README / DESIGN / INSTRUCTIONS）仅在「列举预置 profile」时出现 vendor 名（事实陈述）
- 具体厂商实现（hsf/sls/dms/aone/diamond/arthas）全部下沉到团队侧 `.test-workspace/adapters/`，由用户私有维护

**审计结论**：v1.8 满足项目零厂商私货架构原则。后续若需新增预置 profile（如新 AI 工具），不应在框架内再引入具体业务适配实现。

**补充清理（Audit 后发现的孤儿目录）**：
- 删除框架根目录的 `proposals/`（含 `.gitkeep`）——上一代设计残留，与 v1.5「`.test-sop/` 只读、所有提案下沉到 `.test-workspace/proposals/`」语义冲突
- `install.sh` 修正：Bootstrap 时显式 `mkdir -p $WORKSPACE_DIR/proposals`，与其他子目录对齐

---

## [1.7] - 2026-05-15

### Added
- **agents/_interfaces/profile.md**：Agent Profile schema 契约（Identity / Infrastructure / Capability Namespace / Degradation / Failure Handling 五段必填）
- **agents/profiles/**：5 份预置画像
  - `hermes.md`：参考实现（Multi-Agent Orchestration，全 MCP 绑定）
  - `qoder.md`：Qoder（Pair-Programming + Sub-Agent，全 MCP）
  - `cursor.md`：Cursor（Single-Agent，无 fan-out）
  - `aone-copilot.md`：Aone Copilot（IDE-bound，全 CLI 绑定到工作区）
  - `claude-code.md`：Claude Code（Multi-Agent，Terminal-native）

### Changed
- **agents/template.md**：升级为 5 段结构，新增 Capability Namespace Support 区块（绑定 `mcp` / `cli` / `native` / `none`）
- **agents/self-check-instructions.md**：从 5 步线性探测重构为 Phase A（基础设施）+ Phase B（能力命名空间）+ Phase C（默认降级）
- **INSTRUCTIONS Step 1（中英）**：解析顺序 `agents/profiles/` → `.test-workspace/agents/` → self-check；自检产物落到工作区，框架只读
- **DESIGN §2.3（中英）**：重写 Agent Layer，明确契约 + 预置 + 工作区三段位置关系
- **schema.yaml**：`initialization` 与 Layer-3 注释同步新解析顺序

### Removed
- **agents/hermes.md**（根目录）：迁入 `agents/profiles/hermes.md`，避免与 self-check 输出位置混淆

### BREAKING
- 下游若有脚本/规则引用 `agents/<name>.md`（无 `profiles/` 前缀），需迁移到 `agents/profiles/<name>.md`（框架预置）或 `.test-workspace/agents/<name>.md`（团队自检产物）
- 旧版 profile 缺少 Section 3（Capability Namespace Support）的需补全；缺失视为 `binding: none` 触发降级

---

## [1.6] - 2026-05-15

### Added
- **adapters/_interfaces/**：6 份接口契约（trigger / logging / database / deployment / config-center / diagnose），明确必需操作、返回格式、降级行为、配置契约、失败语义
- **adapters/_capabilities.yaml**：能力命名空间（`cap.trigger.rpc`、`cap.log.query` 等），任务计划引用能力而非具体工具
- **schemas/ai-test-workflow/standards/**：3 份质量契约
  - `case-generation.md`：覆盖度/原子性/可追溯/验证层 必须规则 + 自检清单
  - `task-planning.md`：执行顺序/前置条件/能力绑定/降级覆盖/爆炸半径/停止条件
  - `report-writing.md`：结论先行/证据关联/语气规则/禁止模式

### Changed
- **adapters/domains.yaml**：从指向具体文件改为指向能力名；修复 `dom.md` / `visual.md` 死链
- **adapters/validation/log-path.md**：去除写死的 SLS 字眼，改为“通过配置的 logging adapter 查询”
- **INSTRUCTIONS Step 2**：加载 standards/ 与 _capabilities.yaml 作为质量与抽象双重上下文
- **DESIGN §2.1 / §2.2**：重写 Schema 层与 Adapter 层描述，引入契约层语义

### Removed
- **阿里私有 adapter 全部下沉**：sls.md / hsf.md / dms.md / aone.md / diamond.md / arthas.md
- 半通用示例：playwright.md / unit-test.md
- 这些实现现应属于团队侧 `.test-workspace/adapters/<category>/<tool>.md`

### BREAKING
- 任何仍引用 `adapters/<category>/<tool>.md`（框架侧具体实现）的下游需要迁移到能力命名、并在工作区写具体实现
- 首次升级后，团队需在 `.test-workspace/adapters/` 下添加本团队的 trigger/logging/database 等具体适配文件

---

## [1.5] - 2026-05-15

### Added
- **框架边界（§0 Framework Boundaries）**：明确 `.test-sop/` 只读、`.test-workspace/` 承载所有沉淀
- **三层降级规则继承链**：Case > Requirement > Global，合并算法 `later overrides earlier`
- **`.test-workspace/` 工作区**：`install.sh` 一键初始化（skills/pitfalls/runs/memory.md/config.yaml/adaptations.yaml）
- **INSTRUCTIONS Step 0**：AI 启动时自动检测并兜底创建工作区
- **INSTRUCTIONS Step 4 上推识别协议**：AI 自动识别"看起来通用"的沉淀，写入 `.test-workspace/proposals/<id>/`，降低反向反馈成本
- **`schemas/ai-test-workflow/templates/pitfall.md`**：通用陷阱沉淀模板
- **中文版 INSTRUCTIONS_CN.md**

### Changed
- 架构层从 4 层（含 Knowledge）简化为 3 层（Schema / Adapter / Agent）
- `output_base`：`test-runs/` → `.test-workspace/runs/<requirement-id>/`
- README / DESIGN 中英双语同步更新

### Removed
- `knowledge/` 目录（团队私有沉淀全部下沉到 `.test-workspace/`，避免框架被污染）

### BREAKING
- 旧版本 `test-runs/` 路径不再使用，下游若有 CI 引用需更新为 `.test-workspace/runs/`
- 旧版本 `.test-adaptations.yaml`（项目根）→ `.test-workspace/adaptations.yaml`

---

## [1.0] - Initial Release

### Added
- 三层架构基线：Schema / Adapter / Agent
- 双执行模式：Full-Auto / Assisted
- L1-L4 校验体系：Response / LogPath / DataState
- 默认 adapters：hsf / sls / dms / aone / arthas / unit-test / playwright
- 触发协议：`/test-sop` 入口

---

## 维护者升级触发清单

满足以下任一条件，SOP **必须**发版：

| 触发 | 版本类型 | 示例 |
|---|---|---|
| 出现新主流 AI 工具 / IDE | MINOR | Cursor v2、新 IDE 接入 |
| MCP / 协议层升级 | MINOR | MCP spec 大版本变更 |
| 新增降级 trigger / artifact | MINOR | 增加 `no_network` trigger |
| 模板字段在 ≥ 3 个团队反馈缺失 | PATCH | pitfall.md 缺 `severity` 字段 |
| 多团队 fallback 同一 adapter | MINOR | 抽象层不对，需重设计 |
| 单团队具体经验 | ❌ 不发版 | 留在工作区 |
| 业务规则 | ❌ 不发版 | 不属于 SOP 范畴 |
