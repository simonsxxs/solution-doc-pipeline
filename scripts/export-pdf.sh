#!/bin/bash
# export-pdf.sh — 方案文档 QA 第三关：Chromium 打印引擎导出 PDF（ego-browser CDP）
#
# 用法：./export-pdf.sh <input.html> <output.pdf>
# 依赖：ego-browser CLI、python3、mdls(macOS)
#
# 坑位说明（实战验证）：
#   1. ego-browser 的 node 沙箱文件系统只读 → PDF base64 只能走 stdout/stderr 管道传出；
#      本脚本两侧都捕获，取最长的 base64 块（%PDF 的 b64 以 JVBERi 开头）。
#   2. generateDocumentOutline 参数旧版 Chromium 可能拒绝 → 自动降级重试。
#   3. 前置条件：HTML 必须带打印 CSS（@page A4 / 分页 / avoid / print-color-adjust:exact），
#      doc-skeleton.html 已内置。
set -uo pipefail

IN="${1:?用法：export-pdf.sh <input.html> <output.pdf>}"
OUT="${2:?用法：export-pdf.sh <input.html> <output.pdf>}"
IN_ABS=$(cd "$(dirname "$IN")" && pwd)/$(basename "$IN")
[ -f "$IN_ABS" ] || { echo "❌ 文件不存在：$IN_ABS"; exit 2; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

ego-browser nodejs -e '
const task = await taskSpace("doc-pdf-export");
const page = task.page("p1");
await page.goto("file://'"$IN_ABS"'");
await new Promise(r=>setTimeout(r,2000));
const params = {printBackground:true, preferCSSPageSize:true};
let r;
try { r = await page.cdp("Page.printToPDF", {...params, generateDocumentOutline:true}); }
catch(e) { r = await page.cdp("Page.printToPDF", params); }
if (!r || !r.data || r.data.length < 10000) { console.error("PDF-FAIL: printToPDF 返回异常"); process.exit(1); }
process.stdout.write(r.data);
try { await task.finish({keep:[]}); } catch(e) {}
' >"$TMP/out.b64" 2>"$TMP/err.log"

# 从 stdout/stderr 中提取最长的 base64 块（PDF b64 特征：以 JVBERi 开头）
# ⚠️ 大 base64 不走 argv/变量（macOS ARG_MAX 限制），直接落临时文件
python3 - "$TMP" > "$TMP/final.b64" <<'PY'
import sys, os, re
d = sys.argv[1]
t = ""
for f in ("out.b64", "err.log"):
    p = os.path.join(d, f)
    if os.path.exists(p):
        t += open(p, errors="ignore").read()
cands = [m for m in re.findall(r'[A-Za-z0-9+/=]{500,}', t) if m.startswith("JVBERi")]
if not cands:
    cands = re.findall(r'[A-Za-z0-9+/=]{500,}', t)  # 兜底：不以前缀过滤
if not cands:
    sys.exit("未捕获到 PDF base64 数据（检查 ego-browser 是否正常、页面是否可加载）")
print(max(cands, key=len))
PY
[ -s "$TMP/final.b64" ] || { echo "❌ base64 提取失败"; tail -3 "$TMP/err.log" 2>/dev/null; exit 1; }

# ⚠️ 大 base64 不走 argv（macOS ARG_MAX 限制），一律走临时文件
python3 - "$TMP/final.b64" "$OUT" <<'PY'
import sys, base64
raw = base64.b64decode(open(sys.argv[1]).read().strip())
assert raw[:5] == b'%PDF-', "PDF 头缺失"
assert b'%%EOF' in raw[-64:], "PDF 尾不完整（%%EOF 缺失）"
open(sys.argv[2], 'wb').write(raw)
print(f"✅ {sys.argv[2]}（{len(raw)} bytes，头尾校验通过）")
PY
[ $? -eq 0 ] || exit 1

PAGES=$(mdls -raw -name kMDItemNumberOfPages "$OUT" 2>/dev/null)
if [ -z "$PAGES" ] || [ "$PAGES" = "(null)" ]; then
  # mdls 依赖 Spotlight 索引，新文件可能未索引 → 用 PDF 结构粗算页数兜底
  PAGES=$(python3 -c "
import sys,re
raw=open('$OUT','rb').read()
import re
print(max(len(re.findall(rb'/Type\s*/Page[^s]', raw)), 1))
")
fi
echo "📄 页数：${PAGES:-未知} ｜ 命名检查：应为「中文主题名-v版本号.pdf」"
