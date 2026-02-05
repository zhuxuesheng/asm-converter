# Intel 汇编语法详解

> Intel汇编语法完整参考，包含NASM/MASM差异、指令格式、寻址模式、数据指令和宏系统

## 概述

Intel汇编语法是最广泛使用的x86/x64汇编语法之一，直接源自Intel公司的处理器技术文档。其设计理念是**直观可读**，语法结构接近自然语言的表达方式，目标操作数在前，源操作数在后。

### 核心特性

| 特性 | 说明 |
|------|------|
| **操作数顺序** | 目标在前，源在后（destination, source） |
| **内存访问** | 使用方括号 `[address]` 表示 |
| **寄存器命名** | 直接使用寄存器名，无前缀 |
| **大小指定** | 通过寄存器名或显式声明（BYTE, WORD, DWORD, QWORD） |

### 主要汇编器

| 汇编器 | 全称 | 特点 | 平台 |
|--------|------|------|------|
| **NASM** | Netwide Assembler | 开源、跨平台、语法严格 | 跨平台 |
| **MASM** | Microsoft Macro Assembler | Microsoft官方、与VS集成 | Windows |
| **YASM** | Yet Another Assembler | NASM兼容、支持更多格式 | 跨平台 |
| **FASM** | Flat Assembler | 自举、语法独特 | 跨平台 |
| **GAS** | GNU Assembler | 支持`.intel_syntax`指令 | 跨平台 |

---

## NASM vs MASM 语法差异

NASM和MASM是两种最常用的Intel语法汇编器，虽然都使用Intel语法风格，但在具体语法细节上存在显著差异。

### 基本语法对比

| 特性 | NASM | MASM |
|------|------|------|
| **段定义** | `section .text` | `.code` |
| **数据段** | `section .data` | `.data` |
| **BSS段** | `section .bss` | `.data?` |
| **全局符号** | `global symbol` | `PUBLIC symbol` |
| **外部符号** | `extern symbol` | `EXTERN symbol:type` |
| **过程定义** | `label:` | `label PROC` |
| **内存大小** | `QWORD [addr]` | `QWORD PTR [addr]` |
| **偏移量** | `symbol` 或 `$` | `OFFSET symbol` |
| **注释** | `;` | `;` |

### 段/节定义

**NASM风格**：
```nasm
; NASM使用section指令
section .data
    message db "Hello, World!", 0
    
section .bss
    buffer resb 1024
    
section .text
    global _start
    
_start:
    ; 代码
```

**MASM风格**：
```asm
; MASM使用简化段指令
.data
    message BYTE "Hello, World!", 0
    
.data?
    buffer BYTE 1024 DUP(?)
    
.code
main PROC
    ; 代码
main ENDP
END main
```

### 数据定义

| 数据类型 | NASM | MASM |
|----------|------|------|
| 字节 | `db` | `BYTE` 或 `DB` |
| 字 | `dw` | `WORD` 或 `DW` |
| 双字 | `dd` | `DWORD` 或 `DD` |
| 四字 | `dq` | `QWORD` 或 `DQ` |
| 十字节 | `dt` | `TBYTE` 或 `DT` |
| 未初始化字节 | `resb` | `BYTE ?` 或 `DB ?` |
| 未初始化字 | `resw` | `WORD ?` 或 `DW ?` |
| 未初始化双字 | `resd` | `DWORD ?` 或 `DD ?` |
| 未初始化四字 | `resq` | `QWORD ?` 或 `DQ ?` |

**NASM数据定义示例**：
```nasm
section .data
    ; 初始化数据
    byte_val    db 0x42              ; 单字节
    word_val    dw 0x1234            ; 2字节
    dword_val   dd 0x12345678        ; 4字节
    qword_val   dq 0x123456789ABCDEF0 ; 8字节
    
    ; 字符串
    string1     db "Hello", 0        ; 以null结尾
    string2     db 'World', 10, 0    ; 带换行符
    
    ; 数组
    array       dd 1, 2, 3, 4, 5     ; 5个双字
    
    ; 重复数据
    zeros       times 100 db 0       ; 100个零字节
    
section .bss
    ; 未初始化数据
    buffer      resb 1024            ; 1024字节缓冲区
    numbers     resd 10              ; 10个双字
```

**MASM数据定义示例**：
```asm
.data
    ; 初始化数据
    byte_val    BYTE 42h             ; 单字节
    word_val    WORD 1234h           ; 2字节
    dword_val   DWORD 12345678h      ; 4字节
    qword_val   QWORD 123456789ABCDEF0h ; 8字节
    
    ; 字符串
    string1     BYTE "Hello", 0      ; 以null结尾
    string2     BYTE 'World', 10, 0  ; 带换行符
    
    ; 数组
    array       DWORD 1, 2, 3, 4, 5  ; 5个双字
    
    ; 重复数据
    zeros       BYTE 100 DUP(0)      ; 100个零字节
    
.data?
    ; 未初始化数据
    buffer      BYTE 1024 DUP(?)     ; 1024字节缓冲区
    numbers     DWORD 10 DUP(?)      ; 10个双字
```

### 内存操作数大小指定

**NASM风格**：
```nasm
; NASM使用大小关键字（无PTR）
mov BYTE [rax], 0x42
mov WORD [rax], 0x1234
mov DWORD [rax], 0x12345678
mov QWORD [rax], 0x123456789ABCDEF0

; 当寄存器大小明确时可省略
mov al, [rax]           ; 自动推断为BYTE
mov eax, [rax]          ; 自动推断为DWORD
mov rax, [rbx]          ; 自动推断为QWORD
```

**MASM风格**：
```asm
; MASM使用PTR操作符
mov BYTE PTR [rax], 42h
mov WORD PTR [rax], 1234h
mov DWORD PTR [rax], 12345678h
mov QWORD PTR [rax], 123456789ABCDEF0h

; 当寄存器大小明确时可省略
mov al, [rax]           ; 自动推断为BYTE
mov eax, [rax]          ; 自动推断为DWORD
mov rax, [rbx]          ; 自动推断为QWORD
```

### 地址和偏移量

**NASM风格**：
```nasm
section .data
    myvar dd 12345678h

section .text
    ; 加载变量的值
    mov eax, [myvar]        ; 加载myvar的内容
    
    ; 加载变量的地址
    mov rax, myvar          ; 加载myvar的地址（64位模式）
    lea rax, [myvar]        ; 同上，使用LEA
    
    ; 当前位置
    jmp $                   ; 无限循环（跳转到当前位置）
    db $ - start            ; 计算从start到当前的偏移
```

**MASM风格**：
```asm
.data
    myvar DWORD 12345678h

.code
    ; 加载变量的值
    mov eax, myvar          ; MASM自动解引用
    mov eax, [myvar]        ; 显式解引用（同上）
    
    ; 加载变量的地址
    mov rax, OFFSET myvar   ; 使用OFFSET获取地址
    lea rax, myvar          ; 使用LEA获取地址
    
    ; 当前位置
    jmp $                   ; 无限循环
```

