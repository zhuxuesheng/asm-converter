# Windows 调用约定详解

> Windows x64调用约定完整规范，包含Shadow Space、SEH异常处理和系统调用

## 概述

Windows x64使用Microsoft x64调用约定，与System V AMD64 ABI有显著差异。

---

## 用户态调用约定

### 核心特性

| 特性 | 规范 |
|------|------|
| 整数参数 | RCX, RDX, R8, R9 |
| 浮点参数 | XMM0, XMM1, XMM2, XMM3 |
| 返回值 | RAX (整数), XMM0 (浮点) |
| 栈对齐 | 16字节 |
| Shadow Space | 32字节（必需） |
| Red Zone | 无 |

### 参数传递

```
参数寄存器分配:
┌─────────────────────────────────────────────────────────────────────────────┐
│  参数位置  │  整数/指针  │  浮点  │  说明                                   │
├────────────┼─────────────┼────────┼─────────────────────────────────────────┤
│  第1个     │  RCX        │  XMM0  │  同一位置只用一个                       │
│  第2个     │  RDX        │  XMM1  │                                         │
│  第3个     │  R8         │  XMM2  │                                         │
│  第4个     │  R9         │  XMM3  │                                         │
│  第5个+    │  栈         │  栈    │  [RSP+40], [RSP+48], ...                │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Shadow Space

调用者必须在栈上分配32字节的Shadow Space：

```
栈布局（调用前）:
高地址
┌─────────────────────────────────────────┐
│           调用者栈帧                    │
├─────────────────────────────────────────┤
│  [RSP+32] 参数5（如果有）               │
├─────────────────────────────────────────┤
│  Shadow Space (32字节)                  │
│  [RSP+24] 参数4位置 (R9)                │
│  [RSP+16] 参数3位置 (R8)                │
│  [RSP+8]  参数2位置 (RDX)               │
│  [RSP+0]  参数1位置 (RCX)               │  ← 调用前RSP
└─────────────────────────────────────────┘

栈布局（调用后）:
高地址
┌─────────────────────────────────────────┐
│  Shadow Space                           │
│  [RSP+32] 参数4位置                     │
│  [RSP+24] 参数3位置                     │
│  [RSP+16] 参数2位置                     │
│  [RSP+8]  参数1位置                     │
├─────────────────────────────────────────┤
│  返回地址                               │  [RSP+0]
└─────────────────────────────────────────┘ ← 被调用函数RSP
低地址
```


### Shadow Space用途

1. **调试支持**：调试器可以在Shadow Space中查看参数
2. **可变参数函数**：被调用函数可以将寄存器参数保存到Shadow Space
3. **寄存器溢出**：被调用函数可以使用Shadow Space保存寄存器

```asm
# 被调用函数使用Shadow Space
my_function:
    mov     [rsp+8], rcx        # 保存参数1到Shadow Space
    mov     [rsp+16], rdx       # 保存参数2
    mov     [rsp+24], r8        # 保存参数3
    mov     [rsp+32], r9        # 保存参数4
    # ...
    ret
```

---

## 寄存器保存规则

### Volatile（调用者保存）

| 寄存器 | 说明 |
|--------|------|
| RAX | 返回值 |
| RCX | 参数1 |
| RDX | 参数2 |
| R8 | 参数3 |
| R9 | 参数4 |
| R10, R11 | 临时寄存器 |
| XMM0-XMM5 | 浮点参数/返回值/临时 |

### Non-volatile（被调用者保存）

| 寄存器 | 说明 |
|--------|------|
| RBX | 通用 |
| RBP | 帧指针（可选） |
| RDI | 通用（与Linux不同！） |
| RSI | 通用（与Linux不同！） |
| R12-R15 | 通用 |
| XMM6-XMM15 | 浮点（与Linux不同！） |

> **重要**: Windows要求保存XMM6-XMM15，而Linux不需要。

---

## SEH异常处理

### 结构化异常处理

Windows使用SEH（Structured Exception Handling）进行异常处理，需要特殊的栈展开信息。

### UNWIND_INFO结构

```c
typedef struct _UNWIND_INFO {
    UBYTE Version : 3;
    UBYTE Flags : 5;
    UBYTE SizeOfProlog;
    UBYTE CountOfCodes;
    UBYTE FrameRegister : 4;
    UBYTE FrameOffset : 4;
    UNWIND_CODE UnwindCode[1];
} UNWIND_INFO;
```

### 函数序言要求

为支持SEH，函数序言必须遵循特定格式：

```asm
; 标准Windows x64函数序言
my_function PROC FRAME
    push    rbp                 ; 保存帧指针
    .pushreg rbp
    
    sub     rsp, 32             ; 分配栈空间
    .allocstack 32
    
    lea     rbp, [rsp+32]       ; 设置帧指针
    .setframe rbp, 32
    
    .endprolog
    
    ; 函数体...
    
    add     rsp, 32
    pop     rbp
    ret
