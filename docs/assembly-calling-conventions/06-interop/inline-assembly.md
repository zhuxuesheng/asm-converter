# 内联汇编指南

> GCC和MSVC内联汇编语法完整规范，包含约束和修饰符

## 概述

内联汇编允许在C/C++代码中直接嵌入汇编指令。本章节涵盖：

- GCC内联汇编（Extended Asm）
- MSVC内联汇编
- 约束和修饰符
- 最佳实践

---

## GCC 内联汇编

### 基本语法

```c
asm [volatile] (
    "汇编模板"
    : 输出操作数
    : 输入操作数
    : 破坏列表
);
```

### 简单示例

```c
// 无操作数
asm("nop");

// 带操作数
int result;
int a = 10, b = 20;
asm("addl %1, %0"
    : "=r" (result)     // 输出: result
    : "r" (a), "0" (b)  // 输入: a, b (b与result共用寄存器)
);
// result = 30
```

### 操作数约束

| 约束 | 说明 |
|------|------|
| `r` | 通用寄存器 |
| `a` | RAX/EAX/AX/AL |
| `b` | RBX/EBX/BX/BL |
| `c` | RCX/ECX/CX/CL |
| `d` | RDX/EDX/DX/DL |
| `S` | RSI/ESI/SI |
| `D` | RDI/EDI/DI |
| `m` | 内存操作数 |
| `i` | 立即数 |
| `n` | 已知立即数 |
| `g` | 通用（寄存器、内存或立即数） |

### 修饰符

| 修饰符 | 说明 |
|--------|------|
| `=` | 只写（输出） |
| `+` | 读写 |
| `&` | 早期破坏（earlyclobber） |
| `%` | 可交换操作数 |


### 详细示例

#### 加法

```c
int add(int a, int b) {
    int result;
    asm("addl %2, %1\n\t"
        "movl %1, %0"
        : "=r" (result)         // %0: 输出
        : "r" (a), "r" (b)      // %1: a, %2: b
    );
    return result;
}
```

#### 原子操作

```c
int atomic_add(int *ptr, int value) {
    int result;
    asm volatile(
        "lock xaddl %0, %1"
        : "=r" (result), "+m" (*ptr)
        : "0" (value)
        : "memory"
    );
    return result;
}
```

#### CPUID

```c
void cpuid(int code, int *eax, int *ebx, int *ecx, int *edx) {
    asm volatile(
        "cpuid"
        : "=a" (*eax), "=b" (*ebx), "=c" (*ecx), "=d" (*edx)
        : "a" (code)
    );
}
```

#### RDTSC

```c
unsigned long long rdtsc(void) {
    unsigned int lo, hi;
    asm volatile(
        "rdtsc"
        : "=a" (lo), "=d" (hi)
    );
    return ((unsigned long long)hi << 32) | lo;
}
```

### 破坏列表

```c
// 声明被修改的寄存器
asm volatile(
    "..."
    : /* 输出 */
    : /* 输入 */
    : "rax", "rbx", "memory", "cc"  // 破坏列表
);
```

| 破坏项 | 说明 |
|--------|------|
| `"memory"` | 内存被修改 |
| `"cc"` | 条件码被修改 |
| `"rax"` | RAX被修改 |

### 命名操作数

```c
asm("addl %[src], %[dst]"
    : [dst] "=r" (result)
    : [src] "r" (value), "0" (result)
);
```

---

## MSVC 内联汇编

### 基本语法

```c
__asm {
    汇编指令
}

// 或单行
__asm mov eax, value
```

### 示例

```c
int add(int a, int b) {
    __asm {
        mov eax, a
        add eax, b
        // 结果自动在EAX中返回
    }
}
```

### 访问C变量

```c
void example(int *ptr, int value) {
    __asm {
        mov eax, value
        mov ecx, ptr
        mov [ecx], eax
    }
}
```

### 限制

