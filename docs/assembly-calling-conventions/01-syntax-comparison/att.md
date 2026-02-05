# AT&T 汇编语法详解

> AT&T汇编语法完整参考，包含GAS汇编器、指令格式、操作数语法、数据指令和GCC内联汇编

## 概述

AT&T汇编语法是由AT&T贝尔实验室开发的汇编语法风格，最初用于UNIX系统。它是GNU Assembler（GAS）的默认语法，也是GCC编译器生成汇编代码时使用的格式。由于Linux和其他类UNIX系统广泛使用GCC工具链，AT&T语法在这些平台上非常普遍。

### 核心特性

| 特性 | 说明 |
|------|------|
| **操作数顺序** | 源在前，目标在后（source, destination） |
| **寄存器前缀** | 使用 `%` 前缀（如 `%rax`） |
| **立即数前缀** | 使用 `$` 前缀（如 `$42`） |
| **大小后缀** | 指令带大小后缀（b, w, l, q） |
| **内存访问** | 使用 `displacement(%base, %index, scale)` 格式 |

### 与Intel语法的主要差异

| 特性 | AT&T语法 | Intel语法 |
|------|----------|-----------|
| 操作数顺序 | 源, 目标 | 目标, 源 |
| 寄存器 | `%rax` | `rax` |
| 立即数 | `$42` | `42` |
| 内存访问 | `(%rax)` | `[rax]` |
| 大小指定 | 指令后缀 `movq` | 操作数前缀 `QWORD` |
| 绝对地址 | `*address` | `address` |

### 主要汇编器

| 汇编器 | 全称 | 特点 | 平台 |
|--------|------|------|------|
| **GAS** | GNU Assembler | GNU工具链核心、支持多架构 | 跨平台 |
| **Clang/LLVM** | LLVM Assembler | 兼容GAS语法、现代化 | 跨平台 |

---

## GAS（GNU Assembler）详解

### GAS简介

GNU Assembler（通常称为GAS或`as`）是GNU Binutils工具集的一部分，是GNU/Linux系统上最常用的汇编器。它支持多种处理器架构，并且是GCC编译器的后端汇编器。

### 调用方式

```bash
# 直接调用GAS
as -o output.o input.s

# 通过GCC调用（推荐）
gcc -c -o output.o input.s

# 生成汇编代码
gcc -S -o output.s input.c

# 使用Intel语法（GAS也支持）
gcc -S -masm=intel -o output.s input.c
```

### GAS命令行选项

| 选项 | 说明 |
|------|------|
| `-o file` | 指定输出文件 |
| `-g` | 生成调试信息 |
| `--gstabs` | 生成STABS调试信息 |
| `--gdwarf-2` | 生成DWARF2调试信息 |
| `-a` | 生成列表文件 |
| `-I path` | 添加包含路径 |
| `--32` | 生成32位代码 |
| `--64` | 生成64位代码 |
| `-march=arch` | 指定目标架构 |
| `-mtune=cpu` | 针对特定CPU优化 |

### 切换语法模式

GAS支持在AT&T和Intel语法之间切换：

```asm
# 默认AT&T语法
movq %rax, %rbx

# 切换到Intel语法
.intel_syntax noprefix
mov rbx, rax

# 切换回AT&T语法
.att_syntax prefix
movq %rax, %rbx
```

**语法指令说明**：

| 指令 | 说明 |
|------|------|
| `.intel_syntax` | 切换到Intel语法 |
| `.intel_syntax noprefix` | Intel语法，寄存器无前缀 |
| `.att_syntax` | 切换到AT&T语法 |
| `.att_syntax prefix` | AT&T语法，寄存器带%前缀 |

---

## 指令格式

### 基本格式

AT&T语法的指令格式遵循以下模式：

```
instruction[suffix]  source, destination
```

**操作数顺序**：源操作数在前，目标操作数在后（与Intel语法相反）。

```asm
movq %rax, %rbx        # 将rax的值移动到rbx（rax → rbx）
addq $10, %rcx         # 将10加到rcx（rcx = rcx + 10）
subq %rdx, %rax        # 从rax减去rdx（rax = rax - rdx）
```

### 指令大小后缀

AT&T语法使用后缀来指定操作数大小，这是其最显著的特征之一：

| 后缀 | 大小 | 说明 | Intel等效 |
|------|------|------|-----------|
| **b** | 1字节 | Byte | BYTE |
| **w** | 2字节 | Word | WORD |
| **l** | 4字节 | Long/Doubleword | DWORD |
| **q** | 8字节 | Quadword | QWORD |
| **s** | 4字节 | Single-precision float | REAL4 |
| **d** | 8字节 | Double-precision float | REAL8 |
| **t** | 10字节 | Extended-precision float | REAL10 |

**示例**：

```asm
movb $0x41, %al        # 移动1字节
movw $0x1234, %ax      # 移动2字节
movl $0x12345678, %eax # 移动4字节
movq $0x123456789ABCDEF0, %rax  # 移动8字节

# 浮点操作
flds (%rax)            # 加载单精度浮点
fldl (%rax)            # 加载双精度浮点
fldt (%rax)            # 加载扩展精度浮点
```

### 后缀省略规则

当操作数大小可以从寄存器推断时，后缀可以省略（但不推荐）：

```asm
# 可以省略后缀（不推荐）
mov %eax, %ebx         # 自动推断为movl
mov %rax, %rbx         # 自动推断为movq

# 推荐：始终使用后缀
movl %eax, %ebx
movq %rax, %rbx

# 必须使用后缀的情况（内存操作数大小不明确）
movb $0, (%rax)        # 必须指定大小
movl $0, (%rax)        # 必须指定大小
```

### 指令前缀

AT&T语法支持多种指令前缀：

| 前缀 | 用途 | 示例 |
|------|------|------|
| `lock` | 原子操作 | `lock addq $1, (%rax)` |
| `rep` | 重复字符串操作 | `rep movsb` |
| `repe/repz` | 相等时重复 | `repe cmpsb` |
| `repne/repnz` | 不等时重复 | `repne scasb` |

```asm
# 原子递增
lock incq counter(%rip)

# 原子比较交换
lock cmpxchgq %rbx, (%rax)

# 字符串复制
movq $src, %rsi
movq $dst, %rdi
movq $length, %rcx
cld                    # 清除方向标志
rep movsb              # 复制rcx字节

# 字符串比较
movq $str1, %rsi
movq $str2, %rdi
movq $length, %rcx
repe cmpsb             # 比较直到不相等或rcx=0
```

---

## 寄存器命名

### 通用寄存器（x86-64）

AT&T语法中，所有寄存器名称都以 `%` 前缀开头：

