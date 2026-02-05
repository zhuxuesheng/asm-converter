# Go Plan9 汇编语法详解

> Go语言使用的Plan9汇编语法完整参考，包含伪寄存器、指令格式、寻址模式和与Go运行时的集成

## 概述

Go Plan9汇编是Go语言生态系统中使用的汇编语法，源自贝尔实验室的Plan 9操作系统。它与传统的Intel或AT&T汇编语法有显著差异，最突出的特点是引入了**伪寄存器**（pseudo-registers）系统，用于抽象不同CPU架构之间的差异。

### 核心特性

| 特性 | 说明 |
|------|------|
| **伪寄存器** | FP、SP、SB、PC四个虚拟寄存器 |
| **跨平台抽象** | 统一的语法风格适用于多种架构 |
| **Go运行时集成** | 支持栈增长、垃圾回收等机制 |
| **类型安全** | 函数签名与Go类型系统对应 |

### 适用架构

Go Plan9汇编支持以下主要架构：

| 架构 | GOARCH值 | 说明 |
|------|----------|------|
| x86-64 | amd64 | 64位Intel/AMD处理器 |
| x86 | 386 | 32位Intel处理器 |
| ARM64 | arm64 | 64位ARM处理器（AArch64） |
| ARM | arm | 32位ARM处理器 |
| RISC-V | riscv64 | 64位RISC-V处理器 |
| PowerPC | ppc64/ppc64le | 64位PowerPC处理器 |
| s390x | s390x | IBM Z系列处理器 |
| MIPS | mips/mips64 | MIPS处理器系列 |

---

## 伪寄存器（Pseudo-Registers）

伪寄存器是Go Plan9汇编最独特的特性。它们不是真实的硬件寄存器，而是由汇编器和链接器维护的虚拟概念，用于简化跨平台汇编编程。

### FP - 帧指针（Frame Pointer）

**FP**是一个伪寄存器，指向当前函数参数的起始位置。它用于访问函数的输入参数和返回值。

```
┌─────────────────────────────────────────────────────────────┐
│                    FP 伪寄存器                               │
├─────────────────────────────────────────────────────────────┤
│  用途：访问函数参数和返回值                                    │
│  方向：正偏移量访问参数，从第一个参数开始                        │
│  注意：FP总是需要符号名称前缀                                  │
└─────────────────────────────────────────────────────────────┘
```

**使用语法**：
```asm
// 访问第一个参数（假设是int64类型）
MOVQ    arg1+0(FP), AX      // arg1是符号名，0是偏移量

// 访问第二个参数
MOVQ    arg2+8(FP), BX      // 第二个int64参数在偏移8处

// 设置返回值
MOVQ    AX, ret+16(FP)      // 返回值在参数之后
```

**重要规则**：
- FP**必须**带有符号名称前缀（如`arg1+0(FP)`而非`0(FP)`）
- 符号名称用于文档目的，帮助理解代码
- 偏移量从0开始，按参数大小递增

**参数布局示例**：

对于函数 `func Example(a int64, b int32, c int64) int64`：

```
偏移量    内容              访问方式
──────────────────────────────────────
0         a (int64)        a+0(FP)
8         b (int32)        b+8(FP)
12        padding          (对齐填充)
16        c (int64)        c+16(FP)
24        返回值 (int64)    ret+24(FP)
```

### SP - 栈指针（Stack Pointer）

Go Plan9汇编中有**两个SP**概念，这是最容易混淆的地方：

| SP类型 | 表示方式 | 含义 |
|--------|----------|------|
| **伪SP** | `symbol+offset(SP)` | 当前栈帧的局部变量基址 |
| **硬件SP** | `offset(SP)` | 真实的栈指针寄存器 |

```
┌─────────────────────────────────────────────────────────────┐
│                    SP 的两种形式                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  伪SP（带符号名）：                                          │
│    local+0(SP)  →  指向栈帧顶部（局部变量区域）               │
│                                                             │
│  硬件SP（无符号名）：                                        │
│    0(SP)        →  真实的栈指针寄存器值                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**伪SP使用示例**：
```asm
TEXT ·Example(SB), NOSPLIT, $24-0
    // $24 表示需要24字节的局部变量空间
    
    // 使用伪SP访问局部变量
    MOVQ    $100, local1+0(SP)     // 第一个局部变量
    MOVQ    $200, local2+8(SP)     // 第二个局部变量
    MOVQ    $300, local3+16(SP)    // 第三个局部变量
```

**硬件SP使用示例**：
```asm
TEXT ·Example(SB), NOSPLIT, $0-0
    // 使用硬件SP（无符号名前缀）
    SUBQ    $16, SP                // 调整栈指针
    MOVQ    AX, 0(SP)              // 存储到栈顶
    MOVQ    BX, 8(SP)              // 存储到栈顶+8
    ADDQ    $16, SP                // 恢复栈指针
```

**关键区别**：
- 伪SP在函数入口时指向局部变量区域的高地址端
- 硬件SP是实际的CPU栈指针
- 在大多数架构上，伪SP = 硬件SP + 局部变量大小

### SB - 静态基址（Static Base）

**SB**伪寄存器用于引用全局符号，包括函数和全局变量。

```
┌─────────────────────────────────────────────────────────────┐
│                    SB 伪寄存器                               │
├─────────────────────────────────────────────────────────────┤
│  用途：引用全局符号（函数、全局变量）                          │
│  语法：symbol(SB) 或 symbol<>(SB)                           │
│  特殊：<>表示当前文件私有符号                                 │
└─────────────────────────────────────────────────────────────┘
```

**使用示例**：
```asm
// 引用全局函数
TEXT ·MyFunction(SB), NOSPLIT, $0-0
    CALL    runtime·morestack(SB)  // 调用runtime包的函数
    RET

