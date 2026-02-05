# ARM32 AAPCS 调用约定验证示例

本目录包含验证 ARM32 AAPCS（ARM Architecture Procedure Call Standard）调用约定的完整示例代码。

## 概述

AAPCS 是 ARM32 架构的标准过程调用约定，定义了函数调用时参数传递、返回值处理、寄存器使用和栈管理的规则。

### 核心特性

| 特性 | 规范 |
|------|------|
| **整数参数寄存器** | R0, R1, R2, R3（4个） |
| **浮点参数寄存器** | S0-S15 / D0-D7（VFP硬浮点） |
| **整数返回值** | R0（32位）/ R0-R1（64位） |
| **浮点返回值** | S0 / D0 |
| **栈对齐** | 8字节（公共接口） |
| **栈清理** | 调用者（Caller） |
| **帧指针** | R11（可选） |
| **链接寄存器** | R14（LR） |

### 寄存器分类

**Caller-saved（易失）**: R0-R3, R12, S0-S15/D0-D7

**Callee-saved（非易失）**: R4-R11, S16-S31/D8-D15

### 64位参数对齐规则

64位参数（如 `long long`、`double`）必须在偶数寄存器对开始：
- 第1个64位参数 → R0-R1
- 第2个64位参数 → R2-R3（如果可用）
- 如果64位参数在R1时，跳过R1，使用R2-R3

## 文件说明

| 文件 | 说明 |
|------|------|
| `calling_conv.s` | ARM32 汇编实现（GAS语法），演示AAPCS调用约定 |
| `main.c` | C 语言测试程序，调用汇编函数 |
| `Makefile` | 构建脚本（交叉编译） |

## 验证内容

### 1. 参数传递验证

验证前4个整数参数通过 R0, R1, R2, R3 传递：

```c
// C 函数声明
int sum_four(int a, int b, int c, int d);

// 调用示例
int result = sum_four(10, 20, 30, 40);  // 期望: 100
```

### 2. 栈参数验证

验证第5个及以后的参数通过栈传递：

```c
// C 函数声明
int sum_six(int a, int b, int c, int d, int e, int f);

// 调用示例
int result = sum_six(1, 2, 3, 4, 5, 6);  // 期望: 21
```

### 3. 64位参数对齐验证

验证64位参数在偶数寄存器对开始：

```c
// C 函数声明
long long add64(int a, long long b, int c);

// 参数分配: R0=a, R2-R3=b (跳过R1), [SP]=c
```

### 4. 浮点参数验证（硬浮点）

验证浮点参数通过 S0-S15/D0-D7 传递：

```c
// C 函数声明
float sum_floats(float a, float b, float c, float d);

// 调用示例
float result = sum_floats(1.5f, 2.5f, 3.5f, 4.5f);  // 期望: 12.0
```

### 5. 混合参数验证

验证整数和浮点参数的混合传递：

```c
// C 函数声明
double mixed_params(int n, double x, int m, double y);

// 硬浮点: R0=n, D0=x, R1=m, D1=y
```

### 6. 汇编调用 C 函数

验证从汇编代码正确调用 C 函数：

```c
// C 函数
int c_add(int a, int b);

// 汇编函数调用 C 函数
int asm_calls_c(int x, int y);
```

### 7. 返回值验证

验证整数返回值通过 R0/R0-R1，浮点返回值通过 S0/D0：

```c
int get_magic_number(void);       // 返回 R0
long long get_big_value(void);    // 返回 R0-R1
float get_pi_float(void);         // 返回 S0
```

### 8. Callee-saved 寄存器验证

验证 R4-R11 在函数调用后保持不变：

```c
int verify_callee_saved(int a, int b, int c, int d);
```

## 构建方法

### 前置要求

- **ARM交叉编译工具链**: `arm-linux-gnueabihf-gcc` 和 `arm-linux-gnueabihf-as`
- **QEMU用户模式模拟器**: `qemu-arm`（用于运行测试）

### 安装工具链（Ubuntu/Debian）

```bash
# 安装ARM32交叉编译工具链
sudo apt-get install gcc-arm-linux-gnueabihf

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
# 1. 汇编 ARM32 代码
arm-linux-gnueabihf-as -mfpu=vfpv3 -mfloat-abi=hard -o calling_conv.o calling_conv.s

# 2. 编译 C 代码
arm-linux-gnueabihf-gcc -mfpu=vfpv3 -mfloat-abi=hard -c -o main.o main.c

# 3. 链接
arm-linux-gnueabihf-gcc -mfpu=vfpv3 -mfloat-abi=hard -o test_calling_conv main.o calling_conv.o -lm

# 4. 运行（使用QEMU）
qemu-arm -L /usr/arm-linux-gnueabihf ./test_calling_conv
```

