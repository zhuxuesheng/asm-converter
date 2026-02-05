---
layout: default
title: 首页
---

# 汇编语言调用约定技术文档

> 面向汇编语言专家的全面调用约定参考资料

## 📚 开始阅读

[**进入文档 →**](docs/assembly-calling-conventions/00-index.md)

## 文档概述

本文档提供了汇编语言调用约定的完整技术参考，涵盖：

- **汇编语法对比** - Go Plan9、Intel、AT&T 三种语法
- **x86/x64 调用约定** - cdecl、stdcall、fastcall、System V、Microsoft x64
- **ARM 调用约定** - AAPCS (ARM32)、AAPCS64 (ARM64)
- **PowerPC 调用约定** - PPC32、PPC64 ELFv1/v2
- **操作系统差异** - Linux、Windows、macOS 系统调用
- **语言互操作** - C/C++、Go、cgo、内联汇编
- **栈帧结构** - 各架构栈帧详解

## 适用读者

- 汇编语言开发者
- 系统程序员
- 编译器开发者
- 逆向工程师
- 底层优化工程师

## 快速导航

| 架构 | 调用约定 | 寄存器 | 栈帧 |
|------|----------|--------|------|
| x86 | [调用约定](docs/assembly-calling-conventions/02-x86-x64/x86-conventions.md) | [寄存器](docs/assembly-calling-conventions/02-x86-x64/registers.md) | [栈帧](docs/assembly-calling-conventions/07-stack-frames/x86-x64-frames.md) |
| x64 | [System V](docs/assembly-calling-conventions/02-x86-x64/x64-sysv.md) / [Microsoft](docs/assembly-calling-conventions/02-x86-x64/x64-microsoft.md) | [寄存器](docs/assembly-calling-conventions/02-x86-x64/registers.md) | [栈帧](docs/assembly-calling-conventions/07-stack-frames/x86-x64-frames.md) |
| ARM32 | [AAPCS](docs/assembly-calling-conventions/03-arm/arm32-aapcs.md) | [寄存器](docs/assembly-calling-conventions/03-arm/registers.md) | [栈帧](docs/assembly-calling-conventions/07-stack-frames/arm-frames.md) |
| ARM64 | [AAPCS64](docs/assembly-calling-conventions/03-arm/arm64-aapcs64.md) | [寄存器](docs/assembly-calling-conventions/03-arm/registers.md) | [栈帧](docs/assembly-calling-conventions/07-stack-frames/arm-frames.md) |
| PPC | [PPC32](docs/assembly-calling-conventions/04-powerpc/ppc32.md) / [PPC64](docs/assembly-calling-conventions/04-powerpc/ppc64.md) | [寄存器](docs/assembly-calling-conventions/04-powerpc/registers.md) | [栈帧](docs/assembly-calling-conventions/07-stack-frames/ppc-frames.md) |

## 附录

- [寄存器快速参考](docs/assembly-calling-conventions/appendix/register-reference.md)
- [术语表](docs/assembly-calling-conventions/appendix/glossary.md)
- [参考资料](docs/assembly-calling-conventions/appendix/references.md)

---

## 源码

本项目源码托管在 [GitHub](https://github.com/zhuxuesheng/asm-converter)。

## 许可证

本文档采用 [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) 许可证。
