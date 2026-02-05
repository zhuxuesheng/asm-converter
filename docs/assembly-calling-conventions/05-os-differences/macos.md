# macOS 调用约定详解

> macOS系统调用约定完整规范，包含Mach-O特性和与Linux的差异

## 概述

macOS在x64架构上使用System V AMD64 ABI，与Linux基本相同，但在系统调用和某些细节上有差异。

---

## 用户态调用约定

macOS用户态调用遵循System V AMD64 ABI，与Linux相同：

| 特性 | 规范 |
|------|------|
| 整数参数 | RDI, RSI, RDX, RCX, R8, R9 |
| 浮点参数 | XMM0-XMM7 |
| 返回值 | RAX (整数), XMM0 (浮点) |
| 栈对齐 | 16字节 |
| Red Zone | 128字节 |

---

## 系统调用机制

### macOS系统调用号

macOS系统调用号需要加上类别前缀：

| 类别 | 前缀 | 说明 |
|------|------|------|
| Mach | 0x1000000 | Mach内核调用 |
| Unix | 0x2000000 | BSD/POSIX调用 |
| Machine-dependent | 0x3000000 | 机器相关调用 |

```asm
; macOS系统调用号 = 前缀 + 基础号
; 例如: write = 0x2000000 + 4 = 0x2000004
```

### 系统调用寄存器

| 用途 | 寄存器 | 说明 |
|------|--------|------|
| 系统调用号 | RAX | 包含类别前缀 |
| 参数1 | RDI | |
| 参数2 | RSI | |
| 参数3 | RDX | |
| 参数4 | R10 | 注意：不是RCX |
| 参数5 | R8 | |
| 参数6 | R9 | |
| 返回值 | RAX | |
| 错误标志 | CF | 进位标志指示错误 |


### 常用系统调用号

| 系统调用 | 号码 | 说明 |
|----------|------|------|
| exit | 0x2000001 | 退出进程 |
| fork | 0x2000002 | 创建进程 |
| read | 0x2000003 | 读取 |
| write | 0x2000004 | 写入 |
| open | 0x2000005 | 打开文件 |
| close | 0x2000006 | 关闭文件 |
| wait4 | 0x2000007 | 等待进程 |
| link | 0x2000009 | 创建硬链接 |
| unlink | 0x200000A | 删除文件 |
| execve | 0x200003B | 执行程序 |
| getpid | 0x2000014 | 获取进程ID |
| getuid | 0x2000018 | 获取用户ID |
| kill | 0x2000025 | 发送信号 |
| mmap | 0x20000C5 | 内存映射 |
| munmap | 0x2000049 | 取消映射 |
| mprotect | 0x200004A | 修改保护 |

### 错误处理

macOS使用进位标志（CF）指示系统调用错误：

```asm
    syscall
    jc      error               ; CF=1表示错误
    ; 成功，RAX包含返回值
    jmp     done

error:
    ; RAX包含errno值
    ; 错误处理...

done:
```

### 系统调用示例

```asm
; macOS x64 - Hello World
    .section __TEXT,__text
    .globl _main

_main:
    ; write(1, "Hello\n", 6)
    mov     rax, 0x2000004      ; syscall: write
    mov     rdi, 1              ; fd: stdout
    lea     rsi, [rip + msg]    ; buf
    mov     rdx, 6              ; count
    syscall
    jc      exit_error
    
    ; exit(0)
    mov     rax, 0x2000001      ; syscall: exit
    xor     rdi, rdi            ; status: 0
    syscall

exit_error:
    mov     rax, 0x2000001
    mov     rdi, 1              ; status: 1
    syscall

    .section __DATA,__data
msg:
    .ascii "Hello\n"
```

---

## 与Linux的差异

### 系统调用差异

| 特性 | Linux | macOS |
|------|-------|-------|
| 系统调用号 | 直接使用 | 需要加前缀 |
| 错误指示 | RAX为负值 | CF标志 |
| errno位置 | RAX取反 | RAX直接是errno |

### 代码对比

```asm
; Linux write系统调用
    mov     rax, 1              ; syscall号
    mov     rdi, 1
    lea     rsi, [rip + msg]
    mov     rdx, 6
    syscall
    test    rax, rax            ; 检查负值
    js      error

; macOS write系统调用
    mov     rax, 0x2000004      ; syscall号（含前缀）
    mov     rdi, 1
    lea     rsi, [rip + msg]
    mov     rdx, 6
    syscall
    jc      error               ; 检查CF标志
```

---

## Mach-O可执行格式

### 段和节命名

macOS使用Mach-O格式，段和节命名与ELF不同：

| ELF | Mach-O | 说明 |
|-----|--------|------|
| .text | __TEXT,__text | 代码段 |
| .data | __DATA,__data | 数据段 |
| .rodata | __TEXT,__const | 只读数据 |
| .bss | __DATA,__bss | 未初始化数据 |

### 汇编语法差异

```asm
; Linux (GAS)
    .section .text
    .globl main
main:
    ...
    .section .rodata
msg:
    .ascii "Hello\n"

; macOS (GAS)
    .section __TEXT,__text
    .globl _main
_main:
    ...
    .section __TEXT,__const
msg:
    .ascii "Hello\n"
```

### 符号命名

macOS C函数符号需要下划线前缀：

| C函数 | Linux符号 | macOS符号 |
|-------|-----------|-----------|
| main | main | _main |
| printf | printf | _printf |
| my_func | my_func | _my_func |

---

## 位置无关代码（PIC）

### RIP相对寻址

macOS强制要求位置无关代码：

```asm
; 正确：RIP相对寻址
    lea     rax, [rip + my_data]
    mov     rax, [rip + my_var]

; 错误：绝对寻址（macOS不允许）
    mov     rax, my_data        ; 链接错误
```

### GOT访问

```asm
; 访问外部符号
    mov     rax, [rip + external_var@GOTPCREL]
    mov     rax, [rax]          ; 实际值
```

---

## ARM64 (Apple Silicon)

### Apple Silicon调用约定

macOS在ARM64上使用修改版的AAPCS64：

| 特性 | 规范 |
|------|------|
| 整数参数 | X0-X7 |
| 浮点参数 | V0-V7 |
| 返回值 | X0 (整数), V0 (浮点) |
| 栈对齐 | 16字节 |
| 帧指针 | X29（必须使用） |
| 链接寄存器 | X30 |

### ARM64系统调用

```asm
; ARM64 macOS系统调用
    mov     x16, #4             ; syscall: write
    mov     x0, #1              ; fd
    adr     x1, msg             ; buf
    mov     x2, #6              ; count
    svc     #0x80               ; 系统调用
```

---

## 参考资料

### 官方规范

- [OS X ABI Mach-O File Format Reference](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/MachORuntime/)
- [Writing 64-bit Intel Code for Apple Platforms](https://developer.apple.com/documentation/xcode/writing-64-bit-intel-code-for-apple-platforms)

### 相关文档

- 参见: [System V AMD64 ABI详解](../02-x86-x64/x64-sysv.md)
- 参见: [操作系统差异概述](./overview.md)
- 参见: [Linux调用约定](./linux.md)