### 过程（函数）定义

**NASM风格**：
```nasm
section .text
    global my_function

; NASM使用简单标签定义函数
my_function:
    push rbp
    mov rbp, rsp
    
    ; 函数体
    
    pop rbp
    ret
```

**MASM风格**：
```asm
.code

; MASM使用PROC/ENDP定义过程
my_function PROC
    push rbp
    mov rbp, rsp
    
    ; 函数体
    
    pop rbp
    ret
my_function ENDP

; MASM支持参数声明
add_numbers PROC, a:QWORD, b:QWORD
    mov rax, a
    add rax, b
    ret
add_numbers ENDP
```

---

## 指令格式

### 基本格式

Intel语法的指令格式遵循以下模式：

```
INSTRUCTION  destination, source
```

**操作数顺序**：目标操作数在前，源操作数在后（与AT&T语法相反）。

```nasm
mov rax, rbx        ; 将rbx的值移动到rax（rbx → rax）
add rcx, 10         ; 将10加到rcx（rcx = rcx + 10）
sub rax, rdx        ; 从rax减去rdx（rax = rax - rdx）
```

### 操作数类型

Intel语法支持三种基本操作数类型：

| 类型 | 说明 | 示例 |
|------|------|------|
| **寄存器** | CPU寄存器 | `rax`, `ebx`, `cl` |
| **立即数** | 常量值 | `42`, `0x1234`, `'A'` |
| **内存** | 内存地址 | `[rax]`, `[rbp-8]` |

**操作数组合规则**：

| 目标 | 源 | 有效性 | 示例 |
|------|-----|--------|------|
| 寄存器 | 寄存器 | ✓ | `mov rax, rbx` |
| 寄存器 | 立即数 | ✓ | `mov rax, 42` |
| 寄存器 | 内存 | ✓ | `mov rax, [rbx]` |
| 内存 | 寄存器 | ✓ | `mov [rax], rbx` |
| 内存 | 立即数 | ✓ | `mov QWORD [rax], 42` |
| 内存 | 内存 | ✗ | 不允许 |

### 指令前缀

Intel语法支持多种指令前缀：

| 前缀 | 用途 | 示例 |
|------|------|------|
| `LOCK` | 原子操作 | `lock add [rax], 1` |
| `REP` | 重复字符串操作 | `rep movsb` |
| `REPE/REPZ` | 相等时重复 | `repe cmpsb` |
| `REPNE/REPNZ` | 不等时重复 | `repne scasb` |

```nasm
; 原子递增
lock inc DWORD [counter]

; 原子比较交换
lock cmpxchg [rax], rbx

; 字符串复制
mov rsi, src
mov rdi, dst
mov rcx, length
cld                     ; 清除方向标志
rep movsb               ; 复制rcx字节

; 字符串比较
mov rsi, str1
mov rdi, str2
mov rcx, length
repe cmpsb              ; 比较直到不相等或rcx=0
```

---

## 寄存器命名约定

### 通用寄存器（x86-64）

Intel语法直接使用寄存器名，无需前缀：

| 64位 | 32位 | 16位 | 8位高 | 8位低 | 用途 |
|------|------|------|-------|-------|------|
| RAX | EAX | AX | AH | AL | 累加器/返回值 |
| RBX | EBX | BX | BH | BL | 基址寄存器 |
| RCX | ECX | CX | CH | CL | 计数器/第4参数(Win) |
| RDX | EDX | DX | DH | DL | 数据/第3参数(Win) |
| RSI | ESI | SI | - | SIL | 源索引/第2参数(SysV) |
| RDI | EDI | DI | - | DIL | 目标索引/第1参数(SysV) |
| RBP | EBP | BP | - | BPL | 帧指针 |
| RSP | ESP | SP | - | SPL | 栈指针 |
| R8 | R8D | R8W | - | R8B | 第5参数(Win)/第5参数(SysV) |
| R9 | R9D | R9W | - | R9B | 第6参数(Win)/第6参数(SysV) |
| R10 | R10D | R10W | - | R10B | 临时寄存器 |
| R11 | R11D | R11W | - | R11B | 临时寄存器 |
| R12 | R12D | R12W | - | R12B | 被调用者保存 |
| R13 | R13D | R13W | - | R13B | 被调用者保存 |
| R14 | R14D | R14W | - | R14B | 被调用者保存 |
| R15 | R15D | R15W | - | R15B | 被调用者保存 |

**寄存器访问示例**：
```nasm
; 64位操作
mov rax, 0x123456789ABCDEF0

; 32位操作（自动清零高32位）
mov eax, 0x12345678

; 16位操作（保留高位）
mov ax, 0x1234

; 8位操作（保留高位）
mov al, 0x12            ; 低8位
mov ah, 0x34            ; 高8位（仅AX,BX,CX,DX）
```

### 段寄存器

| 寄存器 | 用途 |
|--------|------|
| CS | 代码段 |
| DS | 数据段 |
| SS | 栈段 |
| ES | 额外段 |
| FS | 通用段（TLS in Linux） |
| GS | 通用段（TLS in Windows） |

```nasm
; 段覆盖前缀
mov rax, [fs:0x28]      ; 访问FS段偏移0x28（Linux栈保护）
mov rax, [gs:0x30]      ; 访问GS段偏移0x30（Windows TEB）
```

### SIMD寄存器

| 类型 | 寄存器 | 大小 | 数量 |
|------|--------|------|------|
| SSE | XMM0-XMM15 | 128位 | 16个 |
| AVX | YMM0-YMM15 | 256位 | 16个 |
| AVX-512 | ZMM0-ZMM31 | 512位 | 32个 |

```nasm
; SSE操作
movaps xmm0, [rax]      ; 对齐加载128位
movups xmm1, [rbx]      ; 非对齐加载128位
addps xmm0, xmm1        ; 4个单精度浮点加法
mulpd xmm0, xmm1        ; 2个双精度浮点乘法

; AVX操作
vmovaps ymm0, [rax]     ; 对齐加载256位
vaddps ymm0, ymm1, ymm2 ; 三操作数形式
vfmadd213ps ymm0, ymm1, ymm2  ; 融合乘加

; AVX-512操作
vmovaps zmm0, [rax]     ; 加载512位
vaddps zmm0, zmm1, zmm2 ; 16个单精度浮点加法
```

### 特殊寄存器

| 寄存器 | 用途 |
|--------|------|
| RIP | 指令指针 |
| RFLAGS | 标志寄存器 |
| CR0-CR4 | 控制寄存器 |
| DR0-DR7 | 调试寄存器 |