| 64位 | 32位 | 16位 | 8位高 | 8位低 | 用途 |
|------|------|------|-------|-------|------|
| %rax | %eax | %ax | %ah | %al | 累加器/返回值 |
| %rbx | %ebx | %bx | %bh | %bl | 基址寄存器 |
| %rcx | %ecx | %cx | %ch | %cl | 计数器/第4参数(Win) |
| %rdx | %edx | %dx | %dh | %dl | 数据/第3参数(Win) |
| %rsi | %esi | %si | - | %sil | 源索引/第2参数(SysV) |
| %rdi | %edi | %di | - | %dil | 目标索引/第1参数(SysV) |
| %rbp | %ebp | %bp | - | %bpl | 帧指针 |
| %rsp | %esp | %sp | - | %spl | 栈指针 |
| %r8 | %r8d | %r8w | - | %r8b | 第5参数(Win)/第5参数(SysV) |
| %r9 | %r9d | %r9w | - | %r9b | 第6参数(Win)/第6参数(SysV) |
| %r10 | %r10d | %r10w | - | %r10b | 临时寄存器 |
| %r11 | %r11d | %r11w | - | %r11b | 临时寄存器 |
| %r12 | %r12d | %r12w | - | %r12b | 被调用者保存 |
| %r13 | %r13d | %r13w | - | %r13b | 被调用者保存 |
| %r14 | %r14d | %r14w | - | %r14b | 被调用者保存 |
| %r15 | %r15d | %r15w | - | %r15b | 被调用者保存 |

**寄存器访问示例**：

```asm
# 64位操作
movq $0x123456789ABCDEF0, %rax

# 32位操作（自动清零高32位）
movl $0x12345678, %eax

# 16位操作（保留高位）
movw $0x1234, %ax

# 8位操作（保留高位）
movb $0x12, %al        # 低8位
movb $0x34, %ah        # 高8位（仅ax,bx,cx,dx）
```

### 段寄存器

| 寄存器 | 用途 |
|--------|------|
| %cs | 代码段 |
| %ds | 数据段 |
| %ss | 栈段 |
| %es | 额外段 |
| %fs | 通用段（Linux TLS） |
| %gs | 通用段（Windows TEB） |

```asm
# 段覆盖前缀
movq %fs:0x28, %rax    # 访问FS段偏移0x28（Linux栈保护）
movq %gs:0x30, %rax    # 访问GS段偏移0x30（Windows TEB）
```

### SIMD寄存器

| 类型 | 寄存器 | 大小 | 数量 |
|------|--------|------|------|
| SSE | %xmm0-%xmm15 | 128位 | 16个 |
| AVX | %ymm0-%ymm15 | 256位 | 16个 |
| AVX-512 | %zmm0-%zmm31 | 512位 | 32个 |

```asm
# SSE操作
movaps (%rax), %xmm0   # 对齐加载128位
movups (%rbx), %xmm1   # 非对齐加载128位
addps %xmm1, %xmm0     # 4个单精度浮点加法
mulpd %xmm1, %xmm0     # 2个双精度浮点乘法

# AVX操作
vmovaps (%rax), %ymm0  # 对齐加载256位
vaddps %ymm1, %ymm2, %ymm0  # 三操作数形式

# AVX-512操作
vmovaps (%rax), %zmm0  # 加载512位
vaddps %zmm1, %zmm2, %zmm0  # 16个单精度浮点加法
```

### 特殊寄存器

| 寄存器 | 用途 |
|--------|------|
| %rip | 指令指针 |
| %rflags | 标志寄存器 |
| %cr0-%cr4 | 控制寄存器 |
| %dr0-%dr7 | 调试寄存器 |

```asm
# RIP相对寻址（64位模式）
leaq myvar(%rip), %rax  # 加载相对于RIP的地址
movq myvar(%rip), %rax  # 加载相对于RIP的值

# 标志操作
pushfq                  # 保存RFLAGS
popfq                   # 恢复RFLAGS
```

---

## 立即数和常量

### 立即数格式

AT&T语法中，立即数以 `$` 前缀开头：

| 类型 | 格式 | 示例 |
|------|------|------|
| 十进制 | `$123` | `movq $100, %rax` |
| 十六进制 | `$0x7B` | `movq $0x64, %rax` |
| 八进制 | `$0173` | `movq $0144, %rax` |
| 二进制 | `$0b1111011` | `movq $0b1100100, %rax` |
| 字符 | `$'A'` | `movb $'A', %al` |
| 符号地址 | `$symbol` | `movq $myvar, %rax` |

**示例**：

```asm
movq $100, %rax        # 十进制
movq $0x64, %rax       # 十六进制
movq $0144, %rax       # 八进制
movq $0b1100100, %rax  # 二进制（GAS 2.10+）
movb $'A', %al         # 字符（ASCII 65）
movq $myvar, %rax      # 符号地址
```

### 常量定义

GAS使用多种方式定义常量：

```asm
# 使用.equ定义常量
.equ BUFFER_SIZE, 1024
.equ MAX_COUNT, 100
.equ NEWLINE, 10

# 使用.set定义可重新赋值的常量
.set counter, 0
.set counter, counter + 1

# 使用=定义常量（等同于.set）
ARRAY_LEN = 50
OFFSET_X = 8

# 使用常量
movq $BUFFER_SIZE, %rcx
movb $NEWLINE, %al
```

### 表达式计算

GAS支持编译时表达式计算：

```asm
.equ STRUCT_SIZE, 24
.equ ARRAY_LEN, 10
.equ TOTAL_SIZE, STRUCT_SIZE * ARRAY_LEN  # = 240

movq $(1 << 10), %rax      # 位移：1024
movq $(0xFF & 0x0F), %rbx  # 位与：15
movq $(100 + 50 * 2), %rcx # 算术：200

# 地址计算
.data
array:
    .skip 800              # 100个qword
array_end:
.equ array_len, (array_end - array) / 8  # 计算元素数量
```

---

## 内存寻址语法

AT&T语法使用独特的内存寻址格式，这是与Intel语法最显著的差异之一。

### 寻址模式概览

AT&T内存寻址的通用格式：

```
displacement(%base, %index, scale)
```

| 组件 | 说明 | 有效值 |
|------|------|--------|
| displacement | 偏移量 | 常量或符号 |
| %base | 基址寄存器 | 任意通用寄存器 |
| %index | 索引寄存器 | 除%rsp外的通用寄存器 |
| scale | 比例因子 | 1, 2, 4, 8 |

### 基本寻址模式

**1. 直接寻址**：

```asm
movq 0x1000, %rax      # 从绝对地址加载
movq myvar, %rax       # 从符号地址加载（32位模式）
movq myvar(%rip), %rax # RIP相对寻址（64位模式推荐）
```

**2. 寄存器间接寻址**：

```asm
movq (%rbx), %rax      # 从rbx指向的地址加载
movq %rdx, (%rcx)      # 存储到rcx指向的地址
```

