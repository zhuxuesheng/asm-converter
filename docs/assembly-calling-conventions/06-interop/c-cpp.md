# C/C++ 与汇编互操作

> C/C++与汇编语言互操作完整规范，包含函数调用、名称修饰、结构体传递

## 概述

C/C++与汇编的互操作是混合语言编程的基础。本章节涵盖：

- C调用汇编函数
- 汇编调用C函数
- C++名称修饰和extern "C"
- 结构体和浮点参数传递
- 可变参数函数

---

## C调用汇编函数

### 基本规则

1. 汇编函数必须遵循目标平台的调用约定
2. 函数名必须正确导出（考虑符号前缀）
3. 参数和返回值类型必须匹配

### x64 Linux/macOS 示例

```c
// C代码
extern long asm_add(long a, long b);
extern long asm_multiply(long a, long b);

int main() {
    long sum = asm_add(10, 20);      // 30
    long product = asm_multiply(5, 6); // 30
    return 0;
}
```

```asm
# GAS语法 (Linux)
    .text
    .globl asm_add
    .type asm_add, @function
asm_add:
    # 参数: RDI=a, RSI=b
    lea     rax, [rdi + rsi]
    ret
    .size asm_add, .-asm_add

    .globl asm_multiply
    .type asm_multiply, @function
asm_multiply:
    mov     rax, rdi
    imul    rax, rsi
    ret
    .size asm_multiply, .-asm_multiply
```

### x64 Windows 示例

```c
// C代码
extern long long asm_add(long long a, long long b);
```

```asm
; NASM语法 (Windows)
section .text
global asm_add

asm_add:
    ; 参数: RCX=a, RDX=b
    lea     rax, [rcx + rdx]
    ret
```


---

## 汇编调用C函数

### 基本规则

1. 正确设置参数寄存器
2. 保持栈对齐（16字节）
3. 保存volatile寄存器（如需要）
4. Windows需要分配Shadow Space

### x64 Linux 示例

```asm
# 调用 printf("Result: %d\n", 42)
    .text
    .globl call_printf
call_printf:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16             # 保持16字节对齐
    
    # 设置参数
    lea     rdi, [rip + fmt]    # 参数1: 格式字符串
    mov     esi, 42             # 参数2: 整数值
    xor     eax, eax            # 浮点参数数量 = 0
    
    call    printf
    
    add     rsp, 16
    pop     rbp
    ret

    .section .rodata
fmt:
    .string "Result: %d\n"
```

### x64 Windows 示例

```asm
; 调用 printf("Result: %d\n", 42)
section .data
    fmt db "Result: %d", 13, 10, 0

section .text
extern printf
global call_printf

call_printf:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32             ; Shadow Space
    
    lea     rcx, [rel fmt]      ; 参数1
    mov     edx, 42             ; 参数2
    call    printf
    
    add     rsp, 32
    pop     rbp
    ret
```

---

## C++ 名称修饰

### 名称修饰（Name Mangling）

C++编译器会修饰函数名以支持重载：

| C++函数 | 修饰后名称（GCC） | 修饰后名称（MSVC） |
|---------|-------------------|-------------------|
| `void foo()` | `_Z3foov` | `?foo@@YAXXZ` |
| `void foo(int)` | `_Z3fooi` | `?foo@@YAXH@Z` |
| `void foo(int, double)` | `_Z3fooid` | `?foo@@YAXHN@Z` |
| `int Bar::method(int)` | `_ZN3Bar6methodEi` | `?method@Bar@@QEAAHH@Z` |

### extern "C"

使用`extern "C"`禁用名称修饰：

```cpp
// C++代码
extern "C" {
    // 这些函数使用C链接，无名称修饰
    long asm_add(long a, long b);
    void asm_process(void* data);
}

// 或单个函数
extern "C" long asm_multiply(long a, long b);
```

### 从汇编调用C++函数

```cpp
// C++代码
extern "C" void cpp_callback(int value) {
    // 可以从汇编调用
}
```

```asm
; 汇编调用
    mov     edi, 42
    call    cpp_callback
```

---

## 结构体参数传递

### 小结构体（≤16字节）

小结构体可能通过寄存器传递：

```c
struct Point {
    int x;
    int y;
};

extern struct Point asm_make_point(int x, int y);
extern int asm_point_sum(struct Point p);
```

```asm
# Linux x64
# struct Point asm_make_point(int x, int y)
# 参数: EDI=x, ESI=y
# 返回: RAX (低32位=x, 高32位=y)
asm_make_point:
    mov     eax, edi            # x
    shl     rsi, 32
    or      rax, rsi            # 合并y到高32位
    ret

# int asm_point_sum(struct Point p)
# 参数: RDI (低32位=x, 高32位=y)
asm_point_sum:
    mov     eax, edi            # x
    shr     rdi, 32
    add     eax, edi            # x + y
    ret
```

