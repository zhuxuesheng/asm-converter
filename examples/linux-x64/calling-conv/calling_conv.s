# =============================================================================
# System V AMD64 ABI Calling Convention Verification Examples
# =============================================================================
#
# This file demonstrates the System V AMD64 ABI calling convention:
# - Parameter registers: RDI, RSI, RDX, RCX, R8, R9 (integers)
# - Parameter registers: XMM0-XMM7 (floats) - independent counting!
# - Return value: RAX (integer), XMM0 (float)
# - Red Zone: 128 bytes below RSP (leaf functions can use without adjusting RSP)
# - Stack alignment: 16 bytes before CALL
# - No Shadow Space (unlike Microsoft x64)
#
# Assemble with: as -o calling_conv.o calling_conv.s
# Or:            gcc -c calling_conv.s
# =============================================================================

    .text

# =============================================================================
# Function: sum_six
# Purpose:  Verify integer parameter passing via RDI, RSI, RDX, RCX, R8, R9
#
# Prototype: int64_t sum_six(int64_t a, int64_t b, int64_t c, 
#                            int64_t d, int64_t e, int64_t f)
# Parameters:
#   RDI = a (1st parameter)
#   RSI = b (2nd parameter)
#   RDX = c (3rd parameter)
#   RCX = d (4th parameter)
#   R8  = e (5th parameter)
#   R9  = f (6th parameter)
# Returns: RAX = a + b + c + d + e + f
# =============================================================================
    .globl sum_six
    .type sum_six, @function
sum_six:
    # Leaf function - no stack frame needed
    # Simply add all parameters
    movq    %rdi, %rax          # rax = a
    addq    %rsi, %rax          # rax = a + b
    addq    %rdx, %rax          # rax = a + b + c
    addq    %rcx, %rax          # rax = a + b + c + d
    addq    %r8, %rax           # rax = a + b + c + d + e
    addq    %r9, %rax           # rax = a + b + c + d + e + f
    ret
.size sum_six, .-sum_six

# =============================================================================
# Function: sum_eight
# Purpose:  Verify stack parameter passing (7th and beyond)
#
# Prototype: int64_t sum_eight(int64_t a, int64_t b, int64_t c, int64_t d,
#                              int64_t e, int64_t f, int64_t g, int64_t h)
# Parameters:
#   RDI = a (1st parameter)
#   RSI = b (2nd parameter)
#   RDX = c (3rd parameter)
#   RCX = d (4th parameter)
#   R8  = e (5th parameter)
#   R9  = f (6th parameter)
#   [RSP + 8]  = g (7th parameter, after return address)
#   [RSP + 16] = h (8th parameter)
# Returns: RAX = a + b + c + d + e + f + g + h
#
# Stack layout at function entry (NO Shadow Space in System V!):
#   [RSP + 16] = h
#   [RSP + 8]  = g
#   [RSP + 0]  = return address
# =============================================================================
    .globl sum_eight
    .type sum_eight, @function
sum_eight:
    # Add register parameters
    movq    %rdi, %rax          # rax = a
    addq    %rsi, %rax          # rax = a + b
    addq    %rdx, %rax          # rax = a + b + c
    addq    %rcx, %rax          # rax = a + b + c + d
    addq    %r8, %rax           # rax = a + b + c + d + e
    addq    %r9, %rax           # rax = a + b + c + d + e + f
    
    # Add stack parameters
    # Note: RSP + 8 because there's NO Shadow Space in System V!
    # Only the return address is between RSP and the 7th parameter
    addq    8(%rsp), %rax       # rax += g
    addq    16(%rsp), %rax      # rax += h
    ret
.size sum_eight, .-sum_eight

# =============================================================================
# Function: use_red_zone
# Purpose:  Demonstrate Red Zone usage - leaf function can use RSP-128 to RSP
#           without adjusting the stack pointer
#
# Prototype: int64_t use_red_zone(int64_t a, int64_t b, int64_t c)
# Parameters: RDI=a, RSI=b, RDX=c
# Returns: RAX = a + b + c (computed after saving to Red Zone)
#
# This function saves parameters to the Red Zone (below RSP) without
# adjusting RSP, demonstrating this System V ABI feature.
# =============================================================================
    .globl use_red_zone
    .type use_red_zone, @function