```nasm
; RIP相对寻址（64位模式）
lea rax, [rip + offset] ; 加载相对于RIP的地址
mov rax, [rel myvar]    ; NASM的RIP相对寻址语法

; 标志操作
pushfq                  ; 保存RFLAGS
popfq                   ; 恢复RFLAGS
```

---

## 内存寻址语法

Intel语法使用方括号`[]`表示内存访问，支持丰富的寻址模式。

### 寻址模式概览

```
[base + index*scale + displacement]
```

| 组件 | 说明 | 有效值 |
|------|------|--------|
| base | 基址寄存器 | 任意通用寄存器 |
| index | 索引寄存器 | 除RSP外的通用寄存器 |
| scale | 比例因子 | 1, 2, 4, 8 |
| displacement | 偏移量 | 8位、16位或32位常量 |

### 基本寻址模式

**1. 直接寻址**：
```nasm
mov rax, [0x1000]       ; 从绝对地址加载
mov rax, [myvar]        ; 从符号地址加载
```

**2. 寄存器间接寻址**：
```nasm
mov rax, [rbx]          ; 从rbx指向的地址加载
mov [rcx], rdx          ; 存储到rcx指向的地址
```

**3. 基址+偏移寻址**：
```nasm
mov rax, [rbx + 8]      ; 从rbx+8加载
mov rax, [rbp - 16]     ; 从rbp-16加载（局部变量）
mov rax, [rsp + 32]     ; 从rsp+32加载（栈参数）
```

**4. 基址+索引寻址**：
```nasm
mov rax, [rbx + rcx]    ; 从rbx+rcx加载
mov rax, [rsi + rdi]    ; 从rsi+rdi加载
```

**5. 基址+索引*比例寻址**：
```nasm
; 数组访问（scale对应元素大小）
mov al, [rbx + rcx*1]   ; 字节数组
mov ax, [rbx + rcx*2]   ; 字数组
mov eax, [rbx + rcx*4]  ; 双字数组
mov rax, [rbx + rcx*8]  ; 四字数组
```

**6. 完整寻址模式**：
```nasm
; base + index*scale + displacement
mov rax, [rbx + rcx*8 + 16]     ; 结构体数组访问
mov rax, [rbp + rdi*4 - 32]     ; 复杂偏移计算
```

### RIP相对寻址（64位模式）

64位模式下，推荐使用RIP相对寻址访问全局数据：

```nasm
; NASM语法
default rel             ; 设置默认使用相对寻址

section .data
    myvar dq 12345678h

section .text
    ; 显式RIP相对
    mov rax, [rel myvar]
    lea rbx, [rel myvar]
    
    ; 使用default rel后可省略rel
    mov rax, [myvar]
```

```asm
; MASM语法（自动使用RIP相对）
.data
    myvar QWORD 12345678h

.code
    mov rax, myvar      ; MASM自动生成RIP相对代码
    lea rbx, myvar
```

### 段覆盖

```nasm
; 使用段前缀访问特定段
mov rax, [fs:0]         ; FS段偏移0
mov rax, [gs:0x28]      ; GS段偏移0x28
mov rax, [es:rdi]       ; ES段，RDI偏移

; 常见用途
mov rax, [fs:0x28]      ; Linux: 栈金丝雀值
mov rax, [gs:0x30]      ; Windows: TEB指针
```

### 寻址模式示例汇总

```nasm
; 各种寻址模式示例
mov rax, [1000h]                ; 直接寻址
mov rax, [rbx]                  ; 寄存器间接
mov rax, [rbx + 8]              ; 基址+偏移
mov rax, [rbx + rcx]            ; 基址+索引
mov rax, [rbx + rcx*4]          ; 基址+索引*比例
mov rax, [rbx + rcx*4 + 8]      ; 完整形式
mov rax, [rel myvar]            ; RIP相对
mov rax, [fs:0x28]              ; 段覆盖

; 实际应用场景
mov rax, [rbp - 8]              ; 访问局部变量
mov rax, [rbp + 16]             ; 访问函数参数
mov rax, [rsp + 32]             ; 访问栈上数据
mov rax, [array + rcx*8]        ; 访问数组元素
mov rax, [struct + field_off]   ; 访问结构体字段
```

---

## 立即数和常量

### 数值表示

Intel语法支持多种数值表示方式：

| 进制 | NASM格式 | MASM格式 | 示例 |
|------|----------|----------|------|
| 十进制 | `123` | `123` | `mov rax, 123` |
| 十六进制 | `0x7B` 或 `7Bh` | `7Bh` 或 `0x7B` | `mov rax, 0x7B` |
| 八进制 | `173o` 或 `0o173` | `173o` | `mov rax, 173o` |
| 二进制 | `1111011b` | `1111011b` | `mov rax, 1111011b` |
| 字符 | `'A'` | `'A'` | `mov al, 'A'` |

**NASM数值示例**：
```nasm
mov rax, 100            ; 十进制
mov rax, 0x64           ; 十六进制（C风格）
mov rax, 64h            ; 十六进制（汇编风格）
mov rax, 0o144          ; 八进制（NASM 2.x）
mov rax, 144o           ; 八进制（传统）
mov rax, 1100100b       ; 二进制
mov al, 'A'             ; 字符（ASCII 65）
mov ax, 'AB'            ; 双字符
mov eax, `ABCD`         ; NASM反引号字符串
```

**MASM数值示例**：
```asm
mov rax, 100            ; 十进制
mov rax, 64h            ; 十六进制
mov rax, 0x64           ; 十六进制（MASM 14+）
mov rax, 144o           ; 八进制
mov rax, 1100100b       ; 二进制
mov al, 'A'             ; 字符
```

### 常量定义

**NASM常量**：
```nasm
; 使用EQU定义常量
BUFFER_SIZE equ 1024
MAX_COUNT   equ 100
NEWLINE     equ 10

; 使用%define定义宏常量
%define ARRAY_LEN 50
%define OFFSET_X  8

; 使用%assign定义可重新赋值的常量
%assign counter 0
%assign counter counter+1

; 使用常量
mov rcx, BUFFER_SIZE
mov al, NEWLINE
```

**MASM常量**：
```asm
; 使用EQU定义常量
BUFFER_SIZE EQU 1024
MAX_COUNT   EQU 100
NEWLINE     EQU 10

; 使用=定义可重新赋值的常量
counter = 0
counter = counter + 1

; 使用TEXTEQU定义文本宏
greeting TEXTEQU <"Hello">

; 使用常量
mov rcx, BUFFER_SIZE
mov al, NEWLINE
```

### 表达式计算

汇编器支持编译时表达式计算：

```nasm
; NASM表达式
STRUCT_SIZE equ 24
ARRAY_LEN   equ 10
TOTAL_SIZE  equ STRUCT_SIZE * ARRAY_LEN     ; = 240

mov rax, (1 << 10)          ; 位移：1024
mov rbx, (0xFF & 0x0F)      ; 位与：15
mov rcx, (100 + 50 * 2)     ; 算术：200

; 地址计算
section .data
    array times 100 dq 0
    array_end:
    array_len equ (array_end - array) / 8   ; 计算元素数量
```