// 引用全局变量
MOVQ    globalVar(SB), AX          // 加载全局变量的值
LEAQ    globalVar(SB), AX          // 加载全局变量的地址

// 文件私有符号（使用<>）
TEXT myPrivateFunc<>(SB), NOSPLIT, $0-0
    RET

DATA    privateData<>+0(SB)/8, $0x1234  // 私有数据
```

**符号命名规则**：
- `·`（中点）用于分隔包名和符号名
- `<>`表示文件私有符号，不会被导出
- 包名使用Unicode中点（U+00B7），不是普通的点

### PC - 程序计数器（Program Counter）

**PC**伪寄存器代表程序计数器，主要用于跳转指令的目标计算。

```asm
// PC通常在跳转指令中隐式使用
JMP     2(PC)       // 跳转到当前指令后2条指令处
JMP     -1(PC)      // 向后跳转1条指令（无限循环）

// 更常见的是使用标签
loop:
    DECQ    CX
    JNZ     loop    // 条件跳转到标签
```

**注意**：直接使用PC偏移量的情况较少，通常使用标签更清晰。

---

## 指令格式与命名约定

### 基本指令格式

Go Plan9汇编的指令格式遵循以下模式：

```
INSTRUCTION  source, destination
```

**操作数顺序**：源操作数在前，目标操作数在后（与AT&T语法相同，与Intel语法相反）。

```asm
MOVQ    AX, BX      // 将AX的值移动到BX（AX → BX）
ADDQ    $10, CX     // 将10加到CX（CX = CX + 10）
SUBQ    DX, AX      // 从AX减去DX（AX = AX - DX）
```

### 指令大小后缀

Go Plan9汇编使用后缀来指定操作数大小：

| 后缀 | 大小 | 说明 | 示例 |
|------|------|------|------|
| **B** | 1字节 | Byte | MOVB |
| **W** | 2字节 | Word | MOVW |
| **L** | 4字节 | Long/Doubleword | MOVL |
| **Q** | 8字节 | Quadword | MOVQ |
| **O** | 16字节 | Octword (SSE) | MOVO |

```asm
MOVB    $0x41, AL       // 移动1字节
MOVW    $0x1234, AX     // 移动2字节
MOVL    $0x12345678, EAX    // 移动4字节
MOVQ    $0x123456789ABCDEF0, RAX  // 移动8字节
```

### 指令命名约定

Go Plan9汇编的指令名称与Intel/AT&T有所不同：

| 操作 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 移动 | MOVQ | mov | movq |
| 加法 | ADDQ | add | addq |
| 减法 | SUBQ | sub | subq |
| 比较 | CMPQ | cmp | cmpq |
| 跳转 | JMP | jmp | jmp |
| 调用 | CALL | call | call |
| 返回 | RET | ret | ret |
| 压栈 | PUSHQ | push | pushq |
| 出栈 | POPQ | pop | popq |
| 异或 | XORQ | xor | xorq |
| 与 | ANDQ | and | andq |
| 或 | ORQ | or | orq |
| 左移 | SHLQ | shl | shlq |
| 右移(逻辑) | SHRQ | shr | shrq |
| 右移(算术) | SARQ | sar | sarq |
| 乘法 | IMULQ | imul | imulq |
| 除法 | IDIVQ | idiv | idivq |
| 取反 | NEGQ | neg | negq |
| 取补 | NOTQ | not | notq |
| 加载有效地址 | LEAQ | lea | leaq |

### 条件跳转指令

| 指令 | 条件 | 说明 |
|------|------|------|
| JEQ / JE | ZF=1 | 相等/零 |
| JNE | ZF=0 | 不相等/非零 |
| JLT / JL | SF≠OF | 小于（有符号） |
| JLE | ZF=1 或 SF≠OF | 小于等于（有符号） |
| JGT / JG | ZF=0 且 SF=OF | 大于（有符号） |
| JGE | SF=OF | 大于等于（有符号） |
| JCS / JB / JLO | CF=1 | 进位/低于（无符号） |
| JCC / JAE / JHS | CF=0 | 无进位/高于等于（无符号） |
| JHI | CF=0 且 ZF=0 | 高于（无符号） |
| JLS | CF=1 或 ZF=1 | 低于等于（无符号） |

```asm
    CMPQ    AX, BX
    JEQ     equal       // 如果AX == BX，跳转
    JLT     less        // 如果AX < BX（有符号），跳转
    JGT     greater     // 如果AX > BX（有符号），跳转
```

---

## 寻址模式

Go Plan9汇编支持多种寻址模式，语法与传统汇编有所不同。

### 立即数寻址

立即数以`$`前缀表示：

```asm
MOVQ    $42, AX         // 十进制立即数
MOVQ    $0x2A, AX       // 十六进制立即数
MOVQ    $052, AX        // 八进制立即数
MOVQ    $'A', AX        // 字符常量（ASCII值65）
```

### 寄存器寻址

直接使用寄存器名：

```asm
MOVQ    AX, BX          // 寄存器到寄存器
ADDQ    CX, DX          // 寄存器操作
```

### 内存寻址

Go Plan9汇编的内存寻址格式：

```
offset(base)(index*scale)
```

**基本形式**：

| 形式 | 语法 | 等效Intel语法 |
|------|------|---------------|
| 基址 | `(AX)` | `[rax]` |
| 基址+偏移 | `8(AX)` | `[rax+8]` |
| 基址+索引 | `(AX)(BX*1)` | `[rax+rbx]` |
| 基址+索引*比例 | `(AX)(BX*8)` | `[rax+rbx*8]` |
| 完整形式 | `16(AX)(BX*4)` | `[rax+rbx*4+16]` |

**示例**：

```asm
// 简单内存访问
MOVQ    (AX), BX            // 从AX指向的地址加载
MOVQ    BX, (AX)            // 存储到AX指向的地址

