#!/usr/bin/env python3
"""validate-html.py — 方案文档 QA 第一关：HTML 结构校验（标签配平）。

用法：python3 validate-html.py <file.html>
规则：html.parser 栈式校验；VOID 元素豁免；错误列表输出；退出码 0=通过。
零依赖（仅标准库），无需联网。
"""
import sys
from html.parser import HTMLParser

VOID = {'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input',
        'link', 'meta', 'param', 'source', 'track', 'wbr'}


class Validator(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.stack = []
        self.errs = []

    def handle_starttag(self, tag, attrs):
        if tag not in VOID:
            self.stack.append((tag, self.getpos()))

    def handle_endtag(self, tag):
        if tag in VOID:
            return
        if self.stack and self.stack[-1][0] == tag:
            self.stack.pop()
        else:
            # 回溯找匹配：把途中的未闭合元素记为错误（比直接报 mismatch 信息量大）
            names = [t for t, _ in self.stack]
            if tag in names:
                while self.stack and self.stack[-1][0] != tag:
                    t, p = self.stack.pop()
                    self.errs.append(f"unclosed <{t}> opened at {p}, closed by </{tag}> at {self.getpos()}")
                self.stack.pop()
            else:
                top = f" (top is <{self.stack[-1][0]}>)" if self.stack else ""
                self.errs.append(f"stray </{tag}> at {self.getpos()}{top}")


def main():
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(2)
    v = Validator()
    with open(sys.argv[1], encoding='utf-8') as f:
        v.feed(f.read())
    for t, p in v.stack:
        v.errs.append(f"unclosed <{t}> opened at {p}")
    if v.errs:
        print(f"❌ {len(v.errs)} 处结构错误：")
        for e in v.errs[:30]:
            print("  -", e)
        sys.exit(1)
    print("✅ HTML 结构校验通过（标签全部配平）")


if __name__ == '__main__':
    main()