## 预期输出

```
=== ARM32 AAPCS Calling Convention Verification ===

[Test 1] Integer Parameters (R0, R1, R2, R3)
  sum_four(10, 20, 30, 40) = 100
  Expected: 100 ... PASSED

[Test 2] Stack Parameters (5th and beyond)
  sum_six(1, 2, 3, 4, 5, 6) = 21
  Expected: 21 ... PASSED

[Test 3] 64-bit Parameter Alignment
  add64(1, 0x100000002, 3) = 0x100000006
  Expected: 0x100000006 ... PASSED

[Test 4] Floating Point Parameters (S0-S15)
  sum_floats(1.5, 2.5, 3.5, 4.5) = 12.000000
  Expected: 12.0 ... PASSED

[Test 5] Mixed Integer/Float Parameters
  mixed_params(2, 3.0, 4, 5.0) = 26.000000
  Expected: 26.0 (2*3.0 + 4*5.0) ... PASSED

[Test 6] Assembly Calling C Function
  asm_calls_c(100, 200) = 300
  Expected: 300 ... PASSED

[Test 7] Return Values
  get_magic_number() = 0x12345678
  get_big_value() = 0x123456789ABCDEF0
  get_pi_float() = 3.141593
  ... PASSED

[Test 8] Callee-saved Register Preservation
  verify_callee_saved(1000, 2000, 3000, 4000) = 10000
  Expected: 10000 ... PASSED

=== All Tests Passed! ===
```

## 调试技巧

### 使用 GDB 远程调试

```bash
# 启动QEMU调试服务器
qemu-arm -g 1234 -L /usr/arm-linux-gnueabihf ./test_calling_conv

# 在另一个终端连接GDB
arm-linux-gnueabihf-gdb ./test_calling_conv
(gdb) target remote localhost:1234
(gdb) break sum_four
(gdb) continue
(gdb) info registers r0 r1 r2 r3
```

### 使用 objdump 查看汇编

```bash
# 反汇编目标文件
arm-linux-gnueabihf-objdump -d calling_conv.o

# 反汇编可执行文件
arm-linux-gnueabihf-objdump -d test_calling_conv
```

## 关键概念说明

### 64位参数对齐

ARM32 AAPCS 要求64位参数在偶数寄存器对开始：

```
函数: void func(int a, long long b, int c)

参数分配:
┌─────────────────────────────────────────────────────────┐
│ a → R0                                                  │
│ b → R2-R3 (跳过R1以保持64位对齐)                        │
│ c → 栈 [SP + 0]                                         │
│ R1 → 未使用（填充）                                     │
└─────────────────────────────────────────────────────────┘
```

### 栈帧结构

```
ARM32 AAPCS 标准栈帧:

高地址
┌─────────────────────────────────────────┐
│         调用者的栈帧                     │
├─────────────────────────────────────────┤
│         栈参数 N                         │
├─────────────────────────────────────────┤
│         栈参数 5                         │  [SP + 0] (函数入口时)
├─────────────────────────────────────────┤
│         保存的 LR (R14)                  │
├─────────────────────────────────────────┤
│         保存的 FP (R11)                  │  ← FP
├─────────────────────────────────────────┤
│         保存的寄存器 (R4-R10)            │
├─────────────────────────────────────────┤
│         局部变量                         │
├─────────────────────────────────────────┤
│         子函数的栈参数                   │  ← SP
└─────────────────────────────────────────┘
低地址
```

## 参考资料

- [ARM Architecture Procedure Call Standard (AAPCS)](https://developer.arm.com/documentation/ihi0042/latest)
- [ARM Compiler armasm User Guide](https://developer.arm.com/documentation/dui0473/latest)
- [本项目文档: arm32-aapcs.md](../../../../docs/assembly-calling-conventions/03-arm/arm32-aapcs.md)

## 相关需求

- **需求 3.1**: ARM32（AAPCS）调用约定完整规范
- **需求 3.5**: ARM调用约定参数传递规则（R0-R3）
- **需求 3.6**: ARM调用约定返回值处理规则
- **需求 10.4**: 代码示例和图表
