# macOS x64 System Call Examples
# 验证macOS系统调用约定

    .section __TEXT,__text
    .globl _main

_main:
    # === write(1, "Hello from macOS syscall!\n", 26) ===
    mov     $0x2000004, %rax    # syscall: write (0x2000000 + 4)
    mov     $1, %rdi            # fd: stdout
    lea     msg(%rip), %rsi     # buf
    mov     $26, %rdx           # count
    syscall
    
    # 检查错误（macOS使用CF标志）
    jc      error
    
    # === getpid() ===
    mov     $0x2000014, %rax    # syscall: getpid (0x2000000 + 20)
    syscall
    # PID现在在RAX中
    
    # === exit(0) ===
    mov     $0x2000001, %rax    # syscall: exit (0x2000000 + 1)
    xor     %rdi, %rdi          # status: 0
    syscall

error:
    mov     $0x2000001, %rax    # syscall: exit
    mov     $1, %rdi            # status: 1
    syscall

    .section __TEXT,__const
msg:
    .ascii "Hello from macOS syscall!\n"