### 大结构体（>16字节）

大结构体通过隐藏指针传递：

```c
struct BigData {
    long values[4];
};

extern struct BigData asm_make_big(long value);
```

```asm
# Linux x64
# struct BigData asm_make_big(long value)
# 参数: RDI=隐藏指针, RSI=value
# 返回: RAX=隐藏指针
asm_make_big:
    mov     [rdi], rsi
    mov     [rdi+8], rsi
    mov     [rdi+16], rsi
    mov     [rdi+24], rsi
    mov     rax, rdi            # 返回隐藏指针
    ret
```


---

## 浮点参数和返回值

### 浮点参数传递

```c
extern double asm_add_doubles(double a, double b);
extern float asm_add_floats(float a, float b);
```

```asm
# Linux x64
# double asm_add_doubles(double a, double b)
# 参数: XMM0=a, XMM1=b
# 返回: XMM0
asm_add_doubles:
    addsd   xmm0, xmm1
    ret

# float asm_add_floats(float a, float b)
asm_add_floats:
    addss   xmm0, xmm1
    ret
```

### 混合整数和浮点参数

```c
// Linux: 整数和浮点参数独立计数
extern double asm_mixed(int n, double x, int m, double y);
// n→RDI, x→XMM0, m→RSI, y→XMM1

// Windows: 参数位置决定寄存器
extern double asm_mixed_win(int n, double x, int m, double y);
// n→RCX, x→XMM1, m→R8, y→XMM3
```

```asm
# Linux x64
asm_mixed:
    # RDI=n, XMM0=x, RSI=m, XMM1=y
    cvtsi2sd xmm2, edi          # n转double
    cvtsi2sd xmm3, esi          # m转double
    mulsd   xmm2, xmm0          # n * x
    mulsd   xmm3, xmm1          # m * y
    addsd   xmm0, xmm2
    addsd   xmm0, xmm3          # 返回 n*x + m*y
    ret
```

---

## 可变参数函数

### 调用可变参数函数

```c
// C声明
int printf(const char* fmt, ...);
```

```asm
# Linux x64 - 调用printf
# 重要: AL必须设置为使用的XMM寄存器数量
call_printf_example:
    sub     rsp, 8              # 对齐
    
    lea     rdi, [rip + fmt]    # 格式字符串
    mov     esi, 42             # 整数参数
    movsd   xmm0, [rip + pi]    # 浮点参数
    mov     eax, 1              # 1个XMM寄存器用于可变参数
    
    call    printf
    
    add     rsp, 8
    ret

fmt:    .string "Int: %d, Float: %f\n"
pi:     .double 3.14159
```

### 实现可变参数函数

```asm
# Linux x64 - 可变参数求和
# int sum_varargs(int count, ...)
    .globl sum_varargs
sum_varargs:
    push    rbp
    mov     rbp, rsp
    
    # 保存寄存器参数到栈
    mov     [rbp+16], rsi       # 第2个参数
    mov     [rbp+24], rdx       # 第3个参数
    mov     [rbp+32], rcx       # 第4个参数
    mov     [rbp+40], r8        # 第5个参数
    mov     [rbp+48], r9        # 第6个参数
    
    xor     eax, eax            # sum = 0
    mov     ecx, edi            # count
    lea     rdx, [rbp+16]       # 指向第一个可变参数
    
.Lloop:
    test    ecx, ecx
    jz      .Ldone
    add     eax, [rdx]
    add     rdx, 8
    dec     ecx
    jmp     .Lloop

.Ldone:
    pop     rbp
    ret
```

---

## 编译和链接

### GCC编译

```bash
# 编译C代码
gcc -c main.c -o main.o

# 编译汇编（GAS语法）
as -o asm_funcs.o asm_funcs.s

# 或使用gcc
gcc -c asm_funcs.s -o asm_funcs.o

# 链接
gcc -o program main.o asm_funcs.o
```

### NASM + GCC (Linux)

```bash
nasm -f elf64 asm_funcs.asm -o asm_funcs.o
gcc -o program main.c asm_funcs.o
```

### NASM + GCC (Windows)

```bash
nasm -f win64 asm_funcs.asm -o asm_funcs.obj
gcc -o program.exe main.c asm_funcs.obj
```

---

## 参考资料

- 参见: [System V AMD64 ABI](../02-x86-x64/x64-sysv.md)
- 参见: [Microsoft x64调用约定](../02-x86-x64/x64-microsoft.md)
- 参见: [内联汇编](./inline-assembly.md)
- 参见: [Go与汇编互操作](./go-assembly.md)