**3. 基址+偏移寻址**：

```asm
movq 8(%rbx), %rax     # 从rbx+8加载
movq -16(%rbp), %rax   # 从rbp-16加载（局部变量）
movq 32(%rsp), %rax    # 从rsp+32加载（栈参数）
```

**4. 基址+索引寻址**：

```asm
movq (%rbx, %rcx), %rax      # 从rbx+rcx加载
movq (%rsi, %rdi), %rax      # 从rsi+rdi加载
```

**5. 基址+索引*比例寻址**：

```asm
# 数组访问（scale对应元素大小）
movb (%rbx, %rcx, 1), %al    # 字节数组
movw (%rbx, %rcx, 2), %ax    # 字数组
movl (%rbx, %rcx, 4), %eax   # 双字数组
movq (%rbx, %rcx, 8), %rax   # 四字数组
```

**6. 完整寻址模式**：

```asm
# displacement(%base, %index, scale)
movq 16(%rbx, %rcx, 8), %rax     # 结构体数组访问
movq -32(%rbp, %rdi, 4), %rax    # 复杂偏移计算
```

### 寻址模式对比表

| 寻址模式 | AT&T语法 | Intel语法 |
|----------|----------|-----------|
| 直接 | `0x1000` | `[0x1000]` |
| 间接 | `(%rax)` | `[rax]` |
| 基址+偏移 | `8(%rax)` | `[rax+8]` |
| 基址+索引 | `(%rax, %rbx)` | `[rax+rbx]` |
| 索引*比例 | `(, %rbx, 4)` | `[rbx*4]` |
| 基址+索引*比例 | `(%rax, %rbx, 4)` | `[rax+rbx*4]` |
| 完整形式 | `8(%rax, %rbx, 4)` | `[rax+rbx*4+8]` |
| RIP相对 | `symbol(%rip)` | `[rel symbol]` |

### RIP相对寻址（64位模式）

64位模式下，推荐使用RIP相对寻址访问全局数据：

```asm
.data
myvar:
    .quad 0x12345678

.text
    # RIP相对寻址（推荐）
    movq myvar(%rip), %rax     # 加载myvar的值
    leaq myvar(%rip), %rbx     # 加载myvar的地址
    
    # 绝对寻址（不推荐，需要重定位）
    movabs $myvar, %rax        # 加载绝对地址
```

### 段覆盖

```asm
# 使用段前缀访问特定段
movq %fs:0, %rax           # FS段偏移0
movq %gs:0x28, %rax        # GS段偏移0x28
movq %es:(%rdi), %rax      # ES段，RDI偏移

# 常见用途
movq %fs:0x28, %rax        # Linux: 栈金丝雀值
movq %gs:0x30, %rax        # Windows: TEB指针
```

### 寻址模式示例汇总

```asm
# 各种寻址模式示例
movq 0x1000, %rax              # 直接寻址
movq (%rbx), %rax              # 寄存器间接
movq 8(%rbx), %rax             # 基址+偏移
movq (%rbx, %rcx), %rax        # 基址+索引
movq (%rbx, %rcx, 4), %rax     # 基址+索引*比例
movq 8(%rbx, %rcx, 4), %rax    # 完整形式
movq myvar(%rip), %rax         # RIP相对
movq %fs:0x28, %rax            # 段覆盖

# 实际应用场景
movq -8(%rbp), %rax            # 访问局部变量
movq 16(%rbp), %rax            # 访问函数参数
movq 32(%rsp), %rax            # 访问栈上数据
movq array(, %rcx, 8), %rax    # 访问数组元素
movq 8(%rdi), %rax             # 访问结构体字段
```

---

## 数据指令

### 初始化数据定义

GAS使用以下指令定义初始化数据：

| 指令 | 大小 | 说明 | Intel等效 |
|------|------|------|-----------|
| `.byte` | 1字节 | 字节 | DB |
| `.word` / `.short` | 2字节 | 字 | DW |
| `.long` / `.int` | 4字节 | 双字 | DD |
| `.quad` | 8字节 | 四字 | DQ |
| `.octa` | 16字节 | 八字 | DO |
| `.float` | 4字节 | 单精度浮点 | REAL4 |
| `.double` | 8字节 | 双精度浮点 | REAL8 |
| `.ascii` | 变长 | ASCII字符串（无终止符） | - |
| `.asciz` / `.string` | 变长 | ASCII字符串（带null终止符） | - |

**数据定义示例**：

```asm
.data
    # 基本数据类型
    byte_val:   .byte 0x42
    word_val:   .word 0x1234
    long_val:   .long 0x12345678
    quad_val:   .quad 0x123456789ABCDEF0
    
    # 浮点数据
    float_val:  .float 3.14159
    double_val: .double 3.14159265358979
    
    # 字符串
    string1:    .asciz "Hello, World!"      # 带null终止符
    string2:    .ascii "No terminator"      # 无null终止符
    string3:    .string "Also terminated"   # 等同于.asciz
    
    # 多值定义
    int_array:  .long 1, 2, 3, 4, 5         # 5个双字
    ptr_array:  .quad func1, func2, func3  # 3个指针
    
    # 重复数据
    zeros:      .fill 100, 1, 0            # 100个零字节
    pattern:    .fill 10, 2, 0xABCD        # 10个0xABCD
    
    # 对齐
    .align 16
    aligned_data: .quad 0
```

### 未初始化数据定义

GAS使用以下指令定义未初始化数据：

| 指令 | 说明 |
|------|------|
| `.skip N` / `.space N` | 跳过N字节（填充0） |
| `.skip N, fill` | 跳过N字节（填充指定值） |
| `.comm symbol, size` | 声明公共符号 |
| `.lcomm symbol, size` | 声明本地公共符号 |

```asm
.bss
    # 未初始化数据
    buffer:     .skip 1024         # 1024字节缓冲区
    numbers:    .skip 400          # 100个双字（400字节）
    
    # 使用.comm声明
    .comm global_buffer, 2048      # 全局未初始化缓冲区
    .lcomm local_buffer, 1024      # 本地未初始化缓冲区
    
    # 对齐的未初始化数据
    .align 16
    aligned_buf: .skip 256
```

### 结构体定义

GAS没有内置的结构体支持，但可以使用常量偏移量模拟：

```asm
# 定义结构体偏移量
.equ Point.x, 0
.equ Point.y, 8
.equ Point.size, 16

.equ Rectangle.origin, 0
.equ Rectangle.width, 16
.equ Rectangle.height, 24
.equ Rectangle.size, 32

.data
    # 实例化结构体
    mypoint:
        .quad 100              # x
        .quad 200              # y
    
    myrect:
        .quad 10, 20           # origin.x, origin.y
        .quad 100              # width
        .quad 50               # height

.text
    # 访问结构体字段
    movq mypoint + Point.x(%rip), %rax
    movq mypoint + Point.y(%rip), %rbx
    movq myrect + Rectangle.width(%rip), %rcx
```