// 带偏移量
MOVQ    8(AX), BX           // 从AX+8加载
MOVQ    -16(AX), BX         // 从AX-16加载

// 带索引
MOVQ    (AX)(CX*1), BX      // 从AX+CX加载
MOVQ    (AX)(CX*8), BX      // 从AX+CX*8加载（数组访问）

// 完整形式
MOVQ    16(AX)(CX*8), BX    // 从AX+CX*8+16加载
```

### 比例因子

比例因子可以是1、2、4或8：

```asm
// 字节数组访问（scale=1）
MOVB    (AX)(CX*1), BL

// 16位数组访问（scale=2）
MOVW    (AX)(CX*2), BX

// 32位数组访问（scale=4）
MOVL    (AX)(CX*4), EBX

// 64位数组访问（scale=8）
MOVQ    (AX)(CX*8), RBX
```

### 符号寻址

使用SB伪寄存器访问全局符号：

```asm
// 加载全局变量的值
MOVQ    myGlobal(SB), AX

// 加载全局变量的地址
LEAQ    myGlobal(SB), AX

// 带偏移量访问结构体字段
MOVQ    myStruct+8(SB), AX      // 访问偏移8处的字段

// 访问数组元素
MOVQ    myArray+24(SB), AX      // 访问第4个int64元素
```

### 帧寻址

使用FP和SP伪寄存器访问栈帧：

```asm
// 访问函数参数（使用FP）
MOVQ    arg1+0(FP), AX
MOVQ    arg2+8(FP), BX

// 访问局部变量（使用伪SP）
MOVQ    local1+0(SP), AX
MOVQ    $100, local2+8(SP)

// 设置返回值
MOVQ    AX, ret+16(FP)
```

---

## 数据指令

### DATA 指令

`DATA`指令用于定义初始化的全局数据：

```
DATA    symbol+offset(SB)/size, value
```

**参数说明**：
- `symbol`：符号名称
- `offset`：在符号内的偏移量
- `size`：数据大小（1、2、4或8字节）
- `value`：初始值

**示例**：

```asm
// 定义单个值
DATA    myByte+0(SB)/1, $0x42           // 1字节
DATA    myWord+0(SB)/2, $0x1234         // 2字节
DATA    myDword+0(SB)/4, $0x12345678    // 4字节
DATA    myQword+0(SB)/8, $0x123456789ABCDEF0  // 8字节

// 定义数组
DATA    myArray+0(SB)/8, $100           // 第1个元素
DATA    myArray+8(SB)/8, $200           // 第2个元素
DATA    myArray+16(SB)/8, $300          // 第3个元素

// 定义字符串
DATA    myString+0(SB)/8, $"Hello, W"   // 前8字节
DATA    myString+8(SB)/8, $"orld!\x00\x00\x00"  // 后8字节

// 引用其他符号的地址
DATA    myPtr+0(SB)/8, $otherSymbol(SB)
```

### GLOBL 指令

`GLOBL`指令声明全局符号及其大小：

```
GLOBL   symbol(SB), flags, $size
```

**标志（flags）**：

| 标志 | 值 | 说明 |
|------|-----|------|
| NOPTR | 16 | 数据不包含指针（GC不扫描） |
| RODATA | 8 | 只读数据 |
| DUPOK | 2 | 允许重复定义 |
| NOPROF | 1 | 不进行性能分析 |

**示例**：

```asm
// 基本全局变量
DATA    counter+0(SB)/8, $0
GLOBL   counter(SB), NOPTR, $8

// 只读数据
DATA    message+0(SB)/8, $"Hello!\x00\x00"
GLOBL   message(SB), RODATA, $8

// 数组
DATA    buffer+0(SB)/8, $0
DATA    buffer+8(SB)/8, $0
DATA    buffer+16(SB)/8, $0
DATA    buffer+24(SB)/8, $0
GLOBL   buffer(SB), NOPTR, $32

// 私有符号
DATA    privateVar<>+0(SB)/8, $0
GLOBL   privateVar<>(SB), NOPTR, $8
```

### 常量定义

使用`#define`或Go的常量：

```asm
// 在汇编文件中定义常量
#define BUFFER_SIZE 1024
#define OFFSET_X    8
#define OFFSET_Y    16

// 使用常量
MOVQ    $BUFFER_SIZE, AX
MOVQ    OFFSET_X(BX), CX
```

---

## 函数声明（TEXT指令）

### TEXT 指令语法

`TEXT`指令用于声明函数：

```
TEXT    package·functionName(SB), flags, $frameSize-argSize
```

**组成部分**：

| 部分 | 说明 | 示例 |
|------|------|------|
| `package` | 包名（当前包用`·`开头） | `runtime·`, `·`（当前包） |
| `functionName` | 函数名 | `Add`, `myFunc` |
| `(SB)` | 静态基址标记 | 必须 |
| `flags` | 函数标志 | `NOSPLIT`, `0` |
| `$frameSize` | 局部变量栈帧大小 | `$0`, `$24` |
| `-argSize` | 参数和返回值总大小 | `-16`, `-24` |

### 函数标志

