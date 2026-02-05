# 操作系统调用约定对比表格

> Linux、Windows、macOS在x64架构上的调用约定完整对比

## 用户态调用约定对比

### 参数传递寄存器

| 参数位置 | Linux | Windows | macOS |
|----------|-------|---------|-------|
| 第1个整数 | RDI | RCX | RDI |
| 第2个整数 | RSI | RDX | RSI |
| 第3个整数 | RDX | R8 | RDX |
| 第4个整数 | RCX | R9 | RCX |
| 第5个整数 | R8 | 栈 | R8 |
| 第6个整数 | R9 | 栈 | R9 |
| 第7个+ | 栈 | 栈 | 栈 |

### 浮点参数寄存器

| 参数位置 | Linux | Windows | macOS |
|----------|-------|---------|-------|
| 第1个浮点 | XMM0 | XMM0 | XMM0 |
| 第2个浮点 | XMM1 | XMM1 | XMM1 |
| 第3个浮点 | XMM2 | XMM2 | XMM2 |
| 第4个浮点 | XMM3 | XMM3 | XMM3 |
| 第5个浮点 | XMM4 | 栈 | XMM4 |
| 第6个浮点 | XMM5 | 栈 | XMM5 |
| 第7个浮点 | XMM6 | 栈 | XMM6 |
| 第8个浮点 | XMM7 | 栈 | XMM7 |

### 返回值寄存器

| 返回类型 | Linux | Windows | macOS |
|----------|-------|---------|-------|
| 整数 ≤64位 | RAX | RAX | RAX |
| 整数 128位 | RAX:RDX | RAX | RAX:RDX |
| 浮点 | XMM0 | XMM0 | XMM0 |
| 浮点 128位 | XMM0:XMM1 | XMM0 | XMM0:XMM1 |


---

## 寄存器保存规则对比

### Volatile（调用者保存）

| 寄存器 | Linux | Windows | macOS |
|--------|:-----:|:-------:|:-----:|
| RAX | ✓ | ✓ | ✓ |
| RCX | ✓ | ✓ | ✓ |
| RDX | ✓ | ✓ | ✓ |
| RSI | ✓ | ✗ | ✓ |
| RDI | ✓ | ✗ | ✓ |
| R8 | ✓ | ✓ | ✓ |
| R9 | ✓ | ✓ | ✓ |
| R10 | ✓ | ✓ | ✓ |
| R11 | ✓ | ✓ | ✓ |
| XMM0-XMM5 | ✓ | ✓ | ✓ |
| XMM6-XMM15 | ✓ | ✗ | ✓ |

### Non-volatile（被调用者保存）

| 寄存器 | Linux | Windows | macOS |
|--------|:-----:|:-------:|:-----:|
| RBX | ✓ | ✓ | ✓ |
| RBP | ✓ | ✓ | ✓ |
| RSI | ✗ | ✓ | ✗ |
| RDI | ✗ | ✓ | ✗ |
| R12 | ✓ | ✓ | ✓ |
| R13 | ✓ | ✓ | ✓ |
| R14 | ✓ | ✓ | ✓ |
| R15 | ✓ | ✓ | ✓ |
| XMM6-XMM15 | ✗ | ✓ | ✗ |

---

## 栈特性对比

| 特性 | Linux | Windows | macOS |
|------|-------|---------|-------|
| **栈对齐** | 16字节 | 16字节 | 16字节 |
| **栈增长方向** | 向下 | 向下 | 向下 |
| **栈清理责任** | 调用者 | 调用者 | 调用者 |
| **Shadow Space** | 无 | 32字节 | 无 |
| **Red Zone** | 128字节 | 无 | 128字节 |

### 栈布局对比

```
Linux/macOS 栈布局:                    Windows 栈布局:
高地址                                 高地址
┌─────────────────────┐                ┌─────────────────────┐
│    调用者栈帧       │                │    调用者栈帧       │
├─────────────────────┤                ├─────────────────────┤
│    栈参数           │                │    栈参数           │
├─────────────────────┤                ├─────────────────────┤
│    返回地址         │                │    Shadow Space     │
├─────────────────────┤ ← RSP          │    (32字节)         │
│                     │                ├─────────────────────┤
│    Red Zone         │                │    返回地址         │
│    (128字节)        │                ├─────────────────────┤ ← RSP
│                     │                │    (无Red Zone)     │
└─────────────────────┘                └─────────────────────┘
低地址                                 低地址
```

