# 汇编语言调用约定技术文档

> 面向汇编语言专家的全面调用约定参考资料

## 文档概述

本文档提供了汇编语言调用约定的完整技术参考，涵盖不同汇编语法、CPU架构、操作系统以及与高级语言互操作的调用约定规范。

### 适用读者

- 汇编语言开发者
- 系统程序员
- 编译器开发者
- 逆向工程师
- 底层优化工程师

### 文档结构

本文档按照"语法 → 架构 → 操作系统 → 互操作"的逻辑顺序组织，便于按需查阅或系统学习。

---

## 目录

### 1. 汇编语法对比

比较Go Plan9、Intel和AT&T三种主流汇编语法的差异。

| 章节 | 描述 |
|------|------|
| [概述](01-syntax-comparison/overview.md) | 三种语法的历史背景和适用场景 |
| [Go Plan9 汇编](01-syntax-comparison/go-plan9.md) | Go语言使用的Plan9汇编语法详解 |
| [Intel 汇编](01-syntax-comparison/intel.md) | NASM/MASM风格的Intel语法详解 |
| [AT&T 汇编](01-syntax-comparison/att.md) | GAS风格的AT&T语法详解 |
| [语法对比表](01-syntax-comparison/comparison-tables.md) | 三种语法的详细对比和等效代码示例 |

### 2. x86/x64 架构调用约定

Intel x86和x64架构的调用约定规范。

| 章节 | 描述 |
|------|------|
| [x86 调用约定](02-x86-x64/x86-conventions.md) | cdecl、stdcall、fastcall完整规范 |
| [System V AMD64 ABI](02-x86-x64/x64-sysv.md) | Linux/macOS/BSD使用的x64调用约定 |
| [Microsoft x64](02-x86-x64/x64-microsoft.md) | Windows x64调用约定 |
| [寄存器参考](02-x86-x64/registers.md) | x86/x64寄存器完整说明 |

### 3. ARM 架构调用约定

ARM32和ARM64架构的调用约定规范。

| 章节 | 描述 |
|------|------|
| [概述](03-arm/overview.md) | ARM32和ARM64架构差异 |
| [ARM32 AAPCS](03-arm/arm32-aapcs.md) | ARM32过程调用标准 |
| [ARM64 AAPCS64](03-arm/arm64-aapcs64.md) | ARM64过程调用标准 |
| [寄存器参考](03-arm/registers.md) | ARM寄存器完整说明 |

### 4. PowerPC 架构调用约定

PowerPC 32位和64位架构的调用约定规范。

| 章节 | 描述 |
|------|------|
| [概述](04-powerpc/overview.md) | PPC32和PPC64架构特点 |
| [PPC32 调用约定](04-powerpc/ppc32.md) | PowerPC 32位调用约定 |
| [PPC64 ELFv1/v2](04-powerpc/ppc64.md) | PowerPC 64位调用约定（ELFv1和ELFv2） |
| [寄存器参考](04-powerpc/registers.md) | PowerPC寄存器完整说明 |

### 5. 操作系统差异

不同操作系统的调用约定差异。

| 章节 | 描述 |
|------|------|
| [概述](05-os-differences/overview.md) | 用户态调用和系统调用的区别 |
| [Linux](05-os-differences/linux.md) | Linux系统调用约定 |
| [Windows](05-os-differences/windows.md) | Windows系统调用约定 |
| [macOS](05-os-differences/macos.md) | macOS系统调用约定 |
| [对比表](05-os-differences/comparison.md) | 三个操作系统的调用约定对比 |

### 6. 语言互操作

汇编与高级语言的互操作规范。

| 章节 | 描述 |
|------|------|
| [C/C++ 互操作](06-interop/c-cpp.md) | C/C++与汇编的互操作规范 |
| [Go 汇编](06-interop/go-assembly.md) | Go语言与汇编的互操作规范 |
| [cgo 互操作](06-interop/cgo.md) | Go汇编调用C函数的规范 |
| [内联汇编](06-interop/inline-assembly.md) | GCC和MSVC内联汇编指南 |

### 7. 栈帧结构

各平台的栈帧结构详解。

| 章节 | 描述 |
|------|------|
| [概述](07-stack-frames/overview.md) | 栈帧的基本概念和组成部分 |
| [x86/x64 栈帧](07-stack-frames/x86-x64-frames.md) | x86和x64栈帧结构详解 |
| [ARM 栈帧](07-stack-frames/arm-frames.md) | ARM32和ARM64栈帧结构详解 |
| [PowerPC 栈帧](07-stack-frames/ppc-frames.md) | PowerPC栈帧结构详解 |

### 附录

| 章节 | 描述 |
|------|------|
| [寄存器快速参考](appendix/register-reference.md) | 所有架构寄存器的快速查阅表 |
| [术语表](appendix/glossary.md) | 专业术语定义 |
| [参考资料](appendix/references.md) | 官方规范文档和扩展阅读 |

---

## 快速导航

### 按架构查找

- **x86 (32位)**: [调用约定](02-x86-x64/x86-conventions.md) | [寄存器](02-x86-x64/registers.md) | [栈帧](07-stack-frames/x86-x64-frames.md)
- **x64 (64位)**: [System V](02-x86-x64/x64-sysv.md) | [Microsoft](02-x86-x64/x64-microsoft.md) | [寄存器](02-x86-x64/registers.md) | [栈帧](07-stack-frames/x86-x64-frames.md)
- **ARM32**: [AAPCS](03-arm/arm32-aapcs.md) | [寄存器](03-arm/registers.md) | [栈帧](07-stack-frames/arm-frames.md)
- **ARM64**: [AAPCS64](03-arm/arm64-aapcs64.md) | [寄存器](03-arm/registers.md) | [栈帧](07-stack-frames/arm-frames.md)
- **PowerPC**: [PPC32](04-powerpc/ppc32.md) | [PPC64](04-powerpc/ppc64.md) | [寄存器](04-powerpc/registers.md) | [栈帧](07-stack-frames/ppc-frames.md)

### 按操作系统查找

- **Linux**: [系统调用](05-os-differences/linux.md) | [x64 ABI](02-x86-x64/x64-sysv.md)
- **Windows**: [系统调用](05-os-differences/windows.md) | [x64 ABI](02-x86-x64/x64-microsoft.md)
- **macOS**: [系统调用](05-os-differences/macos.md) | [x64 ABI](02-x86-x64/x64-sysv.md)

### 按语言查找

- **C/C++**: [互操作规范](06-interop/c-cpp.md) | [内联汇编](06-interop/inline-assembly.md)
- **Go**: [Go汇编](06-interop/go-assembly.md) | [cgo](06-interop/cgo.md) | [Plan9语法](01-syntax-comparison/go-plan9.md)

---

## 版本信息

- **文档版本**: 1.0
- **最后更新**: 2026年2月
- **维护者**: Assembly Documentation Team

## 许可证

本文档采用 [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) 许可证。
