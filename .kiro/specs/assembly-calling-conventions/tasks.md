# 实施计划：汇编语言调用约定技术文档

## 概述

本计划将设计文档转化为具体的文档编写任务。采用模块化方式，按照"基础设施 → 语法对比 → 架构调用约定 → 操作系统差异 → 互操作 → 附录"的顺序逐步完成。

每个章节的代码示例将通过实际编译和运行进行验证。Windows x64平台可直接验证，其他平台（Linux、macOS、ARM、PPC）将准备验证脚本供跨平台验证。

## 任务

- [x] 1. 创建文档基础结构和验证框架
  - [x] 1.1 创建目录结构和主索引文件
    - 创建 `docs/assembly-calling-conventions/` 目录结构
    - 创建 `00-index.md` 主索引文件，包含完整目录导航
    - 创建 `appendix/glossary.md` 术语表文件
    - _需求: 10.1, 10.2_
  
  - [x] 1.2 创建验证脚本框架
    - 创建 `examples/` 目录存放可验证的代码示例
    - 创建 `examples/windows-x64/` 用于Windows平台验证
    - 创建 `examples/linux-x64/` 用于Linux平台验证脚本
    - 创建 `examples/macos/` 用于macOS平台验证脚本
    - 创建 `examples/arm/` 用于ARM平台验证脚本
    - 创建 `Makefile` 或构建脚本用于批量验证
    - _需求: 10.4_

- [x] 2. 编写汇编语法对比章节
  - [x] 2.1 编写语法对比概述
    - 创建 `01-syntax-comparison/overview.md`
    - 说明三种语法的历史背景和适用场景
    - _需求: 1.1, 1.2, 1.3_
  
  - [x] 2.2 编写Go Plan9汇编语法详解
    - 创建 `01-syntax-comparison/go-plan9.md`
    - 包含伪寄存器、指令格式、寻址模式
    - _需求: 1.1_
  
  - [x] 2.3 编写Intel汇编语法详解
    - 创建 `01-syntax-comparison/intel.md`
    - 包含NASM/MASM语法差异、指令格式
    - _需求: 1.2_
  
  - [x] 2.4 编写AT&T汇编语法详解
    - 创建 `01-syntax-comparison/att.md`
    - 包含GAS语法、指令后缀、操作数格式
    - _需求: 1.3_
  
  - [x] 2.5 编写语法对比表格
    - 创建 `01-syntax-comparison/comparison-tables.md`
    - 包含操作数顺序、寄存器命名、内存寻址、立即数对比表
    - 包含等效指令对照示例
    - _需求: 1.4, 1.5, 1.6, 1.7, 1.8_
  
  - [x] 2.6 创建语法对比验证示例
    - 创建 `examples/syntax/` 目录
    - 编写等效功能的Go汇编、NASM、GAS示例代码
    - 在Windows x64上使用go/nasm/gcc验证编译
    - _需求: 1.8, 10.4_

- [x] 3. 检查点 - 语法对比章节审查和验证
  - 确保所有语法对比内容完整
  - 运行语法示例验证编译正确性
  - 如有问题请提出

- [x] 4. 编写x86/x64架构调用约定章节
  - [x] 4.1 编写x86/x64概述
    - 创建 `02-x86-x64/overview.md`
    - 说明x86和x64架构的演进和主要差异
    - _需求: 2.1, 2.4_
  
  - [x] 4.2 编写x86调用约定详解
    - 创建 `02-x86-x64/x86-conventions.md`
    - 包含cdecl、stdcall、fastcall完整规范
    - 包含参数传递、返回值、栈清理规则
    - _需求: 2.1, 2.2, 2.3, 2.6, 2.7, 2.8_
  
  - [x] 4.3 编写System V AMD64 ABI详解
    - 创建 `02-x86-x64/x64-sysv.md`
    - 包含参数寄存器（RDI, RSI, RDX, RCX, R8, R9）
    - 包含浮点参数（XMM0-XMM7）、返回值、Red Zone
    - _需求: 2.4, 2.6, 2.7, 2.8_
  
  - [x] 4.4 编写Microsoft x64调用约定详解
    - 创建 `02-x86-x64/x64-microsoft.md`
    - 包含参数寄存器（RCX, RDX, R8, R9）
    - 包含Shadow Space、栈对齐要求
    - _需求: 2.5, 2.6, 2.7, 2.8_
  
  - [x] 4.5 编写x86/x64寄存器参考
    - 创建 `02-x86-x64/registers.md`
    - 包含通用寄存器、SIMD寄存器完整说明
    - 包含caller-saved和callee-saved分类
    - _需求: 2.9, 8.1, 8.2, 8.5, 8.6, 8.7_
  
  - [x] 4.6 创建x86/x64调用约定验证示例
    - 创建 `examples/windows-x64/calling-conv/` 目录
    - 编写C调用汇编函数示例，验证Microsoft x64约定
    - 编写汇编调用C函数示例
    - 验证参数传递寄存器（RCX, RDX, R8, R9）
    - 验证Shadow Space分配
    - 使用NASM+GCC在Windows上编译运行验证
    - _需求: 2.5, 2.6, 2.7, 10.4_
  
  - [x] 4.7 准备Linux x64 System V ABI验证脚本
    - 创建 `examples/linux-x64/calling-conv/` 目录
    - 编写验证System V AMD64 ABI的示例代码
    - 验证参数传递寄存器（RDI, RSI, RDX, RCX, R8, R9）
    - 验证Red Zone使用
    - 准备Makefile供Linux平台验证
    - _需求: 2.4, 2.6, 2.7, 10.4_