---

## 系统调用对比

### 系统调用机制

| 特性 | Linux | Windows | macOS |
|------|-------|---------|-------|
| **指令** | syscall | syscall | syscall |
| **调用号寄存器** | RAX | RAX | RAX |
| **调用号格式** | 直接 | 直接 | 前缀+号 |
| **参数1** | RDI | R10 | RDI |
| **参数2** | RSI | RDX | RSI |
| **参数3** | RDX | R8 | RDX |
| **参数4** | R10 | R9 | R10 |
| **参数5** | R8 | 栈 | R8 |
| **参数6** | R9 | 栈 | R9 |
| **返回值** | RAX | RAX | RAX |
| **错误指示** | RAX<0 | CF=1 | CF=1 |

### 常用系统调用号对比

| 功能 | Linux | macOS |
|------|-------|-------|
| exit | 60 | 0x2000001 |
| read | 0 | 0x2000003 |
| write | 1 | 0x2000004 |
| open | 2 | 0x2000005 |
| close | 3 | 0x2000006 |
| mmap | 9 | 0x20000C5 |
| munmap | 11 | 0x2000049 |
| fork | 57 | 0x2000002 |
| execve | 59 | 0x200003B |
| getpid | 39 | 0x2000014 |

> **注意**: Windows系统调用号在不同版本间不稳定，不建议直接使用。

---

## 线程局部存储对比

| 特性 | Linux | Windows | macOS |
|------|-------|---------|-------|
| **段寄存器** | FS | GS | GS |
| **TLS基址** | fs:[0] | gs:[0x58] | gs:[0] |
| **线程ID** | 系统调用 | gs:[0x48] | 系统调用 |

---

## 可执行格式对比

| 特性 | Linux | Windows | macOS |
|------|-------|---------|-------|
| **格式** | ELF | PE/COFF | Mach-O |
| **代码段** | .text | .text | __TEXT,__text |
| **数据段** | .data | .data | __DATA,__data |
| **只读数据** | .rodata | .rdata | __TEXT,__const |
| **BSS段** | .bss | .bss | __DATA,__bss |
| **符号前缀** | 无 | 无 | _ |
| **PIC要求** | 可选 | 可选 | 强制 |

---

## 代码示例对比

### Hello World

```asm
; === Linux ===
section .data
    msg db "Hello", 10
section .text
global _start
_start:
    mov rax, 1          ; write
    mov rdi, 1
    lea rsi, [rel msg]
    mov rdx, 6
    syscall
    mov rax, 60         ; exit
    xor rdi, rdi
    syscall

; === macOS ===
.section __DATA,__data
msg: .ascii "Hello\n"
.section __TEXT,__text
.globl _main
_main:
    mov rax, 0x2000004  ; write
    mov rdi, 1
    lea rsi, [rip + msg]
    mov rdx, 6
    syscall
    mov rax, 0x2000001  ; exit
    xor rdi, rdi
    syscall

; === Windows ===
section .data
    msg db "Hello", 13, 10
section .text
extern GetStdHandle
extern WriteConsoleA
extern ExitProcess
global main
main:
    sub rsp, 40
    mov rcx, -11        ; STD_OUTPUT_HANDLE
    call GetStdHandle
    mov rcx, rax
    lea rdx, [rel msg]
    mov r8, 7
    lea r9, [rsp+32]
    mov qword [rsp+32], 0
    call WriteConsoleA
    xor rcx, rcx
    call ExitProcess
```

---

## 参考资料

- 参见: [Linux调用约定](./linux.md)
- 参见: [Windows调用约定](./windows.md)
- 参见: [macOS调用约定](./macos.md)
- 参见: [操作系统差异概述](./overview.md)
