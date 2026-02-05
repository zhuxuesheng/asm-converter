# Microsoft x64 调用约定验证示例

本目录包含验证 Microsoft x64 调用约定的完整示例代码。

## 概述

Microsoft x64 调用约定（也称为 Windows x64 ABI）是 Windows 操作系统在 x86-64 架构上使用的标准调用约定。

### 核心特性

| 特性 | 规范 |
|------|------|
| **整数参数寄存器** | RCX, RDX, R8, R9（4个） |
| **浮点参数寄存器** | XMM0-XMM3（4个） |
| **整数返回值** | RAX |
| **浮点返回值** | XMM0 |
| **栈对齐** | 16字节（CALL前） |
| **Shadow Space** | 32字节（必须分配） |
| **栈清理** | 调用者（Caller） |

### 寄存器分类

**Caller-saved（易失）**: RAX, RCX, RDX, R8-R11, XMM0-XMM5

**Callee-saved（非易失）**: RBX, RBP, RDI, RSI, R12-R15, XMM6-XMM15

## 文件说明

| 文件 | 说明 |
|------|------|
| `calling_conv.asm` | NASM 汇编实现，演示调用约定 |
| `main.c` | C 语言测试程序，调用汇编函数 |
| `Makefile` | 构建脚本（MinGW-w64） |
| `build.bat` | Windows 批处理构建脚本 |

## 验证内容

### 1. 参数传递验证

验证前4个整数参数通过 RCX, RDX, R8, R9 传递：

```c
// C 函数声明
int64_t sum_four(int64_t a, int64_t b, int64_t c, int64_t d);

// 调用示例
int64_t result = sum_four(10, 20, 30, 40);  // 期望: 100
```

### 2. 栈参数验证

验证第5个及以后的参数通过栈传递：

```c
// C 函数声明
int64_t sum_six(int64_t a, int64_t b, int64_t c, int64_t d, int64_t e, int64_t f);

// 调用示例
int64_t result = sum_six(1, 2, 3, 4, 5, 6);  // 期望: 21
```

### 3. Shadow Space 验证

验证被调用函数可以使用 Shadow Space 保存参数：

```c
// C 函数声明
int64_t use_shadow_space(int64_t a, int64_t b, int64_t c, int64_t d);

// 汇编实现将参数保存到 Shadow Space 后再计算
```

### 4. 浮点参数验证

验证浮点参数通过 XMM0-XMM3 传递：

```c
// C 函数声明
double sum_doubles(double a, double b, double c, double d);

// 调用示例
double result = sum_doubles(1.5, 2.5, 3.5, 4.5);  // 期望: 12.0
```

### 5. 混合参数验证

验证整数和浮点参数共享位置：

```c
// C 函数声明
double mixed_params(int64_t n, double x, int64_t m, double y);

// 参数分配: RCX=n, XMM1=x, R8=m, XMM3=y
```

### 6. 汇编调用 C 函数

验证从汇编代码正确调用 C 函数：

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

## 构建方法

### 前置要求

- **NASM** >= 2.15
- **MinGW-w64** (GCC for Windows)

### 使用 Make

```bash
# 构建
make

# 运行测试
make test

# 清理
make clean
```

### 使用批处理脚本

```cmd
# 构建并运行
build.bat
```

### 手动构建

```bash
# 1. 汇编 NASM 代码
nasm -f win64 -o calling_conv.obj calling_conv.asm

# 2. 编译 C 代码
gcc -c -o main.obj main.c

# 3. 链接
gcc -o test_calling_conv.exe main.obj calling_conv.obj

# 4. 运行
./test_calling_conv.exe
```

## 预期输出

```
=== Microsoft x64 Calling Convention Verification ===

[Test 1] Integer Parameters (RCX, RDX, R8, R9)
  sum_four(10, 20, 30, 40) = 100
  Expected: 100 ... PASSED

[Test 2] Stack Parameters (5th and beyond)
  sum_six(1, 2, 3, 4, 5, 6) = 21
  Expected: 21 ... PASSED

[Test 3] Shadow Space Usage
  use_shadow_space(100, 200, 300, 400) = 1000
  Expected: 1000 ... PASSED

[Test 4] Floating Point Parameters (XMM0-XMM3)
  sum_doubles(1.5, 2.5, 3.5, 4.5) = 12.000000
  Expected: 12.0 ... PASSED

[Test 5] Mixed Integer/Float Parameters
  mixed_params(2, 3.0, 4, 5.0) = 26.000000
  Expected: 26.0 (2*3.0 + 4*5.0) ... PASSED

[Test 6] Assembly Calling C Function
  asm_calls_c(100, 200) = 300
  Expected: 300 ... PASSED

[Test 7] Return Values
  get_magic_number() = 0x123456789ABCDEF0
  get_pi() = 3.141593
  ... PASSED

=== All Tests Passed! ===
```

## 调试技巧

### 使用 x64dbg

1. 加载 `test_calling_conv.exe`
2. 在 `sum_four` 函数入口设置断点
3. 检查寄存器：RCX=10, RDX=20, R8=30, R9=40
4. 单步执行验证计算过程

### 使用 GDB

```bash
gdb test_calling_conv.exe
(gdb) break sum_four
(gdb) run
(gdb) info registers rcx rdx r8 r9
(gdb) x/8gx $rsp
```

## 关键概念说明

### Shadow Space（影子空间）

调用者必须在栈上为前4个参数预留32字节空间，即使参数通过寄存器传递。

```
栈布局（CALL之后）:
高地址
┌─────────────────┐
│  Shadow (R9)    │  [RSP + 32]
├─────────────────┤
│  Shadow (R8)    │  [RSP + 24]
├─────────────────┤
│  Shadow (RDX)   │  [RSP + 16]
├─────────────────┤
│  Shadow (RCX)   │  [RSP + 8]
├─────────────────┤
│  返回地址       │  [RSP + 0]
└─────────────────┘
低地址
```

### 参数位置共享

整数和浮点参数共享相同的参数位置：

```
func(int a, double b, int c, double d)
位置1: a → RCX
位置2: b → XMM1 (不是 XMM0!)
位置3: c → R8
位置4: d → XMM3 (不是 XMM2!)
```

## 参考资料

- [Microsoft x64 调用约定](https://docs.microsoft.com/en-us/cpp/build/x64-calling-convention)
- [x64 软件约定](https://docs.microsoft.com/en-us/cpp/build/x64-software-conventions)
- [本项目文档: x64-microsoft.md](../../../docs/assembly-calling-conventions/02-x86-x64/x64-microsoft.md)

## 相关需求

- **需求 2.5**: Microsoft x64 调用约定完整规范
- **需求 2.6**: 参数传递寄存器详细说明
- **需求 2.7**: 返回值寄存器说明
- **需求 10.4**: 代码示例和图表