---

## 数据指令

### 初始化数据定义

**NASM数据指令**：

| 指令 | 大小 | 说明 |
|------|------|------|
| `db` | 1字节 | Define Byte |
| `dw` | 2字节 | Define Word |
| `dd` | 4字节 | Define Doubleword |
| `dq` | 8字节 | Define Quadword |
| `dt` | 10字节 | Define Ten-byte (80位浮点) |
| `do` | 16字节 | Define Octword (SSE) |
| `dy` | 32字节 | Define YMM (AVX) |
| `dz` | 64字节 | Define ZMM (AVX-512) |

```nasm
section .data
    ; 基本数据类型
    byte_data   db 0x42
    word_data   dw 0x1234
    dword_data  dd 0x12345678
    qword_data  dq 0x123456789ABCDEF0
    
    ; 浮点数据
    float_data  dd 3.14159           ; 单精度
    double_data dq 3.14159265358979  ; 双精度
    extended    dt 3.14159265358979  ; 扩展精度
    
    ; 字符串
    string1     db "Hello, World!", 0
    string2     db 'Line 1', 10, 'Line 2', 10, 0
    
    ; 数组
    int_array   dd 1, 2, 3, 4, 5
    ptr_array   dq func1, func2, func3
    
    ; 重复数据
    zeros       times 100 db 0
    pattern     times 10 dw 0xABCD
    
    ; 对齐
    align 16
    aligned_data dq 0
```

**MASM数据指令**：

| 指令 | 大小 | 说明 |
|------|------|------|
| `BYTE` / `DB` | 1字节 | 字节 |
| `WORD` / `DW` | 2字节 | 字 |
| `DWORD` / `DD` | 4字节 | 双字 |
| `QWORD` / `DQ` | 8字节 | 四字 |
| `TBYTE` / `DT` | 10字节 | 十字节 |
| `OWORD` | 16字节 | 八字（SSE） |
| `YMMWORD` | 32字节 | YMM（AVX） |
| `ZMMWORD` | 64字节 | ZMM（AVX-512） |
| `REAL4` | 4字节 | 单精度浮点 |
| `REAL8` | 8字节 | 双精度浮点 |
| `REAL10` | 10字节 | 扩展精度浮点 |

```asm
.data
    ; 基本数据类型
    byte_data   BYTE 42h
    word_data   WORD 1234h
    dword_data  DWORD 12345678h
    qword_data  QWORD 123456789ABCDEF0h
    
    ; 浮点数据
    float_data  REAL4 3.14159
    double_data REAL8 3.14159265358979
    
    ; 字符串
    string1     BYTE "Hello, World!", 0
    string2     BYTE 'Line 1', 10, 'Line 2', 10, 0
    
    ; 数组
    int_array   DWORD 1, 2, 3, 4, 5
    
    ; 重复数据
    zeros       BYTE 100 DUP(0)
    pattern     WORD 10 DUP(0ABCDh)
    
    ; 对齐
    ALIGN 16
    aligned_data QWORD 0
```

### 未初始化数据定义

**NASM未初始化数据**：

| 指令 | 大小 | 说明 |
|------|------|------|
| `resb` | 1字节 | Reserve Byte |
| `resw` | 2字节 | Reserve Word |
| `resd` | 4字节 | Reserve Doubleword |
| `resq` | 8字节 | Reserve Quadword |
| `rest` | 10字节 | Reserve Ten-byte |
| `reso` | 16字节 | Reserve Octword |
| `resy` | 32字节 | Reserve YMM |
| `resz` | 64字节 | Reserve ZMM |

```nasm
section .bss
    buffer      resb 1024       ; 1024字节缓冲区
    numbers     resd 100        ; 100个双字
    pointers    resq 50         ; 50个指针
    
    ; 对齐的未初始化数据
    alignb 16
    aligned_buf resb 256
```

**MASM未初始化数据**：

```asm
.data?
    buffer      BYTE 1024 DUP(?)    ; 1024字节缓冲区
    numbers     DWORD 100 DUP(?)    ; 100个双字
    pointers    QWORD 50 DUP(?)     ; 50个指针
    
    ; 对齐
    ALIGN 16
    aligned_buf BYTE 256 DUP(?)
```

### 结构体定义

**NASM结构体**：
```nasm
; 使用struc/endstruc定义结构体
struc Point
    .x: resq 1
    .y: resq 1
endstruc

struc Rectangle
    .origin: resb Point_size    ; 嵌套结构体
    .width:  resq 1
    .height: resq 1
endstruc

section .data
    ; 实例化结构体
    mypoint:
        istruc Point
            at Point.x, dq 100
            at Point.y, dq 200
        iend

section .text
    ; 访问结构体字段
    mov rax, [mypoint + Point.x]
    mov rbx, [mypoint + Point.y]
```

**MASM结构体**：
```asm
; 使用STRUCT/ENDS定义结构体
Point STRUCT
    x QWORD ?
    y QWORD ?
Point ENDS

Rectangle STRUCT
    origin Point <>         ; 嵌套结构体
    width  QWORD ?
    height QWORD ?
Rectangle ENDS

.data
    ; 实例化结构体
    mypoint Point <100, 200>
    myrect  Rectangle <<10, 20>, 100, 50>

.code
    ; 访问结构体字段
    mov rax, mypoint.x
    mov rbx, mypoint.y
    mov rcx, myrect.origin.x
```

---

## 节/段指令

### NASM节指令

```nasm
; 基本节定义
section .text           ; 代码节
section .data           ; 初始化数据节
section .bss            ; 未初始化数据节
section .rodata         ; 只读数据节

; 带属性的节定义
section .text   progbits alloc exec nowrite align=16
section .data   progbits alloc noexec write align=8
section .bss    nobits alloc noexec write align=8
section .rodata progbits alloc noexec nowrite align=8

; 自定义节
section .mydata progbits alloc noexec write align=4

; 节属性
; progbits - 包含数据
; nobits   - 不包含数据（BSS）
; alloc    - 运行时分配内存
; exec     - 可执行
; write    - 可写
; noexec   - 不可执行
; nowrite  - 不可写
```

### MASM段指令

```asm
; 简化段指令
.code               ; 代码段
.data               ; 初始化数据段
.data?              ; 未初始化数据段
.const              ; 常量数据段
.stack 4096         ; 栈段（指定大小）

; 完整段指令
_TEXT SEGMENT PARA PUBLIC 'CODE'
    ; 代码
_TEXT ENDS

_DATA SEGMENT PARA PUBLIC 'DATA'
    ; 数据
_DATA ENDS

; 段组
DGROUP GROUP _DATA, _BSS

; 假设段寄存器
ASSUME CS:_TEXT, DS:DGROUP
```