| 标志 | 值 | 说明 |
|------|-----|------|
| NOSPLIT | 4 | 不进行栈分裂检查 |
| WRAPPER | 32 | 包装函数（不出现在traceback中） |
| NEEDCTXT | 64 | 需要闭包上下文 |
| REFLECTMETHOD | 1024 | 反射调用的方法 |
| TOPFRAME | 2048 | 栈顶帧（不继续展开） |
| NOFRAME | 512 | 不分配栈帧 |
| ABIInternal | 16 | 使用内部ABI |

**常用组合**：

```asm
// 最简单的函数（无局部变量，无参数）
TEXT ·SimpleFunc(SB), NOSPLIT, $0-0
    RET

// 有参数和返回值的函数
TEXT ·Add(SB), NOSPLIT, $0-24
    // 参数: 2个int64 = 16字节
    // 返回值: 1个int64 = 8字节
    // 总计: 24字节
    MOVQ    a+0(FP), AX
    ADDQ    b+8(FP), AX
    MOVQ    AX, ret+16(FP)
    RET

// 有局部变量的函数
TEXT ·WithLocals(SB), $24-16
    // $24: 24字节局部变量空间
    // -16: 16字节参数/返回值
    MOVQ    $0, local1+0(SP)
    MOVQ    $0, local2+8(SP)
    MOVQ    $0, local3+16(SP)
    // ...
    RET
```

### 函数签名对应

Go函数签名与汇编声明的对应关系：

```go
// Go函数声明
func Add(a, b int64) int64
```

```asm
// 对应的汇编声明
TEXT ·Add(SB), NOSPLIT, $0-24
    // 参数布局:
    //   a:   0(FP) - 8字节
    //   b:   8(FP) - 8字节
    //   ret: 16(FP) - 8字节
    // 总计: 24字节
```

**复杂类型示例**：

```go
// Go函数
func Process(data []byte, offset int) (result int, err error)
```

```asm
// 汇编声明
TEXT ·Process(SB), $0-56
    // 参数布局:
    //   data.ptr:  0(FP)  - 8字节
    //   data.len:  8(FP)  - 8字节
    //   data.cap:  16(FP) - 8字节
    //   offset:    24(FP) - 8字节
    //   result:    32(FP) - 8字节
    //   err.type:  40(FP) - 8字节
    //   err.data:  48(FP) - 8字节
    // 总计: 56字节
```

### 方法声明

Go方法在汇编中的声明方式：

```go
// Go方法
func (r *Reader) Read(p []byte) (n int, err error)
```

```asm
// 汇编声明（接收者作为第一个参数）
TEXT ·Reader·Read(SB), $0-56
    // 参数布局:
    //   r:        0(FP)  - 8字节（*Reader）
    //   p.ptr:    8(FP)  - 8字节
    //   p.len:    16(FP) - 8字节
    //   p.cap:    24(FP) - 8字节
    //   n:        32(FP) - 8字节
    //   err.type: 40(FP) - 8字节
    //   err.data: 48(FP) - 8字节
```

---

## 与Go运行时集成

### 栈增长机制

Go使用分段栈（segmented stacks）或连续栈（contiguous stacks，Go 1.3+）来支持goroutine的轻量级栈。汇编函数需要与这个机制配合。

**栈检查序言**：

对于非NOSPLIT函数，Go编译器会在函数入口插入栈检查代码：

```asm
TEXT ·MyFunc(SB), $64-16    // 需要64字节栈空间
    // 编译器自动插入的栈检查（概念性）：
    // CMPQ    SP, stackguard
    // JLS     morestack
    
    // 函数体
    // ...
    RET

// 栈增长处理（由运行时提供）
// morestack:
//     CALL    runtime·morestack(SB)
//     JMP     MyFunc(SB)
```

### NOSPLIT 函数

`NOSPLIT`标志表示函数不需要栈检查：

```asm
TEXT ·FastFunc(SB), NOSPLIT, $0-16
    // 不进行栈检查
    // 适用于：
    // 1. 不调用其他函数
    // 2. 栈使用量很小（<128字节）
    // 3. 性能关键路径
    MOVQ    arg+0(FP), AX
    ADDQ    arg+8(FP), AX
    MOVQ    AX, ret+16(FP)
    RET
```

**NOSPLIT限制**：
- 局部变量空间不能超过StackLimit（通常128字节）
- 不能调用非NOSPLIT函数（除非通过特殊方式）
- 违反限制会导致链接错误

### 栈分裂（Stack Splitting）

当NOSPLIT函数需要调用可能触发栈增长的函数时：

```asm
TEXT ·Wrapper(SB), NOSPLIT, $0-0
    // 方法1：使用go:nosplit pragma（在Go代码中）
    // 方法2：手动处理栈增长
    
    // 检查是否需要更多栈空间
    MOVQ    (TLS), CX           // 获取g
    CMPQ    SP, 16(CX)          // 比较stackguard
    JLS     needmore
    
    // 正常执行
    CALL    ·SomeFunc(SB)
    RET

needmore:
    CALL    runtime·morestack_noctxt(SB)
    JMP     ·Wrapper(SB)
```

### 调用其他Go函数

从汇编调用Go函数：

```asm
TEXT ·Caller(SB), $24-0
    // 为被调用函数准备参数
    MOVQ    $100, 0(SP)         // 第一个参数
    MOVQ    $200, 8(SP)         // 第二个参数
    
    // 调用Go函数
    CALL    ·Add(SB)
    
    // 获取返回值
    MOVQ    16(SP), AX          // 返回值在参数之后
    
    RET
```

### Go 1.17+ 寄存器调用约定

从Go 1.17开始，Go引入了基于寄存器的调用约定（仅限amd64）：

**寄存器分配（amd64）**：

