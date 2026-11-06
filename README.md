# 正式方案文档生产线（solution-doc-pipeline）

> 把一次方案探讨，变成一份可以直接拿去评审、汇报的**正式文档**：自包含 HTML 单文件 + A4 排版 PDF。

无论底座是什么——Agent 平台、业务系统、技术选型——只要你在「探讨方案」，这个 Skill 就能把整个过程沉淀成一份带拓扑图、流程图、技术选型表、署名和二维码的工程蓝图白皮书。

## 产出物形态（三件套，缺一不可）

| 产物 | 特征 |
|---|---|
| `主题名.html` | 单文件自包含：CSS/SVG/二维码全部内嵌，离线可开，可进 Git 评审 |
| `主题名-v版本号.pdf` | A4、章节自动分页、图表不跨页断行、中文命名 |
| 正文标配 | 编号章节 + 图号图注 + 技术选型总表 + ADR 决策表 + 三色 callout（设计要点/风险/已验证模式）+ 封面元数据 + 尾页签名页 |

## 五阶段流程

1. **探讨锁定** —— 先讨论稿后产出；六决策点集中提问（部署/规模/模型/登录/业务/交付）；决策进 ADR 表
2. **底座实证盘点** —— 产出前拆解真实实现，「已验证模式」必须指向读过的代码，严禁虚构
3. **蓝图构建** —— 工程蓝图白皮书风格；图表全部手绘 SVG 内嵌（离线 + 打印保真）；插章走联动改号引擎
4. **署名注入** —— 五件套完整链接 + 封面小二维码 + 尾页签名页大二维码 + 悬浮胶囊组件（打印自动隐藏）
5. **QA 三关 + 交付** —— 结构校验 → 浏览器渲染 QA → Chromium 导出 PDF → 中文命名

## 快速开始

**安装（二选一）：**

```bash
# 方式一：clone 到 skills 目录
git clone https://github.com/simonsxxs/solution-doc-pipeline.git ~/.agents/skills/solution-doc-pipeline

# 方式二：下载 zip 解压到 skills 目录
```

**使用**：装好后对你的 Agent 说——

- 「把这次讨论整理成正式方案文档」
- 「出一份带拓扑图和流程图的部署方案，HTML 加 PDF」
- 「把这个架构设计做成白皮书」

Skill 会自动触发完整生产线。

## 目录结构

```
solution-doc-pipeline/
├── SKILL.md                 # 主指令：五阶段流程 + 红线 + 署名规范
├── templates/doc-skeleton.html   # 文档骨架（实战验证的全套 CSS + 章节模板块）
├── scripts/
│   ├── validate-html.py     # QA 第一关：HTML 结构校验（零依赖）
│   ├── renumber.mjs         # 插章联动改号引擎（逐条断言 + 原子写入）
│   └── export-pdf.sh        # QA 第三关：Chromium → PDF（管道解码 + 完整性校验）
└── assets/                  # 署名五件套 + 微信二维码
```

依赖：`python3`（标准库即可）、`node`（renumber）、`ego-browser`（渲染 QA 与 PDF 导出，可换成任何 Chromium 打印通道）。

## 实战范例

本 Skill 从 **《基于 DeepSeek Harness 的企业级 Agent 平台部署方案》**（DSH-ENT-2026-001）的制作全程提炼：18 章 9 图、五件套署名、双二维码、37 页 A4 PDF，全部由本生产线产出并三关验证。

## 关于作者

- **作者**：simon，一个不懂代码的AI极客
- **微信交流群**：simonsxxs
- **个人网站**：<https://simonsxx.com>
- **GitHub**：<https://github.com/simonsxxs>
- **Gitee**：<https://gitee.com/simonsxx>