### 对齐指令

**NASM对齐**：
```nasm
section .data
    db 1
    align 4             ; 对齐到4字节边界
    dd 0x12345678
    
    align 16            ; 对齐到16字节边界
    dq 0, 0             ; SSE对齐数据
    
section .bss
    resb 1
    alignb 8            ; BSS节对齐
    resq 1

section .text
    ; 代码对齐
    align 16            ; 对齐循环入口
loop_start:
    ; 循环体
```

**MASM对齐**：
```asm
.data
    BYTE 1
    ALIGN 4             ; 对齐到4字节边界
    DWORD 12345678h
    
    ALIGN 16            ; 对齐到16字节边界
    QWORD 0, 0          ; SSE对齐数据

.code
    ALIGN 16            ; 对齐代码
loop_start:
    ; 循环体
```

---

## 宏系统

### NASM宏

**单行宏**：
```nasm
; 定义单行宏
%define BUFFER_SIZE 1024
%define SYSCALL_WRITE 1
%define STDOUT 1

; 带参数的宏
%define multiply(a, b) ((a) * (b))
%define square(x) multiply(x, x)

; 使用宏
mov rcx, BUFFER_SIZE
mov rax, square(5)          ; 展开为 ((5) * (5))
```

**多行宏**：
```nasm
; 基本多行宏
%macro push_all 0
    push rax
    push rbx
    push rcx
    push rdx
%endmacro

%macro pop_all 0
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro

; 带参数的宏
%macro prologue 1
    push rbp
    mov rbp, rsp
    sub rsp, %1         ; %1 是第一个参数
%endmacro

%macro epilogue 0
    mov rsp, rbp
    pop rbp
    ret
%endmacro

; 使用宏
my_function:
    prologue 32         ; 分配32字节局部空间
    push_all
    ; 函数体
    pop_all
    epilogue

; 可变参数宏
%macro print_values 1-*
    %rep %0             ; %0 是参数数量
        push %1
        %rotate 1
    %endrep
%endmacro

; 带默认参数的宏
%macro alloc_stack 0-1 0
    %if %1 > 0
        sub rsp, %1
    %endif
%endmacro

; 局部标签宏
%macro safe_div 0
    test rbx, rbx
    jz %%skip           ; %% 创建局部标签
    xor rdx, rdx
    div rbx
%%skip:
%endmacro
```

**条件宏**：
```nasm
; 条件编译
%ifdef DEBUG
    %define LOG(msg) call debug_log
%else
    %define LOG(msg)
%endif

; 条件汇编
%if BITS == 64
    mov rax, [rbx]
%else
    mov eax, [ebx]
%endif

; 检查宏是否定义
%ifndef BUFFER_SIZE
    %define BUFFER_SIZE 1024
%endif

; 复杂条件
%if (VERSION >= 2) && (PLATFORM == 'linux')
    ; Linux特定代码
%elif PLATFORM == 'windows'
    ; Windows特定代码
%else
    %error "Unsupported platform"
%endif
```

### MASM宏

**基本宏**：
```asm
; 定义宏
push_all MACRO
    push rax
    push rbx
    push rcx
    push rdx
ENDM

pop_all MACRO
    pop rdx
    pop rcx
    pop rbx
    pop rax
ENDM

; 带参数的宏
prologue MACRO localsize
    push rbp
    mov rbp, rsp
    sub rsp, localsize
ENDM

epilogue MACRO
    mov rsp, rbp
    pop rbp
    ret
ENDM

; 使用宏
my_function PROC
    prologue 32
    push_all
    ; 函数体
    pop_all
    epilogue
my_function ENDP
```

**MASM高级宏**：
```asm
; 可变参数宏
print_values MACRO args:VARARG
    FOR arg, <args>
        push arg
    ENDM
ENDM

; 条件宏
DEBUG_LOG MACRO msg
    IFDEF DEBUG
        lea rcx, msg
        call debug_print
    ENDIF
ENDM

; 重复宏
REPEAT_NOP MACRO count
    REPEAT count
        nop
    ENDM
ENDM

; 宏函数（返回值）
ALIGN_UP MACRO value, alignment
    EXITM <((value + alignment - 1) AND NOT (alignment - 1))>
ENDM

; 使用宏函数
buffer_size = ALIGN_UP(100, 16)     ; = 112

; 局部标签
safe_div MACRO
    LOCAL skip
    test rbx, rbx
    jz skip
    xor rdx, rdx
    div rbx
skip:
ENDM
```

---

## 预处理指令

### NASM预处理器

```nasm
; 文件包含
%include "macros.inc"
%include "constants.inc"

; 条件编译
%ifdef DEBUG
    ; 调试代码
%endif

%ifndef RELEASE
    ; 非发布代码
%endif

%if VERSION >= 2
    ; 版本2+代码
%elif VERSION == 1
    ; 版本1代码
%else
    %error "Unknown version"
%endif

; 错误和警告
%error "This is an error"
%warning "This is a warning"
%fatal "This is a fatal error"

; 行号和文件
%line 100 "myfile.asm"

; 上下文栈
%push mycontext
%define %$localvar 100
%pop

; 字符串操作
%strlen len "Hello"         ; len = 5
%substr char "Hello" 1      ; char = 'H'

; 标记粘贴
%define CONCAT(a, b) a %+ b
CONCAT(my, var) dq 0        ; 定义 myvar

; 重复块
%rep 10
    nop
%endrep

; 赋值
%assign counter 0
%rep 5
    db counter
    %assign counter counter+1
%endrep
```

### MASM预处理器

```asm
; 文件包含
INCLUDE macros.inc
INCLUDE constants.inc

; 条件编译
IFDEF DEBUG
    ; 调试代码
ENDIF

IFNDEF RELEASE
    ; 非发布代码
ENDIF

IF VERSION GE 2
    ; 版本2+代码
ELSEIF VERSION EQ 1
    ; 版本1代码
ELSE
    .ERR <Unknown version>
ENDIF

; 错误
.ERR                        ; 无条件错误
.ERRNZ expression           ; 表达式非零时错误
.ERRE expression            ; 表达式为零时错误
.ERRDEF symbol              ; 符号已定义时错误
.ERRNDEF symbol             ; 符号未定义时错误

; 显示消息
ECHO This is a message
%OUT This is also a message

; 重复块
REPEAT 10
    nop
ENDM

; FOR循环
FOR reg, <rax, rbx, rcx, rdx>
    push reg
ENDM

; WHILE循环
counter = 0
WHILE counter LT 5
    DB counter
    counter = counter + 1
ENDM
```

---

## 代码示例

### 示例1：Hello World（Linux x64）

