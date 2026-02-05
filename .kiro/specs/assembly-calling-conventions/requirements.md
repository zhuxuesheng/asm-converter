# 需求文档

## 简介

本文档定义了汇编语言调用约定技术文档的需求规范。该文档旨在为汇编语言专家提供一份全面的调用约定参考资料，涵盖不同汇编语法、平台架构、操作系统以及与高级语言互操作的调用约定规范。

## 术语表

- **Calling_Convention（调用约定）**: 定义函数调用时参数传递、返回值处理、寄存器使用和栈管理的规则集合
- **ABI（应用二进制接口）**: 定义二进制程序模块之间接口的规范
- **Stack_Frame（栈帧）**: 函数调用时在栈上分配的内存区域，包含局部变量、返回地址和保存的寄存器
- **Caller（调用者）**: 发起函数调用的代码
- **Callee（被调用者）**: 被调用的函数
- **Caller_Saved_Register（调用者保存寄存器）**: 调用者负责在函数调用前后保存和恢复的寄存器
- **Callee_Saved_Register（被调用者保存寄存器）**: 被调用函数负责保存和恢复的寄存器
- **Red_Zone（红区）**: 栈指针以下的一段内存区域，某些ABI允许函数使用而无需调整栈指针
- **Shadow_Space（影子空间）**: Windows x64调用约定中为前四个参数预留的栈空间
- **Plan9_Assembly（Plan9汇编）**: Go语言使用的汇编语法，源自Plan 9操作系统

## 需求

### 需求 1：汇编语法对比分析

**用户故事：** 作为汇编语言开发者，我希望了解不同汇编语法的差异，以便在不同环境中正确编写和阅读汇编代码。

#### 验收标准

1. THE Document SHALL 提供Go汇编（Plan9语法）的完整语法规范说明
2. THE Document SHALL 提供Intel汇编语法的完整规范说明
3. THE Document SHALL 提供AT&T汇编语法的完整规范说明
4. THE Document SHALL 包含三种语法在操作数顺序上的对比分析
5. THE Document SHALL 包含三种语法在寄存器命名上的对比分析
6. THE Document SHALL 包含三种语法在内存寻址表示上的对比分析
7. THE Document SHALL 包含三种语法在立即数表示上的对比分析
8. THE Document SHALL 提供等效指令在三种语法下的对照示例

### 需求 2：Intel x86/x64架构调用约定

**用户故事：** 作为汇编语言开发者，我希望了解Intel x86和x64架构的调用约定，以便正确实现函数调用和参数传递。

#### 验收标准

1. THE Document SHALL 描述x86架构下cdecl调用约定的完整规范
2. THE Document SHALL 描述x86架构下stdcall调用约定的完整规范
3. THE Document SHALL 描述x86架构下fastcall调用约定的完整规范
4. THE Document SHALL 描述x64架构下System V AMD64 ABI的完整规范
5. THE Document SHALL 描述x64架构下Microsoft x64调用约定的完整规范
6. WHEN 描述每种调用约定时 THE Document SHALL 包含参数传递寄存器的详细说明
7. WHEN 描述每种调用约定时 THE Document SHALL 包含返回值寄存器的详细说明
8. WHEN 描述每种调用约定时 THE Document SHALL 包含栈对齐要求的说明
9. THE Document SHALL 包含caller-saved和callee-saved寄存器的完整列表

### 需求 3：ARM架构调用约定

**用户故事：** 作为汇编语言开发者，我希望了解ARM架构的调用约定，以便在ARM平台上正确实现函数调用。

#### 验收标准

1. THE Document SHALL 描述ARM32（AAPCS）调用约定的完整规范
2. THE Document SHALL 描述ARM64（AAPCS64）调用约定的完整规范
3. THE Document SHALL 包含ARM架构下通用寄存器的用途说明
4. THE Document SHALL 包含ARM架构下浮点寄存器的使用规范
5. WHEN 描述ARM调用约定时 THE Document SHALL 包含参数传递规则（R0-R3/X0-X7）
6. WHEN 描述ARM调用约定时 THE Document SHALL 包含返回值处理规则
7. THE Document SHALL 包含ARM架构下栈帧结构的详细说明

### 需求 4：PowerPC架构调用约定

**用户故事：** 作为汇编语言开发者，我希望了解PowerPC架构的调用约定，以便在PPC平台上正确实现函数调用。

#### 验收标准

1. THE Document SHALL 描述PowerPC 32位调用约定的完整规范
2. THE Document SHALL 描述PowerPC 64位（ELFv1和ELFv2）调用约定的完整规范
3. THE Document SHALL 包含PowerPC通用寄存器（GPR）的用途说明
4. THE Document SHALL 包含PowerPC浮点寄存器（FPR）的使用规范
5. THE Document SHALL 包含PowerPC特殊寄存器（LR、CTR、CR）的说明
6. WHEN 描述PPC调用约定时 THE Document SHALL 包含参数传递规则
7. THE Document SHALL 包含PowerPC架构下TOC（Table of Contents）的说明

