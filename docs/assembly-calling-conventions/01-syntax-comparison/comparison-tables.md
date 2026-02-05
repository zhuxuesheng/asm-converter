# 汇编语法对比表格

> Go Plan9、Intel和AT&T三种汇编语法的全面对比参考，包含操作数顺序、寄存器命名、内存寻址、立即数表示和等效指令示例

## 概述

本文档提供三种主流汇编语法的详细对比表格，帮助开发者快速理解和转换不同语法之间的代码。每个表格都包含实际示例，便于直接参考使用。

### 语法概览

| 特性 | Go Plan9 | Intel (NASM) | AT&T (GAS) |
|------|----------|--------------|------------|
| **代表工具** | Go编译器 | NASM, MASM | GAS, GCC |
| **主要平台** | Go生态系统 | Windows, 跨平台 | Linux/Unix |
| **操作数顺序** | 源, 目标 | 目标, 源 | 源, 目标 |
| **寄存器前缀** | 无 | 无 | `%` |
| **立即数前缀** | `$` | 无 | `$` |
| **内存访问** | `offset(base)` | `[base+offset]` | `offset(%base)` |
| **大小指定** | 指令后缀 | 操作数前缀/推断 | 指令后缀 |

---

## 1. 操作数顺序对比

### 1.1 基本操作数顺序

这是三种语法最根本的差异之一。

| 操作 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| **顺序规则** | 源 → 目标 | 目标 ← 源 | 源 → 目标 |
| **助记方式** | "从左到右" | "赋值语句" | "从左到右" |

### 1.2 操作数顺序示例

| 操作描述 | Go Plan9 | Intel | AT&T |
|----------|----------|-------|------|
| 将BX复制到AX | `MOVQ BX, AX` | `mov rax, rbx` | `movq %rbx, %rax` |
| 将10加到AX | `ADDQ $10, AX` | `add rax, 10` | `addq $10, %rax` |
| 从AX减去BX | `SUBQ BX, AX` | `sub rax, rbx` | `subq %rbx, %rax` |
| 比较AX和BX | `CMPQ BX, AX` | `cmp rax, rbx` | `cmpq %rbx, %rax` |
| AX与BX异或 | `XORQ BX, AX` | `xor rax, rbx` | `xorq %rbx, %rax` |


### 1.3 双操作数指令对比

```
操作: 将寄存器B的值加到寄存器A

Go Plan9:  ADDQ BX, AX      // AX = AX + BX
Intel:     add  rax, rbx    // rax = rax + rbx  
AT&T:      addq %rbx, %rax  // %rax = %rax + %rbx

结果: A = A + B
```

### 1.4 三操作数指令对比（SIMD/AVX）

| 操作描述 | Go Plan9 | Intel | AT&T |
|----------|----------|-------|------|
| Y0 = Y1 + Y2 | `VADDPS Y2, Y1, Y0` | `vaddps ymm0, ymm1, ymm2` | `vaddps %ymm2, %ymm1, %ymm0` |
| Y0 = Y1 * Y2 | `VMULPS Y2, Y1, Y0` | `vmulps ymm0, ymm1, ymm2` | `vmulps %ymm2, %ymm1, %ymm0` |

> **注意**: 三操作数指令中，Intel语法为 `dest, src1, src2`，而AT&T和Go Plan9为 `src2, src1, dest`

---

## 2. 寄存器命名对比

### 2.1 通用寄存器（64位）

| 用途 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 累加器 | `AX` | `rax` | `%rax` |
| 基址 | `BX` | `rbx` | `%rbx` |
| 计数器 | `CX` | `rcx` | `%rcx` |
| 数据 | `DX` | `rdx` | `%rdx` |
| 源索引 | `SI` | `rsi` | `%rsi` |
| 目标索引 | `DI` | `rdi` | `%rdi` |
| 栈指针 | `SP` | `rsp` | `%rsp` |
| 帧指针 | `BP` | `rbp` | `%rbp` |
| 扩展寄存器 | `R8`-`R15` | `r8`-`r15` | `%r8`-`%r15` |

### 2.2 寄存器大小变体

| 大小 | Go Plan9 | Intel | AT&T | 说明 |
|------|----------|-------|------|------|
| 64位 | `AX` | `rax` | `%rax` | 完整寄存器 |
| 32位 | `AX`* | `eax` | `%eax` | 低32位 |
| 16位 | `AX`* | `ax` | `%ax` | 低16位 |
| 8位低 | `AL` | `al` | `%al` | 最低8位 |
| 8位高 | `AH` | `ah` | `%ah` | 次低8位 |

> *Go Plan9通过指令后缀区分大小，寄存器名相同


### 2.3 扩展寄存器（R8-R15）