my_function ENDP
```

### MASM伪指令

| 伪指令 | 说明 |
|--------|------|
| `.pushreg reg` | 记录寄存器压栈 |
| `.allocstack size` | 记录栈分配 |
| `.setframe reg, offset` | 设置帧寄存器 |
| `.savereg reg, offset` | 记录寄存器保存到栈 |
| `.savexmm128 reg, offset` | 记录XMM寄存器保存 |
| `.endprolog` | 标记序言结束 |

---

## 系统调用

### Windows系统调用机制

Windows不鼓励直接使用syscall，应通过ntdll.dll调用：

```asm
; 不推荐：直接syscall
mov     r10, rcx                ; Windows syscall使用R10而非RCX
mov     eax, <syscall_number>   ; 系统调用号（版本相关！）
syscall
```

### 通过ntdll调用

```asm
; 推荐：通过ntdll.dll
extern NtWriteFile: PROC

    sub     rsp, 88             ; 分配栈空间（含Shadow Space）
    
    mov     rcx, handle         ; 参数1: 文件句柄
    xor     rdx, rdx            ; 参数2: Event
    xor     r8, r8              ; 参数3: ApcRoutine
    xor     r9, r9              ; 参数4: ApcContext
    ; 栈参数...
    mov     qword ptr [rsp+40], offset io_status
    mov     qword ptr [rsp+48], offset buffer
    mov     qword ptr [rsp+56], buffer_length
    mov     qword ptr [rsp+64], 0
    mov     qword ptr [rsp+72], 0
    
    call    NtWriteFile
    
    add     rsp, 88
```

### 系统调用号不稳定性

| Windows版本 | NtWriteFile号 |
|-------------|---------------|
| Windows 7 | 0x0005 |
| Windows 10 1803 | 0x0008 |
| Windows 10 1903 | 0x0008 |
| Windows 11 | 可能不同 |

> **警告**: 直接使用syscall会导致程序在不同Windows版本间不兼容。


---

## 代码示例

### 基本函数调用

```asm
; NASM语法 - Windows x64
section .text
global my_add

; int my_add(int a, int b)
; 参数: RCX=a, RDX=b
; 返回: RAX
my_add:
    lea     rax, [rcx + rdx]    ; RAX = a + b
    ret

; 调用示例
caller:
    sub     rsp, 40             ; 32字节Shadow Space + 8字节对齐
    
    mov     ecx, 10             ; 参数1
    mov     edx, 20             ; 参数2
    call    my_add
    
    ; 结果在RAX中
    
    add     rsp, 40
    ret
```

### 调用Windows API

```asm
; 调用MessageBoxA
section .data
    title   db "Title", 0
    message db "Hello, World!", 0

section .text
extern MessageBoxA

global main
main:
    sub     rsp, 40             ; Shadow Space + 对齐
    
    xor     rcx, rcx            ; hWnd = NULL
    lea     rdx, [rel message]  ; lpText
    lea     r8, [rel title]     ; lpCaption
    xor     r9d, r9d            ; uType = MB_OK
    call    MessageBoxA
    
    add     rsp, 40
    xor     eax, eax            ; 返回0
    ret
```

### 保存Non-volatile寄存器

```asm
; 使用Non-volatile寄存器的函数
complex_function:
    push    rbx                 ; 保存Non-volatile寄存器
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 32             ; Shadow Space
    
    ; 现在可以使用RBX, RSI, RDI, R12
    mov     rbx, rcx            ; 保存参数1
    mov     rsi, rdx            ; 保存参数2
    
    ; 函数体...
    
    add     rsp, 32
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    ret
```

### 保存XMM寄存器

```asm
; 保存XMM6-XMM15（Windows要求）
sse_function:
    sub     rsp, 168            ; 32 Shadow + 10*16 XMM保存区 - 8对齐
    
    movaps  [rsp+32], xmm6
    movaps  [rsp+48], xmm7
    movaps  [rsp+64], xmm8
    movaps  [rsp+80], xmm9
    movaps  [rsp+96], xmm10
    movaps  [rsp+112], xmm11
    movaps  [rsp+128], xmm12
    movaps  [rsp+144], xmm13
    ; xmm14, xmm15 如果需要也要保存
    
    ; 函数体...
    
    movaps  xmm6, [rsp+32]
    movaps  xmm7, [rsp+48]
    ; ... 恢复其他XMM寄存器
    
    add     rsp, 168
    ret
```

---

## 线程局部存储（TLS）

### GS段寄存器

Windows使用GS段寄存器访问线程环境块（TEB）：

```asm
; 访问TEB
mov     rax, gs:[0x30]          ; 获取TEB指针
mov     rax, gs:[0x60]          ; 获取PEB指针

; TLS槽位
mov     rax, gs:[0x58]          ; TLS数组指针
mov     rax, [rax + index*8]    ; 访问TLS槽位
```

### TEB重要偏移

| 偏移 | 内容 |
|------|------|
| 0x00 | SEH链 |
| 0x08 | 栈基址 |
| 0x10 | 栈限制 |
| 0x30 | TEB自身指针 |
| 0x40 | 进程ID |
| 0x48 | 线程ID |
| 0x58 | TLS数组 |
| 0x60 | PEB指针 |

---

## 参考资料

### 官方规范

- [Microsoft x64 Calling Convention](https://docs.microsoft.com/en-us/cpp/build/x64-calling-convention)
- [x64 Exception Handling](https://docs.microsoft.com/en-us/cpp/build/exception-handling-x64)

### 相关文档

- 参见: [Microsoft x64调用约定详解](../02-x86-x64/x64-microsoft.md)
- 参见: [操作系统差异概述](./overview.md)
- 参见: [Linux调用约定](./linux.md)
