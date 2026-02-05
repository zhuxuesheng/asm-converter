; NASM (Intel Syntax) Assembly - Arithmetic Functions for Windows x64
; Demonstrates Intel syntax on Windows x64
;
; Key syntax features:
; - Operand order: destination, source (opposite of AT&T)
; - Register names: rax, rbx, rcx, rdx, rsi, rdi, rsp, rbp, r8-r15
; - No immediate prefix (just the value)
; - Memory access: [base + index*scale + offset]
; - Size prefixes: BYTE, WORD, DWORD, QWORD
;
; Windows x64 Calling Convention (Microsoft ABI):
; - Parameters: RCX, RDX, R8, R9 (first 4 integer/pointer args)
; - Return value: RAX
; - Caller-saved: RAX, RCX, RDX, R8, R9, R10, R11
; - Callee-saved: RBX, RBP, RDI, RSI, R12-R15
; - Shadow space: 32 bytes must be allocated by caller

; Use default rel for RIP-relative addressing
default rel

section .text

; Export symbols for linking with C
global add_numbers
global sub_numbers
global mul_numbers
global sum_array
global find_max
global factorial

; int64_t add_numbers(int64_t a, int64_t b)
; Parameters: a in RCX, b in RDX
; Return: RAX
add_numbers:
    ; Intel syntax: mov destination, source
    mov     rax, rcx        ; rax = a (first parameter)
    add     rax, rdx        ; rax = rax + b (add second parameter)
    ret

; int64_t sub_numbers(int64_t a, int64_t b)
; Parameters: a in RCX, b in RDX
; Return: RAX
sub_numbers:
    mov     rax, rcx        ; rax = a
    sub     rax, rdx        ; rax = a - b
    ret

; int64_t mul_numbers(int64_t a, int64_t b)
; Parameters: a in RCX, b in RDX
; Return: RAX
mul_numbers:
    mov     rax, rcx        ; rax = a
    imul    rax, rdx        ; rax = a * b (signed multiply)
    ret

; int64_t sum_array(int64_t* arr, size_t len)
; Parameters: arr in RCX, len in RDX
; Return: RAX
sum_array:
    xor     rax, rax        ; rax = 0 (accumulator)
    
    ; Check for empty array
    test    rdx, rdx        ; Test if len == 0
    jz      .sum_done       ; If zero, return 0
    
    ; RCX = array pointer, RDX = length
.sum_loop:
    ; Memory access: [rcx] means dereference pointer in rcx
    add     rax, [rcx]      ; rax += *arr (add current element)
    add     rcx, 8          ; arr++ (move to next int64)
    dec     rdx             ; len--
    jnz     .sum_loop       ; Continue while len != 0
    
.sum_done:
    ret

; int64_t find_max(int64_t* arr, size_t len)
; Parameters: arr in RCX, len in RDX
; Return: RAX
find_max:
    ; Check for empty array
    test    rdx, rdx
    jz      .max_empty      ; Return 0 for empty array
    
    ; Initialize max with first element
    mov     rax, [rcx]      ; rax = arr[0] (current max)
    add     rcx, 8          ; Move to next element
    dec     rdx             ; Decrement counter
    jz      .max_done       ; If only one element, done
    
.max_loop:
    mov     r8, [rcx]       ; r8 = current element
    cmp     r8, rax         ; Compare r8 with current max
    jle     .max_skip       ; If r8 <= rax, skip update
    mov     rax, r8         ; Update max: rax = r8
    
.max_skip:
    add     rcx, 8          ; Move to next element
    dec     rdx             ; Decrement counter
    jnz     .max_loop       ; Continue if more elements
    jmp     .max_done
    
.max_empty:
    xor     rax, rax        ; Return 0 for empty array
    
.max_done:
    ret

; int64_t factorial(int64_t n)
; Parameters: n in RCX
; Return: RAX
; Iterative implementation
factorial:
    mov     rax, 1          ; rax = 1 (result accumulator)
    
    ; Handle n <= 1
    cmp     rcx, 1
    jle     .fact_done      ; If n <= 1, return 1
    
.fact_loop:
    imul    rax, rcx        ; rax = rax * n
    dec     rcx             ; n--
    cmp     rcx, 1
    jg      .fact_loop      ; Continue while n > 1
    
.fact_done:
    ret