| 大小 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 64位 | `R8` | `r8` | `%r8` |
| 32位 | `R8`* | `r8d` | `%r8d` |
| 16位 | `R8`* | `r8w` | `%r8w` |
| 8位 | `R8B` | `r8b` | `%r8b` |

### 2.4 SIMD寄存器

| 类型 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| SSE (128位) | `X0`-`X15` | `xmm0`-`xmm15` | `%xmm0`-`%xmm15` |
| AVX (256位) | `Y0`-`Y15` | `ymm0`-`ymm15` | `%ymm0`-`%ymm15` |
| AVX-512 (512位) | `Z0`-`Z31` | `zmm0`-`zmm31` | `%zmm0`-`%zmm31` |

### 2.5 特殊寄存器

| 寄存器 | Go Plan9 | Intel | AT&T | 说明 |
|--------|----------|-------|------|------|
| 指令指针 | `PC` | `rip` | `%rip` | 程序计数器 |
| 标志寄存器 | - | `rflags` | `%rflags` | 状态标志 |
| 段寄存器 | - | `fs`, `gs` | `%fs`, `%gs` | 段选择器 |

### 2.6 Go Plan9 伪寄存器

Go Plan9汇编特有的伪寄存器：

| 伪寄存器 | 用途 | 示例 |
|----------|------|------|
| `FP` | 帧指针（参数访问） | `arg+0(FP)` |
| `SP` (伪) | 栈指针（局部变量） | `local+0(SP)` |
| `SB` | 静态基址（全局符号） | `symbol(SB)` |
| `PC` | 程序计数器 | `2(PC)` |

---

## 3. 内存寻址语法对比

### 3.1 寻址模式通用格式

| 语法 | 通用格式 |
|------|----------|
| **Go Plan9** | `offset(base)(index*scale)` |
| **Intel** | `[base + index*scale + offset]` |
| **AT&T** | `offset(%base, %index, scale)` |


### 3.2 基本寻址模式对比

| 寻址模式 | Go Plan9 | Intel | AT&T |
|----------|----------|-------|------|
| 寄存器间接 | `(AX)` | `[rax]` | `(%rax)` |
| 基址+偏移 | `8(AX)` | `[rax+8]` | `8(%rax)` |
| 负偏移 | `-16(BP)` | `[rbp-16]` | `-16(%rbp)` |
| 基址+索引 | `(AX)(BX*1)` | `[rax+rbx]` | `(%rax,%rbx)` |
| 索引*比例 | `(AX)(BX*8)` | `[rax+rbx*8]` | `(%rax,%rbx,8)` |
| 完整形式 | `16(AX)(BX*4)` | `[rax+rbx*4+16]` | `16(%rax,%rbx,4)` |

### 3.3 寻址模式详细示例

#### 直接/绝对寻址

| 描述 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 绝对地址 | `0x1000` | `[0x1000]` | `0x1000` |
| 符号地址 | `myvar(SB)` | `[myvar]` | `myvar(%rip)` |

#### 寄存器间接寻址

| 描述 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 从AX指向的地址加载 | `(AX)` | `[rax]` | `(%rax)` |
| 存储到BX指向的地址 | `(BX)` | `[rbx]` | `(%rbx)` |

#### 基址+偏移寻址

| 描述 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 基址+8 | `8(AX)` | `[rax+8]` | `8(%rax)` |
| 基址-16 | `-16(BP)` | `[rbp-16]` | `-16(%rbp)` |
| 栈偏移 | `32(SP)` | `[rsp+32]` | `32(%rsp)` |

#### 索引寻址（数组访问）

| 数组类型 | Go Plan9 | Intel | AT&T |
|----------|----------|-------|------|
| 字节数组 | `(AX)(CX*1)` | `[rax+rcx]` | `(%rax,%rcx,1)` |
| 字数组 | `(AX)(CX*2)` | `[rax+rcx*2]` | `(%rax,%rcx,2)` |
| 双字数组 | `(AX)(CX*4)` | `[rax+rcx*4]` | `(%rax,%rcx,4)` |
| 四字数组 | `(AX)(CX*8)` | `[rax+rcx*8]` | `(%rax,%rcx,8)` |

### 3.4 RIP相对寻址（64位模式）

| 描述 | Go Plan9 | Intel (NASM) | AT&T |
|------|----------|--------------|------|
| 加载全局变量 | `myvar(SB)` | `[rel myvar]` | `myvar(%rip)` |
| 加载地址 | `myvar(SB)` | `lea rax, [rel myvar]` | `leaq myvar(%rip), %rax` |


### 3.5 段覆盖寻址

| 描述 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| FS段偏移0x28 | - | `[fs:0x28]` | `%fs:0x28` |
| GS段偏移0x30 | - | `[gs:0x30]` | `%gs:0x30` |

---

## 4. 立即数表示对比

