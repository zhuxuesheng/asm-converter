# Go 与汇编互操作

> Go语言与汇编互操作完整规范，包含伪寄存器、栈布局、寄存器调用约定

## 概述

Go使用独特的Plan 9汇编语法，与传统汇编有显著差异。本章节涵盖：

- Go汇编伪寄存器
- 函数签名与汇编对应
- 栈布局和参数传递
- Go 1.17+寄存器调用约定
- 栈增长和栈分裂

---

## 伪寄存器

Go汇编定义了四个伪寄存器：

| 伪寄存器 | 说明 | 实际映射 |
|----------|------|----------|
| **FP** | Frame Pointer | 参数和局部变量基址 |
| **SP** | Stack Pointer | 当前栈顶（伪） |
| **SB** | Static Base | 全局符号基址 |
| **PC** | Program Counter | 程序计数器 |

### FP - 帧指针

FP用于访问函数参数和返回值：

```go
// Go函数签名
func Add(a, b int) int
```

```asm
// Go汇编
TEXT ·Add(SB), NOSPLIT, $0-24
    // 参数布局:
    // a: FP+0
    // b: FP+8
    // 返回值: FP+16
    MOVQ    a+0(FP), AX
    ADDQ    b+8(FP), AX
    MOVQ    AX, ret+16(FP)
    RET
```

### SP - 栈指针

Go汇编中有两个SP：
- **伪SP**：`name+offset(SP)` - 相对于栈帧底部
- **硬件SP**：`offset(SP)` - 实际栈指针

```asm
TEXT ·Example(SB), $16-0
    // 伪SP访问局部变量
    MOVQ    $0, local+0(SP)     // 局部变量
    
    // 硬件SP访问
    MOVQ    $0, 0(SP)           // 栈顶
```

### SB - 静态基址

SB用于访问全局符号：

```asm
// 访问全局变量
MOVQ    globalVar(SB), AX

// 访问函数
CALL    runtime·printint(SB)

// 定义全局数据
DATA    message<>+0(SB)/8, $"Hello\n"
GLOBL   message<>(SB), RODATA, $8
```


---

## 函数声明

### 函数签名格式

```asm
TEXT package·FunctionName(SB), [flags], $framesize-argsize
```

| 组件 | 说明 |
|------|------|
| `package` | 包名（·是中点符号） |
| `FunctionName` | 函数名 |
| `flags` | NOSPLIT, NOFRAME等 |
| `framesize` | 局部变量大小 |
| `argsize` | 参数+返回值大小 |

### 常用标志

| 标志 | 说明 |
|------|------|
| `NOSPLIT` | 不检查栈分裂 |
| `NOFRAME` | 不分配栈帧 |
| `NOPTR` | 栈帧不含指针 |
| `WRAPPER` | 包装函数 |

### 示例

```asm
// func Add(a, b int) int
// 参数: 8+8=16字节, 返回值: 8字节, 总计24字节
TEXT ·Add(SB), NOSPLIT, $0-24
    MOVQ    a+0(FP), AX
    ADDQ    b+8(FP), AX
    MOVQ    AX, ret+16(FP)
    RET

// func Process(data []byte) int
// slice: 24字节 (ptr+len+cap), 返回值: 8字节
TEXT ·Process(SB), $0-32
    MOVQ    data+0(FP), SI      // ptr
    MOVQ    data+8(FP), CX      // len
    // MOVQ data+16(FP), DX    // cap (如需要)
    // ...
    MOVQ    AX, ret+24(FP)
    RET
```

---

## 栈布局（传统ABI）

### Go 1.16及之前的栈布局

```
高地址
┌─────────────────────────────────────────────────────────────────────────────┐
│                        调用者栈帧                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                        返回值                                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                        参数                                                 │
├─────────────────────────────────────────────────────────────────────────────┤ ← FP
│                        返回地址                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                        局部变量                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                        保存的寄存器                                         │
└─────────────────────────────────────────────────────────────────────────────┘ ← SP
低地址
```

### 参数传递示例

```go
func Example(a int, b string, c float64) (int, error)
```

```
栈布局:
┌─────────────────────────────────────────┐
│  返回值2: error (16字节)                │  FP+48
├─────────────────────────────────────────┤
│  返回值1: int (8字节)                   │  FP+40
├─────────────────────────────────────────┤
│  参数c: float64 (8字节)                 │  FP+32
├─────────────────────────────────────────┤
│  参数b: string (16字节: ptr+len)        │  FP+16
├─────────────────────────────────────────┤
│  参数a: int (8字节)                     │  FP+0
└─────────────────────────────────────────┘ ← FP
```

---

## Go 1.17+ 寄存器调用约定

### 寄存器分配

Go 1.17引入了基于寄存器的调用约定：

| 用途 | AMD64寄存器 |
|------|-------------|
| 整数参数 | AX, BX, CX, DI, SI, R8, R9, R10, R11 |
| 浮点参数 | X0-X14 |
| 整数返回值 | AX, BX, CX, DI, SI, R8, R9, R10, R11 |
| 浮点返回值 | X0-X14 |

### 寄存器ABI示例

```go
//go:noinline
func Add(a, b int) int {
    return a + b
}
```