- [x] 5. 编写ARM架构调用约定章节
  - [x] 5.1 编写ARM概述
    - 创建 `03-arm/overview.md`
    - 说明ARM32和ARM64架构差异
    - _需求: 3.1, 3.2_
  
  - [x] 5.2 编写ARM32 AAPCS详解
    - 创建 `03-arm/arm32-aapcs.md`
    - 包含R0-R3参数传递、R0-R1返回值
    - 包含栈帧结构和对齐要求
    - _需求: 3.1, 3.5, 3.6, 3.7_
  
  - [x] 5.3 编写ARM64 AAPCS64详解
    - 创建 `03-arm/arm64-aapcs64.md`
    - 包含X0-X7参数传递、X0返回值
    - 包含SIMD/FP寄存器使用规范
    - _需求: 3.2, 3.5, 3.6, 3.7_
  
  - [x] 5.4 编写ARM寄存器参考
    - 创建 `03-arm/registers.md`
    - 包含通用寄存器和浮点寄存器完整说明
    - _需求: 3.3, 3.4, 8.3_
  
  - [x] 5.5 准备ARM调用约定验证脚本
    - 创建 `examples/arm/calling-conv/` 目录
    - 编写ARM32和ARM64调用约定验证示例
    - 准备交叉编译脚本或QEMU验证脚本
    - _需求: 3.5, 3.6, 10.4_

- [x] 6. 编写PowerPC架构调用约定章节
  - [x] 6.1 编写PowerPC概述
    - 创建 `04-powerpc/overview.md`
    - 说明PPC32和PPC64架构特点
    - _需求: 4.1, 4.2_
  
  - [x] 6.2 编写PPC32调用约定详解
    - 创建 `04-powerpc/ppc32.md`
    - 包含GPR3-GPR10参数传递规则
    - 包含栈帧结构和链接区
    - _需求: 4.1, 4.6_
  
  - [x] 6.3 编写PPC64 ELFv1/v2调用约定详解
    - 创建 `04-powerpc/ppc64.md`
    - 包含ELFv1和ELFv2差异对比
    - 包含TOC指针和函数描述符
    - _需求: 4.2, 4.6, 4.7_
  
  - [x] 6.4 编写PowerPC寄存器参考
    - 创建 `04-powerpc/registers.md`
    - 包含GPR、FPR、特殊寄存器完整说明
    - _需求: 4.3, 4.4, 4.5, 8.4_
  
  - [x] 6.5 准备PowerPC调用约定验证脚本
    - 创建 `examples/ppc/calling-conv/` 目录
    - 编写PPC调用约定验证示例
    - 准备交叉编译脚本或QEMU验证脚本
    - _需求: 4.6, 10.4_

- [x] 7. 检查点 - 架构调用约定章节审查和验证
  - 确保所有架构调用约定内容完整
  - 在Windows x64上运行验证示例
  - 准备好其他平台的验证脚本
  - 如有问题请提出

- [x] 8. 编写操作系统差异章节
  - [x] 8.1 编写操作系统差异概述
    - 创建 `05-os-differences/overview.md`
    - 说明用户态调用和系统调用的区别
    - _需求: 5.1, 5.2, 5.3_
  
  - [x] 8.2 编写Linux调用约定详解
    - 创建 `05-os-differences/linux.md`
    - 包含syscall指令、系统调用号、参数寄存器
    - 包含Red Zone规范
    - _需求: 5.1, 5.5, 5.6, 5.7_
  
  - [x] 8.3 编写Windows调用约定详解
    - 创建 `05-os-differences/windows.md`
    - 包含syscall机制、Shadow Space
    - 包含SEH异常处理相关
    - _需求: 5.2, 5.5, 5.6_
  
  - [x] 8.4 编写macOS调用约定详解
    - 创建 `05-os-differences/macos.md`
    - 包含syscall机制、Mach-O特性
    - 包含与Linux的差异
    - _需求: 5.3, 5.5, 5.6, 5.7_
  
  - [x] 8.5 编写操作系统对比表格
    - 创建 `05-os-differences/comparison.md`
    - 包含x64用户态调用约定对比
    - 包含系统调用对比、栈对齐对比
    - _需求: 5.4, 5.5, 5.6, 5.7, 5.8_
  
  - [x] 8.6 创建操作系统差异验证示例
    - 创建 `examples/windows-x64/syscall/` Windows系统调用示例
    - 创建 `examples/linux-x64/syscall/` Linux系统调用验证脚本
    - 创建 `examples/macos/syscall/` macOS系统调用验证脚本
    - 在Windows上验证syscall示例
    - _需求: 5.1, 5.2, 5.3, 10.4_

