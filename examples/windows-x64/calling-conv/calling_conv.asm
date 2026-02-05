; =============================================================================
; Microsoft x64 Calling Convention Verification Examples
; =============================================================================
; 
; This file demonstrates the Microsoft x64 calling convention:
; - Parameter registers: RCX, RDX, R8, R9 (integers), XMM0-XMM3 (floats)
; - Return value: RAX (integer), XMM0 (float)
; - Shadow Space: 32 bytes must be allocated by caller
; - Stack alignment: 16 bytes before CALL
;
; Assemble with: nasm -f win64 -o calling_conv.obj calling_conv.asm
; =============================================================================

; Export symbols for C linkage
global sum_four
global sum_six
global use_shadow_space
global sum_doubles
global mixed_params
global asm_calls_c
global get_magic_number
global get_pi
global verify_registers

; Import C function
extern c_add

section .data
    ; Pi value for get_pi function
    pi_value dq 3.14159265358979323846

section .text

; =============================================================================
; Function: sum_four
; Purpose:  Verify integer parameter passing via RCX, RDX, R8, R9
; 
; Prototype: int64_t sum_four(int64_t a, int64_t b, int64_t c, int64_t d)
; Parameters:
;   RCX = a (1st parameter)
;   RDX = b (2nd parameter)
;   R8  = c (3rd parameter)
;   R9  = d (4th parameter)
; Returns: RAX = a + b + c + d
; =============================================================================
sum_four:
    ; No stack frame needed for leaf function
    ; Simply add all parameters
    mov     rax, rcx            ; rax = a
    add     rax, rdx            ; rax = a + b
    add     rax, r8             ; rax = a + b + c
    add     rax, r9             ; rax = a + b + c + d
    ret

; =============================================================================
; Function: sum_six
; Purpose:  Verify stack parameter passing (5th and beyond)
;
; Prototype: int64_t sum_six(int64_t a, int64_t b, int64_t c, int64_t d, 
;                            int64_t e, int64_t f)
; Parameters:
;   RCX = a (1st parameter)
;   RDX = b (2nd parameter)
;   R8  = c (3rd parameter)
;   R9  = d (4th parameter)
;   [RSP + 40] = e (5th parameter, after shadow space + return address)
;   [RSP + 48] = f (6th parameter)
; Returns: RAX = a + b + c + d + e + f
;
; Stack layout at function entry:
;   [RSP + 48] = f
;   [RSP + 40] = e
;   [RSP + 32] = shadow space for R9
;   [RSP + 24] = shadow space for R8
;   [RSP + 16] = shadow space for RDX
;   [RSP + 8]  = shadow space for RCX
;   [RSP + 0]  = return address
; =============================================================================
sum_six:
    ; Add register parameters
    mov     rax, rcx            ; rax = a
    add     rax, rdx            ; rax = a + b
    add     rax, r8             ; rax = a + b + c
    add     rax, r9             ; rax = a + b + c + d
    
    ; Add stack parameters
    ; Note: RSP + 40 because:
    ;   - Return address at RSP + 0 (8 bytes)
    ;   - Shadow space at RSP + 8 to RSP + 39 (32 bytes)
    ;   - 5th parameter at RSP + 40
    add     rax, [rsp + 40]     ; rax += e
    add     rax, [rsp + 48]     ; rax += f
    ret

; =============================================================================
; Function: use_shadow_space
; Purpose:  Demonstrate Shadow Space usage - callee can save parameters there
;
; Prototype: int64_t use_shadow_space(int64_t a, int64_t b, int64_t c, int64_t d)
; Parameters: RCX=a, RDX=b, R8=c, R9=d
; Returns: RAX = a + b + c + d (computed after saving to shadow space)
;
; This function saves all register parameters to shadow space first,
; then reads them back to compute the sum. This demonstrates that
; the callee owns the shadow space and can use it freely.
; =============================================================================
use_shadow_space:
    ; Save all parameters to shadow space
    ; Shadow space is at [RSP + 8] to [RSP + 39] (caller allocated)
    mov     [rsp + 8], rcx      ; Save a to shadow space
    mov     [rsp + 16], rdx     ; Save b to shadow space
    mov     [rsp + 24], r8      ; Save c to shadow space
    mov     [rsp + 32], r9      ; Save d to shadow space
    
    ; Now we can freely use RCX, RDX, R8, R9 for other purposes
    ; For demonstration, read back from shadow space
    mov     rax, [rsp + 8]      ; rax = a
    add     rax, [rsp + 16]     ; rax += b
    add     rax, [rsp + 24]     ; rax += c
    add     rax, [rsp + 32]     ; rax += d
    ret

