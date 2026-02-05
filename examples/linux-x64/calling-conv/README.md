# System V AMD64 ABI 调用约定验证示例

本目录包含验证 System V AMD64 ABI 调用约定的完整示例代码，适用于 Linux 平台。

## 概述

System V AMD64 ABI 是 Linux、macOS、BSD 等 Unix-like 操作系统在 x86-64 架构上使用的标准调用约定。

### 核心特性

| 特性 | 规范 |
|------|------|
| **整数参数寄存器** | RDI, RSI, RDX, RCX, R8, R9（6个） |
| **浮点参数寄存器** | XMM0-XMM7（8个） |
| **整数返回值** | RAX, RDX |
| **浮点返回值** | XMM0, XMM1 |
| **栈对齐** | 16字节（CALL前） |
| **Red Zone** | 128字节（RSP以下） |
| **栈清理** | 调用者（Caller） |
| **Shadow Space** | 无（与Windows x64的主要区别） |

### 寄存器分类

**Caller-saved（易失）**: RAX, RCX, RDX, RSI, RDI, R8-R11, XMM0-XMM15

**Callee-saved（非易失）**: RBX, RBP, RSP, R12-R15

### 与 Microsoft x64 的主要区别

| 特性 | System V AMD64 | Microsoft x64 |
|------|----------------|---------------|
| 整数参数寄存器 | RDI, RSI, RDX, RCX, R8, R9 | RCX, RDX, R8, R9 |
| 参数寄存器数量 | 6个整数 + 8个浮点 | 4个（整数/浮点共享位置） |
| Red Zone | 128字节 | 无 |
| Shadow Space | 无 | 32字节（必须分配） |
| RDI/RSI | Caller-saved | Callee-saved |

## 文件说明

| 文件 | 说明 |
|------|------|
| `calling_conv.s` | GAS (AT&T语法) 汇编实现，演示调用约定 |
| `main.c` | C 语言测试程序，调用汇编函数 |
| `Makefile` | 构建脚本（GCC + GAS） |

## 验证内容

### 1. 参数传递验证

验证前6个整数参数通过 RDI, RSI, RDX, RCX, R8, R9 传递：

```c
// C 函数声明
int64_t sum_six(int64_t a, int64_t b, int64_t c, int64_t d, int64_t e, int64_t f);

// 调用示例
int64_t result = sum_six(1, 2, 3, 4, 5, 6);  // 期望: 21
```

### 2. 栈参数验证

验证第7个及以后的参数通过栈传递：

```c
// C 函数声明
int64_t sum_eight(int64_t a, int64_t b, int64_t c, int64_t d, 
                  int64_t e, int64_t f, int64_t g, int64_t h);

// 调用示例
int64_t result = sum_eight(1, 2, 3, 4, 5, 6, 7, 8);  // 期望: 36
```

### 3. Red Zone 验证

验证叶子函数可以使用 RSP 以下 128 字节的 Red Zone：

```c
// C 函数声明
int64_t use_red_zone(int64_t a, int64_t b, int64_t c);

// 汇编实现使用 Red Zone 存储临时数据，无需调整 RSP
```

### 4. 浮点参数验证

验证浮点参数通过 XMM0-XMM7 传递（独立于整数参数计数）：

```c
// C 函数声明
double sum_doubles(double a, double b, double c, double d);

// 调用示例
double result = sum_doubles(1.5, 2.5, 3.5, 4.5);  // 期望: 12.0
```

### 5. 混合参数验证

验证整数和浮点参数独立计数（与Windows不同）：

```c
// C 函数声明
double mixed_params(int64_t n, double x, int64_t m, double y);

// 参数分配: RDI=n, XMM0=x, RSI=m, XMM1=y
// 注意：整数和浮点参数各自独立计数！
```

### 6. 汇编调用 C 函数

验证从汇编代码正确调用 C 函数（无需 Shadow Space）：

```c
// C 函数
int64_t c_add(int64_t a, int64_t b);

// 汇编函数调用 C 函数
int64_t asm_calls_c(int64_t x, int64_t y);
```

### 7. 返回值验证

验证整数返回值通过 RAX，浮点返回值通过 XMM0：

```c
int64_t get_magic_number(void);  // 返回 RAX
double get_pi(void);             // 返回 XMM0
```

### 8. Callee-saved 寄存器验证

验证 RBX, R12-R15 在函数调用后保持不变：

```c
int64_t verify_callee_saved(int64_t a, int64_t b, int64_t c, int64_t d);
```

## 构建方法

### 前置要求

- **GCC** (GNU Compiler Collection)
- **GNU as** (GNU Assembler，通常随 GCC 安装)
- **make** (可选，用于自动化构建)

### 使用 Make

```bash
# 构建
make

# 运行测试
make test

# 清理
make clean

# 查看详细编译信息
make V=1
```

### 手动构建