---

## 节/段指令

### 节定义

GAS使用`.section`指令定义节：

```asm
# 标准节
.text                          # 代码节
.data                          # 初始化数据节
.bss                           # 未初始化数据节
.rodata                        # 只读数据节

# 带属性的节定义
.section .text, "ax", @progbits
.section .data, "aw", @progbits
.section .bss, "aw", @nobits
.section .rodata, "a", @progbits

# 自定义节
.section .mydata, "aw", @progbits
```

**节属性说明**：

| 属性 | 说明 |
|------|------|
| `a` | 可分配（allocatable） |
| `w` | 可写（writable） |
| `x` | 可执行（executable） |
| `M` | 可合并（mergeable） |
| `S` | 包含字符串 |
| `G` | 节组成员 |

| 类型 | 说明 |
|------|------|
| `@progbits` | 包含数据 |
| `@nobits` | 不包含数据（BSS） |
| `@note` | 注释信息 |
| `@init_array` | 初始化函数数组 |
| `@fini_array` | 终止函数数组 |

### 对齐指令

```asm
.data
    .byte 1
    .align 4               # 对齐到4字节边界
    .long 0x12345678
    
    .align 16              # 对齐到16字节边界
    .quad 0, 0             # SSE对齐数据

.text
    # 代码对齐
    .align 16              # 对齐循环入口
loop_start:
    # 循环体
    
    # 使用.p2align（2的幂对齐）
    .p2align 4             # 对齐到2^4=16字节
    
    # 带填充的对齐
    .p2align 4, 0x90       # 用NOP填充
```

---

## 汇编器指令

### 符号定义指令

```asm
# 全局符号（导出）
.globl my_function
.global my_function        # 等同于.globl

# 外部符号（导入）
# GAS不需要显式声明外部符号，直接使用即可

# 弱符号
.weak weak_symbol

# 符号类型
.type my_function, @function
.type my_variable, @object

# 符号大小
.size my_function, .-my_function
.size my_variable, 8
```

### 函数定义模板

GAS中定义函数的标准模板：

```asm
.text
.globl my_function
.type my_function, @function

my_function:
    # 函数序言
    pushq %rbp
    movq %rsp, %rbp
    
    # 函数体
    # ...
    
    # 函数尾声
    popq %rbp
    ret

.size my_function, .-my_function
```

### 条件汇编指令

```asm
# 条件编译
.ifdef DEBUG
    # 调试代码
.endif

.ifndef RELEASE
    # 非发布代码
.endif

.if VERSION >= 2
    # 版本2+代码
.elseif VERSION == 1
    # 版本1代码
.else
    .error "Unknown version"
.endif

# 检查符号是否定义
.ifdef BUFFER_SIZE
.else
    .equ BUFFER_SIZE, 1024
.endif
```

### 文件包含和宏

```asm
# 文件包含
.include "macros.inc"
.include "constants.inc"

# 宏定义
.macro push_all
    pushq %rax
    pushq %rbx
    pushq %rcx
    pushq %rdx
.endm

.macro pop_all
    popq %rdx
    popq %rcx
    popq %rbx
    popq %rax
.endm

# 带参数的宏
.macro prologue size
    pushq %rbp
    movq %rsp, %rbp
    subq $\size, %rsp
.endm

.macro epilogue
    movq %rbp, %rsp
    popq %rbp
    ret
.endm

# 使用宏
my_function:
    prologue 32
    push_all
    # 函数体
    pop_all
    epilogue
```

### 高级宏功能

```asm
# 可变参数宏
.macro print_regs regs:vararg
    .irp reg, \regs
        pushq \reg
    .endr
.endm

# 局部标签宏
.macro safe_div
    testq %rbx, %rbx
    jz 1f                  # 跳转到局部标签1
    xorq %rdx, %rdx
    divq %rbx
1:                         # 局部标签
.endm

# 重复块
.rept 10
    nop
.endr

# 迭代宏
.irp reg, %rax, %rbx, %rcx, %rdx
    pushq \reg
.endr

# 字符迭代
.irpc char, ABCD
    .byte '\char'
.endr
```

### 调试信息指令

```asm
# 文件和行号信息
.file "myfile.s"
.loc 1 10 0                # 文件1，行10，列0

# CFI（Call Frame Information）指令
.cfi_startproc
    pushq %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset %rbp, -16
    movq %rsp, %rbp
    .cfi_def_cfa_register %rbp
    
    # 函数体
    
    popq %rbp
    .cfi_def_cfa %rsp, 8
    ret
.cfi_endproc
```

---

## GCC内联汇编

GCC内联汇编允许在C/C++代码中嵌入AT&T汇编指令，是AT&T语法最重要的应用场景之一。

### 基本语法

```c
asm [volatile] (
    "assembly template"
    : output operands      /* 可选 */
    : input operands       /* 可选 */
    : clobbered registers  /* 可选 */
);
```

### 简单示例

```c
// 最简单的内联汇编
asm("nop");

// 带volatile防止优化
asm volatile("mfence");

// 多条指令
asm volatile(
    "pushq %%rbp\n\t"
    "movq %%rsp, %%rbp\n\t"
    "popq %%rbp"
);
```

### 操作数约束

**输出约束**：

| 约束 | 说明 |
|------|------|
| `=r` | 输出到通用寄存器 |
| `=m` | 输出到内存 |
| `=a` | 输出到%rax |
| `=b` | 输出到%rbx |
| `=c` | 输出到%rcx |
| `=d` | 输出到%rdx |
| `=S` | 输出到%rsi |
| `=D` | 输出到%rdi |
| `+r` | 读写寄存器 |
| `=&r` | 早期破坏寄存器 |

**输入约束**：

| 约束 | 说明 |
|------|------|
| `r` | 通用寄存器 |
| `m` | 内存操作数 |
| `i` | 立即数 |
| `n` | 已知立即数 |
| `g` | 通用（寄存器、内存或立即数） |
| `0-9` | 与第N个操作数相同 |
| `a,b,c,d,S,D` | 特定寄存器 |

### 内联汇编示例

**示例1：简单加法**

```c
int add(int a, int b) {
    int result;
    asm(
        "addl %2, %0"
        : "=r" (result)      // 输出：result
        : "0" (a), "r" (b)   // 输入：a（与输出相同），b
    );
    return result;
}
```

**示例2：读取时间戳计数器**

```c
uint64_t rdtsc(void) {
    uint32_t lo, hi;
    asm volatile(
        "rdtsc"
        : "=a" (lo), "=d" (hi)  // 输出：lo=%eax, hi=%edx
    );
    return ((uint64_t)hi << 32) | lo;
}
```