**NASM版本**：
```nasm
; hello.asm - NASM Linux x64
section .data
    message db "Hello, World!", 10
    msg_len equ $ - message

section .text
    global _start

_start:
    ; sys_write(stdout, message, msg_len)
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd: stdout
    mov rsi, message        ; buffer
    mov rdx, msg_len        ; count
    syscall
    
    ; sys_exit(0)
    mov rax, 60             ; syscall: exit
    xor rdi, rdi            ; status: 0
    syscall
```

### 示例2：Hello World（Windows x64）

**MASM版本**：
```asm
; hello.asm - MASM Windows x64
EXTRN GetStdHandle:PROC
EXTRN WriteConsoleA:PROC
EXTRN ExitProcess:PROC

.data
    message BYTE "Hello, World!", 13, 10
    msg_len = $ - message
    written DWORD ?

.code
main PROC
    sub rsp, 40             ; Shadow space + alignment
    
    ; GetStdHandle(STD_OUTPUT_HANDLE)
    mov rcx, -11            ; STD_OUTPUT_HANDLE
    call GetStdHandle
    
    ; WriteConsoleA(handle, message, len, &written, NULL)
    mov rcx, rax            ; handle
    lea rdx, message        ; buffer
    mov r8d, msg_len        ; length
    lea r9, written         ; bytes written
    mov QWORD PTR [rsp+32], 0  ; reserved
    call WriteConsoleA
    
    ; ExitProcess(0)
    xor rcx, rcx
    call ExitProcess
main ENDP
END
```

### 示例3：函数调用（System V ABI）

```nasm
; function.asm - NASM Linux x64
section .text
    global add_numbers
    global call_example

; int64_t add_numbers(int64_t a, int64_t b)
; 参数: rdi=a, rsi=b
; 返回: rax
add_numbers:
    mov rax, rdi
    add rax, rsi
    ret

; 调用示例
call_example:
    push rbp
    mov rbp, rsp
    
    ; 调用 add_numbers(10, 20)
    mov rdi, 10             ; 第一个参数
    mov rsi, 20             ; 第二个参数
    call add_numbers
    ; 结果在 rax 中
    
    pop rbp
    ret
```

### 示例4：函数调用（Microsoft x64 ABI）

```asm
; function.asm - MASM Windows x64
.code

; int64_t add_numbers(int64_t a, int64_t b)
; 参数: rcx=a, rdx=b
; 返回: rax
add_numbers PROC
    mov rax, rcx
    add rax, rdx
    ret
add_numbers ENDP

; 调用示例
call_example PROC
    push rbp
    mov rbp, rsp
    sub rsp, 32             ; Shadow space
    
    ; 调用 add_numbers(10, 20)
    mov rcx, 10             ; 第一个参数
    mov rdx, 20             ; 第二个参数
    call add_numbers
    ; 结果在 rax 中
    
    add rsp, 32
    pop rbp
    ret
call_example ENDP
END
```

### 示例5：数组操作

```nasm
; array.asm - NASM
section .data
    array dq 10, 20, 30, 40, 50
    array_len equ ($ - array) / 8

section .text
    global sum_array

; int64_t sum_array(int64_t* arr, size_t len)
sum_array:
    xor rax, rax            ; sum = 0
    test rsi, rsi           ; if len == 0
    jz .done
    
.loop:
    add rax, [rdi]          ; sum += *arr
    add rdi, 8              ; arr++
    dec rsi                 ; len--
    jnz .loop
    
.done:
    ret
```

### 示例6：字符串操作

```nasm
; string.asm - NASM
section .text
    global strlen
    global strcpy

; size_t strlen(const char* str)
strlen:
    xor rax, rax            ; len = 0
    
.loop:
    cmp BYTE [rdi + rax], 0 ; if str[len] == 0
    je .done
    inc rax                 ; len++
    jmp .loop
    
.done:
    ret

; char* strcpy(char* dst, const char* src)
strcpy:
    mov rax, rdi            ; 保存dst作为返回值
    
.loop:
    mov cl, [rsi]           ; cl = *src
    mov [rdi], cl           ; *dst = cl
    test cl, cl             ; if cl == 0
    jz .done
    inc rsi                 ; src++
    inc rdi                 ; dst++
    jmp .loop
    
.done:
    ret
```

### 示例7：SIMD向量操作

```nasm
; simd.asm - NASM AVX
section .text
    global add_vectors_avx

; void add_vectors_avx(float* a, float* b, float* result, size_t count)
; 参数: rdi=a, rsi=b, rdx=result, rcx=count
add_vectors_avx:
    ; 处理8个float一组（256位）
    shr rcx, 3              ; count /= 8
    jz .remainder
    
.loop8:
    vmovups ymm0, [rdi]     ; 加载8个float
    vmovups ymm1, [rsi]
    vaddps ymm0, ymm0, ymm1 ; 向量加法
    vmovups [rdx], ymm0     ; 存储结果
    
    add rdi, 32
    add rsi, 32
    add rdx, 32
    dec rcx
    jnz .loop8
    
.remainder:
    ; 处理剩余元素（简化版，省略）
    vzeroupper              ; 清除YMM高位
    ret
```

### 示例8：原子操作

```nasm
; atomic.asm - NASM
section .text
    global atomic_add
    global atomic_cmpxchg
    global spinlock_acquire
    global spinlock_release

; int64_t atomic_add(int64_t* ptr, int64_t value)
; 返回旧值
atomic_add:
    mov rax, rsi
    lock xadd [rdi], rax
    ret

; bool atomic_cmpxchg(int64_t* ptr, int64_t expected, int64_t desired)
; 返回是否成功
atomic_cmpxchg:
    mov rax, rsi            ; expected
    lock cmpxchg [rdi], rdx ; compare and exchange
    sete al                 ; 设置返回值
    movzx eax, al
    ret

; void spinlock_acquire(int64_t* lock)
spinlock_acquire:
    mov rax, 1
.spin:
    xor rcx, rcx
    lock cmpxchg [rdi], rax ; 尝试获取锁
    jnz .spin               ; 如果失败，重试
    ret

; void spinlock_release(int64_t* lock)
spinlock_release:
    mov QWORD [rdi], 0      ; 释放锁
    ret
```

### 示例9：栈帧和局部变量

```nasm
; stack.asm - NASM
section .text
    global complex_function

; 演示完整的栈帧管理
complex_function:
    ; 函数序言
    push rbp
    mov rbp, rsp
    sub rsp, 48             ; 分配局部变量空间
    
    ; 保存被调用者保存寄存器
    push rbx
    push r12
    push r13
    
    ; 局部变量布局:
    ; [rbp-8]  : local1 (8字节)
    ; [rbp-16] : local2 (8字节)
    ; [rbp-24] : local3 (8字节)
    ; [rbp-32] : local4 (8字节)
    ; [rbp-40] : local5 (8字节)
    ; [rbp-48] : local6 (8字节)
    
    ; 初始化局部变量
    mov QWORD [rbp-8], 0
    mov QWORD [rbp-16], 0
    
    ; 使用局部变量
    mov rax, [rbp-8]
    add rax, [rbp-16]
    mov [rbp-24], rax
    
    ; 恢复被调用者保存寄存器
    pop r13
    pop r12
    pop rbx
    
    ; 函数尾声
    mov rsp, rbp
    pop rbp
    ret
```