```bash
# 1. 汇编 GAS 代码
as -o calling_conv.o calling_conv.s

# 2. 编译 C 代码
gcc -c -o main.o main.c

# 3. 链接
gcc -o test_calling_conv main.o calling_conv.o

# 4. 运行
./test_calling_conv
```

## 预期输出

```
=== System V AMD64 ABI Calling Convention Verification ===

[Test 1] Integer Parameters (RDI, RSI, RDX, RCX, R8, R9)
  sum_six(1, 2, 3, 4, 5, 6) = 21
  Expected: 21 ... PASSED

[Test 2] Stack Parameters (7th and beyond)
  sum_eight(1, 2, 3, 4, 5, 6, 7, 8) = 36
  Expected: 36 ... PASSED

[Test 3] Red Zone Usage (Leaf Function)
  use_red_zone(100, 200, 300) = 600
  Expected: 600 ... PASSED

[Test 4] Floating Point Parameters (XMM0-XMM7)
  sum_doubles(1.5, 2.5, 3.5, 4.5) = 12.000000
  Expected: 12.0 ... PASSED

[Test 5] Mixed Integer/Float Parameters (Independent Counting)
  mixed_params(2, 3.0, 4, 5.0) = 26.000000
  Expected: 26.0 (2*3.0 + 4*5.0) ... PASSED

[Test 6] Assembly Calling C Function
  asm_calls_c(100, 200) = 300
  Expected: 300 ... PASSED

[Test 7] Return Values
  get_magic_number() = 0x123456789ABCDEF0
  get_pi() = 3.141593
  ... PASSED

[Test 8] Callee-saved Register Preservation
  verify_callee_saved(1000, 2000, 3000, 4000) = 10000
  Expected: 10000 ... PASSED

=== All Tests Passed! ===
```

## 调试技巧

### 使用 GDB

```bash
# 启动调试
gdb ./test_calling_conv

# 设置断点
(gdb) break sum_six
(gdb) run

# 查看寄存器
(gdb) info registers rdi rsi rdx rcx r8 r9

# 查看栈
(gdb) x/8gx $rsp

# 单步执行
(gdb) stepi

# 查看 Red Zone
(gdb) x/16gx $rsp-128
```

### 使用 objdump 查看汇编

```bash
# 反汇编目标文件
objdump -d calling_conv.o

# 反汇编可执行文件
objdump -d test_calling_conv
```

## 关键概念说明

### Red Zone（红区）

System V AMD64 ABI 允许叶子函数使用 RSP 以下 128 字节的区域，而无需调整栈指针。

```
栈布局（包含 Red Zone）:

高地址
┌─────────────────┐
│  调用者栈帧     │
├─────────────────┤
│  返回地址       │  [RSP + 0]
├─────────────────┤ ← RSP
│                 │
│   Red Zone      │  [RSP - 1] 到 [RSP - 128]
│   (128字节)     │
│   可自由使用    │
│                 │
└─────────────────┘
低地址
```

**Red Zone 使用规则**：
- 仅限叶子函数（不调用其他函数）
- 最多使用 128 字节
- 信号处理程序不会覆盖 Red Zone
- 内核代码通常禁用 Red Zone（`-mno-red-zone`）

### 参数独立计数

与 Microsoft x64 不同，System V ABI 中整数和浮点参数**独立计数**：

```
func(int a, double b, int c, double d)

System V AMD64:
  a → RDI  (第1个整数)
  b → XMM0 (第1个浮点)
  c → RSI  (第2个整数)
  d → XMM1 (第2个浮点)

Microsoft x64 (对比):
  a → RCX  (位置1)
  b → XMM1 (位置2，不是XMM0!)
  c → R8   (位置3)
  d → XMM3 (位置4，不是XMM2!)
```

### 无 Shadow Space

System V ABI 不需要 Shadow Space，调用函数时无需预留额外栈空间：

```nasm
# System V AMD64 - 调用函数
call_function:
    # 直接调用，无需分配 Shadow Space
    movq    $1, %rdi
    movq    $2, %rsi
    call    some_function
    ret

# Microsoft x64 - 调用函数 (对比)
# call_function:
#     sub     $32, %rsp       # 必须分配 Shadow Space
#     movq    $1, %rcx
#     movq    $2, %rdx
#     call    some_function
#     add     $32, %rsp
#     ret
```

## 参考资料

- [System V AMD64 ABI 规范](https://gitlab.com/x86-psABIs/x86-64-ABI)
- [AMD64 Architecture Programmer's Manual](https://developer.amd.com/resources/developer-guides-manuals/)
- [本项目文档: x64-sysv.md](../../../docs/assembly-calling-conventions/02-x86-x64/x64-sysv.md)

## 相关需求

- **需求 2.4**: System V AMD64 ABI 完整规范
- **需求 2.6**: 参数传递寄存器详细说明
- **需求 2.7**: 返回值寄存器说明
- **需求 10.4**: 代码示例和图表