**示例3：原子比较交换**

```c
int atomic_cmpxchg(int *ptr, int expected, int desired) {
    int result;
    asm volatile(
        "lock cmpxchgl %3, %1"
        : "=a" (result), "+m" (*ptr)  // 输出：result=%eax, *ptr读写
        : "0" (expected), "r" (desired)  // 输入：expected=%eax, desired
        : "cc"  // 破坏：条件码
    );
    return result;
}
```

**示例4：CPUID**

```c
void cpuid(uint32_t leaf, uint32_t *eax, uint32_t *ebx, 
           uint32_t *ecx, uint32_t *edx) {
    asm volatile(
        "cpuid"
        : "=a" (*eax), "=b" (*ebx), "=c" (*ecx), "=d" (*edx)
        : "a" (leaf)
    );
}
```

**示例5：内存屏障**

```c
// 完整内存屏障
#define barrier() asm volatile("" ::: "memory")

// 读屏障
#define rmb() asm volatile("lfence" ::: "memory")

// 写屏障
#define wmb() asm volatile("sfence" ::: "memory")

// 全屏障
#define mb() asm volatile("mfence" ::: "memory")
```

**示例6：位操作**

```c
// 查找最低设置位
int find_first_set(uint64_t value) {
    uint64_t result;
    asm(
        "bsfq %1, %0"
        : "=r" (result)
        : "r" (value)
        : "cc"
    );
    return (int)result;
}

// 人口计数
int popcount(uint64_t value) {
    uint64_t result;
    asm(
        "popcntq %1, %0"
        : "=r" (result)
        : "r" (value)
    );
    return (int)result;
}
```

### 扩展内联汇编语法

**命名操作数**（GCC 3.1+）：

```c
int add_named(int a, int b) {
    int result;
    asm(
        "addl %[input_b], %[output]"
        : [output] "=r" (result)
        : [input_a] "0" (a), [input_b] "r" (b)
    );
    return result;
}
```

**goto标签**（GCC 4.5+）：

```c
void check_and_jump(int value) {
    asm goto(
        "testl %0, %0\n\t"
        "jz %l[zero_label]"
        :
        : "r" (value)
        :
        : zero_label
    );
    printf("Non-zero\n");
    return;
    
zero_label:
    printf("Zero\n");
}
```

### 内联汇编最佳实践

**1. 始终使用volatile**（除非确定可以优化）：

```c
// 有副作用的操作必须使用volatile
asm volatile("wbinvd");  // 刷新缓存

// 纯计算可以不用volatile（允许优化）
asm("addl %1, %0" : "=r"(result) : "r"(a), "0"(b));
```

**2. 正确声明破坏列表**：

```c
asm volatile(
    "..."
    : outputs
    : inputs
    : "rax", "rbx", "cc", "memory"  // 破坏的寄存器和标志
);
```

**3. 使用%%转义寄存器名**：

```c
// 在内联汇编中，%用于操作数引用
// 使用%%表示字面的%
asm("movq %%rax, %%rbx");  // 正确
asm("movq %rax, %rbx");    // 错误！%rax会被解释为操作数
```

**4. 处理64位立即数**：

```c
// 64位立即数需要特殊处理
uint64_t value = 0x123456789ABCDEF0ULL;
asm(
    "movabsq %1, %0"  // 使用movabs加载64位立即数
    : "=r" (result)
    : "i" (value)
);
```

---

## 代码示例

### 示例1：Hello World（Linux x64）

```asm
# hello.s - GAS Linux x64
.section .data
message:
    .asciz "Hello, World!\n"
    .equ msg_len, . - message

.section .text
.globl _start

_start:
    # sys_write(stdout, message, msg_len)
    movq $1, %rax              # syscall: write
    movq $1, %rdi              # fd: stdout
    leaq message(%rip), %rsi   # buffer
    movq $msg_len, %rdx        # count
    syscall
    
    # sys_exit(0)
    movq $60, %rax             # syscall: exit
    xorq %rdi, %rdi            # status: 0
    syscall
```

### 示例2：函数调用（System V ABI）

```asm
# function.s - GAS Linux x64
.section .text
.globl add_numbers
.type add_numbers, @function

# int64_t add_numbers(int64_t a, int64_t b)
# 参数: %rdi=a, %rsi=b
# 返回: %rax
add_numbers:
    movq %rdi, %rax
    addq %rsi, %rax
    ret
.size add_numbers, .-add_numbers

.globl call_example
.type call_example, @function

# 调用示例
call_example:
    pushq %rbp
    movq %rsp, %rbp
    
    # 调用 add_numbers(10, 20)
    movq $10, %rdi             # 第一个参数
    movq $20, %rsi             # 第二个参数
    call add_numbers
    # 结果在 %rax 中
    
    popq %rbp
    ret
.size call_example, .-call_example
```

### 示例3：数组操作

```asm
# array.s - GAS
.section .data
array:
    .quad 10, 20, 30, 40, 50
    .equ array_len, (. - array) / 8

.section .text
.globl sum_array
.type sum_array, @function

# int64_t sum_array(int64_t* arr, size_t len)
sum_array:
    xorq %rax, %rax            # sum = 0
    testq %rsi, %rsi           # if len == 0
    jz .done
    
.loop:
    addq (%rdi), %rax          # sum += *arr
    addq $8, %rdi              # arr++
    decq %rsi                  # len--
    jnz .loop
    
.done:
    ret
.size sum_array, .-sum_array
```

### 示例4：字符串操作

```asm
# string.s - GAS
.section .text
.globl my_strlen
.type my_strlen, @function

# size_t my_strlen(const char* str)
my_strlen:
    xorq %rax, %rax            # len = 0
    
.loop:
    cmpb $0, (%rdi, %rax)      # if str[len] == 0
    je .done
    incq %rax                  # len++
    jmp .loop
    
.done:
    ret
.size my_strlen, .-my_strlen

.globl my_strcpy
.type my_strcpy, @function

# char* my_strcpy(char* dst, const char* src)
my_strcpy:
    movq %rdi, %rax            # 保存dst作为返回值
    
.copy_loop:
    movb (%rsi), %cl           # cl = *src
    movb %cl, (%rdi)           # *dst = cl
    testb %cl, %cl             # if cl == 0
    jz .copy_done
    incq %rsi                  # src++
    incq %rdi                  # dst++
    jmp .copy_loop
    
.copy_done:
    ret
.size my_strcpy, .-my_strcpy
```

### 示例5：SIMD向量操作