| 用途 | 寄存器 |
|------|--------|
| 整数参数/返回值 | AX, BX, CX, DI, SI, R8, R9, R10, R11 |
| 浮点参数/返回值 | X0-X14 |
| 上下文寄存器 | DX（闭包上下文） |
| 栈指针 | SP |
| g指针 | R14 |

**使用ABIInternal**：

```asm
// 使用新ABI的函数
TEXT ·FastAdd(SB), NOSPLIT|ABIInternal, $0-0
    // 参数通过寄存器传递
    // AX = 第一个参数
    // BX = 第二个参数
    ADDQ    BX, AX
    // 返回值在AX中
    RET
```

**ABI0 vs ABIInternal**：

| 特性 | ABI0（传统） | ABIInternal（Go 1.17+） |
|------|--------------|-------------------------|
| 参数传递 | 栈 | 寄存器优先 |
| 返回值 | 栈 | 寄存器优先 |
| 兼容性 | 所有版本 | Go 1.17+ amd64 |
| 性能 | 较慢 | 较快 |

### TLS和g指针

访问当前goroutine的g结构：

```asm
// 获取当前g指针
MOVQ    (TLS), R14          // R14 = g

// 访问g的字段
MOVQ    0(R14), AX          // g.stack.lo
MOVQ    8(R14), BX          // g.stack.hi
MOVQ    16(R14), CX         // g.stackguard0
```

---

## 架构特定考虑

### AMD64 (x86-64)

**寄存器命名**：

| Go Plan9 | Intel/AT&T | 大小 |
|----------|------------|------|
| AX | RAX | 64位 |
| BX | RBX | 64位 |
| CX | RCX | 64位 |
| DX | RDX | 64位 |
| SI | RSI | 64位 |
| DI | RDI | 64位 |
| SP | RSP | 64位 |
| BP | RBP | 64位 |
| R8-R15 | R8-R15 | 64位 |

**子寄存器访问**：

```asm
// 64位寄存器
MOVQ    $0x123456789ABCDEF0, AX

// 32位子寄存器（低32位）
MOVL    $0x12345678, AX     // 清零高32位

// 16位子寄存器
MOVW    $0x1234, AX

// 8位子寄存器
MOVB    $0x12, AL           // 低8位
MOVB    $0x34, AH           // 高8位（仅AX,BX,CX,DX）
```

**SIMD寄存器**：

```asm
// SSE寄存器 (128位)
MOVUPS  (AX), X0            // 非对齐加载
MOVAPS  (AX), X0            // 对齐加载
ADDPS   X1, X0              // 单精度加法

// AVX寄存器 (256位)
VMOVUPS (AX), Y0            // 非对齐加载
VADDPS  Y1, Y0, Y2          // 三操作数形式
```

**AMD64特有指令**：

```asm
// 64位乘法
IMULQ   BX, AX              // AX = AX * BX

// 64位除法
MOVQ    $0, DX              // 清零高位
IDIVQ   CX                  // AX = DX:AX / CX, DX = 余数

// 位操作
BSFQ    AX, BX              // 位扫描（正向）
BSRQ    AX, BX              // 位扫描（反向）
POPCNTQ AX, BX              // 人口计数

// 原子操作
LOCK
XADDQ   AX, (BX)            // 原子加法
LOCK
CMPXCHGQ CX, (BX)           // 原子比较交换
```

### ARM64 (AArch64)

**寄存器命名**：

| Go Plan9 | ARM64 | 说明 |
|----------|-------|------|
| R0-R30 | X0-X30 | 通用寄存器 |
| RSP | SP | 栈指针 |
| R29 | FP/X29 | 帧指针 |
| R30 | LR/X30 | 链接寄存器 |
| ZR | XZR | 零寄存器 |

**ARM64特有语法**：

```asm
// 加载/存储
MOVD    (R0), R1            // 加载64位
MOVW    (R0), R1            // 加载32位
MOVH    (R0), R1            // 加载16位
MOVB    (R0), R1            // 加载8位

// 带偏移的加载
MOVD    8(R0), R1           // 从R0+8加载

// 后索引寻址
MOVD.P  8(R0), R1           // 加载后R0+=8

// 前索引寻址
MOVD.W  8(R0), R1           // R0+=8后加载

// 条件执行
CMP     R0, R1
BEQ     label               // 相等跳转
BNE     label               // 不等跳转
BLT     label               // 小于跳转
BGT     label               // 大于跳转
```

**ARM64 SIMD (NEON)**：

```asm
// 向量加载
VLD1    (R0), [V0.B16]      // 加载16字节到V0

// 向量运算
VADD    V0.S4, V1.S4, V2.S4 // 4个32位整数加法

// 向量存储
VST1    [V0.B16], (R0)      // 存储V0到内存
```

### ARM (32位)

**寄存器命名**：

| Go Plan9 | ARM | 说明 |
|----------|-----|------|
| R0-R12 | R0-R12 | 通用寄存器 |
| R13 | SP | 栈指针 |
| R14 | LR | 链接寄存器 |
| R15 | PC | 程序计数器 |

**ARM32特有语法**：

```asm
// 条件执行后缀
MOVEQ   R0, R1              // 相等时移动
ADDNE   R0, R1, R2          // 不等时加法

// 移位操作
MOVW    R0<<2, R1           // 逻辑左移
MOVW    R0>>2, R1           // 逻辑右移
MOVW    R0->2, R1           // 算术右移

// 多寄存器加载/存储
MOVM.IA [R0-R3], (R13)      // 存储多个寄存器
MOVM.DB.W [R0-R3], (R13)    // 带回写的存储
```

### RISC-V (64位)

**寄存器命名**：