- [x] 9. 编写语言互操作章节
  - [x] 9.1 编写C/C++与汇编互操作
    - 创建 `06-interop/c-cpp.md`
    - 包含C调用汇编、汇编调用C的规范
    - 包含extern "C"、名称修饰、结构体传递
    - 包含浮点参数、可变参数函数规范
    - _需求: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7_
  
  - [x] 9.2 编写Go与汇编互操作
    - 创建 `06-interop/go-assembly.md`
    - 包含Go汇编调用约定、伪寄存器详解
    - 包含函数签名对应、栈布局
    - 包含Go 1.17+寄存器调用约定
    - 包含栈增长和栈分裂机制
    - _需求: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.8_
  
  - [x] 9.3 编写cgo互操作规范
    - 创建 `06-interop/cgo.md`
    - 包含Go汇编调用C函数的规范
    - 包含cgo调用开销和注意事项
    - _需求: 7.7_
  
  - [x] 9.4 编写内联汇编指南
    - 创建 `06-interop/inline-assembly.md`
    - 包含GCC内联汇编语法
    - 包含MSVC内联汇编语法
    - 包含约束和修饰符说明
    - _需求: 6.8_
  
  - [x] 9.5 创建语言互操作验证示例
    - 创建 `examples/windows-x64/interop/` 目录
    - 编写C调用NASM汇编函数示例并验证
    - 编写Go调用汇编函数示例并验证
    - 编写GCC内联汇编示例并验证
    - _需求: 6.1, 6.2, 7.1, 6.8, 10.4_
  
  - [x] 9.6 准备跨平台互操作验证脚本
    - 创建 `examples/linux-x64/interop/` Linux互操作验证脚本
    - 创建 `examples/macos/interop/` macOS互操作验证脚本
    - _需求: 6.1, 6.2, 10.4_

- [x] 10. 编写栈帧结构章节
  - [x] 10.1 编写栈帧概述
    - 创建 `07-stack-frames/overview.md`
    - 说明栈帧的基本概念和组成部分
    - _需求: 9.5, 9.6_
  
  - [x] 10.2 编写x86/x64栈帧详解
    - 创建 `07-stack-frames/x86-x64-frames.md`
    - 包含x86和x64栈帧结构图示
    - 包含帧指针使用、局部变量布局
    - 包含异常处理栈展开信息
    - _需求: 9.1, 9.2, 9.5, 9.6, 9.7, 9.8_
  
  - [x] 10.3 编写ARM栈帧详解
    - 创建 `07-stack-frames/arm-frames.md`
    - 包含ARM32和ARM64栈帧结构图示
    - _需求: 9.3, 9.8_
  
  - [x] 10.4 编写PowerPC栈帧详解
    - 创建 `07-stack-frames/ppc-frames.md`
    - 包含PPC栈帧结构图示
    - 包含链接区和参数保存区
    - _需求: 9.4, 9.8_

- [x] 11. 编写附录
  - [x] 11.1 编写寄存器快速参考
    - 创建 `appendix/register-reference.md`
    - 包含所有架构寄存器的快速查阅表
    - _需求: 8.1, 8.3, 8.4, 8.5, 8.6, 8.7_
  
  - [x] 11.2 完善术语表
    - 更新 `appendix/glossary.md`
    - 包含文档中所有专业术语的定义
    - _需求: 10.3_
  
  - [x] 11.3 编写参考资料
    - 创建 `appendix/references.md`
    - 包含官方规范文档链接
    - 包含扩展阅读资源
    - _需求: 10.6_

- [x] 12. 最终检查点 - 完整文档审查和验证
  - 确保所有章节完整，交叉引用正确，格式统一
  - 在Windows x64上运行所有验证示例
  - 确认所有跨平台验证脚本已准备就绪
  - 检查所有内部链接有效性

## 验证策略

### Windows x64 可直接验证的内容
- 三种汇编语法示例（Go汇编、NASM、GAS）
- Microsoft x64调用约定
- C/C++与汇编互操作
- Go与汇编互操作
- Windows系统调用
- GCC/MSVC内联汇编

### 需要跨平台验证的内容（准备脚本）
- Linux: System V AMD64 ABI、Linux syscall、Red Zone
- macOS: macOS调用约定、Mach-O syscall
- ARM: AAPCS/AAPCS64（可用QEMU或交叉编译）
- PowerPC: PPC调用约定（可用QEMU或交叉编译）

## 备注

- 每个任务完成后应进行自查，确保内容准确性
- 代码示例应覆盖三种汇编语法
- 图表使用Mermaid格式便于维护
- 所有技术内容应与官方规范保持一致