```asm
# simd.s - GAS AVX
.section .text
.globl add_vectors_avx
.type add_vectors_avx, @function

# void add_vectors_avx(float* a, float* b, float* result, size_t count)
# 参数: %rdi=a, %rsi=b, %rdx=result, %rcx=count
add_vectors_avx:
    # 处理8个float一组（256位）
    shrq $3, %rcx              # count /= 8
    jz .remainder
    
.loop8:
    vmovups (%rdi), %ymm0      # 加载8个float
    vmovups (%rsi), %ymm1
    vaddps %ymm1, %ymm0, %ymm0 # 向量加法
    vmovups %ymm0, (%rdx)      # 存储结果
    
    addq $32, %rdi
    addq $32, %rsi
    addq $32, %rdx
    decq %rcx
    jnz .loop8
    
.remainder:
    # 处理剩余元素（简化版，省略）
    vzeroupper                 # 清除YMM高位
    ret
.size add_vectors_avx, .-add_vectors_avx
```

### 示例6：原子操作

```asm
# atomic.s - GAS
.section .text
.globl atomic_add
.type atomic_add, @function

# int64_t atomic_add(int64_t* ptr, int64_t value)
# 返回旧值
atomic_add:
    movq %rsi, %rax
    lock xaddq %rax, (%rdi)
    ret
.size atomic_add, .-atomic_add

.globl atomic_cmpxchg
.type atomic_cmpxchg, @function

# bool atomic_cmpxchg(int64_t* ptr, int64_t expected, int64_t desired)
# 返回是否成功
atomic_cmpxchg:
    movq %rsi, %rax            # expected
    lock cmpxchgq %rdx, (%rdi) # compare and exchange
    sete %al                   # 设置返回值
    movzbl %al, %eax
    ret
.size atomic_cmpxchg, .-atomic_cmpxchg

.globl spinlock_acquire
.type spinlock_acquire, @function

# void spinlock_acquire(int64_t* lock)
spinlock_acquire:
    movq $1, %rax
.spin:
    xorq %rcx, %rcx
    lock cmpxchgq %rax, (%rdi) # 尝试获取锁
    jnz .spin                  # 如果失败，重试
    ret
.size spinlock_acquire, .-spinlock_acquire

.globl spinlock_release
.type spinlock_release, @function

# void spinlock_release(int64_t* lock)
spinlock_release:
    movq $0, (%rdi)            # 释放锁
    ret
.size spinlock_release, .-spinlock_release
```

### 示例7：栈帧和局部变量

```asm
# stack.s - GAS
.section .text
.globl complex_function
.type complex_function, @function

# 演示完整的栈帧管理
complex_function:
    .cfi_startproc
    # 函数序言
    pushq %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset %rbp, -16
    movq %rsp, %rbp
    .cfi_def_cfa_register %rbp
    subq $48, %rsp             # 分配局部变量空间
    
    # 保存被调用者保存寄存器
    pushq %rbx
    pushq %r12
    pushq %r13
    
    # 局部变量布局:
    # -8(%rbp)  : local1 (8字节)
    # -16(%rbp) : local2 (8字节)
    # -24(%rbp) : local3 (8字节)
    # -32(%rbp) : local4 (8字节)
    # -40(%rbp) : local5 (8字节)
    # -48(%rbp) : local6 (8字节)
    
    # 初始化局部变量
    movq $0, -8(%rbp)
    movq $0, -16(%rbp)
    
    # 使用局部变量
    movq -8(%rbp), %rax
    addq -16(%rbp), %rax
    movq %rax, -24(%rbp)
    
    # 恢复被调用者保存寄存器
    popq %r13
    popq %r12
    popq %rbx
    
    # 函数尾声
    movq %rbp, %rsp
    popq %rbp
    .cfi_def_cfa %rsp, 8
    ret
    .cfi_endproc
.size complex_function, .-complex_function
```

### 示例8：条件执行和分支

```asm
# branch.s - GAS
.section .text
.globl max
.type max, @function

# int64_t max(int64_t a, int64_t b)
max:
    movq %rdi, %rax
    cmpq %rsi, %rdi
    cmovlq %rsi, %rax          # 如果a < b，rax = b
    ret
.size max, .-max

.globl abs_value
.type abs_value, @function

# int64_t abs_value(int64_t x)
abs_value:
    movq %rdi, %rax
    negq %rdi                  # rdi = -x
    cmovsq %rdi, %rax          # 如果原值为负，使用取反后的值
    ret
.size abs_value, .-abs_value

.globl clamp
.type clamp, @function

# int64_t clamp(int64_t value, int64_t min, int64_t max)
clamp:
    movq %rdi, %rax            # rax = value
    cmpq %rsi, %rax
    cmovlq %rsi, %rax          # if value < min, rax = min
    cmpq %rdx, %rax
    cmovgq %rdx, %rax          # if value > max, rax = max
    ret
.size clamp, .-clamp
```

### 示例9：系统调用

```asm
# syscall.s - GAS Linux x64
.section .text
.globl sys_write
.type sys_write, @function

# ssize_t sys_write(int fd, const void* buf, size_t count)
sys_write:
    movq %rdx, %rdx            # count (已在正确位置)
    movq %rsi, %rsi            # buf (已在正确位置)
    movq %rdi, %rdi            # fd (已在正确位置)
    movq $1, %rax              # syscall number: write
    syscall
    ret
.size sys_write, .-sys_write

.globl sys_read
.type sys_read, @function

# ssize_t sys_read(int fd, void* buf, size_t count)
sys_read:
    movq $0, %rax              # syscall number: read
    syscall
    ret
.size sys_read, .-sys_read

.globl sys_exit
.type sys_exit, @function

# void sys_exit(int status)
sys_exit:
    movq $60, %rax             # syscall number: exit
    syscall
    # 不返回
.size sys_exit, .-sys_exit
```

### 示例10：C调用汇编函数

**汇编文件（asm_funcs.s）**：

```asm
.section .text
.globl asm_multiply
.type asm_multiply, @function

# int64_t asm_multiply(int64_t a, int64_t b)
asm_multiply:
    movq %rdi, %rax
    imulq %rsi, %rax
    ret
.size asm_multiply, .-asm_multiply

.globl asm_divide
.type asm_divide, @function

# int64_t asm_divide(int64_t dividend, int64_t divisor)
asm_divide:
    movq %rdi, %rax
    cqto                       # 符号扩展到rdx:rax
    idivq %rsi
    ret
.size asm_divide, .-asm_divide
```

**C文件（main.c）**：

```c
#include <stdio.h>
#include <stdint.h>

// 声明汇编函数
extern int64_t asm_multiply(int64_t a, int64_t b);
extern int64_t asm_divide(int64_t dividend, int64_t divisor);

int main() {
    int64_t a = 42, b = 10;
    
    printf("multiply: %ld * %ld = %ld\n", a, b, asm_multiply(a, b));
    printf("divide: %ld / %ld = %ld\n", a, b, asm_divide(a, b));
    
    return 0;
}
```

**编译命令**：