### 4.1 立即数格式

| 类型 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 十进制 | `$100` | `100` | `$100` |
| 十六进制 | `$0x64` | `0x64` 或 `64h` | `$0x64` |
| 八进制 | `$0144` | `144o` | `$0144` |
| 二进制 | `$0b1100100` | `1100100b` | `$0b1100100` |
| 字符 | `$'A'` | `'A'` | `$'A'` |
| 符号地址 | `$symbol(SB)` | `OFFSET symbol` | `$symbol` |

### 4.2 立即数使用示例

| 操作 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 加载立即数到寄存器 | `MOVQ $42, AX` | `mov rax, 42` | `movq $42, %rax` |
| 立即数加法 | `ADDQ $10, BX` | `add rbx, 10` | `addq $10, %rbx` |
| 立即数比较 | `CMPQ $100, CX` | `cmp rcx, 100` | `cmpq $100, %rcx` |
| 立即数存入内存 | `MOVQ $0, 8(SP)` | `mov QWORD [rsp+8], 0` | `movq $0, 8(%rsp)` |

### 4.3 大立即数处理

| 描述 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 64位立即数 | `MOVQ $0x123456789ABC, AX` | `mov rax, 0x123456789ABC` | `movabsq $0x123456789ABC, %rax` |

---

## 5. 指令大小后缀/前缀对比

### 5.1 大小指定方式

| 大小 | Go Plan9 后缀 | Intel 前缀 | AT&T 后缀 |
|------|---------------|------------|-----------|
| 1字节 | `B` | `BYTE` / `BYTE PTR` | `b` |
| 2字节 | `W` | `WORD` / `WORD PTR` | `w` |
| 4字节 | `L` | `DWORD` / `DWORD PTR` | `l` |
| 8字节 | `Q` | `QWORD` / `QWORD PTR` | `q` |
| 16字节 | `O` | `OWORD` / `XMMWORD` | - |


### 5.2 大小指定示例

| 操作 | Go Plan9 | Intel (NASM) | AT&T |
|------|----------|--------------|------|
| 移动字节 | `MOVB $0x42, AL` | `mov al, 0x42` | `movb $0x42, %al` |
| 移动字 | `MOVW $0x1234, AX` | `mov ax, 0x1234` | `movw $0x1234, %ax` |
| 移动双字 | `MOVL $0x12345678, AX` | `mov eax, 0x12345678` | `movl $0x12345678, %eax` |
| 移动四字 | `MOVQ $0x123456789ABC, AX` | `mov rax, 0x123456789ABC` | `movq $0x123456789ABC, %rax` |

### 5.3 内存操作大小指定

| 操作 | Go Plan9 | Intel (NASM) | AT&T |
|------|----------|--------------|------|
| 存储字节到内存 | `MOVB $0, (AX)` | `mov BYTE [rax], 0` | `movb $0, (%rax)` |
| 存储字到内存 | `MOVW $0, (AX)` | `mov WORD [rax], 0` | `movw $0, (%rax)` |
| 存储双字到内存 | `MOVL $0, (AX)` | `mov DWORD [rax], 0` | `movl $0, (%rax)` |
| 存储四字到内存 | `MOVQ $0, (AX)` | `mov QWORD [rax], 0` | `movq $0, (%rax)` |

---

## 6. 等效指令对照表

### 6.1 数据移动指令

| 操作 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 寄存器到寄存器 | `MOVQ AX, BX` | `mov rbx, rax` | `movq %rax, %rbx` |
| 立即数到寄存器 | `MOVQ $42, AX` | `mov rax, 42` | `movq $42, %rax` |
| 内存到寄存器 | `MOVQ (BX), AX` | `mov rax, [rbx]` | `movq (%rbx), %rax` |
| 寄存器到内存 | `MOVQ AX, (BX)` | `mov [rbx], rax` | `movq %rax, (%rbx)` |
| 加载有效地址 | `LEAQ 8(AX), BX` | `lea rbx, [rax+8]` | `leaq 8(%rax), %rbx` |
| 符号扩展 | `MOVSLQ AX, BX` | `movsxd rbx, eax` | `movslq %eax, %rbx` |
| 零扩展 | `MOVL AX, AX` | `mov eax, eax` | `movl %eax, %eax` |

### 6.2 算术运算指令

| 操作 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 加法 | `ADDQ BX, AX` | `add rax, rbx` | `addq %rbx, %rax` |
| 减法 | `SUBQ BX, AX` | `sub rax, rbx` | `subq %rbx, %rax` |
| 乘法（有符号） | `IMULQ BX, AX` | `imul rax, rbx` | `imulq %rbx, %rax` |
| 除法（有符号） | `IDIVQ BX` | `idiv rbx` | `idivq %rbx` |
| 递增 | `INCQ AX` | `inc rax` | `incq %rax` |
| 递减 | `DECQ AX` | `dec rax` | `decq %rax` |
| 取反 | `NEGQ AX` | `neg rax` | `negq %rax` |