| Go Plan9 | RISC-V | ABI名称 | 说明 |
|----------|--------|---------|------|
| X0 | x0 | zero | 零寄存器 |
| X1 | x1 | ra | 返回地址 |
| X2 | x2 | sp | 栈指针 |
| X3-X31 | x3-x31 | - | 通用寄存器 |

**RISC-V特有语法**：

```asm
// 加载/存储
MOV     (X10), X11          // 加载
MOV     X11, (X10)          // 存储

// 立即数加载
MOV     $0x12345678, X10    // 可能展开为多条指令

// 分支
BEQ     X10, X11, label     // 相等跳转
BNE     X10, X11, label     // 不等跳转
BLT     X10, X11, label     // 小于跳转
```

---

## 代码示例

### 示例1：简单的加法函数

**Go声明**（在`.go`文件中）：
```go
package example

//go:noescape
func Add(a, b int64) int64
```

**汇编实现**（在`_amd64.s`文件中）：
```asm
#include "textflag.h"

// func Add(a, b int64) int64
TEXT ·Add(SB), NOSPLIT, $0-24
    MOVQ    a+0(FP), AX     // AX = a
    ADDQ    b+8(FP), AX     // AX = AX + b
    MOVQ    AX, ret+16(FP)  // 返回值 = AX
    RET
```

### 示例2：数组求和

**Go声明**：
```go
package example

//go:noescape
func SumArray(arr []int64) int64
```

**汇编实现**：
```asm
#include "textflag.h"

// func SumArray(arr []int64) int64
TEXT ·SumArray(SB), NOSPLIT, $0-32
    MOVQ    arr_base+0(FP), SI   // SI = 数组基址
    MOVQ    arr_len+8(FP), CX    // CX = 数组长度
    XORQ    AX, AX               // AX = 0 (累加器)
    
    TESTQ   CX, CX               // 检查长度是否为0
    JEQ     done
    
loop:
    ADDQ    (SI), AX             // AX += *SI
    ADDQ    $8, SI               // SI += 8
    DECQ    CX                   // CX--
    JNZ     loop                 // 如果CX != 0，继续循环
    
done:
    MOVQ    AX, ret+24(FP)       // 返回结果
    RET
```

### 示例3：内存复制

**Go声明**：
```go
package example

//go:noescape
func MemCopy(dst, src []byte, n int)
```

**汇编实现**：
```asm
#include "textflag.h"

// func MemCopy(dst, src []byte, n int)
TEXT ·MemCopy(SB), NOSPLIT, $0-56
    MOVQ    dst_base+0(FP), DI   // DI = 目标地址
    MOVQ    src_base+24(FP), SI  // SI = 源地址
    MOVQ    n+48(FP), CX         // CX = 字节数
    
    // 使用REP MOVSB进行复制
    CLD                          // 清除方向标志
    REP
    MOVSB                        // 复制CX字节
    
    RET
```

### 示例4：使用SIMD的向量加法

**Go声明**：
```go
package example

//go:noescape
func AddFloat64x4(a, b, result *[4]float64)
```

**汇编实现**：
```asm
#include "textflag.h"

// func AddFloat64x4(a, b, result *[4]float64)
TEXT ·AddFloat64x4(SB), NOSPLIT, $0-24
    MOVQ    a+0(FP), AX          // AX = &a
    MOVQ    b+8(FP), BX          // BX = &b
    MOVQ    result+16(FP), CX    // CX = &result
    
    // 加载256位向量（4个float64）
    VMOVUPD (AX), Y0             // Y0 = a[0:4]
    VMOVUPD (BX), Y1             // Y1 = b[0:4]
    
    // 向量加法
    VADDPD  Y1, Y0, Y2           // Y2 = Y0 + Y1
    
    // 存储结果
    VMOVUPD Y2, (CX)             // result[0:4] = Y2
    
    VZEROUPPER                   // 清除YMM高位
    RET
```

### 示例5：原子操作

**Go声明**：
```go
package example

//go:noescape
func AtomicAdd64(addr *int64, delta int64) int64
```

**汇编实现**：
```asm
#include "textflag.h"

// func AtomicAdd64(addr *int64, delta int64) int64
TEXT ·AtomicAdd64(SB), NOSPLIT, $0-24
    MOVQ    addr+0(FP), BX       // BX = addr
    MOVQ    delta+8(FP), AX      // AX = delta
    
    LOCK
    XADDQ   AX, (BX)             // 原子交换并加法
    
    ADDQ    delta+8(FP), AX      // 返回新值
    MOVQ    AX, ret+16(FP)
    RET
```

### 示例6：调用其他Go函数

**Go声明**：
```go
package example

func helper(x int64) int64 {
    return x * 2
}

//go:noescape
func CallHelper(x int64) int64
```

**汇编实现**：
```asm
#include "textflag.h"

// func CallHelper(x int64) int64
TEXT ·CallHelper(SB), $16-16
    // 准备调用helper的参数
    MOVQ    x+0(FP), AX
    MOVQ    AX, 0(SP)            // 参数放在栈上
    
    // 调用helper
    CALL    ·helper(SB)
    
    // 获取返回值
    MOVQ    8(SP), AX
    MOVQ    AX, ret+8(FP)
    RET
```

### 示例7：条件分支

```asm
#include "textflag.h"

// func Max(a, b int64) int64
TEXT ·Max(SB), NOSPLIT, $0-24
    MOVQ    a+0(FP), AX
    MOVQ    b+8(FP), BX
    
    CMPQ    AX, BX
    JGE     return_a             // 如果a >= b，返回a
    
    // 返回b
    MOVQ    BX, ret+16(FP)
    RET
    
return_a:
    MOVQ    AX, ret+16(FP)
    RET
```

