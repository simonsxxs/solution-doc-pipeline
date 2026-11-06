---
name: solution-doc-pipeline
description: "正式方案文档生产线。当用户要把方案、架构设计、部署方案、白皮书、解决方案做成正式文档（HTML 单文件 + PDF），或要求文档里带拓扑图、流程图、技术选型表、署名、二维码时使用。覆盖全流程：探讨锁定决策（ADR）→ 底座实证盘点 → 工程蓝图风格 HTML 构建（手绘 SVG 图表）→ simon 权威署名注入（五件套 + 双二维码 + 胶囊组件）→ 三关 QA（结构 / 渲染 / PDF）→ Chromium 导出 PDF → 中文命名交付。源自 DSH 企业级 Agent 平台方案（DSH-ENT-2026-001，2026-11-06 实战定稿，37 页 PDF 验证）。触发词：正式方案、出方案文档、方案 PDF、部署方案文档、白皮书、企业级方案、拓扑图流程图、方案转 PDF。即使用户只说『把这个整理成正式文档』，也应先读本 skill 再动手。"
---

# 正式方案文档生产线（solution-doc-pipeline）

把一次方案探讨变成一份**可以直接拿去评审/汇报的正式文档**：自包含 HTML 单文件 + 排版 PDF。本 skill 是从 DSH 企业级 Agent 平台方案（DSH-ENT-2026-001）的制作全程提炼的流水线，与具体业务无关。

**产出物形态**（三件套，缺一不可）：

1. `主题名.html` —— 单文件自包含（CSS/SVG/二维码全部内嵌，离线可开）；
2. `主题名-v版本号.pdf` —— A4、章节自动分页、中文命名；
3. 正文标配：编号章节（01–NN）、图号图注（图 N）、技术选型总表、ADR 决策表、三色 callout（设计要点 / 风险 / 已验证模式）、封面元数据、目录、尾页签名页。

## 一、五阶段流程

### 阶段 1 · 探讨锁定（先讨论，后产出）

- 先给**方案骨架讨论稿**（分层表格 + 每主题 5–10 行设计主张），不要直接写正式文档。
- 用一次集中提问锁定决策点（ask_user_question，每题带推荐项）。通用六问：**部署形态 / 规模阶段 / 模型或核心依赖 / 登录与账号 / 一期业务范围 / 交付形式**。用户自由回答的按原意归纳，不硬套选项。
- 决策落成文档开头的 **ADR 表**（编号 D1…Dn：决策/结论/理由）。
- 补充用户没想到但绕不开的维度（安全审计、成本、升级、合规……），列入讨论稿。

### 阶段 2 · 底座实证盘点（Grounding，防止纸上谈兵）

- 产出前先拆解方案所依赖的**真实实现**：版本号、服务/API 层、已有参照实现（读源码/文档，记录具体事实）。
- 文档中专设「底座能力盘点」章 + 「已验证模式」绿色 callout：**每条「已验证」声明必须指向真实读过的实现**，严禁虚构。
- 记录版本红线（如预发布版必须锁定 + 预发回归）。

### 阶段 3 · 构建写作（工程蓝图白皮书风格）

- 从 `templates/doc-skeleton.html` 起步：全套 CSS（纸感底色 / 墨蓝油墨 / 靛蓝强调 / 衬线标题 / 等宽技术标注 / 打印 CSS）已内置并经 37 页 PDF 验证。
- **图表全部手绘 SVG 内嵌**（不依赖 Mermaid CDN——离线与打印保真）。规矩：
  - 每图有 `figure.fig` 卡片 + `fig-no`（图 N）+ 标题 + 说明；viewBox 整百宽；文字 11–13px。
  - 每个 SVG 的 `<marker id>` **全文档唯一**（如 af1、af2…），否则箭头错乱。
  - 双行文字用两个 `<text>`（SVG 不自动换行）；旋转标签会误报溢出，QA 时跳过带 transform 的 text。
- 结构顺序：封面（kicker/标题/副题/署名行/chips/元数据表+小二维码）→ 目录（sticky，JS 滚动高亮）→ 编号章节 → 尾页签名页（colophon）→ footer。
- 大文档分部分写作再合并（cat），**插入新章节必须用联动改号**（见第三节）。

### 阶段 4 · 署名注入（simon 专属，权威资产）

署名五件套以本 skill `assets/signature.json` 为副本，**权威源**是 `~/project/05_skills/reverse-system-replica-engineer/assets/`（变更后刷新副本）。三个注入位置：