MSVC内联汇编的限制：

1. **仅支持x86**：x64不支持__asm
2. **无法指定寄存器约束**
3. **编译器优化受限**

### x64替代方案

x64 MSVC使用内部函数（intrinsics）：

```c
#include <intrin.h>

// CPUID
int cpuInfo[4];
__cpuid(cpuInfo, 0);

// RDTSC
unsigned __int64 tsc = __rdtsc();

// 原子操作
long result = _InterlockedAdd(&value, 1);
```


---

## x86-64 GCC 内联汇编

### 64位寄存器约束

| 约束 | 64位寄存器 |
|------|------------|
| `a` | RAX |
| `b` | RBX |
| `c` | RCX |
| `d` | RDX |
| `S` | RSI |
| `D` | RDI |
| `r` | 任意通用寄存器 |

### 64位示例

```c
long add64(long a, long b) {
    long result;
    asm("addq %2, %1\n\t"
        "movq %1, %0"
        : "=r" (result)
        : "r" (a), "r" (b)
    );
    return result;
}

// 系统调用
long syscall1(long num, long arg1) {
    long result;
    asm volatile(
        "syscall"
        : "=a" (result)
        : "a" (num), "D" (arg1)
        : "rcx", "r11", "memory"
    );
    return result;
}
```

### SIMD操作

```c
#include <emmintrin.h>

void add_vectors(float *a, float *b, float *c, int n) {
    for (int i = 0; i < n; i += 4) {
        __m128 va, vb, vc;
        asm("movaps %1, %0\n\t"
            "addps %2, %0"
            : "=x" (vc)
            : "m" (a[i]), "x" (*(__m128*)&b[i])
        );
        _mm_store_ps(&c[i], vc);
    }
}
```

---

## 最佳实践

### 何时使用内联汇编

✓ 适合：
- 访问特殊CPU指令（CPUID, RDTSC）
- 原子操作
- 性能关键的小代码段
- 硬件访问

✗ 避免：
- 大段汇编代码（使用独立汇编文件）
- 可用内部函数替代的操作
- 可移植性要求高的代码

### 可移植性

```c
// 使用条件编译
#if defined(__GNUC__)
    asm volatile("pause" ::: "memory");
#elif defined(_MSC_VER)
    _mm_pause();
#endif
```

### 调试技巧

```c
// 添加标签便于调试
asm volatile(
    "# BEGIN critical section\n\t"
    "lock incl %0\n\t"
    "# END critical section"
    : "+m" (counter)
    :
    : "memory"
);
```

---

## 常用内联汇编模式

### 内存屏障

```c
// 编译器屏障
asm volatile("" ::: "memory");

// CPU内存屏障
asm volatile("mfence" ::: "memory");  // 全屏障
asm volatile("lfence" ::: "memory");  // 读屏障
asm volatile("sfence" ::: "memory");  // 写屏障
```

### 自旋等待

```c
static inline void cpu_relax(void) {
    asm volatile("pause" ::: "memory");
}
```

### 端口I/O

```c
static inline void outb(unsigned short port, unsigned char value) {
    asm volatile("outb %0, %1" : : "a" (value), "Nd" (port));
}

static inline unsigned char inb(unsigned short port) {
    unsigned char value;
    asm volatile("inb %1, %0" : "=a" (value) : "Nd" (port));
    return value;
}
```

---

## 参考资料

### 官方文档

- [GCC Extended Asm](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html)
- [GCC Constraints](https://gcc.gnu.org/onlinedocs/gcc/Constraints.html)
- [MSVC Inline Assembler](https://docs.microsoft.com/en-us/cpp/assembler/inline/inline-assembler)

### 相关文档

- 参见: [C/C++与汇编互操作](./c-cpp.md)
- 参见: [AT&T汇编语法](../01-syntax-comparison/att.md)
- 参见: [Intel汇编语法](../01-syntax-comparison/intel.md)