```bash
# 汇编
as -o asm_funcs.o asm_funcs.s

# 编译C文件
gcc -c -o main.o main.c

# 链接
gcc -o program main.o asm_funcs.o

# 或一步完成
gcc -o program main.c asm_funcs.s
```

---

## 常见模式与最佳实践

### 函数序言和尾声

**标准序言**：

```asm
function_name:
    .cfi_startproc
    pushq %rbp                 # 保存旧帧指针
    .cfi_def_cfa_offset 16
    .cfi_offset %rbp, -16
    movq %rsp, %rbp            # 建立新帧
    .cfi_def_cfa_register %rbp
    subq $N, %rsp              # 分配局部变量（N需16字节对齐）
    
    # 保存被调用者保存寄存器（如需要）
    pushq %rbx
    pushq %r12
    # ...
```

**标准尾声**：

```asm
    # 恢复被调用者保存寄存器
    # ...
    popq %r12
    popq %rbx
    
    movq %rbp, %rsp            # 释放局部变量
    popq %rbp                  # 恢复旧帧指针
    .cfi_def_cfa %rsp, 8
    ret
    .cfi_endproc

# 或使用leave指令
    leave                      # 等价于 movq %rbp, %rsp; popq %rbp
    ret
```

**无帧指针优化**：

```asm
# 对于简单函数，可以省略帧指针
simple_function:
    .cfi_startproc
    subq $8, %rsp              # 保持16字节对齐
    .cfi_def_cfa_offset 16
    # 函数体（使用rsp相对寻址）
    addq $8, %rsp
    .cfi_def_cfa_offset 8
    ret
    .cfi_endproc
```

### 循环优化

**基本循环**：

```asm
# 计数循环
    movq $count, %rcx
.loop:
    # 循环体
    decq %rcx
    jnz .loop
```

**循环展开**：

```asm
# 4倍展开
    movq $count, %rcx
    shrq $2, %rcx              # count / 4
    jz .remainder
    
.loop4:
    # 处理4个元素
    movq (%rsi), %rax
    movq %rax, (%rdi)
    movq 8(%rsi), %rax
    movq %rax, 8(%rdi)
    movq 16(%rsi), %rax
    movq %rax, 16(%rdi)
    movq 24(%rsi), %rax
    movq %rax, 24(%rdi)
    
    addq $32, %rsi
    addq $32, %rdi
    decq %rcx
    jnz .loop4
    
.remainder:
    # 处理剩余元素
    movq $count, %rcx
    andq $3, %rcx              # count % 4
    jz .done
    
.loop1:
    movq (%rsi), %rax
    movq %rax, (%rdi)
    addq $8, %rsi
    addq $8, %rdi
    decq %rcx
    jnz .loop1
    
.done:
    ret
```

**对齐循环入口**：

```asm
    .p2align 4                 # 对齐到16字节边界
.hot_loop:
    # 性能关键循环
    # ...
    jnz .hot_loop
```

### 内存访问优化

**预取数据**：

```asm
    # 预取下一个缓存行
    prefetcht0 64(%rsi)
    
    # 处理当前数据
    movq (%rsi), %rax
    # ...
```

**避免缓存行分裂**：

```asm
.section .data
    .align 64                  # 对齐到缓存行边界
hot_data:
    .skip 64
```

**使用非临时存储**：

```asm
    # 对于不会很快再次访问的数据
    movntdq %xmm0, (%rdi)      # 非临时存储，绕过缓存
    sfence                     # 确保存储完成
```

### 分支预测友好

**将常见情况放在前面**：

```asm
    testq %rax, %rax
    jz .rare_case              # 罕见情况跳转
    
    # 常见情况代码（顺序执行）
    # ...
    ret
    
.rare_case:
    # 罕见情况处理
    # ...
    ret
```

**使用条件移动代替分支**：

```asm
    # 不好：分支可能预测失败
    cmpq %rbx, %rax
    jl .less
    movq %rax, %rcx
    jmp .done
.less:
    movq %rbx, %rcx
.done:

    # 好：无分支
    cmpq %rbx, %rax
    movq %rax, %rcx
    cmovlq %rbx, %rcx          # 条件移动
```

### 调试技巧

**插入断点**：

```asm
    int $3                     # 软件断点
    # 或
    .byte 0xCC                 # INT3的机器码
```

**保留调试信息**：

```asm
# 使用有意义的标签名
.check_bounds:
    cmpq %rbx, %rax
    jae .bounds_error
    
.process_element:
    # ...
    
.bounds_error:
    # 错误处理
```

**添加注释**：

```asm
# 函数: calculate_hash
# 参数: %rdi = 数据指针, %rsi = 数据长度
# 返回: %rax = 哈希值
# 修改: %rcx, %rdx
calculate_hash:
    # 初始化哈希值
    movq $0x811c9dc5, %rax     # FNV-1a初始值
    # ...
```

---

## 工具与资源

### 汇编和链接

**GAS（通过gcc）**：

```bash
# 汇编为目标文件
gcc -c -o output.o input.s

# 带调试信息
gcc -c -g -o output.o input.s

# 生成汇编代码
gcc -S -o output.s input.c

# 使用Intel语法生成
gcc -S -masm=intel -o output.s input.c

# 查看预处理后的汇编
gcc -E input.s > preprocessed.s
```

**直接使用as**：

```bash
# 汇编
as -o output.o input.s

# 带调试信息
as -g -o output.o input.s

# 生成64位代码
as --64 -o output.o input.s

# 生成32位代码
as --32 -o output.o input.s
```

**链接**：

```bash
# 使用ld
ld -o program output.o

# 使用gcc（推荐，自动链接C库）
gcc -o program output.o

# 静态链接
gcc -static -o program output.o

# 链接多个文件
gcc -o program file1.o file2.o file3.o
```

### 反汇编和分析

**objdump**：

```bash
# 反汇编（AT&T语法，默认）
objdump -d program

# 反汇编（Intel语法）
objdump -d -M intel program

# 显示所有节
objdump -h program

# 显示符号表
objdump -t program

# 显示重定位信息
objdump -r program.o

# 显示源码和汇编混合
objdump -d -S program
```

**readelf**：

```bash
# 显示ELF头
readelf -h program

# 显示节头
readelf -S program

# 显示符号表
readelf -s program

# 显示重定位
readelf -r program.o
```

### 调试

**GDB**：

```bash
# 启动调试
gdb ./program

# 常用命令
(gdb) break main           # 设置断点
(gdb) run                  # 运行程序
(gdb) stepi                # 单步执行（指令级）
(gdb) nexti                # 单步执行（跳过调用）
(gdb) info registers       # 显示寄存器
(gdb) x/10i $rip           # 显示接下来10条指令
(gdb) x/10gx $rsp          # 显示栈内容
(gdb) disassemble          # 反汇编当前函数

# 设置Intel语法显示
(gdb) set disassembly-flavor intel

# 设置AT&T语法显示（默认）
(gdb) set disassembly-flavor att
```

