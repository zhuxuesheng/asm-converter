# ARM64 AAPCS64 调用约定验证示例

本目录包含验证 ARM64 AAPCS64（ARM Architecture Procedure Call Standard for 64-bit）调用约定的完整示例代码。

## 概述

AAPCS64 是 ARM64（AArch64）架构的标准过程调用约定，定义了函数调用时参数传递、返回值处理、寄存器使用和栈管理的规则。

### 核心特性

| 特性 | 规范 |
|------|------|
| **整数参数寄存器** | X0-X7（8个） |
| **浮点/SIMD参数寄存器** | V0-V7（8个） |
| **整数返回值** | X0（64位）/ X0-X1（128位） |
| **浮点返回值** | V0 |
| **栈对齐** | 16字节（强制） |
| **栈清理** | 调用者（Caller） |
| **帧指针** | X29（FP） |
| **链接寄存器** | X30（LR） |
| **间接结果寄存器** | X8 |

### 寄存器分类

**Caller-saved（易失）**: X0-X15, X16-X17, V0-V7, V16-V31

**Callee-saved（非易失）**: X19-X28, X29(FP), V8-V15（仅低64位）

### 与ARM32 AAPCS的主要区别

| 特性 | ARM32 AAPCS | ARM64 AAPCS64 |
|------|-------------|---------------|
| 整数参数寄存器 | R0-R3 (4个) | X0-X7 (8个) |
| 浮点参数寄存器 | S0-S15/D0-D7 | V0-V7 |
| 栈对齐 | 8字节 | 16字节 |
| 64位参数对齐 | 偶数寄存器对 | 无特殊要求 |
| 零寄存器 | 无 | XZR/WZR |
| 间接结果寄存器 | 无 | X8 |

## 文件说明

| 文件 | 说明 |
|------|------|
| `calling_conv.s` | ARM64 汇编实现（GAS语法），演示AAPCS64调用约定 |
| `main.c` | C 语言测试程序，调用汇编函数 |
| `Makefile` | 构建脚本（交叉编译） |

## 验证内容

### 1. 参数传递验证

验证前8个整数参数通过 X0-X7 传递：

```c
// C 函数声明
long sum_eight(long a, long b, long c, long d, long e, long f, long g, long h);

// 调用示例
long result = sum_eight(1, 2, 3, 4, 5, 6, 7, 8);  // 期望: 36
```

### 2. 栈参数验证

验证第9个及以后的参数通过栈传递：

```c
// C 函数声明
long sum_ten(long a, long b, long c, long d, long e, long f, long g, long h, long i, long j);

// 调用示例
long result = sum_ten(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);  // 期望: 55
```

### 3. 浮点参数验证

验证浮点参数通过 V0-V7 传递（独立于整数参数计数）：

```c
// C 函数声明
double sum_doubles(double a, double b, double c, double d);

// 调用示例
double result = sum_doubles(1.5, 2.5, 3.5, 4.5);  // 期望: 12.0
```

### 4. 混合参数验证

验证整数和浮点参数独立计数：

```c
// C 函数声明
double mixed_params(long n, double x, long m, double y);

// 参数分配: X0=n, D0=x, X1=m, D1=y
// 注意：整数和浮点参数各自独立计数！
```

### 5. 汇编调用 C 函数

验证从汇编代码正确调用 C 函数：

```c
// C 函数
long c_add(long a, long b);

// 汇编函数调用 C 函数
long asm_calls_c(long x, long y);
```

### 6. 返回值验证

验证整数返回值通过 X0/X0-X1，浮点返回值通过 D0：

```c
long get_magic_number(void);      // 返回 X0
__int128 get_big_value(void);     // 返回 X0-X1
double get_pi(void);              // 返回 D0
```

### 7. Callee-saved 寄存器验证

验证 X19-X28 在函数调用后保持不变：

```c
long verify_callee_saved(long a, long b, long c, long d);
```

### 8. 16字节栈对齐验证

验证栈指针始终保持16字节对齐：

```c
long verify_stack_alignment(long a, long b);
```

## 构建方法

### 前置要求

- **ARM64交叉编译工具链**: `aarch64-linux-gnu-gcc` 和 `aarch64-linux-gnu-as`
- **QEMU用户模式模拟器**: `qemu-aarch64`（用于运行测试）

### 安装工具链（Ubuntu/Debian）

```bash
# 安装ARM64交叉编译工具链
sudo apt-get install gcc-aarch64-linux-gnu

# 安装QEMU用户模式模拟器
sudo apt-get install qemu-user qemu-user-static
```

### 使用 Make

```bash
# 构建
make

# 运行测试（使用QEMU）
make test

# 清理
make clean

# 查看详细编译信息
make V=1
```

### 手动构建

```bash
# 1. 汇编 ARM64 代码
aarch64-linux-gnu-as -o calling_conv.o calling_conv.s

# 2. 编译 C 代码
aarch64-linux-gnu-gcc -c -o main.o main.c

# 3. 链接
aarch64-linux-gnu-gcc -o test_calling_conv main.o calling_conv.o -lm

# 4. 运行（使用QEMU）
qemu-aarch64 -L /usr/aarch64-linux-gnu ./test_calling_conv
```

