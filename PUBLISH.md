# 发布记录：solution-doc-pipeline（正式方案文档生产线）

> 每发布一个平台就更新一行。状态：✅已上架 / ⏳审核中 / ❌失败（写原因）/ ➖不适用

| 平台 | 状态 | 链接 | 发布日期 | 备注 |
|------|------|------|---------|------|
| ima 技能广场 | ➖ | | | 待用户在 ima 客户端手动发布（zip 已备好，见下方物料） |
| GitHub | ✅ | https://github.com/simonsxxs/solution-doc-pipeline | 2026-11-06 | 公开仓库，main 分支，已推送 |
| Gitee | ✅ | https://gitee.com/simonsxx/solution-doc-pipeline | 2026-11-06 | API 建仓 + SSH 推送，与 GitHub 同 commit 镜像 |
| SkillHub | ➖ | | | 待发布（skillhub.cn，微信登录+实名） |
| aiSkill.market | ➖ | | | 待发布（后端爬 GitHub 校验，仓库公开后可提交） |
| ClawHub | ➖ | | | 待发布（GitHub OAuth 一键导入） |
| 扣子（豆包） | ➖ | | | 本 Skill 依赖本地脚本与浏览器，不适合移植为对话机器人 |
| 腾讯元器 | ➖ | | | 同上 |
| 文心智能体 | ➖ | | | 同上 |
| ChatGPT GPTs | ➖ | | | 同上，需 Plus |

## 统一物料

- 发布名：正式方案文档生产线（solution-doc-pipeline）
- 简介（短，50字）：把方案探讨变成可评审的正式文档：自包含 HTML 单文件 + A4 排版 PDF，含拓扑图流程图、署名与二维码。
- 简介（长，200字）：五阶段生产线：探讨锁定决策（ADR）→ 底座实证盘点 → 工程蓝图风格 HTML 构建（手绘 SVG 图表）→ 权威署名注入（五件套 + 双二维码 + 胶囊组件）→ 三关 QA（结构/渲染/PDF）→ Chromium 导出 PDF → 中文命名交付。附带实战验证的文档骨架模板、联动改号引擎、零依赖结构校验与 PDF 导出脚本。源自 DSH 企业级 Agent 平台方案（18 章 9 图、37 页 PDF）的制作全程。
- 分类标签：科技 / 效率工具
- 使用示例（3条）：
  1. 「把这次讨论整理成正式方案文档」
  2. 「出一份带拓扑图和流程图的部署方案，HTML 加 PDF」
  3. 「把这个架构设计做成白皮书」
- 头像/封面：无专属封面，ima 发布时选预设像素图标（分类：科技）
- zip 包：`/tmp/solution-doc-pipeline-ima.zip`（打包脚本产出，≤10MB，含 SKILL.md）