### 6.3 逻辑运算指令

| 操作 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 与 | `ANDQ BX, AX` | `and rax, rbx` | `andq %rbx, %rax` |
| 或 | `ORQ BX, AX` | `or rax, rbx` | `orq %rbx, %rax` |
| 异或 | `XORQ BX, AX` | `xor rax, rbx` | `xorq %rbx, %rax` |
| 取反 | `NOTQ AX` | `not rax` | `notq %rax` |
| 测试 | `TESTQ BX, AX` | `test rax, rbx` | `testq %rbx, %rax` |

### 6.4 移位指令

| 操作 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 逻辑左移 | `SHLQ $4, AX` | `shl rax, 4` | `shlq $4, %rax` |
| 逻辑右移 | `SHRQ $4, AX` | `shr rax, 4` | `shrq $4, %rax` |
| 算术右移 | `SARQ $4, AX` | `sar rax, 4` | `sarq $4, %rax` |
| 循环左移 | `ROLQ $4, AX` | `rol rax, 4` | `rolq $4, %rax` |
| 循环右移 | `RORQ $4, AX` | `ror rax, 4` | `rorq $4, %rax` |
| CL寄存器移位 | `SHLQ CL, AX` | `shl rax, cl` | `shlq %cl, %rax` |

### 6.5 比较和跳转指令

| 操作 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 比较 | `CMPQ BX, AX` | `cmp rax, rbx` | `cmpq %rbx, %rax` |
| 无条件跳转 | `JMP label` | `jmp label` | `jmp label` |
| 相等跳转 | `JEQ label` | `je label` | `je label` |
| 不等跳转 | `JNE label` | `jne label` | `jne label` |
| 小于跳转（有符号） | `JLT label` | `jl label` | `jl label` |
| 大于跳转（有符号） | `JGT label` | `jg label` | `jg label` |
| 小于等于（有符号） | `JLE label` | `jle label` | `jle label` |
| 大于等于（有符号） | `JGE label` | `jge label` | `jge label` |
| 低于跳转（无符号） | `JCS label` | `jb label` | `jb label` |
| 高于跳转（无符号） | `JHI label` | `ja label` | `ja label` |

### 6.6 栈操作指令

| 操作 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 压栈 | `PUSHQ AX` | `push rax` | `pushq %rax` |
| 出栈 | `POPQ AX` | `pop rax` | `popq %rax` |
| 调用函数 | `CALL func` | `call func` | `call func` |
| 返回 | `RET` | `ret` | `ret` |


### 6.7 条件移动指令

| 操作 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 相等时移动 | `CMOVQEQ BX, AX` | `cmove rax, rbx` | `cmoveq %rbx, %rax` |
| 不等时移动 | `CMOVQNE BX, AX` | `cmovne rax, rbx` | `cmovneq %rbx, %rax` |
| 小于时移动 | `CMOVQLT BX, AX` | `cmovl rax, rbx` | `cmovlq %rbx, %rax` |
| 大于时移动 | `CMOVQGT BX, AX` | `cmovg rax, rbx` | `cmovgq %rbx, %rax` |

### 6.8 字符串操作指令

| 操作 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 移动字节 | `MOVSB` | `movsb` | `movsb` |
| 移动四字 | `MOVSQ` | `movsq` | `movsq` |
| 重复移动 | `REP; MOVSB` | `rep movsb` | `rep movsb` |
| 比较字节 | `CMPSB` | `cmpsb` | `cmpsb` |
| 扫描字节 | `SCASB` | `scasb` | `scasb` |
| 存储字节 | `STOSB` | `stosb` | `stosb` |
| 加载字节 | `LODSB` | `lodsb` | `lodsb` |

### 6.9 原子操作指令

| 操作 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| 原子加法 | `LOCK; XADDQ AX, (BX)` | `lock xadd [rbx], rax` | `lock xaddq %rax, (%rbx)` |
| 原子交换 | `XCHGQ AX, (BX)` | `xchg [rbx], rax` | `xchgq %rax, (%rbx)` |
| 原子比较交换 | `LOCK; CMPXCHGQ CX, (BX)` | `lock cmpxchg [rbx], rcx` | `lock cmpxchgq %rcx, (%rbx)` |
| 原子递增 | `LOCK; INCQ (AX)` | `lock inc QWORD [rax]` | `lock incq (%rax)` |

---

## 7. 数据指令对比

### 7.1 数据定义指令