## 预期输出

```
=== ARM64 AAPCS64 Calling Convention Verification ===

[Test 1] Integer Parameters (X0-X7)
  sum_eight(1, 2, 3, 4, 5, 6, 7, 8) = 36
  Expected: 36 ... PASSED

[Test 2] Stack Parameters (9th and beyond)
  sum_ten(1, 2, 3, 4, 5, 6, 7, 8, 9, 10) = 55
  Expected: 55 ... PASSED

[Test 3] Floating Point Parameters (D0-D7)
  sum_doubles(1.5, 2.5, 3.5, 4.5) = 12.000000
  Expected: 12.0 ... PASSED

[Test 4] Mixed Integer/Float Parameters (Independent Counting)
  mixed_params(2, 3.0, 4, 5.0) = 26.000000
  Expected: 26.0 (2*3.0 + 4*5.0) ... PASSED

[Test 5] Assembly Calling C Function
  asm_calls_c(100, 200) = 300
  Expected: 300 ... PASSED

[Test 6] Return Values
  get_magic_number() = 0x123456789ABCDEF0
  get_pi() = 3.141593
  ... PASSED

[Test 7] Callee-saved Register Preservation
  verify_callee_saved(1000, 2000, 3000, 4000) = 10000
  Expected: 10000 ... PASSED

[Test 8] 16-byte Stack Alignment
  verify_stack_alignment(100, 200) = 300
  Expected: 300 ... PASSED

=== All Tests Passed! ===
```

## 调试技巧

### 使用 GDB 远程调试

```bash
# 启动QEMU调试服务器
qemu-aarch64 -g 1234 -L /usr/aarch64-linux-gnu ./test_calling_conv

# 在另一个终端连接GDB
aarch64-linux-gnu-gdb ./test_calling_conv
(gdb) target remote localhost:1234
(gdb) break sum_eight
(gdb) continue
(gdb) info registers x0 x1 x2 x3 x4 x5 x6 x7
```

### 使用 objdump 查看汇编

```bash
# 反汇编目标文件
aarch64-linux-gnu-objdump -d calling_conv.o

# 反汇编可执行文件
aarch64-linux-gnu-objdump -d test_calling_conv
```

## 关键概念说明

### 16字节栈对齐

ARM64 AAPCS64 **强制要求**栈指针始终保持16字节对齐：

```
栈对齐检查:

正确对齐 (SP % 16 == 0):
┌─────────────────┐
│                 │  地址: 0x1000 (16字节对齐)
├─────────────────┤
│                 │  地址: 0x0FF0 (16字节对齐)
└─────────────────┘ ← SP

错误对齐 (SP % 16 != 0):
┌─────────────────┐
│                 │  地址: 0x0FF8 (未对齐!)
└─────────────────┘ ← SP  ❌ 违反AAPCS64！
```

### 参数独立计数

与ARM32不同，ARM64中整数和浮点参数**独立计数**：

```
func(long a, double b, long c, double d)

ARM64 AAPCS64:
  a → X0  (第1个整数)
  b → D0  (第1个浮点)
  c → X1  (第2个整数)
  d → D1  (第2个浮点)
```

### 栈帧结构

```
ARM64 AAPCS64 标准栈帧:

高地址
┌─────────────────────────────────────────┐
│         调用者的栈帧                     │
├─────────────────────────────────────────┤
│         栈参数 N                         │
├─────────────────────────────────────────┤
│         栈参数 9                         │  [SP + 0] (函数入口时)
├─────────────────────────────────────────┤
│         保存的 LR (X30)                  │  [FP + 8]
├─────────────────────────────────────────┤
│         保存的 FP (X29)                  │  [FP + 0] ← FP
├─────────────────────────────────────────┤
│         保存的寄存器 (X19-X28)           │
├─────────────────────────────────────────┤
│         保存的SIMD寄存器 (D8-D15)        │
├─────────────────────────────────────────┤
│         局部变量                         │
├─────────────────────────────────────────┤
│         子函数的栈参数                   │  ← SP (16字节对齐)
└─────────────────────────────────────────┘
低地址
```

### 间接结果寄存器 (X8)

当返回值太大无法通过寄存器返回时，使用X8传递结果存储地址：

```c
// 大结构体返回
struct BigStruct { long data[4]; };
BigStruct get_big_struct(void);

// 调用者分配空间，地址通过X8传入
// 被调用者将结果写入X8指向的地址
```

## 参考资料

- [ARM Architecture Procedure Call Standard for AArch64 (AAPCS64)](https://developer.arm.com/documentation/ihi0055/latest)
- [ARM Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest)
- [本项目文档: arm64-aapcs64.md](../../../../docs/assembly-calling-conventions/03-arm/arm64-aapcs64.md)

## 相关需求

- **需求 3.2**: ARM64（AAPCS64）调用约定完整规范
- **需求 3.5**: ARM调用约定参数传递规则（X0-X7）
- **需求 3.6**: ARM调用约定返回值处理规则
- **需求 10.4**: 代码示例和图表
