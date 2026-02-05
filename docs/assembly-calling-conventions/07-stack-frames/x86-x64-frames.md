# x86/x64 栈帧详解

> x86和x64架构栈帧结构完整规范，包含帧指针、局部变量布局和异常处理

## x86 栈帧

### 标准栈帧布局

```
高地址
┌─────────────────────────────────────────┐
│           调用者栈帧                    │
├─────────────────────────────────────────┤
│  参数N                                  │  [EBP+8+4*(N-1)]
│  ...                                    │
│  参数2                                  │  [EBP+12]
│  参数1                                  │  [EBP+8]
├─────────────────────────────────────────┤
│  返回地址                               │  [EBP+4]
├─────────────────────────────────────────┤ ← EBP
│  保存的EBP                              │  [EBP+0]
├─────────────────────────────────────────┤
│  局部变量1                              │  [EBP-4]
│  局部变量2                              │  [EBP-8]
│  ...                                    │
├─────────────────────────────────────────┤
│  保存的寄存器                           │
└─────────────────────────────────────────┘ ← ESP
低地址
```

### x86 函数序言/尾声

```asm
; 序言
my_function:
    push    ebp             ; 保存帧指针
    mov     ebp, esp        ; 设置新帧指针
    sub     esp, 16         ; 分配局部变量
    push    ebx             ; 保存callee-saved寄存器
    push    esi
    push    edi
    
    ; 函数体
    mov     eax, [ebp+8]    ; 访问参数1
    mov     [ebp-4], eax    ; 访问局部变量1
    
    ; 尾声
    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp        ; 或 leave
    pop     ebp
    ret
```

---

## x64 栈帧

### System V AMD64 栈帧

```
高地址
┌─────────────────────────────────────────┐
│           调用者栈帧                    │
├─────────────────────────────────────────┤
│  栈参数（第7个及以后）                  │
├─────────────────────────────────────────┤
│  返回地址                               │  [RBP+8]
├─────────────────────────────────────────┤ ← RBP (可选)
│  保存的RBP                              │  [RBP+0]
├─────────────────────────────────────────┤
│  局部变量                               │  [RBP-8], [RBP-16]...
├─────────────────────────────────────────┤
│  保存的寄存器                           │
├─────────────────────────────────────────┤
│  对齐填充（如需要）                     │
└─────────────────────────────────────────┘ ← RSP (16字节对齐)
│                                         │
│  Red Zone (128字节)                     │  ← 叶子函数可用
│                                         │
低地址
```


### Microsoft x64 栈帧

```
高地址
┌─────────────────────────────────────────┐
│           调用者栈帧                    │
├─────────────────────────────────────────┤
│  栈参数（第5个及以后）                  │  [RSP+40], [RSP+48]...
├─────────────────────────────────────────┤
│  Shadow Space (32字节)                  │
│  [RSP+24] 参数4位置                     │
│  [RSP+16] 参数3位置                     │
│  [RSP+8]  参数2位置                     │
│  [RSP+0]  参数1位置                     │  ← 调用前RSP
├─────────────────────────────────────────┤
│  返回地址                               │
├─────────────────────────────────────────┤ ← 被调用函数RSP
│  保存的RBP (可选)                       │
├─────────────────────────────────────────┤
│  局部变量                               │
├─────────────────────────────────────────┤
│  保存的Non-volatile寄存器               │
│  (RBX, RSI, RDI, R12-R15)              │
├─────────────────────────────────────────┤
│  保存的XMM寄存器                        │
│  (XMM6-XMM15, 各16字节)                │
└─────────────────────────────────────────┘ ← RSP (16字节对齐)
低地址
```

### x64 函数示例

```asm
; System V AMD64
my_function:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32             ; 局部变量
    
    ; 参数在 RDI, RSI, RDX, RCX, R8, R9
    mov     [rbp-8], rdi        ; 保存参数1
    
    ; 调用其他函数前确保16字节对齐
    call    other_function
    
    mov     rsp, rbp
    pop     rbp
    ret

; Microsoft x64
my_function_win:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 64             ; 局部变量 + Shadow Space
    
    ; 参数在 RCX, RDX, R8, R9
    mov     [rbp-8], rcx        ; 保存参数1
    
    ; 调用前分配Shadow Space
    mov     rcx, arg1
    mov     rdx, arg2
    call    other_function
    
    add     rsp, 64
    pop     rbp
    ret
```

---

## 局部变量布局

### 变量对齐

```
局部变量布局示例:
┌─────────────────────────────────────────┐
│  char c        (1字节)                  │  [RBP-1]
│  填充          (3字节)                  │  [RBP-4]
│  int i         (4字节)                  │  [RBP-8]
│  double d      (8字节)                  │  [RBP-16]
│  char arr[10]  (10字节)                 │  [RBP-26]
│  填充          (6字节)                  │  [RBP-32]
└─────────────────────────────────────────┘
```

### 数组和结构体

```c
struct Example {
    int a;          // 偏移 0
    char b;         // 偏移 4
    // 填充 3字节
    double c;       // 偏移 8
};  // 总大小 16字节
```

---

## 异常处理栈展开

### Windows SEH

Windows使用UNWIND_INFO结构记录栈展开信息：

```asm
; MASM语法
my_function PROC FRAME
    push    rbp
    .pushreg rbp
    
    sub     rsp, 32
    .allocstack 32
    
    lea     rbp, [rsp+32]
    .setframe rbp, 32
    
    .endprolog
    
    ; 函数体...
    
    add     rsp, 32
    pop     rbp
    ret
my_function ENDP
```

### DWARF (Linux/macOS)

Linux使用DWARF格式的CFI（Call Frame Information）：

```asm
; GAS语法
my_function:
    .cfi_startproc
    push    %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset %rbp, -16
    
    mov     %rsp, %rbp
    .cfi_def_cfa_register %rbp
    
    sub     $32, %rsp
    
    ; 函数体...
    
    add     $32, %rsp
    pop     %rbp
    .cfi_def_cfa %rsp, 8
    ret
    .cfi_endproc
```

---

## 参考资料

- 参见: [栈帧概述](./overview.md)
- 参见: [System V AMD64 ABI](../02-x86-x64/x64-sysv.md)
- 参见: [Microsoft x64调用约定](../02-x86-x64/x64-microsoft.md)