### 示例8：循环展开优化

```asm
#include "textflag.h"

// func SumArrayUnrolled(arr []int64) int64
TEXT ·SumArrayUnrolled(SB), NOSPLIT, $0-32
    MOVQ    arr_base+0(FP), SI
    MOVQ    arr_len+8(FP), CX
    XORQ    AX, AX               // 累加器
    XORQ    DX, DX               // 第二累加器
    
    // 每次处理4个元素
    SHRQ    $2, CX               // CX = len / 4
    JZ      remainder
    
loop4:
    ADDQ    0(SI), AX
    ADDQ    8(SI), DX
    ADDQ    16(SI), AX
    ADDQ    24(SI), DX
    ADDQ    $32, SI
    DECQ    CX
    JNZ     loop4
    
    ADDQ    DX, AX               // 合并累加器
    
remainder:
    // 处理剩余元素
    MOVQ    arr_len+8(FP), CX
    ANDQ    $3, CX               // CX = len % 4
    JZ      done
    
loop1:
    ADDQ    (SI), AX
    ADDQ    $8, SI
    DECQ    CX
    JNZ     loop1
    
done:
    MOVQ    AX, ret+24(FP)
    RET
```

---

## 常见模式与最佳实践

### 文件组织

**命名约定**：

| 文件名模式 | 说明 |
|------------|------|
| `*_amd64.s` | AMD64架构专用 |
| `*_arm64.s` | ARM64架构专用 |
| `*_386.s` | x86 32位架构专用 |
| `*_arm.s` | ARM 32位架构专用 |
| `*.s` | 通用（需要条件编译） |

**典型项目结构**：

```
mypackage/
├── mypackage.go          // Go声明
├── mypackage_amd64.s     // AMD64实现
├── mypackage_arm64.s     // ARM64实现
├── mypackage_generic.go  // 纯Go后备实现
└── mypackage_test.go     // 测试
```

### Go声明文件

每个汇编函数都需要在Go文件中声明：

```go
package mypackage

// 使用//go:noescape防止参数逃逸分析
//go:noescape
func FastFunc(data []byte) int

// 使用//go:nosplit标记不需要栈检查
//go:nosplit
func TinyFunc() int

// 链接到外部符号
//go:linkname runtimeFunc runtime.someInternalFunc
func runtimeFunc()
```

### 头文件包含

常用的头文件：

```asm
#include "textflag.h"     // TEXT标志定义
#include "funcdata.h"     // 函数数据定义
#include "go_asm.h"       // Go特定常量（自动生成）
```

**textflag.h中的常量**：

```asm
// 函数标志
NOSPLIT     = 4
WRAPPER     = 32
NEEDCTXT    = 64
NOFRAME     = 512
TOPFRAME    = 2048
ABIInternal = 16

// 数据标志
NOPTR       = 16
RODATA      = 8
DUPOK       = 2
```

### 性能优化技巧

**1. 避免不必要的内存访问**：

```asm
// 不好：多次访问内存
MOVQ    (AX), BX
ADDQ    (AX), CX
SUBQ    (AX), DX

// 好：加载一次，多次使用
MOVQ    (AX), R8
ADDQ    R8, BX
ADDQ    R8, CX
SUBQ    R8, DX
```

**2. 使用SIMD指令**：

```asm
// 标量处理（慢）
loop:
    MOVQ    (SI), AX
    ADDQ    AX, BX
    ADDQ    $8, SI
    DECQ    CX
    JNZ     loop

// SIMD处理（快）
loop:
    VMOVDQU (SI), Y0
    VPADDQ  Y0, Y1, Y1
    ADDQ    $32, SI
    SUBQ    $4, CX
    JNZ     loop
```

**3. 分支预测友好**：

```asm
// 将常见情况放在前面
    TESTQ   CX, CX
    JZ      empty           // 空数组是罕见情况
    
    // 正常处理（常见情况）
    ...
    RET
    
empty:
    // 处理空数组
    XORQ    AX, AX
    RET
```

**4. 对齐循环**：

```asm
// 使用PCALIGN对齐循环入口
    PCALIGN $16
loop:
    // 循环体
    ...
    JNZ     loop
```

### 调试技巧

**1. 使用BYTE指令插入断点**：

```asm
    BYTE    $0xCC           // INT3断点
```

**2. 保留调试信息**：

```asm
// 使用有意义的符号名
TEXT ·ProcessData(SB), $0-32
    MOVQ    input_ptr+0(FP), SI     // 清晰的参数名
    MOVQ    input_len+8(FP), CX
    MOVQ    output_ptr+16(FP), DI
```

**3. 使用go tool objdump**：

```bash
# 反汇编查看生成的代码
go tool objdump -s 'mypackage.MyFunc' myprogram
```

### 常见错误

**1. 忘记符号名前缀**：

```asm
// 错误：FP必须有符号名
MOVQ    0(FP), AX

// 正确
MOVQ    arg+0(FP), AX
```

**2. 栈帧大小计算错误**：

```asm
// 错误：参数大小不匹配
TEXT ·Func(SB), $0-16      // 声明16字节
    MOVQ    a+0(FP), AX    // 8字节
    MOVQ    b+8(FP), BX    // 8字节
    MOVQ    c+16(FP), CX   // 错误！超出声明范围
```

**3. NOSPLIT函数调用非NOSPLIT函数**：

```asm
// 错误：可能导致栈溢出
TEXT ·BadFunc(SB), NOSPLIT, $0-0
    CALL    ·BigFunc(SB)   // BigFunc不是NOSPLIT
    RET
```

**4. 忘记保存/恢复寄存器**：