### 示例10：条件执行和分支

```nasm
; branch.asm - NASM
section .text
    global max
    global abs_value
    global clamp

; int64_t max(int64_t a, int64_t b)
max:
    mov rax, rdi
    cmp rdi, rsi
    cmovl rax, rsi          ; 如果a < b，rax = b
    ret

; int64_t abs_value(int64_t x)
abs_value:
    mov rax, rdi
    neg rdi                 ; rdi = -x
    cmovs rax, rdi          ; 如果原值为负，使用取反后的值
    ret

; int64_t clamp(int64_t value, int64_t min, int64_t max)
clamp:
    mov rax, rdi            ; rax = value
    cmp rax, rsi
    cmovl rax, rsi          ; if value < min, rax = min
    cmp rax, rdx
    cmovg rax, rdx          ; if value > max, rax = max
    ret
```

---

## 常见模式与最佳实践

### 函数序言和尾声

**标准序言**：
```nasm
function_name:
    push rbp                ; 保存旧帧指针
    mov rbp, rsp            ; 建立新帧
    sub rsp, N              ; 分配局部变量（N需16字节对齐）
    
    ; 保存被调用者保存寄存器（如需要）
    push rbx
    push r12
    ; ...
```

**标准尾声**：
```nasm
    ; 恢复被调用者保存寄存器
    ; ...
    pop r12
    pop rbx
    
    mov rsp, rbp            ; 释放局部变量
    pop rbp                 ; 恢复旧帧指针
    ret

; 或使用leave指令
    leave                   ; 等价于 mov rsp, rbp; pop rbp
    ret
```

**无帧指针优化**：
```nasm
; 对于简单函数，可以省略帧指针
simple_function:
    sub rsp, 8              ; 保持16字节对齐
    ; 函数体（使用rsp相对寻址）
    add rsp, 8
    ret
```

### 循环优化

**基本循环**：
```nasm
; 计数循环
    mov rcx, count
.loop:
    ; 循环体
    dec rcx
    jnz .loop
```

**循环展开**：
```nasm
; 4倍展开
    mov rcx, count
    shr rcx, 2              ; count / 4
    jz .remainder
    
.loop4:
    ; 处理4个元素
    mov rax, [rsi]
    mov [rdi], rax
    mov rax, [rsi+8]
    mov [rdi+8], rax
    mov rax, [rsi+16]
    mov [rdi+16], rax
    mov rax, [rsi+24]
    mov [rdi+24], rax
    
    add rsi, 32
    add rdi, 32
    dec rcx
    jnz .loop4
    
.remainder:
    ; 处理剩余元素
    mov rcx, count
    and rcx, 3              ; count % 4
    jz .done
    
.loop1:
    mov rax, [rsi]
    mov [rdi], rax
    add rsi, 8
    add rdi, 8
    dec rcx
    jnz .loop1
    
.done:
    ret
```

**对齐循环入口**：
```nasm
    align 16                ; 对齐到16字节边界
.hot_loop:
    ; 性能关键循环
    ; ...
    jnz .hot_loop
```

### 内存访问优化

**预取数据**：
```nasm
    ; 预取下一个缓存行
    prefetcht0 [rsi + 64]
    
    ; 处理当前数据
    mov rax, [rsi]
    ; ...
```

**避免缓存行分裂**：
```nasm
section .data
    align 64                ; 对齐到缓存行边界
    hot_data times 64 db 0
```

**使用非临时存储**：
```nasm
    ; 对于不会很快再次访问的数据
    movntdq [rdi], xmm0     ; 非临时存储，绕过缓存
    sfence                  ; 确保存储完成
```

### 分支预测友好

**将常见情况放在前面**：
```nasm
    test rax, rax
    jz .rare_case           ; 罕见情况跳转
    
    ; 常见情况代码（顺序执行）
    ; ...
    ret
    
.rare_case:
    ; 罕见情况处理
    ; ...
    ret
```

**使用条件移动代替分支**：
```nasm
    ; 不好：分支可能预测失败
    cmp rax, rbx
    jl .less
    mov rcx, rax
    jmp .done
.less:
    mov rcx, rbx
.done:

    ; 好：无分支
    cmp rax, rbx
    mov rcx, rax
    cmovl rcx, rbx          ; 条件移动
```

### 调试技巧

**插入断点**：
```nasm
    int3                    ; 软件断点
    ; 或
    db 0xCC                 ; INT3的机器码
```

**保留调试信息**：
```nasm
; 使用有意义的标签名
.check_bounds:
    cmp rax, rbx
    jae .bounds_error
    
.process_element:
    ; ...
    
.bounds_error:
    ; 错误处理
```

**添加注释**：
```nasm
; 函数: calculate_hash
; 参数: rdi = 数据指针, rsi = 数据长度
; 返回: rax = 哈希值
; 修改: rcx, rdx
calculate_hash:
    ; 初始化哈希值
    mov rax, 0x811c9dc5     ; FNV-1a初始值
    ; ...
```

---

## 工具与资源

### 汇编和链接

**NASM**：
```bash
# 汇编为目标文件
nasm -f elf64 -o output.o input.asm      # Linux
nasm -f win64 -o output.obj input.asm    # Windows
nasm -f macho64 -o output.o input.asm    # macOS

# 带调试信息
nasm -f elf64 -g -F dwarf -o output.o input.asm

# 生成列表文件
nasm -f elf64 -l output.lst input.asm

# 预处理
nasm -E input.asm > preprocessed.asm
```

**MASM (ml64)**：
```batch
REM 汇编为目标文件
ml64 /c /Fo output.obj input.asm

REM 带调试信息
ml64 /c /Zi /Fo output.obj input.asm

REM 生成列表文件
ml64 /c /Fl output.lst input.asm

REM 汇编并链接
ml64 /c input.asm
link /subsystem:console /entry:main output.obj kernel32.lib
```

**链接**：
```bash
# Linux (ld)
ld -o program output.o

# Linux (gcc)
gcc -no-pie -o program output.o

# macOS
ld -macosx_version_min 10.13 -o program output.o -lSystem

# Windows (link)
link /subsystem:console /entry:main output.obj kernel32.lib user32.lib
```

### 反汇编和分析

**objdump**：
```bash
# 反汇编（Intel语法）
objdump -d -M intel program

# 显示所有节
objdump -h program

# 显示符号表
objdump -t program

# 显示重定位信息
objdump -r program.o
```

