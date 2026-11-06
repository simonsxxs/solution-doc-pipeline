#!/usr/bin/env node
/* renumber.mjs — 方案文档「联动改号」引擎（原子写入版）
 *
 * 用法：node renumber.mjs <file.html> <map.json> [--dry]
 *
 * map.json 结构：
 * {
 *   "replacements": [ ["旧文本", "新文本", 期望次数], ... ],   // 按数组顺序执行；次数不符即失败
 *   "insertions":   [ ["锚点文本", "插入文本", "before|after", 期望次数], ... ]
 * }
 *
 * 原子性：任何一条断言失败 → 全部放弃、不写盘、逐条报错。
 * （实战教训：曾因部分替换失败仍写盘，产出半迁移文档——本脚本的存在的意义就是杜绝此事。）
 *
 * 插入新章节的 map 编写要点（降序原则，NN 从大到小）：
 *   1. 图号：先改图注 <span class="fig-no">图 N</span>，再改正文引用（上下文不同，分开断言）；
 *   2. 章引用：带上下文短语整体替换（"（14 章验收表）"→"（15 章验收表）"、"见 10 章"→"见 11 章"）；
 *   3. 小节号：带标题文字做锚（"17.3 与参照实现"→"18.3 与参照实现"）；
 *   4. id/href/编号标签：id="sNN"、href="#sNN"、<span class="no">NN</span>、<span class="n">NN</span>、章节注释；
 *      ⚠️ 单数字章节带前导零（s06 不是 s6）；
 *   5. 最后 insertions 插新章（锚点=下一章的节注释）与目录条目。
 */
import fs from "node:fs";

const [file, mapPath] = process.argv.slice(2);
const DRY = process.argv.includes("--dry");
if (!file || !mapPath) { console.error("用法：node renumber.mjs <file.html> <map.json> [--dry]"); process.exit(2); }

const map = JSON.parse(fs.readFileSync(mapPath, "utf8"));
let s = fs.readFileSync(file, "utf8");
const errs = [];
const done = [];

const rep = (from, to, expect = 1) => {
  const n = s.split(from).length - 1;
  if (n !== expect) { errs.push(`  [${n}≠${expect}] ${String(from).slice(0, 70)}`); return; }
  s = s.split(from).join(to);
  done.push(`  ✓ ${String(from).slice(0, 40)} → ${String(to).slice(0, 40)} ×${expect}`);
};

const ins = (anchor, text, pos = "after", expect = 1) => {
  const n = s.split(anchor).length - 1;
  if (n !== expect) { errs.push(`  [锚点 ${n}≠${expect}] ${String(anchor).slice(0, 70)}`); return; }
  s = pos === "before" ? s.split(anchor).join(text + anchor) : s.split(anchor).join(anchor + text);
  done.push(`  ✓ 插入@${pos} ${String(anchor).slice(0, 30)}…`);
};

for (const [from, to, expect] of (map.replacements || [])) rep(from, to, expect);
for (const [anchor, text, pos, expect] of (map.insertions || [])) ins(anchor, text, pos, expect);

if (errs.length) {
  console.error(`❌ ${errs.length} 条断言失败，文件未改动（原子保护）：\n${errs.join("\n")}`);
  process.exit(1);
}
if (!DRY) fs.writeFileSync(file, s);
console.log(`${DRY ? "[dry] " : ""}✅ ${done.length} 条改动${DRY ? "（未写盘）" : "已写入"}：\n${done.join("\n")}`);