use_red_zone:
    # Save parameters to Red Zone (no need to adjust RSP!)
    # Red Zone is RSP-1 to RSP-128
    movq    %rdi, -8(%rsp)      # Save a to Red Zone
    movq    %rsi, -16(%rsp)     # Save b to Red Zone
    movq    %rdx, -24(%rsp)     # Save c to Red Zone
    
    # We can now freely use RDI, RSI, RDX for other purposes
    # For demonstration, read back from Red Zone
    movq    -8(%rsp), %rax      # rax = a
    addq    -16(%rsp), %rax     # rax += b
    addq    -24(%rsp), %rax     # rax += c
    
    # Return directly - no need to restore RSP
    ret
.size use_red_zone, .-use_red_zone

# =============================================================================
# Function: sum_doubles
# Purpose:  Verify floating-point parameter passing via XMM0-XMM7
#
# Prototype: double sum_doubles(double a, double b, double c, double d)
# Parameters:
#   XMM0 = a (1st float parameter)
#   XMM1 = b (2nd float parameter)
#   XMM2 = c (3rd float parameter)
#   XMM3 = d (4th float parameter)
# Returns: XMM0 = a + b + c + d
# =============================================================================
    .globl sum_doubles
    .type sum_doubles, @function
sum_doubles:
    # XMM0 already contains 'a'
    addsd   %xmm1, %xmm0        # xmm0 = a + b
    addsd   %xmm2, %xmm0        # xmm0 = a + b + c
    addsd   %xmm3, %xmm0        # xmm0 = a + b + c + d
    # Return value is in XMM0
    ret
.size sum_doubles, .-sum_doubles

# =============================================================================
# Function: mixed_params
# Purpose:  Verify mixed integer/float parameter passing (INDEPENDENT counting)
#
# Prototype: double mixed_params(int64_t n, double x, int64_t m, double y)
# Parameters:
#   RDI  = n (1st integer parameter)
#   XMM0 = x (1st float parameter - NOT XMM1!)
#   RSI  = m (2nd integer parameter)
#   XMM1 = y (2nd float parameter - NOT XMM3!)
# Returns: XMM0 = n * x + m * y
#
# KEY DIFFERENCE from Microsoft x64:
# In System V, integer and float parameters are counted INDEPENDENTLY!
# Position 1 integer → RDI,  Position 1 float → XMM0
# Position 2 integer → RSI,  Position 2 float → XMM1
# etc.
# =============================================================================
    .globl mixed_params
    .type mixed_params, @function
mixed_params:
    # Convert n (RDI) to double
    cvtsi2sdq %rdi, %xmm2       # xmm2 = (double)n
    
    # Multiply n * x
    mulsd   %xmm0, %xmm2        # xmm2 = n * x
    
    # Convert m (RSI) to double
    cvtsi2sdq %rsi, %xmm3       # xmm3 = (double)m
    
    # Multiply m * y
    mulsd   %xmm1, %xmm3        # xmm3 = m * y
    
    # Add results
    addsd   %xmm3, %xmm2        # xmm2 = n*x + m*y
    
    movsd   %xmm2, %xmm0        # Return value in XMM0
    ret
.size mixed_params, .-mixed_params

# =============================================================================
# Function: asm_calls_c
# Purpose:  Demonstrate calling C function from assembly
#
# Prototype: int64_t asm_calls_c(int64_t x, int64_t y)
# Parameters: RDI=x, RSI=y
# Returns: RAX = c_add(x, y) (result from C function)
#
# This function demonstrates:
# 1. Proper stack frame setup
# 2. 16-byte stack alignment before CALL
# 3. NO Shadow Space needed (unlike Microsoft x64!)
# 4. Calling C function with correct parameter registers
# =============================================================================
    .globl asm_calls_c
    .type asm_calls_c, @function
asm_calls_c:
    # Standard prologue
    pushq   %rbp
    movq    %rsp, %rbp
    
    # At this point, RSP is 16-byte aligned (push rbp restored alignment)
    # NO Shadow Space allocation needed in System V ABI!
    
    # Parameters are already in RDI and RSI (passed through)
    # Call the C function
    call    c_add
    
    # Result is in RAX
    
    # Cleanup and return
    popq    %rbp
    ret
.size asm_calls_c, .-asm_calls_c

# =============================================================================
# Function: get_magic_number
# Purpose:  Verify integer return value via RAX
#
# Prototype: int64_t get_magic_number(void)
# Returns: RAX = 0x123456789ABCDEF0
# =============================================================================
    .globl get_magic_number
    .type get_magic_number, @function
get_magic_number:
    movabsq $0x123456789ABCDEF0, %rax
    ret
.size get_magic_number, .-get_magic_number

# =============================================================================
# Function: get_pi
# Purpose:  Verify floating-point return value via XMM0
#
# Prototype: double get_pi(void)
# Returns: XMM0 = 3.14159265358979...
# =============================================================================
    .globl get_pi
    .type get_pi, @function
