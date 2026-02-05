# Linux x64 System Call Examples
# 验证Linux系统调用约定

    .text
    .globl _start

_start:
    # === write(1, "Hello from Linux syscall!\n", 26) ===
    mov     $1, %rax            # syscall: write
    mov     $1, %rdi            # fd: stdout
    lea     msg(%rip), %rsi     # buf
    mov     $26, %rdx           # count
    syscall
    
    # 检查错误
    test    %rax, %rax
    js      error
    
    # === getpid() ===
    mov     $39, %rax           # syscall: getpid
    syscall
    # PID现在在RAX中
    
    # === exit(0) ===
    mov     $60, %rax           # syscall: exit
    xor     %rdi, %rdi          # status: 0
    syscall

error:
    mov     $60, %rax           # syscall: exit
    mov     $1, %rdi            # status: 1
    syscall

    .section .rodata
msg:
    .ascii "Hello from Linux syscall!\n"
