# Linux x64 C/Assembly Interop Example
# GAS syntax

    .text

# long asm_add(long a, long b)
    .globl asm_add
    .type asm_add, @function
asm_add:
    lea     (%rdi, %rsi), %rax  # RDI=a, RSI=b
    ret
    .size asm_add, .-asm_add

# long asm_multiply(long a, long b)
    .globl asm_multiply
    .type asm_multiply, @function
asm_multiply:
    mov     %rdi, %rax
    imul    %rsi, %rax
    ret
    .size asm_multiply, .-asm_multiply

# double asm_add_doubles(double a, double b)
    .globl asm_add_doubles
    .type asm_add_doubles, @function
asm_add_doubles:
    addsd   %xmm1, %xmm0        # XMM0=a, XMM1=b
    ret
    .size asm_add_doubles, .-asm_add_doubles

# void asm_swap(long *a, long *b)
    .globl asm_swap
    .type asm_swap, @function
asm_swap:
    mov     (%rdi), %rax
    mov     (%rsi), %rcx
    mov     %rcx, (%rdi)
    mov     %rax, (%rsi)
    ret
    .size asm_swap, .-asm_swap
