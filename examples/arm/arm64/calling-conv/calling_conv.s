// =============================================================================
// ARM64 AAPCS64 调用约定验证示例
// =============================================================================
//
// 本文件演示 ARM64 AAPCS64 调用约定:
// - 参数寄存器: X0-X7 (整数)
// - 参数寄存器: V0-V7 / D0-D7 (浮点/SIMD)
// - 返回值: X0 (64位), X0-X1 (128位), D0 (浮点)
// - 栈对齐: 16字节（强制）
// - 整数和浮点参数独立计数
//
// 汇编命令: aarch64-linux-gnu-as -o calling_conv.o calling_conv.s
// =============================================================================

    .text
    .arch armv8-a

// =============================================================================
// 函数: sum_eight
// 功能: 验证整数参数通过 X0-X7 传递
//
// 原型: long sum_eight(long a, long b, long c, long d, long e, long f, long g, long h)
// 参数:
//   X0 = a (第1个参数)
//   X1 = b (第2个参数)
//   X2 = c (第3个参数)
//   X3 = d (第4个参数)
//   X4 = e (第5个参数)
//   X5 = f (第6个参数)
//   X6 = g (第7个参数)
//   X7 = h (第8个参数)
// 返回: X0 = a + b + c + d + e + f + g + h
// =============================================================================
    .global sum_eight
    .type sum_eight, %function

sum_eight:
    // 叶子函数 - 无需栈帧
    // 直接将所有参数相加
    ADD     X0, X0, X1          // X0 = a + b
    ADD     X0, X0, X2          // X0 = a + b + c
    ADD     X0, X0, X3          // X0 = a + b + c + d
    ADD     X0, X0, X4          // X0 = a + b + c + d + e
    ADD     X0, X0, X5          // X0 = a + b + c + d + e + f
    ADD     X0, X0, X6          // X0 = a + b + c + d + e + f + g
    ADD     X0, X0, X7          // X0 = a + b + c + d + e + f + g + h
    RET                         // 返回

    .size sum_eight, .-sum_eight

// =============================================================================
// 函数: sum_ten
// 功能: 验证栈参数传递（第9个及以后的参数）
//
// 原型: long sum_ten(long a, long b, long c, long d, long e, long f, long g, long h, long i, long j)
// 参数:
//   X0-X7 = a-h (前8个参数)
//   [SP + 0] = i (第9个参数)
//   [SP + 8] = j (第10个参数)
// 返回: X0 = a + b + c + d + e + f + g + h + i + j
//
// 栈布局（函数入口时）:
//   [SP + 8] = j
//   [SP + 0] = i
// =============================================================================
    .global sum_ten
    .type sum_ten, %function