get_pi:
    movsd   pi_value(%rip), %xmm0
    ret
.size get_pi, .-get_pi

# =============================================================================
# Function: verify_callee_saved
# Purpose:  Verify callee-saved register preservation (RBX, R12-R15)
#           Also demonstrates proper saving and restoring
#
# Prototype: int64_t verify_callee_saved(int64_t a, int64_t b, 
#                                        int64_t c, int64_t d)
# Parameters: RDI=a, RSI=b, RDX=c, RCX=d
# Returns: RAX = a + b + c + d
#
# This function uses callee-saved registers (RBX, R12, R13) to demonstrate
# proper saving and restoring.
# =============================================================================
    .globl verify_callee_saved
    .type verify_callee_saved, @function
verify_callee_saved:
    # Prologue - save callee-saved registers we'll use
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx                # Save RBX (callee-saved)
    pushq   %r12                # Save R12 (callee-saved)
    pushq   %r13                # Save R13 (callee-saved)
    
    # Use callee-saved registers for computation
    movq    %rdi, %rbx          # rbx = a
    movq    %rsi, %r12          # r12 = b
    movq    %rdx, %r13          # r13 = c
    # rcx still contains d
    
    # Compute sum using the saved values
    movq    %rbx, %rax          # rax = a
    addq    %r12, %rax          # rax = a + b
    addq    %r13, %rax          # rax = a + b + c
    addq    %rcx, %rax          # rax = a + b + c + d
    
    # Epilogue - restore callee-saved registers
    popq    %r13
    popq    %r12
    popq    %rbx
    popq    %rbp
    ret
.size verify_callee_saved, .-verify_callee_saved

# =============================================================================
# Function: red_zone_complex
# Purpose:  More complex Red Zone usage demonstration
#           Shows that 128 bytes can be used for local variables
#
# Prototype: int64_t red_zone_complex(int64_t a, int64_t b, int64_t c,
#                                     int64_t d, int64_t e, int64_t f)
# Parameters: RDI=a, RSI=b, RDX=c, RCX=d, R8=e, R9=f
# Returns: RAX = (a*b) + (c*d) + (e*f)
# =============================================================================
    .globl red_zone_complex
    .type red_zone_complex, @function
red_zone_complex:
    # Use Red Zone for intermediate results
    # No need to adjust RSP for leaf function!
    
    # Calculate a * b
    movq    %rdi, %rax
    imulq   %rsi, %rax
    movq    %rax, -8(%rsp)      # Store a*b in Red Zone
    
    # Calculate c * d
    movq    %rdx, %rax
    imulq   %rcx, %rax
    movq    %rax, -16(%rsp)     # Store c*d in Red Zone
    
    # Calculate e * f
    movq    %r8, %rax
    imulq   %r9, %rax
    movq    %rax, -24(%rsp)     # Store e*f in Red Zone
    
    # Sum all results
    movq    -8(%rsp), %rax      # rax = a*b
    addq    -16(%rsp), %rax     # rax += c*d
    addq    -24(%rsp), %rax     # rax += e*f
    
    ret
.size red_zone_complex, .-red_zone_complex

# =============================================================================
# Function: many_float_params
# Purpose:  Verify that System V supports 8 float parameters in registers
#
# Prototype: double many_float_params(double a, double b, double c, double d,
#                                     double e, double f, double g, double h)
# Parameters: XMM0=a, XMM1=b, XMM2=c, XMM3=d, XMM4=e, XMM5=f, XMM6=g, XMM7=h
# Returns: XMM0 = a + b + c + d + e + f + g + h
# =============================================================================
    .globl many_float_params
    .type many_float_params, @function
many_float_params:
    # XMM0 already contains 'a'
    addsd   %xmm1, %xmm0        # xmm0 = a + b
    addsd   %xmm2, %xmm0        # xmm0 = a + b + c
    addsd   %xmm3, %xmm0        # xmm0 = a + b + c + d
    addsd   %xmm4, %xmm0        # xmm0 = a + b + c + d + e
    addsd   %xmm5, %xmm0        # xmm0 = a + b + c + d + e + f
    addsd   %xmm6, %xmm0        # xmm0 = a + b + c + d + e + f + g
    addsd   %xmm7, %xmm0        # xmm0 = a + b + c + d + e + f + g + h
    ret
.size many_float_params, .-many_float_params

# =============================================================================
# Data section
# =============================================================================
    .section .rodata
    .align 8
pi_value:
    .double 3.14159265358979323846

# =============================================================================
# End of file
# =============================================================================