| 数据类型 | Go Plan9 | Intel (NASM) | AT&T (GAS) |
|----------|----------|--------------|------------|
| 字节 | `DATA sym+0(SB)/1, $0x42` | `db 0x42` | `.byte 0x42` |
| 字 | `DATA sym+0(SB)/2, $0x1234` | `dw 0x1234` | `.word 0x1234` |
| 双字 | `DATA sym+0(SB)/4, $0x12345678` | `dd 0x12345678` | `.long 0x12345678` |
| 四字 | `DATA sym+0(SB)/8, $0x123456789ABC` | `dq 0x123456789ABC` | `.quad 0x123456789ABC` |
| 字符串 | `DATA sym+0(SB)/8, $"Hello"` | `db "Hello", 0` | `.asciz "Hello"` |


### 7.2 未初始化数据

| 数据类型 | Go Plan9 | Intel (NASM) | AT&T (GAS) |
|----------|----------|--------------|------------|
| 保留字节 | - | `resb 100` | `.skip 100` |
| 保留字 | - | `resw 50` | `.skip 100` |
| 保留双字 | - | `resd 25` | `.skip 100` |
| 保留四字 | - | `resq 10` | `.skip 80` |

### 7.3 全局符号声明

| 操作 | Go Plan9 | Intel (NASM) | AT&T (GAS) |
|------|----------|--------------|------------|
| 声明全局符号 | `GLOBL sym(SB), flags, $size` | `global sym` | `.globl sym` |
| 声明外部符号 | - | `extern sym` | - (自动) |
| 私有符号 | `sym<>(SB)` | - | `.local sym` |

---

## 8. 节/段指令对比

### 8.1 节定义

| 节类型 | Go Plan9 | Intel (NASM) | AT&T (GAS) |
|--------|----------|--------------|------------|
| 代码节 | `TEXT` | `section .text` | `.text` |
| 数据节 | `DATA` | `section .data` | `.data` |
| BSS节 | - | `section .bss` | `.bss` |
| 只读数据 | `RODATA` | `section .rodata` | `.rodata` |

### 8.2 对齐指令

| 操作 | Go Plan9 | Intel (NASM) | AT&T (GAS) |
|------|----------|--------------|------------|
| 对齐到N字节 | `PCALIGN $N` | `align N` | `.align N` |
| 2的幂对齐 | - | `align 16` | `.p2align 4` |

---

## 9. 函数定义对比

### 9.1 函数声明语法

**Go Plan9**:
```asm
TEXT ·FuncName(SB), NOSPLIT, $frameSize-argSize
    // 函数体
    RET
```

**Intel (NASM)**:
```nasm
global func_name
func_name:
    ; 函数体
    ret
```

**AT&T (GAS)**:
```asm
.globl func_name
.type func_name, @function
func_name:
    # 函数体
    ret
.size func_name, .-func_name
```


### 9.2 函数序言/尾声对比

**Go Plan9**:
```asm
TEXT ·MyFunc(SB), $24-16
    // 自动处理栈帧
    MOVQ    arg1+0(FP), AX
    // ...
    MOVQ    AX, ret+8(FP)
    RET
```

**Intel (NASM)**:
```nasm
my_func:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    ; 函数体
    mov rsp, rbp
    pop rbp
    ret
```

**AT&T (GAS)**:
```asm
my_func:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp
    # 函数体
    movq %rbp, %rsp
    popq %rbp
    ret
```

---

## 10. 完整代码示例对比

### 10.1 简单加法函数

**Go Plan9** (`add_amd64.s`):
```asm
#include "textflag.h"

// func Add(a, b int64) int64
TEXT ·Add(SB), NOSPLIT, $0-24
    MOVQ    a+0(FP), AX      // 加载第一个参数
    ADDQ    b+8(FP), AX      // 加上第二个参数
    MOVQ    AX, ret+16(FP)   // 存储返回值
    RET
```

**Intel (NASM)** (`add.asm`):
```nasm
section .text
global add_numbers

; int64_t add_numbers(int64_t a, int64_t b)
; System V ABI: a in rdi, b in rsi, return in rax
add_numbers:
    mov     rax, rdi         ; 加载第一个参数
    add     rax, rsi         ; 加上第二个参数
    ret                      ; 返回结果在rax中
```

**AT&T (GAS)** (`add.s`):
```asm
.text
.globl add_numbers
.type add_numbers, @function

# int64_t add_numbers(int64_t a, int64_t b)
# System V ABI: a in %rdi, b in %rsi, return in %rax
add_numbers:
    movq    %rdi, %rax       # 加载第一个参数
    addq    %rsi, %rax       # 加上第二个参数
    ret                      # 返回结果在%rax中
.size add_numbers, .-add_numbers
```


### 10.2 数组求和函数

