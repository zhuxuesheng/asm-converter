# 汇编语言调用约定技术文档

[![GitHub Pages](https://img.shields.io/badge/docs-GitHub%20Pages-blue)](https://zhuxuesheng.github.io/asm-converter/)

面向汇编语言专家的全面调用约定参考资料。

## 📖 在线阅读

**[https://zhuxuesheng.github.io/asm-converter/](https://zhuxuesheng.github.io/asm-converter/)**

## 文档内容

- **汇编语法对比** - Go Plan9、Intel、AT&T 三种语法详解
- **x86/x64 调用约定** - cdecl、stdcall、fastcall、System V AMD64、Microsoft x64
- **ARM 调用约定** - AAPCS (ARM32)、AAPCS64 (ARM64)
- **PowerPC 调用约定** - PPC32、PPC64 ELFv1/v2
- **操作系统差异** - Linux、Windows、macOS 系统调用约定
- **语言互操作** - C/C++、Go、cgo、内联汇编
- **栈帧结构** - 各架构栈帧详解
- **附录** - 寄存器快速参考、术语表、参考资料

## 目录结构

```
docs/assembly-calling-conventions/
├── 00-index.md                 # 主索引
├── 01-syntax-comparison/       # 汇编语法对比
├── 02-x86-x64/                 # x86/x64 调用约定
├── 03-arm/                     # ARM 调用约定
├── 04-powerpc/                 # PowerPC 调用约定
├── 05-os-differences/          # 操作系统差异
├── 06-interop/                 # 语言互操作
├── 07-stack-frames/            # 栈帧结构
└── appendix/                   # 附录

examples/                       # 验证示例代码
├── windows-x64/                # Windows x64 示例
├── linux-x64/                  # Linux x64 示例
├── macos/                      # macOS 示例
├── arm/                        # ARM 示例
├── ppc/                        # PowerPC 示例
└── syntax/                     # 语法对比示例
```

## 本地构建

### 查看文档

直接在 GitHub 上浏览 Markdown 文件，或使用 Jekyll 本地预览：

```bash
gem install bundler jekyll
bundle install
bundle exec jekyll serve
```

然后访问 http://localhost:4000/asm-converter/

### 运行示例

Windows x64 示例：
```bash
cd examples/windows-x64/calling-conv
build.bat
```

Linux x64 示例：
```bash
cd examples/linux-x64/calling-conv
make
./calling_conv_demo
```

## 许可证

本文档采用 [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) 许可证。
