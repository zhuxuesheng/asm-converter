; Windows x64 C/Assembly Interop Example
; NASM syntax

section .text

; int asm_add(int a, int b)
global asm_add
asm_add:
    lea     eax, [ecx + edx]    ; RCX=a, RDX=b
    ret

; long long asm_multiply(long long a, long long b)
global asm_multiply
asm_multiply:
    mov     rax, rcx
    imul    rax, rdx
    ret

; double asm_add_doubles(double a, double b)
global asm_add_doubles
asm_add_doubles:
    addsd   xmm0, xmm1          ; XMM0=a, XMM1=b
    ret

; void asm_swap(int *a, int *b)
global asm_swap
asm_swap:
    mov     eax, [rcx]
    mov     r8d, [rdx]
    mov     [rcx], r8d
    mov     [rdx], eax
    ret