**Go Plan9**:
```asm
#include "textflag.h"

// func SumArray(arr []int64) int64
TEXT ·SumArray(SB), NOSPLIT, $0-32
    MOVQ    arr_base+0(FP), SI   // 数组基址
    MOVQ    arr_len+8(FP), CX    // 数组长度
    XORQ    AX, AX               // 累加器清零
    TESTQ   CX, CX
    JEQ     done
loop:
    ADDQ    (SI), AX
    ADDQ    $8, SI
    DECQ    CX
    JNZ     loop
done:
    MOVQ    AX, ret+24(FP)
    RET
```

**Intel (NASM)**:
```nasm
section .text
global sum_array

; int64_t sum_array(int64_t* arr, size_t len)
sum_array:
    xor     rax, rax             ; 累加器清零
    test    rsi, rsi
    jz      .done
.loop:
    add     rax, [rdi]
    add     rdi, 8
    dec     rsi
    jnz     .loop
.done:
    ret
```

**AT&T (GAS)**:
```asm
.text
.globl sum_array
.type sum_array, @function

# int64_t sum_array(int64_t* arr, size_t len)
sum_array:
    xorq    %rax, %rax           # 累加器清零
    testq   %rsi, %rsi
    jz      .done
.loop:
    addq    (%rdi), %rax
    addq    $8, %rdi
    decq    %rsi
    jnz     .loop
.done:
    ret
.size sum_array, .-sum_array
```

### 10.3 内存复制函数

**Go Plan9**:
```asm
// func MemCopy(dst, src []byte, n int)
TEXT ·MemCopy(SB), NOSPLIT, $0-56
    MOVQ    dst_base+0(FP), DI
    MOVQ    src_base+24(FP), SI
    MOVQ    n+48(FP), CX
    CLD
    REP
    MOVSB
    RET
```

**Intel (NASM)**:
```nasm
; void mem_copy(void* dst, void* src, size_t n)
mem_copy:
    mov     rcx, rdx             ; n -> rcx
    ; rdi = dst, rsi = src (已在正确位置)
    cld
    rep movsb
    ret
```

**AT&T (GAS)**:
```asm
# void mem_copy(void* dst, void* src, size_t n)
mem_copy:
    movq    %rdx, %rcx           # n -> %rcx
    # %rdi = dst, %rsi = src (已在正确位置)
    cld
    rep movsb
    ret
```


### 10.4 原子比较交换

**Go Plan9**:
```asm
// func AtomicCAS(addr *int64, old, new int64) bool
TEXT ·AtomicCAS(SB), NOSPLIT, $0-25
    MOVQ    addr+0(FP), BX
    MOVQ    old+8(FP), AX
    MOVQ    new+16(FP), CX
    LOCK
    CMPXCHGQ CX, (BX)
    SETEQ   ret+24(FP)
    RET
```

**Intel (NASM)**:
```nasm
; bool atomic_cas(int64_t* addr, int64_t old, int64_t new)
atomic_cas:
    mov     rax, rsi             ; old -> rax
    lock cmpxchg [rdi], rdx      ; compare and exchange
    sete    al                   ; 设置返回值
    movzx   eax, al
    ret
```

**AT&T (GAS)**:
```asm
# bool atomic_cas(int64_t* addr, int64_t old, int64_t new)
atomic_cas:
    movq    %rsi, %rax           # old -> %rax
    lock cmpxchgq %rdx, (%rdi)   # compare and exchange
    sete    %al                  # 设置返回值
    movzbl  %al, %eax
    ret
```

---

## 11. 快速参考卡

### 11.1 Go Plan9 快速参考

```
┌─────────────────────────────────────────────────────────────┐
│                   Go Plan9 汇编快速参考                      │
├─────────────────────────────────────────────────────────────┤
│ 操作数顺序: 源, 目标                                         │
│ 寄存器: AX, BX, CX, DX, SI, DI, SP, BP, R8-R15              │
│ 立即数: $value                                               │
│ 内存: offset(base)(index*scale)                             │
│ 大小后缀: B(1), W(2), L(4), Q(8)                            │
├─────────────────────────────────────────────────────────────┤
│ 伪寄存器:                                                    │
│   FP - 帧指针（参数）: arg+0(FP)                            │
│   SP - 栈指针（局部）: local+0(SP)                          │
│   SB - 静态基址（全局）: symbol(SB)                         │
│   PC - 程序计数器                                            │
├─────────────────────────────────────────────────────────────┤
│ 函数声明:                                                    │
│   TEXT ·FuncName(SB), FLAGS, $frameSize-argSize             │
├─────────────────────────────────────────────────────────────┤
│ 常用指令:                                                    │
│   MOVQ src, dst    - 移动64位                               │
│   ADDQ src, dst    - 加法                                   │
│   SUBQ src, dst    - 减法                                   │
│   CMPQ src, dst    - 比较                                   │
│   JMP/JEQ/JNE      - 跳转                                   │
│   CALL/RET         - 调用/返回                              │
└─────────────────────────────────────────────────────────────┘
```


