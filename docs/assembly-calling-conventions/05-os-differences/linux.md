# Linux 调用约定详解

> Linux系统调用约定完整规范，包含syscall机制、系统调用号和Red Zone

## 概述

Linux在x64架构上使用System V AMD64 ABI作为用户态调用约定，同时定义了独特的系统调用接口。

---

## 用户态调用约定

Linux用户态调用遵循System V AMD64 ABI，详见[System V AMD64 ABI](../02-x86-x64/x64-sysv.md)。

### 核心特性

| 特性 | 规范 |
|------|------|
| 整数参数 | RDI, RSI, RDX, RCX, R8, R9 |
| 浮点参数 | XMM0-XMM7 |
| 返回值 | RAX (整数), XMM0 (浮点) |
| 栈对齐 | 16字节 |
| Red Zone | 128字节 |

---

## 系统调用机制

### syscall指令

Linux x64使用`syscall`指令进行系统调用：

```asm
# 系统调用流程
mov     rax, <syscall_number>   # 系统调用号
mov     rdi, <arg1>             # 参数1
mov     rsi, <arg2>             # 参数2
mov     rdx, <arg3>             # 参数3
mov     r10, <arg4>             # 参数4 (注意: 不是RCX)
mov     r8, <arg5>              # 参数5
mov     r9, <arg6>              # 参数6
syscall                         # 执行系统调用
# 返回值在RAX中
```

### 系统调用寄存器

| 用途 | 寄存器 | 说明 |
|------|--------|------|
| 系统调用号 | RAX | 必须设置 |
| 参数1 | RDI | |
| 参数2 | RSI | |
| 参数3 | RDX | |
| 参数4 | R10 | 注意：不是RCX |
| 参数5 | R8 | |
| 参数6 | R9 | |
| 返回值 | RAX | 成功时为结果，失败时为负错误码 |


### 为什么参数4使用R10而不是RCX？

`syscall`指令会将返回地址保存到RCX，将RFLAGS保存到R11，因此这两个寄存器不能用于传递参数。

```
syscall指令行为:
┌─────────────────────────────────────────────────────────────────────────────┐
│  RCX ← RIP (返回地址)                                                       │
│  R11 ← RFLAGS                                                               │
│  RIP ← IA32_LSTAR (内核入口)                                                │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 常用系统调用号

| 系统调用 | 号码 | 参数 |
|----------|------|------|
| read | 0 | fd, buf, count |
| write | 1 | fd, buf, count |
| open | 2 | filename, flags, mode |
| close | 3 | fd |
| stat | 4 | filename, statbuf |
| fstat | 5 | fd, statbuf |
| mmap | 9 | addr, len, prot, flags, fd, off |
| mprotect | 10 | addr, len, prot |
| munmap | 11 | addr, len |
| brk | 12 | brk |
| ioctl | 16 | fd, cmd, arg |
| pipe | 22 | pipefd |
| select | 23 | nfds, readfds, writefds, exceptfds, timeout |
| socket | 41 | domain, type, protocol |
| connect | 42 | sockfd, addr, addrlen |
| accept | 43 | sockfd, addr, addrlen |
| fork | 57 | - |
| execve | 59 | filename, argv, envp |
| exit | 60 | status |
| wait4 | 61 | pid, status, options, rusage |
| kill | 62 | pid, sig |
| getpid | 39 | - |
| getuid | 102 | - |

### 系统调用示例

```asm
# 示例: write(1, "Hello\n", 6)
    .text
    .globl _start
_start:
    # write系统调用
    mov     rax, 1              # syscall: write
    mov     rdi, 1              # fd: stdout
    lea     rsi, [rip + msg]    # buf: 消息地址
    mov     rdx, 6              # count: 6字节
    syscall
    
    # exit系统调用
    mov     rax, 60             # syscall: exit
    xor     rdi, rdi            # status: 0
    syscall

    .section .rodata
msg:
    .ascii "Hello\n"
```

### 错误处理

系统调用失败时，RAX返回负的错误码：

```asm
    syscall
    test    rax, rax            # 检查返回值
    js      error               # 如果为负，跳转到错误处理
    
    # 成功处理...
    jmp     done

error:
    neg     rax                 # 转换为正的errno值
    # 错误处理...

done:
```

| 错误码 | 名称 | 说明 |
|--------|------|------|
| -1 | EPERM | 操作不允许 |
| -2 | ENOENT | 文件不存在 |
| -9 | EBADF | 无效文件描述符 |
| -12 | ENOMEM | 内存不足 |
| -13 | EACCES | 权限拒绝 |
| -14 | EFAULT | 无效地址 |
| -22 | EINVAL | 无效参数 |

---

## Red Zone

### 定义

Red Zone是RSP以下128字节的区域，叶子函数可以使用而无需调整栈指针：

```
栈布局:
高地址
┌─────────────────────────────────────────┐
│           栈帧内容                      │
├─────────────────────────────────────────┤ ← RSP
│                                         │
│           Red Zone                      │
│           (128字节)                     │
│                                         │
│  可用于:                                │
│  - 临时变量                             │
│  - 保存寄存器                           │
│                                         │
└─────────────────────────────────────────┘ ← RSP - 128
低地址
```

### 使用规则

1. **仅叶子函数可用**：不调用其他函数的函数
2. **信号安全**：内核保证信号处理不会破坏Red Zone
3. **无需调整RSP**：直接使用负偏移

```asm
# 使用Red Zone的叶子函数
leaf_function:
    # 无需 sub rsp, ...
    mov     [rsp-8], rbx        # 保存到Red Zone
    mov     [rsp-16], r12
    
    # 函数体...
    
    mov     rbx, [rsp-8]        # 从Red Zone恢复
    mov     r12, [rsp-16]
    ret
```

### 禁用Red Zone

在某些场景（如内核代码）需要禁用Red Zone：

```bash
# GCC编译选项
gcc -mno-red-zone -c kernel_code.c
```

---

## 线程局部存储（TLS）

### FS段寄存器

Linux使用FS段寄存器访问线程局部存储：

```asm
# 访问TLS变量
    mov     rax, fs:[0]         # 读取TLS基址
    mov     rax, fs:tls_var@tpoff  # 读取TLS变量
```

### TLS模型

| 模型 | 说明 | 使用场景 |
|------|------|----------|
| Local Exec | 直接偏移 | 主程序中的TLS |
| Initial Exec | GOT间接 | 动态库中的TLS |
| General Dynamic | 函数调用 | 通用情况 |

---

## 参考资料

### 官方规范

- [System V AMD64 ABI](https://gitlab.com/x86-psABIs/x86-64-ABI)
- [Linux Kernel Syscall Table](https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl)

### 相关文档

- 参见: [System V AMD64 ABI详解](../02-x86-x64/x64-sysv.md)
- 参见: [操作系统差异概述](./overview.md)
- 参见: [Windows调用约定](./windows.md)