| 位置 | 内容 |
|---|---|
| 封面署名行 | simon（大字）· 一个不懂代码的 AI 极客 · 微信 \| GitHub \| Gitee \| 个人网站（完整 URL，`<a>` 可点击） |
| 尾页签名页（colophon） | 深蓝卡片：大名 + tagline + 微信二维码大图（150px 白底卡）+ 五件套链接 + 文档元信息 |
| footer 一行 | 作者全称 + 四个完整链接 |

附加：封面元数据区放**小二维码**（84px）；如需悬浮胶囊（加入社区 + 悬停弹 QR + 链接），用权威源的 `scripts/add-signature.mjs` 在临时目录生成 `static/signature.js/css` 后**内嵌**进 HTML（保持单文件自包含），并在打印 CSS 中隐藏胶囊。

红线：**链接必须写完整 URL**（https:// 前缀，不留裸用户名）；署名信息一律从资产读取，不凭记忆手打。

### 阶段 5 · QA 三关 + PDF 交付

**第一关 结构**：`python3 scripts/validate-html.py <file.html>`（标签配平，Python html.parser，无需联网装依赖）。

**第二关 渲染**（ego-browser）：加载 file:// 后 evaluate 检查——
- 无横向溢出（scrollWidth vs clientWidth）；
- 每个 SVG 的非 transform 文本不越界（getBBox vs viewBox，锚点换算）；
- 目录锚点全部可解析；图片 naturalWidth>0；署名链接计数；关键 class 存在。

**第三关 PDF**：`scripts/export-pdf.sh <file.html> <out.pdf>`（内部走 ego-browser CDP printToPDF）。前置条件：HTML 必须带**打印 CSS**（骨架已含）：

- `@page{size:A4;margin:14mm 12mm 16mm}`；`.sec{page-break-before:always}`（首章豁免）；封面 `page-break-after:always`；
- 图/callout `page-break-inside:avoid`；表格行级 avoid；`print-color-adjust:exact`（深色封面/二维码保色）；
- 悬浮胶囊、进度条、打印按钮 `display:none`。

交付命名：`中文主题名-v版本号.pdf`（如 `基于DeepSeek-Harness的企业级Agent平台部署方案-v1.1.pdf`），HTML 同名或保留工程名由用户定。

## 二、QA 之后的验收口径

- HTML：结构合法 + 渲染零 issue + 修改后必须**重跑两关**（本 session 曾因改号脚本断言失败写过半迁移文件——改号必须原子，见下）。
- PDF：`%PDF-` 头 + `%%EOF` 尾 + mdls 页数合理（37 页方案 ≈ 4.5MB 属正常，二维码/深色页是体积大头）。

## 三、插入章节：联动改号（renumber）

插一章 = 全文档连锁改动，手工必漏。用 `scripts/renumber.mjs`（map.json 驱动，逐条断言次数，**全部通过才写盘**）。降序原则清单（NN 从大到小处理）：

1. 图号：`图 8→图 9 … 图 N→图 N+1`（注意图注和正文引用是**不同上下文**，分开替换、次数分别断言）；
2. 章引用：`（14 章…）→（15 章…）`、`见 10 章→见 11 章` 等带上下文短语；
3. 小节号：`17.3 标题→18.3 标题`（带标题文字做锚）；
4. `id="sNN"` / `href="#sNN"` / `<span class="no">NN</span>` / `<span class="n">NN</span>` / 章节注释 —— **单数字有前导零**（s06 不是 s6，别踩坑）；
5. 最后插新章（锚点=下一章的节注释）+ 目录条目 + 选型表/路线图联动行。

## 四、何时不用本 skill

- 普通 README、单页笔记、聊天里直接回答的方案——直接写，不必上生产线。
- 需要协作评注的文档（飞书文档更合适）；需要频繁小改的活文档（本产物是**定稿交付物**，评审稿也按版本冻结）。

## 五、目录与实战参照

```
solution-doc-pipeline/
├── SKILL.md                  # 本文件
├── templates/doc-skeleton.html
├── scripts/validate-html.py  # QA 第一关
├── scripts/renumber.mjs      # 联动改号引擎（原子写入）
├── scripts/export-pdf.sh     # QA 第三关（Chromium → PDF）
└── assets/signature.json + wechat-qr.b64
```

实战范例：`~/Documents/deepseek-harness/default-workspace/` 下的《基于DeepSeek-Harness的企业级 Agent 平台部署方案》（HTML + 37 页 PDF，含 18 章 9 图、五件套署名、双二维码、悬浮胶囊）。