**ndisasm（NASM自带）**：
```bash
# 反汇编二进制文件
ndisasm -b 64 program.bin

# 指定起始地址
ndisasm -b 64 -o 0x400000 program.bin
```

**dumpbin（Windows）**：
```batch
REM 反汇编
dumpbin /disasm program.exe

REM 显示头信息
dumpbin /headers program.exe

REM 显示导出
dumpbin /exports program.dll

REM 显示导入
dumpbin /imports program.exe
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

# 设置Intel语法
(gdb) set disassembly-flavor intel
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

# 设置Intel语法
(lldb) settings set target.x86-disassembly-flavor intel
```

**WinDbg（Windows）**：
```
# 常用命令
bp main                    ; 设置断点
g                          ; 运行
t                          ; 单步执行
p                          ; 单步执行（跳过调用）
r                          ; 显示寄存器
u rip                      ; 反汇编
dq rsp                     ; 显示栈
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

**VTune（Intel）**：
```bash
# 收集热点数据
vtune -collect hotspots ./program

# 查看报告
vtune -report hotspots -r r000hs
```

---

## 参考资料

### 官方文档

- [Intel® 64 and IA-32 Architectures Software Developer Manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html) - Intel官方手册
- [NASM Manual](https://www.nasm.us/doc/) - NASM官方文档
- [MASM Reference](https://docs.microsoft.com/en-us/cpp/assembler/masm/masm-for-x64-ml64-exe) - Microsoft MASM文档
- [YASM Manual](http://yasm.tortall.net/Guide.html) - YASM用户指南

### 教程和指南

- [x86 Assembly Guide](https://www.cs.virginia.edu/~evans/cs216/guides/x86.html) - 弗吉尼亚大学x86汇编指南
- [x86-64 Assembly Language Programming with Ubuntu](http://www.egr.unlv.edu/~ed/assembly64.pdf) - 内华达大学汇编教程
- [Introduction to x64 Assembly](https://software.intel.com/content/www/us/en/develop/articles/introduction-to-x64-assembly.html) - Intel x64汇编入门

### 在线资源

- [Godbolt Compiler Explorer](https://godbolt.org/) - 在线编译器和反汇编器
- [x86 and amd64 Instruction Reference](https://www.felixcloutier.com/x86/) - x86指令参考
- [Agner Fog's Optimization Manuals](https://www.agner.org/optimize/) - 优化手册
- [uops.info](https://uops.info/) - 指令延迟和吞吐量数据库

### 书籍推荐

- *Assembly Language for x86 Processors* by Kip Irvine
- *Professional Assembly Language* by Richard Blum
- *The Art of Assembly Language* by Randall Hyde
- *Modern X86 Assembly Language Programming* by Daniel Kusswurm

---

## 附录：快速参考卡

### 常用指令速查

| 操作 | 指令 | 示例 |
|------|------|------|
| 移动 | MOV | `mov rax, rbx` |
| 加法 | ADD | `add rax, 1` |
| 减法 | SUB | `sub rax, rbx` |
| 乘法 | IMUL | `imul rax, rbx` |
| 除法 | IDIV | `idiv rbx` |
| 比较 | CMP | `cmp rax, rbx` |
| 测试 | TEST | `test rax, rax` |
| 跳转 | JMP | `jmp label` |
| 条件跳转 | Jcc | `je label` |
| 调用 | CALL | `call function` |
| 返回 | RET | `ret` |
| 压栈 | PUSH | `push rax` |
| 出栈 | POP | `pop rax` |
| 取地址 | LEA | `lea rax, [rbx+8]` |
| 异或 | XOR | `xor rax, rax` |
| 与 | AND | `and rax, 0xFF` |
| 或 | OR | `or rax, 1` |
| 非 | NOT | `not rax` |
| 左移 | SHL | `shl rax, 2` |
| 右移 | SHR | `shr rax, 2` |
| 算术右移 | SAR | `sar rax, 2` |

### 条件跳转速查

| 指令 | 条件 | 说明 |
|------|------|------|
| JE/JZ | ZF=1 | 相等/零 |
| JNE/JNZ | ZF=0 | 不相等/非零 |
| JL/JNGE | SF≠OF | 小于（有符号） |
| JLE/JNG | ZF=1 或 SF≠OF | 小于等于（有符号） |
| JG/JNLE | ZF=0 且 SF=OF | 大于（有符号） |
| JGE/JNL | SF=OF | 大于等于（有符号） |
| JB/JNAE/JC | CF=1 | 低于（无符号）/进位 |
| JBE/JNA | CF=1 或 ZF=1 | 低于等于（无符号） |
| JA/JNBE | CF=0 且 ZF=0 | 高于（无符号） |
| JAE/JNB/JNC | CF=0 | 高于等于（无符号）/无进位 |
| JS | SF=1 | 负数 |
| JNS | SF=0 | 非负数 |
| JO | OF=1 | 溢出 |
| JNO | OF=0 | 无溢出 |

### 寻址模式速查

| 模式 | 语法 | 示例 |
|------|------|------|
| 立即数 | `imm` | `mov rax, 42` |
| 寄存器 | `reg` | `mov rax, rbx` |
| 直接 | `[addr]` | `mov rax, [0x1000]` |
| 间接 | `[reg]` | `mov rax, [rbx]` |
| 基址+偏移 | `[reg+disp]` | `mov rax, [rbx+8]` |
| 基址+索引 | `[reg+reg]` | `mov rax, [rbx+rcx]` |
| 比例索引 | `[reg+reg*s]` | `mov rax, [rbx+rcx*8]` |
| 完整 | `[reg+reg*s+disp]` | `mov rax, [rbx+rcx*8+16]` |
| RIP相对 | `[rel sym]` | `mov rax, [rel myvar]` |

### NASM vs MASM 速查

| 特性 | NASM | MASM |
|------|------|------|
| 代码段 | `section .text` | `.code` |
| 数据段 | `section .data` | `.data` |
| BSS段 | `section .bss` | `.data?` |
| 全局 | `global sym` | `PUBLIC sym` |
| 外部 | `extern sym` | `EXTERN sym:type` |
| 字节 | `db` | `BYTE` |
| 字 | `dw` | `WORD` |
| 双字 | `dd` | `DWORD` |
| 四字 | `dq` | `QWORD` |
| 保留字节 | `resb N` | `BYTE N DUP(?)` |
| 大小指定 | `QWORD [addr]` | `QWORD PTR [addr]` |
| 偏移 | `symbol` | `OFFSET symbol` |
| 过程 | `label:` | `label PROC` |
| 宏 | `%macro` | `MACRO` |
| 常量 | `equ` | `EQU` |
| 包含 | `%include` | `INCLUDE` |

---

*上一节: [Go Plan9 汇编详解](go-plan9.md)*
*下一节: [AT&T 汇编详解](att.md)*