sum_ten:
    // 寄存器参数相加
    ADD     X0, X0, X1          // X0 = a + b
    ADD     X0, X0, X2          // X0 += c
    ADD     X0, X0, X3          // X0 += d
    ADD     X0, X0, X4          // X0 += e
    ADD     X0, X0, X5          // X0 += f
    ADD     X0, X0, X6          // X0 += g
    ADD     X0, X0, X7          // X0 += h
    
    // 栈参数相加
    LDR     X1, [SP, #0]        // X1 = i
    ADD     X0, X0, X1          // X0 += i
    LDR     X1, [SP, #8]        // X1 = j
    ADD     X0, X0, X1          // X0 += j
    
    RET                         // 返回

    .size sum_ten, .-sum_ten

// =============================================================================
// 函数: sum_doubles
// 功能: 验证双精度浮点参数通过 D0-D7 传递
//
// 原型: double sum_doubles(double a, double b, double c, double d)
// 参数:
//   D0 = a (第1个浮点参数)
//   D1 = b (第2个浮点参数)
//   D2 = c (第3个浮点参数)
//   D3 = d (第4个浮点参数)
// 返回: D0 = a + b + c + d
// =============================================================================
    .global sum_doubles
    .type sum_doubles, %function

sum_doubles:
    // D0 已经包含 'a'
    FADD    D0, D0, D1          // D0 = a + b
    FADD    D0, D0, D2          // D0 = a + b + c
    FADD    D0, D0, D3          // D0 = a + b + c + d
    // 返回值在 D0 中
    RET                         // 返回

    .size sum_doubles, .-sum_doubles

// =============================================================================
// 函数: sum_floats
// 功能: 验证单精度浮点参数通过 S0-S7 传递
//
// 原型: float sum_floats(float a, float b, float c, float d)
// 参数:
//   S0 = a (第1个浮点参数)
//   S1 = b (第2个浮点参数)
//   S2 = c (第3个浮点参数)
//   S3 = d (第4个浮点参数)
// 返回: S0 = a + b + c + d
// =============================================================================
    .global sum_floats
    .type sum_floats, %function

sum_floats:
    FADD    S0, S0, S1          // S0 = a + b
    FADD    S0, S0, S2          // S0 = a + b + c
    FADD    S0, S0, S3          // S0 = a + b + c + d
    RET                         // 返回

    .size sum_floats, .-sum_floats

// =============================================================================
// 函数: mixed_params
// 功能: 验证混合整数和浮点参数传递（独立计数）
//
// 原型: double mixed_params(long n, double x, long m, double y)
// 参数（独立计数）:
//   X0 = n (第1个整数参数)
//   D0 = x (第1个浮点参数)
//   X1 = m (第2个整数参数)
//   D1 = y (第2个浮点参数)
// 返回: D0 = n * x + m * y
//
// 关键区别: ARM64中整数和浮点参数独立计数！
// =============================================================================
    .global mixed_params
    .type mixed_params, %function

mixed_params:
    // 将整数n转换为双精度浮点
    SCVTF   D2, X0              // D2 = (double)n
    
    // 将整数m转换为双精度浮点
    SCVTF   D3, X1              // D3 = (double)m
    
    // 计算 n*x + m*y
    FMUL    D2, D2, D0          // D2 = n * x
    FMUL    D3, D3, D1          // D3 = m * y
    FADD    D0, D2, D3          // D0 = n*x + m*y
    
    RET                         // 返回

    .size mixed_params, .-mixed_params

// =============================================================================
// 函数: asm_calls_c
// 功能: 演示从汇编调用C函数
//
// 原型: long asm_calls_c(long x, long y)
// 参数: X0=x, X1=y
// 返回: X0 = c_add(x, y) (C函数的返回值)
//
// 本函数演示:
// 1. 正确的栈帧设置
// 2. 16字节栈对齐
// 3. 调用C函数时的参数传递
// =============================================================================
    .global asm_calls_c
    .type asm_calls_c, %function

asm_calls_c:
    // 标准序言 - 保存FP和LR
    STP     X29, X30, [SP, #-16]!   // 保存FP和LR，SP -= 16
    MOV     X29, SP                  // 建立帧指针
    
    // 参数已经在 X0 和 X1 中（直接传递）
    // 调用 C 函数
    BL      c_add                    // 调用 c_add(x, y)
    
    // 结果在 X0 中
    
    // 清理并返回
    LDP     X29, X30, [SP], #16      // 恢复FP和LR，SP += 16
    RET                              // 返回

    .size asm_calls_c, .-asm_calls_c

// =============================================================================
// 函数: get_magic_number
// 功能: 验证64位整数返回值通过 X0
//
// 原型: long get_magic_number(void)
// 返回: X0 = 0x123456789ABCDEF0
// =============================================================================
    .global get_magic_number
    .type get_magic_number, %function

get_magic_number:
    // 加载64位立即数
    MOV     X0, #0xDEF0
    MOVK    X0, #0x9ABC, LSL #16
    MOVK    X0, #0x5678, LSL #32
    MOVK    X0, #0x1234, LSL #48
    RET                         // 返回

    .size get_magic_number, .-get_magic_number

// =============================================================================
// 函数: get_big_value
// 功能: 验证128位整数返回值通过 X0-X1
//
// 原型: __int128 get_big_value(void)
// 返回: X0=低64位, X1=高64位
// =============================================================================
    .global get_big_value
    .type get_big_value, %function

get_big_value:
    // 低64位
    MOV     X0, #0xDEF0
    MOVK    X0, #0x9ABC, LSL #16
    MOVK    X0, #0x5678, LSL #32
    MOVK    X0, #0x1234, LSL #48
    
    // 高64位
    MOV     X1, #0x5678
    MOVK    X1, #0x1234, LSL #16
    MOVK    X1, #0xDEF0, LSL #32
    MOVK    X1, #0x9ABC, LSL #48
    
    RET                         // 返回

    .size get_big_value, .-get_big_value

// =============================================================================
// 函数: get_pi
// 功能: 验证双精度浮点返回值通过 D0
//
// 原型: double get_pi(void)
// 返回: D0 = 3.14159265358979...
// =============================================================================
    .global get_pi
    .type get_pi, %function

get_pi:
    ADRP    X0, pi_value            // 加载π值地址（页）
    ADD     X0, X0, :lo12:pi_value  // 加载π值地址（偏移）
    LDR     D0, [X0]                // 加载π值到D0
    RET                             // 返回

    .size get_pi, .-get_pi

// =============================================================================
// 函数: get_pi_float
// 功能: 验证单精度浮点返回值通过 S0
//
// 原型: float get_pi_float(void)
// 返回: S0 = 3.14159265...
// =============================================================================
    .global get_pi_float
    .type get_pi_float, %function

get_pi_float:
    ADRP    X0, pi_float_value
    ADD     X0, X0, :lo12:pi_float_value
    LDR     S0, [X0]
    RET

    .size get_pi_float, .-get_pi_float

// =============================================================================
// 函数: verify_callee_saved
// 功能: 验证 callee-saved 寄存器保存（X19-X28）
//       同时演示正确的保存和恢复
//
// 原型: long verify_callee_saved(long a, long b, long c, long d)
// 参数: X0=a, X1=b, X2=c, X3=d
// 返回: X0 = a + b + c + d
//
// 本函数使用 callee-saved 寄存器（X19, X20, X21）来演示
// 正确的保存和恢复
// =============================================================================
    .global verify_callee_saved
    .type verify_callee_saved, %function

verify_callee_saved:
    // 序言 - 保存 callee-saved 寄存器
    STP     X29, X30, [SP, #-48]!   // 保存FP和LR
    MOV     X29, SP                  // 建立帧指针
    STP     X19, X20, [SP, #16]      // 保存X19和X20
    STR     X21, [SP, #32]           // 保存X21
    
    // 使用 callee-saved 寄存器进行计算
    MOV     X19, X0                  // X19 = a
    MOV     X20, X1                  // X20 = b
    MOV     X21, X2                  // X21 = c
    // X3 仍然包含 d
    
    // 使用保存的值计算总和
    MOV     X0, X19                  // X0 = a
    ADD     X0, X0, X20              // X0 = a + b
    ADD     X0, X0, X21              // X0 = a + b + c
    ADD     X0, X0, X3               // X0 = a + b + c + d
    
    // 尾声 - 恢复 callee-saved 寄存器
    LDR     X21, [SP, #32]           // 恢复X21
    LDP     X19, X20, [SP, #16]      // 恢复X19和X20
    LDP     X29, X30, [SP], #48      // 恢复FP和LR
    RET                              // 返回

    .size verify_callee_saved, .-verify_callee_saved

// =============================================================================
// 函数: verify_stack_alignment
// 功能: 验证16字节栈对齐
//
// 原型: long verify_stack_alignment(long a, long b)
// 参数: X0=a, X1=b
// 返回: X0 = a + b
//
// 本函数演示正确的栈对齐（16字节）
// =============================================================================
    .global verify_stack_alignment
    .type verify_stack_alignment, %function

verify_stack_alignment:
    // 序言 - 分配栈空间（必须16字节对齐）
    STP     X29, X30, [SP, #-32]!   // 保存FP和LR，分配32字节
    MOV     X29, SP                  // 建立帧指针
    
    // 保存参数到栈（演示栈使用）
    STR     X0, [SP, #16]            // 保存a
    STR     X1, [SP, #24]            // 保存b
    
    // 从栈读取并计算
    LDR     X0, [SP, #16]            // 读取a
    LDR     X1, [SP, #24]            // 读取b
    ADD     X0, X0, X1               // X0 = a + b
    
    // 尾声
    LDP     X29, X30, [SP], #32      // 恢复FP和LR
    RET                              // 返回

    .size verify_stack_alignment, .-verify_stack_alignment

// =============================================================================
// 函数: multiply_accumulate
// 功能: 演示更复杂的计算，使用多个 callee-saved 寄存器
//
// 原型: long multiply_accumulate(long a, long b, long c, long d, long e, long f)
// 参数: X0=a, X1=b, X2=c, X3=d, X4=e, X5=f
// 返回: X0 = (a*b) + (c*d) + (e*f)
// =============================================================================
    .global multiply_accumulate
    .type multiply_accumulate, %function

multiply_accumulate:
    // 序言
    STP     X29, X30, [SP, #-32]!
    MOV     X29, SP
    STP     X19, X20, [SP, #16]
    
    // 计算 a*b
    MUL     X19, X0, X1              // X19 = a * b
    
    // 计算 c*d
    MUL     X20, X2, X3              // X20 = c * d
    
    // 计算 e*f
    MUL     X0, X4, X5               // X0 = e * f
    
    // 累加所有结果
    ADD     X0, X0, X19              // X0 = (e*f) + (a*b)
    ADD     X0, X0, X20              // X0 = (e*f) + (a*b) + (c*d)
    
    // 尾声
    LDP     X19, X20, [SP, #16]
    LDP     X29, X30, [SP], #32
    RET

    .size multiply_accumulate, .-multiply_accumulate

// =============================================================================
// 函数: many_float_params
// 功能: 验证多个浮点参数传递（8个D寄存器）
//
// 原型: double many_float_params(double a, double b, double c, double d,
//                                double e, double f, double g, double h)
// 参数: D0=a, D1=b, D2=c, D3=d, D4=e, D5=f, D6=g, D7=h
// 返回: D0 = a + b + c + d + e + f + g + h
// =============================================================================
    .global many_float_params
    .type many_float_params, %function

many_float_params:
    FADD    D0, D0, D1              // D0 = a + b
    FADD    D0, D0, D2              // D0 += c
    FADD    D0, D0, D3              // D0 += d
    FADD    D0, D0, D4              // D0 += e
    FADD    D0, D0, D5              // D0 += f
    FADD    D0, D0, D6              // D0 += g
    FADD    D0, D0, D7              // D0 += h
    RET                             // 返回

    .size many_float_params, .-many_float_params

// =============================================================================
// 函数: use_zero_register
// 功能: 演示零寄存器（XZR/WZR）的使用
//
// 原型: long use_zero_register(long a)
// 参数: X0=a
// 返回: X0 = a + 0 (演示XZR读取返回0)
// =============================================================================
    .global use_zero_register
    .type use_zero_register, %function

use_zero_register:
    ADD     X0, X0, XZR             // X0 = a + 0 (XZR读取返回0)
    RET

    .size use_zero_register, .-use_zero_register

// =============================================================================
// 函数: simd_vector_add
// 功能: 演示SIMD向量操作
//
// 原型: void simd_vector_add(float* dst, float* a, float* b, long n)
// 参数: X0=dst, X1=a, X2=b, X3=n
// 功能: dst[i] = a[i] + b[i] for i in 0..n-1
// =============================================================================
    .global simd_vector_add
    .type simd_vector_add, %function

simd_vector_add:
.simd_loop:
    CMP     X3, #4
    B.LT    .scalar_loop
    
    // 向量处理（4个float一次）
    LD1     {V0.4S}, [X1], #16      // 加载4个float从a
    LD1     {V1.4S}, [X2], #16      // 加载4个float从b
    FADD    V0.4S, V0.4S, V1.4S     // 向量加法
    ST1     {V0.4S}, [X0], #16      // 存储结果到dst
    SUB     X3, X3, #4
    B       .simd_loop

.scalar_loop:
    CBZ     X3, .simd_done
    
    // 标量处理（剩余元素）
    LDR     S0, [X1], #4
    LDR     S1, [X2], #4
    FADD    S0, S0, S1
    STR     S0, [X0], #4
    SUB     X3, X3, #1
    B       .scalar_loop

.simd_done:
    RET

    .size simd_vector_add, .-simd_vector_add

// =============================================================================
// 数据段
// =============================================================================
    .section .rodata
    .align 3

pi_value:
    .double 3.14159265358979323846

    .align 2
pi_float_value:
    .float 3.14159265358979323846

// =============================================================================
// 文件结束
// =============================================================================