### 11.2 Intel (NASM) 快速参考

```
┌─────────────────────────────────────────────────────────────┐
│                   Intel (NASM) 汇编快速参考                  │
├─────────────────────────────────────────────────────────────┤
│ 操作数顺序: 目标, 源                                         │
│ 寄存器: rax, rbx, rcx, rdx, rsi, rdi, rsp, rbp, r8-r15      │
│ 立即数: value (无前缀)                                       │
│ 内存: [base + index*scale + offset]                         │
│ 大小前缀: BYTE, WORD, DWORD, QWORD                          │
├─────────────────────────────────────────────────────────────┤
│ 节定义:                                                      │
│   section .text    - 代码节                                 │
│   section .data    - 数据节                                 │
│   section .bss     - 未初始化数据节                         │
├─────────────────────────────────────────────────────────────┤
│ 数据定义:                                                    │
│   db value         - 定义字节                               │
│   dw value         - 定义字                                 │
│   dd value         - 定义双字                               │
│   dq value         - 定义四字                               │
│   resb/resw/resd/resq - 保留空间                            │
├─────────────────────────────────────────────────────────────┤
│ 常用指令:                                                    │
│   mov dst, src     - 移动                                   │
│   add dst, src     - 加法                                   │
│   sub dst, src     - 减法                                   │
│   cmp dst, src     - 比较                                   │
│   jmp/je/jne       - 跳转                                   │
│   call/ret         - 调用/返回                              │
└─────────────────────────────────────────────────────────────┘
```

### 11.3 AT&T (GAS) 快速参考

```
┌─────────────────────────────────────────────────────────────┐
│                   AT&T (GAS) 汇编快速参考                    │
├─────────────────────────────────────────────────────────────┤
│ 操作数顺序: 源, 目标                                         │
│ 寄存器: %rax, %rbx, %rcx, %rdx, %rsi, %rdi, %rsp, %rbp      │
│ 立即数: $value                                               │
│ 内存: offset(%base, %index, scale)                          │
│ 大小后缀: b(1), w(2), l(4), q(8)                            │
├─────────────────────────────────────────────────────────────┤
│ 节定义:                                                      │
│   .text            - 代码节                                 │
│   .data            - 数据节                                 │
│   .bss             - 未初始化数据节                         │
├─────────────────────────────────────────────────────────────┤
│ 数据定义:                                                    │
│   .byte value      - 定义字节                               │
│   .word value      - 定义字                                 │
│   .long value      - 定义双字                               │
│   .quad value      - 定义四字                               │
│   .skip n          - 保留n字节                              │
│   .asciz "str"     - 定义字符串                             │
├─────────────────────────────────────────────────────────────┤
│ 常用指令:                                                    │
│   movq %src, %dst  - 移动64位                               │
│   addq %src, %dst  - 加法                                   │
│   subq %src, %dst  - 减法                                   │
│   cmpq %src, %dst  - 比较                                   │
│   jmp/je/jne       - 跳转                                   │
│   call/ret         - 调用/返回                              │
└─────────────────────────────────────────────────────────────┘
```


---

## 12. 语法转换速查表

### 12.1 从Intel到AT&T转换规则

| 规则 | Intel | AT&T |
|------|-------|------|
| 1. 交换操作数顺序 | `mov rax, rbx` | `movq %rbx, %rax` |
| 2. 添加寄存器前缀% | `rax` | `%rax` |
| 3. 添加立即数前缀$ | `42` | `$42` |
| 4. 添加指令大小后缀 | `mov` | `movq` |
| 5. 转换内存语法 | `[rax+rbx*4+8]` | `8(%rax,%rbx,4)` |
| 6. 转换大小指定 | `QWORD [rax]` | `(%rax)` + `q`后缀 |

### 12.2 从AT&T到Intel转换规则

| 规则 | AT&T | Intel |
|------|------|-------|
| 1. 交换操作数顺序 | `movq %rbx, %rax` | `mov rax, rbx` |
| 2. 移除寄存器前缀% | `%rax` | `rax` |
| 3. 移除立即数前缀$ | `$42` | `42` |
| 4. 移除指令大小后缀 | `movq` | `mov` |
| 5. 转换内存语法 | `8(%rax,%rbx,4)` | `[rax+rbx*4+8]` |
| 6. 添加大小指定（如需要） | `(%rax)` | `QWORD [rax]` |

### 12.3 从Go Plan9到Intel/AT&T转换

