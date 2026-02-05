# GAS (AT&T Syntax) Assembly - Arithmetic Functions for Windows x64
# Demonstrates AT&T syntax on Windows x64
#
# Key syntax features:
# - Operand order: source, destination (like Go Plan9)
# - Register prefix: % (e.g., %rax, %rbx)
# - Immediate prefix: $ (e.g., $42)
# - Memory access: offset(%base, %index, scale)
# - Size suffixes: b(byte), w(word), l(long/32-bit), q(quad/64-bit)
# - Comments: # (hash)
#
# Windows x64 Calling Convention (Microsoft ABI):
# - Parameters: RCX, RDX, R8, R9 (first 4 integer/pointer args)
# - Return value: RAX
# - Caller-saved: RAX, RCX, RDX, R8, R9, R10, R11
# - Callee-saved: RBX, RBP, RDI, RSI, R12-R15
# - Shadow space: 32 bytes must be allocated by caller

    .text

# Export symbols for linking with C
    .globl add_numbers
    .globl sub_numbers
    .globl mul_numbers
    .globl sum_array
    .globl find_max
    .globl factorial

# int64_t add_numbers(int64_t a, int64_t b)
# Parameters: a in %rcx, b in %rdx
# Return: %rax
add_numbers:
    # AT&T syntax: movq %source, %destination
    movq    %rcx, %rax      # %rax = a (first parameter)
    addq    %rdx, %rax      # %rax = %rax + b (add second parameter)
    ret

# int64_t sub_numbers(int64_t a, int64_t b)
# Parameters: a in %rcx, b in %rdx
# Return: %rax
sub_numbers:
    movq    %rcx, %rax      # %rax = a
    subq    %rdx, %rax      # %rax = a - b
    ret

# int64_t mul_numbers(int64_t a, int64_t b)
# Parameters: a in %rcx, b in %rdx
# Return: %rax
mul_numbers:
    movq    %rcx, %rax      # %rax = a
    imulq   %rdx, %rax      # %rax = a * b (signed multiply)
    ret

# int64_t sum_array(int64_t* arr, size_t len)
# Parameters: arr in %rcx, len in %rdx
# Return: %rax
sum_array:
    xorq    %rax, %rax      # %rax = 0 (accumulator)
    
    # Check for empty array
    testq   %rdx, %rdx      # Test if len == 0
    jz      .Lsum_done      # If zero, return 0
    
    # %rcx = array pointer, %rdx = length
.Lsum_loop:
    # Memory access: (%rcx) means dereference pointer in %rcx
    addq    (%rcx), %rax    # %rax += *arr (add current element)
    addq    $8, %rcx        # arr++ (move to next int64)
    decq    %rdx            # len--
    jnz     .Lsum_loop      # Continue while len != 0
    
.Lsum_done:
    ret

# int64_t find_max(int64_t* arr, size_t len)
# Parameters: arr in %rcx, len in %rdx
# Return: %rax
find_max:
    # Check for empty array
    testq   %rdx, %rdx
    jz      .Lmax_empty     # Return 0 for empty array
    
    # Initialize max with first element
    movq    (%rcx), %rax    # %rax = arr[0] (current max)
    addq    $8, %rcx        # Move to next element
    decq    %rdx            # Decrement counter
    jz      .Lmax_done      # If only one element, done
    
.Lmax_loop:
    movq    (%rcx), %r8     # %r8 = current element
    cmpq    %rax, %r8       # Compare %r8 with current max
    jle     .Lmax_skip      # If %r8 <= %rax, skip update
    movq    %r8, %rax       # Update max: %rax = %r8
    
.Lmax_skip:
    addq    $8, %rcx        # Move to next element
    decq    %rdx            # Decrement counter
    jnz     .Lmax_loop      # Continue if more elements
    jmp     .Lmax_done
    
.Lmax_empty:
    xorq    %rax, %rax      # Return 0 for empty array
    
.Lmax_done:
    ret

# int64_t factorial(int64_t n)
# Parameters: n in %rcx
# Return: %rax
# Iterative implementation
factorial:
    movq    $1, %rax        # %rax = 1 (result accumulator)
    
    # Handle n <= 1
    cmpq    $1, %rcx
    jle     .Lfact_done     # If n <= 1, return 1
    
.Lfact_loop:
    imulq   %rcx, %rax      # %rax = %rax * n
    decq    %rcx            # n--
    cmpq    $1, %rcx
    jg      .Lfact_loop     # Continue while n > 1
    
.Lfact_done:
    ret
