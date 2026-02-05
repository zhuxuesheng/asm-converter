// Go Plan9 Assembly - Arithmetic Functions for AMD64
// Demonstrates Go Plan9 syntax on Windows x64
//
// Key syntax features:
// - Operand order: source, destination (like AT&T)
// - Register names: AX, BX, CX, DX, SI, DI, SP, BP, R8-R15
// - Immediate prefix: $
// - Memory access: offset(base)(index*scale)
// - Size suffixes: B(byte), W(word), L(long/32-bit), Q(quad/64-bit)
// - Pseudo-registers: FP (frame pointer), SP (stack pointer), SB (static base)
//
// Go uses a stack-based calling convention for compatibility.
// Parameters are accessed via FP pseudo-register.
// Return values are also placed on the stack via FP.

#include "textflag.h"

// func Add(a, b int64) int64
// Stack layout: a at FP+0, b at FP+8, return at FP+16
TEXT ·Add(SB), NOSPLIT, $0-24
    // Go Plan9 syntax: MOVQ source, destination
    // Access parameters via FP pseudo-register
    MOVQ    a+0(FP), AX     // AX = a (first parameter)
    ADDQ    b+8(FP), AX     // AX = AX + b (add second parameter)
    MOVQ    AX, ret+16(FP)  // Store return value
    RET

// func Sub(a, b int64) int64
// Stack layout: a at FP+0, b at FP+8, return at FP+16
TEXT ·Sub(SB), NOSPLIT, $0-24
    MOVQ    a+0(FP), AX     // AX = a
    SUBQ    b+8(FP), AX     // AX = a - b
    MOVQ    AX, ret+16(FP)  // Store return value
    RET

// func Mul(a, b int64) int64
// Stack layout: a at FP+0, b at FP+8, return at FP+16
TEXT ·Mul(SB), NOSPLIT, $0-24
    MOVQ    a+0(FP), AX     // AX = a
    IMULQ   b+8(FP), AX     // AX = a * b (signed multiply)
    MOVQ    AX, ret+16(FP)  // Store return value
    RET

// func SumArray(arr []int64) int64
// Slice layout: ptr at FP+0, len at FP+8, cap at FP+16
// Return at FP+24
TEXT ·SumArray(SB), NOSPLIT, $0-32
    MOVQ    arr_base+0(FP), SI   // SI = array base pointer
    MOVQ    arr_len+8(FP), CX    // CX = array length
    XORQ    AX, AX               // AX = 0 (accumulator)
    
    // Check for empty array
    TESTQ   CX, CX               // Test if length == 0
    JEQ     sum_done             // If zero, return 0
    
sum_loop:
    // Memory access: (SI) means [SI] - indirect through SI
    ADDQ    (SI), AX             // AX += *SI (add current element)
    ADDQ    $8, SI               // SI += 8 (move to next int64)
    DECQ    CX                   // CX-- (decrement counter)
    JNZ     sum_loop             // If CX != 0, continue loop
    
sum_done:
    MOVQ    AX, ret+24(FP)       // Store return value
    RET

// func FindMax(arr []int64) int64
// Slice layout: ptr at FP+0, len at FP+8, cap at FP+16
// Return at FP+24
TEXT ·FindMax(SB), NOSPLIT, $0-32
    MOVQ    arr_base+0(FP), SI   // SI = array base pointer
    MOVQ    arr_len+8(FP), CX    // CX = array length
    
    // Check for empty array
    TESTQ   CX, CX
    JEQ     max_empty            // Return 0 for empty array
    
    // Initialize max with first element
    MOVQ    (SI), AX             // AX = arr[0] (current max)
    ADDQ    $8, SI               // Move to next element
    DECQ    CX                   // Decrement counter
    JEQ     max_done             // If only one element, done
    
max_loop:
    MOVQ    (SI), DX             // DX = current element
    CMPQ    DX, AX               // Compare DX with current max
    JLE     max_skip             // If DX <= AX, skip update
    MOVQ    DX, AX               // Update max: AX = DX
    
max_skip:
    ADDQ    $8, SI               // Move to next element
    DECQ    CX                   // Decrement counter
    JNZ     max_loop             // Continue if more elements
    JMP     max_done
    
max_empty:
    XORQ    AX, AX               // Return 0 for empty array
    
max_done:
    MOVQ    AX, ret+24(FP)       // Store return value
    RET

// func Factorial(n int64) int64
// Stack layout: n at FP+0, return at FP+8
// Iterative implementation to demonstrate loop constructs
TEXT ·Factorial(SB), NOSPLIT, $0-16
    MOVQ    n+0(FP), CX          // CX = n (counter)
    MOVQ    $1, AX               // AX = 1 (result accumulator)
    
    // Handle n <= 1
    CMPQ    CX, $1
    JLE     fact_done            // If n <= 1, return 1
    
fact_loop:
    IMULQ   CX, AX               // AX = AX * CX
    DECQ    CX                   // CX--
    CMPQ    CX, $1
    JG      fact_loop            // Continue while CX > 1
    
fact_done:
    MOVQ    AX, ret+8(FP)        // Store return value
    RET