| Go Plan9 | Intel | AT&T |
|----------|-------|------|
| `MOVQ AX, BX` | `mov rbx, rax` | `movq %rax, %rbx` |
| `MOVQ $42, AX` | `mov rax, 42` | `movq $42, %rax` |
| `MOVQ (AX), BX` | `mov rbx, [rax]` | `movq (%rax), %rbx` |
| `MOVQ 8(AX), BX` | `mov rbx, [rax+8]` | `movq 8(%rax), %rbx` |
| `MOVQ (AX)(CX*8), BX` | `mov rbx, [rax+rcx*8]` | `movq (%rax,%rcx,8), %rbx` |

---

## 13. 常见错误和注意事项

### 13.1 操作数顺序错误

```
❌ 错误（混淆Intel和AT&T顺序）:
   AT&T: movq %rax, %rbx    // 实际是 rbx = rax
   期望: rax = rbx

✓ 正确:
   AT&T: movq %rbx, %rax    // rax = rbx
   Intel: mov rax, rbx      // rax = rbx
```

### 13.2 前缀遗漏

```
❌ 错误（AT&T中遗漏前缀）:
   movq rax, rbx            // 缺少%前缀
   movq 42, %rax            // 缺少$前缀

✓ 正确:
   movq %rax, %rbx
   movq $42, %rax
```

### 13.3 大小指定错误

```
❌ 错误（大小不匹配）:
   Go Plan9: MOVQ $42, AL   // Q是64位，AL是8位
   AT&T: movq $42, %al      // 同上

✓ 正确:
   Go Plan9: MOVB $42, AL
   AT&T: movb $42, %al
```

### 13.4 内存寻址语法错误

```
❌ 错误（混淆语法）:
   AT&T: movq [%rax], %rbx  // 使用了Intel的方括号
   Intel: movq (%rax), rbx  // 使用了AT&T的圆括号

✓ 正确:
   AT&T: movq (%rax), %rbx
   Intel: mov rbx, [rax]
```


---

## 14. 工具和资源

### 14.1 语法转换工具

| 工具 | 用途 | 命令示例 |
|------|------|----------|
| **objdump** | 反汇编（默认AT&T） | `objdump -d binary` |
| **objdump -M intel** | 反汇编（Intel语法） | `objdump -M intel -d binary` |
| **GCC -S** | 生成汇编（默认AT&T） | `gcc -S source.c` |
| **GCC -masm=intel** | 生成汇编（Intel语法） | `gcc -S -masm=intel source.c` |
| **go tool objdump** | Go程序反汇编 | `go tool objdump -s func binary` |

### 14.2 在线资源

- **Go汇编**: [Go Assembler Guide](https://go.dev/doc/asm)
- **Intel语法**: [NASM Manual](https://www.nasm.us/doc/)
- **AT&T语法**: [GNU Assembler Manual](https://sourceware.org/binutils/docs/as/)
- **Intel指令参考**: [Intel SDM](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)

---

## 15. 总结对比表

### 15.1 语法特性总结

| 特性 | Go Plan9 | Intel | AT&T |
|------|----------|-------|------|
| **操作数顺序** | 源→目标 | 目标←源 | 源→目标 |
| **寄存器前缀** | 无 | 无 | `%` |
| **立即数前缀** | `$` | 无 | `$` |
| **内存访问** | `off(base)` | `[base+off]` | `off(%base)` |
| **大小指定** | 指令后缀 | 操作数前缀 | 指令后缀 |
| **注释** | `//` | `;` | `#` |
| **主要用途** | Go��态 | Windows/独立 | Linux/GCC |

### 15.2 选择建议

| 场景 | 推荐语法 | 原因 |
|------|----------|------|
| Go项目 | Go Plan9 | 与Go运行时集成 |
| Linux内核/驱动 | AT&T | GCC工具链原生支持 |
| Windows开发 | Intel (MASM) | Visual Studio集成 |
| 跨平台项目 | Intel (NASM) | 可读性好，工具支持广 |
| 学习/教学 | Intel | 语法直观，文档丰富 |
| 逆向工程 | Intel | 大多数工具默认使用 |

---

## 参考资料

### 官方文档

- [Go Assembler Guide](https://go.dev/doc/asm) - Go官方汇编指南
- [NASM Manual](https://www.nasm.us/doc/) - NASM官方文档
- [GNU Assembler Manual](https://sourceware.org/binutils/docs/as/) - GAS官方文档
- [Intel® 64 and IA-32 Architectures SDM](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html) - Intel官方手册

### 相关章节

- [语法对比概述](overview.md) - 三种语法的历史和适用场景
- [Go Plan9 汇编详解](go-plan9.md) - Go汇编完整参考
- [Intel 汇编详解](intel.md) - Intel语法完整参考
- [AT&T 汇编详解](att.md) - AT&T语法完整参考

---

*上一节: [AT&T 汇编详解](att.md)*
*返回: [语法对比概述](overview.md)*