```asm
// Go 1.17+ 寄存器ABI
TEXT ·Add(SB), NOSPLIT|ABIInternal, $0-0
    // 参数: AX=a, BX=b
    // 返回: AX
    ADDQ    BX, AX
    RET
```

### 混合栈和寄存器

当参数超过寄存器数量时，剩余参数通过栈传递：

```go
func ManyArgs(a, b, c, d, e, f, g, h, i, j int) int
```

```asm
// a-i通过寄存器，j通过栈
TEXT ·ManyArgs(SB), ABIInternal, $0-8
    // AX=a, BX=b, CX=c, DI=d, SI=e, R8=f, R9=g, R10=h, R11=i
    // j在栈上: j+0(FP)
    ADDQ    BX, AX
    // ...
    ADDQ    j+0(FP), AX
    RET
```


---

## 栈增长和栈分裂

### 栈分裂机制

Go使用分段栈（segmented stack）或连续栈（contiguous stack）：

```asm
// 需要栈检查的函数
TEXT ·NeedsStack(SB), $1024-0
    // 编译器自动插入栈检查
    // 如果栈空间不足，调用runtime.morestack
    ...
    RET

// 禁用栈检查（小函数）
TEXT ·SmallFunc(SB), NOSPLIT, $0-16
    // 不检查栈，必须确保不会溢出
    ...
    RET
```

### 栈检查代码

编译器生成的栈检查：

```asm
// 自动生成的序言
    MOVQ    (TLS), CX           // 获取g
    CMPQ    SP, 16(CX)          // 比较SP和g.stackguard0
    JBE     morestack           // 如果不足，跳转
    
    // 函数体...
    
morestack:
    CALL    runtime·morestack(SB)
    JMP     function_start
```

### NOSPLIT限制

使用NOSPLIT的函数有栈空间限制：

| 架构 | NOSPLIT栈限制 |
|------|---------------|
| AMD64 | 128字节 |
| ARM64 | 128字节 |

---

## 调用Go函数

### 从汇编调用Go函数

```asm
TEXT ·CallGoFunc(SB), $24-0
    // 调用 fmt.Println("Hello")
    
    // 准备参数
    LEAQ    hello(SB), AX
    MOVQ    AX, 0(SP)           // string.ptr
    MOVQ    $5, 8(SP)           // string.len
    
    // 调用
    CALL    fmt·Println(SB)
    
    RET

DATA    hello+0(SB)/8, $"Hello"
GLOBL   hello(SB), RODATA, $8
```

### 调用方法

```asm
// 调用 receiver.Method(arg)
TEXT ·CallMethod(SB), $32-0
    // 设置receiver
    MOVQ    receiver+0(FP), AX
    MOVQ    AX, 0(SP)
    
    // 设置参数
    MOVQ    arg+8(FP), BX
    MOVQ    BX, 8(SP)
    
    // 调用方法
    CALL    ·Type·Method(SB)
    
    RET
```

---

## 数据定义

### 全局变量

```asm
// 定义全局变量
DATA    counter+0(SB)/8, $0
GLOBL   counter(SB), $8

// 只读数据
DATA    message+0(SB)/8, $"Hello\n\x00"
GLOBL   message(SB), RODATA, $8

// 大数据块
DATA    buffer+0(SB)/1, $0
DATA    buffer+1(SB)/1, $0
// ...
GLOBL   buffer(SB), $1024
```

### 数据类型大小

| 类型 | 大小 |
|------|------|
| int8/uint8/bool | 1 |
| int16/uint16 | 2 |
| int32/uint32/float32 | 4 |
| int64/uint64/float64/pointer | 8 |
| string | 16 (ptr+len) |
| slice | 24 (ptr+len+cap) |
| interface | 16 (type+data) |

---

## 完整示例

### 字符串长度函数

```go
// string_len.go
package main

func StringLen(s string) int

func main() {
    println(StringLen("Hello"))
}
```

```asm
// string_len_amd64.s
TEXT ·StringLen(SB), NOSPLIT, $0-24
    // string: ptr+len = 16字节
    // 返回值: 8字节
    MOVQ    s+8(FP), AX         // len在偏移8
    MOVQ    AX, ret+16(FP)
    RET
```

### 数组求和

```go
// sum.go
package main

func Sum(arr []int) int

func main() {
    arr := []int{1, 2, 3, 4, 5}
    println(Sum(arr))
}
```

```asm
// sum_amd64.s
TEXT ·Sum(SB), NOSPLIT, $0-32
    MOVQ    arr+0(FP), SI       // ptr
    MOVQ    arr+8(FP), CX       // len
    XORQ    AX, AX              // sum = 0
    
loop:
    TESTQ   CX, CX
    JZ      done
    ADDQ    (SI), AX
    ADDQ    $8, SI
    DECQ    CX
    JMP     loop

done:
    MOVQ    AX, ret+24(FP)
    RET
```

---

## 参考资料

### 官方文档

- [Go Assembler Guide](https://go.dev/doc/asm)
- [Go Internal ABI Specification](https://github.com/golang/go/blob/master/src/cmd/compile/abi-internal.md)

### 相关文档

- 参见: [Go Plan9汇编语法](../01-syntax-comparison/go-plan9.md)
- 参见: [cgo互操作](./cgo.md)
- 参见: [C/C++与汇编互操作](./c-cpp.md)