**LLDB**：

```bash
# 启动调试
lldb ./program

# 常用命令
(lldb) breakpoint set -n main
(lldb) run
(lldb) register read
(lldb) disassemble -p
(lldb) memory read -fx -c10 $rsp

# 设置AT&T语法
(lldb) settings set target.x86-disassembly-flavor att
```

### 性能分析

**perf（Linux）**：

```bash
# 记录性能数据
perf record ./program

# 查看报告
perf report

# 显示注解（源码/汇编）
perf annotate

# 统计事件
perf stat ./program
```

---

## 参考资料

### 官方文档

- [GNU Assembler Manual](https://sourceware.org/binutils/docs/as/) - GAS官方文档
- [GCC Inline Assembly HOWTO](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html) - GCC内联汇编文档
- [System V AMD64 ABI](https://gitlab.com/x86-psABIs/x86-64-ABI) - System V x86-64 ABI规范

### 教程和指南

- [x86 Assembly Guide](https://www.cs.virginia.edu/~evans/cs216/guides/x86.html) - 弗吉尼亚大学x86汇编指南
- [Linux Assembly HOWTO](https://tldp.org/HOWTO/Assembly-HOWTO/) - Linux汇编入门
- [AT&T Assembly Syntax](https://csiflabs.cs.ucdavis.edu/~ssdavis/50/att-syntax.htm) - AT&T语法详解

### 在线资源

- [Godbolt Compiler Explorer](https://godbolt.org/) - 在线编译器和反汇编器
- [x86 and amd64 Instruction Reference](https://www.felixcloutier.com/x86/) - x86指令参考
- [Agner Fog's Optimization Manuals](https://www.agner.org/optimize/) - 优化手册

### 书籍推荐

- *Programming from the Ground Up* by Jonathan Bartlett - 使用AT&T语法的入门书籍
- *Professional Assembly Language* by Richard Blum - 涵盖AT&T和Intel语法
- *Linux Assembly Language Programming* by Bob Neveln - Linux汇编编程

---

## 附录：快速参考卡

### AT&T vs Intel 语法速查

| 特性 | AT&T | Intel |
|------|------|-------|
| 操作数顺序 | 源, 目标 | 目标, 源 |
| 寄存器 | `%rax` | `rax` |
| 立即数 | `$42` | `42` |
| 内存 | `(%rax)` | `[rax]` |
| 偏移 | `8(%rax)` | `[rax+8]` |
| 索引 | `(%rax,%rbx,4)` | `[rax+rbx*4]` |
| 大小 | `movq` | `mov QWORD` |
| 注释 | `#` 或 `/* */` | `;` |

### 常用指令速查

| 操作 | AT&T语法 | 示例 |
|------|----------|------|
| 移动 | `mov[bwlq]` | `movq %rax, %rbx` |
| 加法 | `add[bwlq]` | `addq $1, %rax` |
| 减法 | `sub[bwlq]` | `subq %rbx, %rax` |
| 乘法 | `imul[wlq]` | `imulq %rbx, %rax` |
| 除法 | `idiv[bwlq]` | `idivq %rbx` |
| 比较 | `cmp[bwlq]` | `cmpq %rbx, %rax` |
| 测试 | `test[bwlq]` | `testq %rax, %rax` |
| 跳转 | `jmp` | `jmp label` |
| 条件跳转 | `j[cc]` | `je label` |
| 调用 | `call` | `call function` |
| 返回 | `ret` | `ret` |
| 压栈 | `push[wlq]` | `pushq %rax` |
| 出栈 | `pop[wlq]` | `popq %rax` |
| 取地址 | `lea[wlq]` | `leaq 8(%rbx), %rax` |
| 异或 | `xor[bwlq]` | `xorq %rax, %rax` |
| 与 | `and[bwlq]` | `andq $0xFF, %rax` |
| 或 | `or[bwlq]` | `orq $1, %rax` |
| 非 | `not[bwlq]` | `notq %rax` |
| 左移 | `shl[bwlq]` | `shlq $2, %rax` |
| 右移 | `shr[bwlq]` | `shrq $2, %rax` |
| 算术右移 | `sar[bwlq]` | `sarq $2, %rax` |

### 条件跳转速查

| 指令 | 条件 | 说明 |
|------|------|------|
| `je/jz` | ZF=1 | 相等/零 |
| `jne/jnz` | ZF=0 | 不相等/非零 |
| `jl/jnge` | SF≠OF | 小于（有符号） |
| `jle/jng` | ZF=1 或 SF≠OF | 小于等于（有符号） |
| `jg/jnle` | ZF=0 且 SF=OF | 大于（有符号） |
| `jge/jnl` | SF=OF | 大于等于（有符号） |
| `jb/jnae/jc` | CF=1 | 低于（无符号）/进位 |
| `jbe/jna` | CF=1 或 ZF=1 | 低于等于（无符号） |
| `ja/jnbe` | CF=0 且 ZF=0 | 高于（无符号） |
| `jae/jnb/jnc` | CF=0 | 高于等于（无符号）/无进位 |
| `js` | SF=1 | 负数 |
| `jns` | SF=0 | 非负数 |
| `jo` | OF=1 | 溢出 |
| `jno` | OF=0 | 无溢出 |

### 寻址模式速查

| 模式 | AT&T语法 | Intel等效 |
|------|----------|-----------|
| 立即数 | `$imm` | `imm` |
| 寄存器 | `%reg` | `reg` |
| 直接 | `addr` | `[addr]` |
| 间接 | `(%reg)` | `[reg]` |
| 基址+偏移 | `disp(%reg)` | `[reg+disp]` |
| 基址+索引 | `(%base,%index)` | `[base+index]` |
| 比例索引 | `(,%index,s)` | `[index*s]` |
| 完整 | `disp(%base,%index,s)` | `[base+index*s+disp]` |
| RIP相对 | `symbol(%rip)` | `[rel symbol]` |

### GAS指令速查

| 指令 | 说明 |
|------|------|
| `.text` | 代码节 |
| `.data` | 数据节 |
| `.bss` | BSS节 |
| `.globl` | 全局符号 |
| `.type` | 符号类型 |
| `.size` | 符号大小 |
| `.byte` | 定义字节 |
| `.word` | 定义字 |
| `.long` | 定义双字 |
| `.quad` | 定义四字 |
| `.asciz` | 定义字符串 |
| `.skip` | 跳过字节 |
| `.align` | 对齐 |
| `.equ` | 定义常量 |
| `.include` | 包含文件 |
| `.macro` | 定义宏 |
| `.if` | 条件汇编 |

---

*上一节: [Intel 汇编详解](intel.md)*
*下一节: [语法对比表格](comparison-tables.md)*