### 需求 5：操作系统调用约定差异

**用户故事：** 作为汇编语言开发者，我希望了解不同操作系统的调用约定差异，以便编写跨平台兼容的汇编代码。

#### 验收标准

1. THE Document SHALL 描述Linux系统调用约定（syscall）的完整规范
2. THE Document SHALL 描述Windows系统调用约定的完整规范
3. THE Document SHALL 描述macOS系统调用约定的完整规范
4. THE Document SHALL 包含三个操作系统在x64架构下用户态调用约定的对比
5. THE Document SHALL 包含系统调用号传递方式的对比说明
6. THE Document SHALL 包含系统调用参数传递寄存器的对比说明
7. IF 存在Red Zone差异 THEN THE Document SHALL 详细说明各系统的Red Zone规范
8. THE Document SHALL 包含各操作系统栈对齐要求的对比

### 需求 6：C/C++与汇编互操作

**用户故事：** 作为汇编语言开发者，我希望了解C/C++与汇编的互操作规范，以便正确实现混合语言编程。

#### 验收标准

1. THE Document SHALL 描述从C/C++调用汇编函数的规范
2. THE Document SHALL 描述从汇编调用C/C++函数的规范
3. THE Document SHALL 包含C++名称修饰（name mangling）的说明
4. THE Document SHALL 包含extern "C"的使用规范
5. THE Document SHALL 包含结构体参数传递的规范
6. THE Document SHALL 包含浮点参数和返回值的处理规范
7. THE Document SHALL 包含可变参数函数（variadic functions）的调用规范
8. WHEN 描述互操作时 THE Document SHALL 包含内联汇编的使用规范

### 需求 7：Go语言与汇编互操作

**用户故事：** 作为Go语言开发者，我希望了解Go与汇编的互操作规范，以便正确编写Go汇编代码。

#### 验收标准

1. THE Document SHALL 描述Go汇编的独特调用约定
2. THE Document SHALL 包含Go汇编中伪寄存器（FP、SP、SB、PC）的详细说明
3. THE Document SHALL 包含Go函数签名与汇编实现的对应规范
4. THE Document SHALL 包含Go汇编中参数和返回值的栈布局说明
5. THE Document SHALL 包含Go 1.17+寄存器调用约定的说明
6. THE Document SHALL 包含Go汇编中调用其他Go函数的规范
7. THE Document SHALL 包含Go汇编中调用C函数（通过cgo）的规范
8. THE Document SHALL 包含Go汇编的栈增长和栈分裂机制说明

### 需求 8：寄存器使用规范

**用户故事：** 作为汇编语言开发者，我希望获得各架构寄存器使用的完整参考，以便正确使用寄存器。

#### 验收标准

1. THE Document SHALL 提供x86/x64架构通用寄存器的完整用途说明
2. THE Document SHALL 提供x86/x64架构SIMD寄存器（XMM/YMM/ZMM）的使用规范
3. THE Document SHALL 提供ARM架构寄存器的完整用途说明
4. THE Document SHALL 提供PowerPC架构寄存器的完整用途说明
5. WHEN 描述寄存器时 THE Document SHALL 区分volatile和non-volatile寄存器
6. THE Document SHALL 包含各架构下特殊用途寄存器的说明
7. THE Document SHALL 包含寄存器别名和子寄存器的说明

### 需求 9：栈帧结构

**用户故事：** 作为汇编语言开发者，我希望了解各平台的栈帧结构，以便正确管理函数调用栈。

#### 验收标准

1. THE Document SHALL 提供x86架构标准栈帧结构的详细说明
2. THE Document SHALL 提供x64架构栈帧结构的详细说明
3. THE Document SHALL 提供ARM架构栈帧结构的详细说明
4. THE Document SHALL 提供PowerPC架构栈帧结构的详细说明
5. THE Document SHALL 包含帧指针（frame pointer）的使用规范
6. THE Document SHALL 包含栈帧中局部变量布局的说明
7. THE Document SHALL 包含异常处理相关的栈展开信息说明
8. WHEN 描述栈帧时 THE Document SHALL 包含图示说明

### 需求 10：文档结构与格式

**用户故事：** 作为文档读者，我希望文档结构清晰、格式规范，以便快速查找和理解所需信息。

#### 验收标准

1. THE Document SHALL 采用层次化的章节结构组织内容
2. THE Document SHALL 包含完整的目录索引
3. THE Document SHALL 使用一致的术语和命名规范
4. THE Document SHALL 包含必要的代码示例和图表
5. THE Document SHALL 提供各章节之间的交叉引用
6. THE Document SHALL 包含参考资料和扩展阅读链接