; =============================================================================
; Function: sum_doubles
; Purpose:  Verify floating-point parameter passing via XMM0-XMM3
;
; Prototype: double sum_doubles(double a, double b, double c, double d)
; Parameters:
;   XMM0 = a (1st float parameter)
;   XMM1 = b (2nd float parameter)
;   XMM2 = c (3rd float parameter)
;   XMM3 = d (4th float parameter)
; Returns: XMM0 = a + b + c + d
; =============================================================================
sum_doubles:
    ; XMM0 already contains 'a'
    addsd   xmm0, xmm1          ; xmm0 = a + b
    addsd   xmm0, xmm2          ; xmm0 = a + b + c
    addsd   xmm0, xmm3          ; xmm0 = a + b + c + d
    ; Return value is in XMM0
    ret

; =============================================================================
; Function: mixed_params
; Purpose:  Verify mixed integer/float parameter passing (position sharing)
;
; Prototype: double mixed_params(int64_t n, double x, int64_t m, double y)
; Parameters:
;   RCX  = n (position 1, integer)
;   XMM1 = x (position 2, float - NOT XMM0!)
;   R8   = m (position 3, integer)
;   XMM3 = y (position 4, float - NOT XMM2!)
; Returns: XMM0 = n * x + m * y
;
; Key insight: Integer and float parameters SHARE positions.
; Position 1 uses RCX or XMM0
; Position 2 uses RDX or XMM1
; Position 3 uses R8 or XMM2
; Position 4 uses R9 or XMM3
; =============================================================================
mixed_params:
    ; Convert n (RCX) to double
    cvtsi2sd xmm0, rcx          ; xmm0 = (double)n
    
    ; Multiply n * x
    mulsd   xmm0, xmm1          ; xmm0 = n * x
    
    ; Convert m (R8) to double
    cvtsi2sd xmm2, r8           ; xmm2 = (double)m
    
    ; Multiply m * y
    mulsd   xmm2, xmm3          ; xmm2 = m * y
    
    ; Add results
    addsd   xmm0, xmm2          ; xmm0 = n*x + m*y
    ret

; =============================================================================
; Function: asm_calls_c
; Purpose:  Demonstrate calling C function from assembly
;
; Prototype: int64_t asm_calls_c(int64_t x, int64_t y)
; Parameters: RCX=x, RDX=y
; Returns: RAX = c_add(x, y) (result from C function)
;
; This function demonstrates:
; 1. Proper stack frame setup
; 2. Shadow space allocation before calling
; 3. 16-byte stack alignment
; 4. Calling C function with correct parameter registers
; =============================================================================
asm_calls_c:
    ; Standard prologue
    push    rbp
    mov     rbp, rsp
    
    ; Allocate shadow space (32 bytes) for the call to c_add
    ; After push rbp, RSP is 16-byte aligned
    ; We need 32 bytes for shadow space
    sub     rsp, 32
    
    ; Parameters are already in RCX and RDX (passed through)
    ; Call the C function
    call    c_add
    
    ; Result is in RAX
    
    ; Cleanup and return
    add     rsp, 32
    pop     rbp
    ret

; =============================================================================
; Function: get_magic_number
; Purpose:  Verify integer return value via RAX
;
; Prototype: int64_t get_magic_number(void)
; Returns: RAX = 0x123456789ABCDEF0
; =============================================================================
get_magic_number:
    mov     rax, 0x123456789ABCDEF0
    ret

; =============================================================================
; Function: get_pi
; Purpose:  Verify floating-point return value via XMM0
;
; Prototype: double get_pi(void)
; Returns: XMM0 = 3.14159265358979...
; =============================================================================
get_pi:
    movsd   xmm0, [rel pi_value]
    ret

; =============================================================================
; Function: verify_registers
; Purpose:  Verify all 4 parameter registers and return their sum
;           Also demonstrates callee-saved register preservation
;
; Prototype: int64_t verify_registers(int64_t a, int64_t b, int64_t c, int64_t d)
; Parameters: RCX=a, RDX=b, R8=c, R9=d
; Returns: RAX = a + b + c + d
;
; This function uses callee-saved registers (RBX, RDI, RSI) to demonstrate
; proper saving and restoring.
; =============================================================================
verify_registers:
    ; Prologue - save callee-saved registers we'll use
    push    rbp
    mov     rbp, rsp
    push    rbx                 ; Save RBX (callee-saved)
    push    rdi                 ; Save RDI (callee-saved in MS x64!)
    push    rsi                 ; Save RSI (callee-saved in MS x64!)
    
    ; Use callee-saved registers for computation
    mov     rbx, rcx            ; rbx = a
    mov     rdi, rdx            ; rdi = b
    mov     rsi, r8             ; rsi = c
    ; r9 still contains d
    
    ; Compute sum using the saved values
    mov     rax, rbx            ; rax = a
    add     rax, rdi            ; rax = a + b
    add     rax, rsi            ; rax = a + b + c
    add     rax, r9             ; rax = a + b + c + d
    
    ; Epilogue - restore callee-saved registers
    pop     rsi
    pop     rdi
    pop     rbx
    pop     rbp
    ret

; =============================================================================
; End of file
; =============================================================================