```asm
// 如果调用其他函数，需要保存caller-saved寄存器
TEXT ·Func(SB), $24-0
    MOVQ    BX, 0(SP)      // 保存BX
    MOVQ    R12, 8(SP)     // 保存R12
    
    // ... 使用BX和R12 ...
    CALL    ·Other(SB)
    
    MOVQ    0(SP), BX      // 恢复BX
    MOVQ    8(SP), R12     // 恢复R12
    RET
```

---

## 工具与资源

### 编译和构建

**编译汇编文件**：

```bash
# 正常构建（自动包含汇编文件）
go build

# 查看汇编输出
go build -gcflags="-S" 2>&1 | head -100

# 生成目标文件
go tool compile -S myfile.go

# 汇编单个文件
go tool asm -o output.o input.s
```

**交叉编译**：

```bash
# 为不同架构编译
GOOS=linux GOARCH=amd64 go build
GOOS=darwin GOARCH=arm64 go build
GOOS=windows GOARCH=amd64 go build
```

### 反汇编和分析

**使用objdump**：

```bash
# 反汇编特定函数
go tool objdump -s 'main.MyFunc' ./myprogram

# 反汇编整个包
go tool objdump ./myprogram > disasm.txt
```

**使用nm查看符号**：

```bash
go tool nm ./myprogram | grep MyFunc
```

### 调试

**使用Delve调试器**：

```bash
# 安装Delve
go install github.com/go-delve/delve/cmd/dlv@latest

# 调试程序
dlv debug ./myprogram

# 在汇编函数设置断点
(dlv) break mypackage.MyFunc
(dlv) continue
(dlv) disassemble
(dlv) regs
```

**使用GDB**：

```bash
# 编译时保留调试信息
go build -gcflags="-N -l" -o myprogram

# 使用GDB调试
gdb ./myprogram
(gdb) break mypackage.MyFunc
(gdb) run
(gdb) disassemble
(gdb) info registers
```

### 性能分析

**使用pprof**：

```bash
# 生成CPU profile
go test -cpuprofile=cpu.prof -bench=.

# 分析profile
go tool pprof cpu.prof
(pprof) list MyFunc
(pprof) disasm MyFunc
```

**使用benchstat比较性能**：

```bash
# 安装benchstat
go install golang.org/x/perf/cmd/benchstat@latest

# 运行基准测试
go test -bench=. -count=10 > old.txt
# 修改代码后
go test -bench=. -count=10 > new.txt

# 比较结果
benchstat old.txt new.txt
```

---

## 参考资料

### 官方文档

- [Go Assembler Guide](https://go.dev/doc/asm) - Go官方汇编指南
- [Go Internal ABI Specification](https://go.dev/src/cmd/compile/abi-internal.md) - Go内部ABI规范
- [A Quick Guide to Go's Assembler](https://go.dev/doc/asm) - 快速入门指南

### Plan 9 文档

- [A Manual for the Plan 9 Assembler](https://9p.io/sys/doc/asm.html) - Plan 9汇编手册
- [Plan 9 C Compilers](https://9p.io/sys/doc/compiler.html) - Plan 9编译器文档

### 源码参考

- [Go runtime源码](https://github.com/golang/go/tree/master/src/runtime) - 包含大量汇编示例
- [Go crypto包](https://github.com/golang/go/tree/master/src/crypto) - 优化的加密算法实现
- [Go math包](https://github.com/golang/go/tree/master/src/math) - 数学函数的汇编实现

### 社区资源

- [Go Assembly by Example](https://davidwong.fr/goasm/) - 实例教程
- [Golang Internals](https://github.com/teh-cmc/go-internals) - Go内部机制分析
- [Go Assembly Workshop](https://github.com/campoy/go-tooling-workshop) - 工具使用研讨

### 架构参考

- [Intel® 64 and IA-32 Architectures Software Developer Manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)
- [ARM Architecture Reference Manual](https://developer.arm.com/documentation/ddi0487/latest)
- [RISC-V Specifications](https://riscv.org/technical/specifications/)

---

## 附录：快速参考卡

### 伪寄存器速查

| 伪寄存器 | 用途 | 语法示例 |
|----------|------|----------|
| FP | 函数参数 | `arg+0(FP)` |
| SP (伪) | 局部变量 | `local+0(SP)` |
| SP (硬件) | 栈指针 | `0(SP)` |
| SB | 全局符号 | `symbol(SB)` |
| PC | 程序计数器 | `2(PC)` |

### 常用指令速查

| 操作 | 指令 | 示例 |
|------|------|------|
| 移动 | MOV[BWLQ] | `MOVQ AX, BX` |
| 加法 | ADD[BWLQ] | `ADDQ $1, AX` |
| 减法 | SUB[BWLQ] | `SUBQ BX, AX` |
| 比较 | CMP[BWLQ] | `CMPQ AX, BX` |
| 跳转 | JMP/Jcc | `JMP label` |
| 调用 | CALL | `CALL ·Func(SB)` |
| 返回 | RET | `RET` |
| 加载地址 | LEA[WLQ] | `LEAQ (AX), BX` |

### TEXT声明速查

```asm
TEXT ·FuncName(SB), FLAGS, $frameSize-argSize
```

| 组件 | 说明 |
|------|------|
| `·FuncName` | 函数名（当前包） |
| `(SB)` | 静态基址（必须） |
| `FLAGS` | NOSPLIT, NOFRAME等 |
| `$frameSize` | 局部变量大小 |
| `-argSize` | 参数+返回值大小 |

---

*上一节: [语法对比概述](overview.md)*
*下一节: [Intel 汇编详解](intel.md)*
