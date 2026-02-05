@ =============================================================================
@ ARM32 AAPCS 调用约定验证示例
@ =============================================================================
@
@ 本文件演示 ARM32 AAPCS 调用约定:
@ - 参数寄存器: R0, R1, R2, R3 (整数)
@ - 参数寄存器: S0-S15 / D0-D7 (浮点，硬浮点模式)
@ - 返回值: R0 (32位), R0-R1 (64位), S0/D0 (浮点)
@ - 栈对齐: 8字节
@ - 64位参数必须在偶数寄存器对开始
@
@ 汇编命令: arm-linux-gnueabihf-as -mfpu=vfpv3 -mfloat-abi=hard -o calling_conv.o calling_conv.s
@ =============================================================================

    .text
    .arm
    .fpu vfpv3
    .arch armv7-a

@ =============================================================================
@ 函数: sum_four
@ 功能: 验证整数参数通过 R0, R1, R2, R3 传递
@
@ 原型: int sum_four(int a, int b, int c, int d)
@ 参数:
@   R0 = a (第1个参数)
@   R1 = b (第2个参数)
@   R2 = c (第3个参数)
@   R3 = d (第4个参数)
@ 返回: R0 = a + b + c + d
@ =============================================================================
    .global sum_four
    .type sum_four, %function

sum_four:
    @ 叶子函数 - 无需栈帧
    @ 直接将所有参数相加
    ADD     R0, R0, R1          @ R0 = a + b
    ADD     R0, R0, R2          @ R0 = a + b + c
    ADD     R0, R0, R3          @ R0 = a + b + c + d
    BX      LR                  @ 返回

    .size sum_four, .-sum_four

@ =============================================================================
@ 函数: sum_six
@ 功能: 验证栈参数传递（第5个及以后的参数）
@
@ 原型: int sum_six(int a, int b, int c, int d, int e, int f)
@ 参数:
@   R0 = a (第1个参数)
@   R1 = b (第2个参数)
@   R2 = c (第3个参数)
@   R3 = d (第4个参数)
@   [SP + 0] = e (第5个参数)
@   [SP + 4] = f (第6个参数)
@ 返回: R0 = a + b + c + d + e + f
@
@ 栈布局（函数入口时）:
@   [SP + 4] = f
@   [SP + 0] = e
@ =============================================================================
    .global sum_six
    .type sum_six, %function

sum_six:
    @ 寄存器参数相加
    ADD     R0, R0, R1          @ R0 = a + b
    ADD     R0, R0, R2          @ R0 = a + b + c
    ADD     R0, R0, R3          @ R0 = a + b + c + d
    
    @ 栈参数相加
    LDR     R1, [SP, #0]        @ R1 = e
    ADD     R0, R0, R1          @ R0 += e
    LDR     R1, [SP, #4]        @ R1 = f
    ADD     R0, R0, R1          @ R0 += f
    
    BX      LR                  @ 返回

    .size sum_six, .-sum_six

@ =============================================================================
@ 函数: add64
@ 功能: 验证64位参数对齐规则（必须在偶数寄存器对开始）
@
@ 原型: long long add64(int a, long long b, int c)
@ 参数:
@   R0 = a (第1个参数)
@   R2-R3 = b (第2个参数，64位，跳过R1以保持对齐)
@   [SP + 0] = c (第3个参数，通过栈传递)
@ 返回: R0-R1 = a + b + c
@
@ 注意: R1 被跳过以保持64位参数的偶数寄存器对齐
@ =============================================================================
    .global add64
    .type add64, %function

add64:
    @ 将32位参数a符号扩展到64位
    MOV     R1, R0, ASR #31     @ R1 = 符号扩展（a的符号位）
    
    @ 64位加法: (R0,R1) + (R2,R3)
    ADDS    R0, R0, R2          @ 低32位相加
    ADC     R1, R1, R3          @ 高32位相加（带进位）
    
    @ 加上栈参数c
    LDR     R2, [SP, #0]        @ R2 = c
    MOV     R3, R2, ASR #31     @ R3 = 符号扩展
    ADDS    R0, R0, R2          @ 低32位相加
    ADC     R1, R1, R3          @ 高32位相加
    
    BX      LR                  @ 返回

    .size add64, .-add64

@ =============================================================================
@ 函数: sum_floats
@ 功能: 验证浮点参数通过 S0-S15 传递（硬浮点模式）
@
@ 原型: float sum_floats(float a, float b, float c, float d)
@ 参数:
@   S0 = a (第1个浮点参数)
@   S1 = b (第2个浮点参数)
@   S2 = c (第3个浮点参数)
@   S3 = d (第4个浮点参数)
@ 返回: S0 = a + b + c + d
@ =============================================================================
    .global sum_floats
    .type sum_floats, %function

sum_floats:
    @ S0 已经包含 'a'
    VADD.F32 S0, S0, S1         @ S0 = a + b
    VADD.F32 S0, S0, S2         @ S0 = a + b + c
    VADD.F32 S0, S0, S3         @ S0 = a + b + c + d
    @ 返回值在 S0 中
    BX      LR                  @ 返回

    .size sum_floats, .-sum_floats

@ =============================================================================
@ 函数: sum_doubles
@ 功能: 验证双精度浮点参数通过 D0-D7 传递
@
@ 原型: double sum_doubles(double a, double b)
@ 参数:
@   D0 = a (第1个双精度参数)
@   D1 = b (第2个双精度参数)
@ 返回: D0 = a + b
@ =============================================================================
    .global sum_doubles
    .type sum_doubles, %function

sum_doubles:
    VADD.F64 D0, D0, D1         @ D0 = a + b
    BX      LR                  @ 返回

    .size sum_doubles, .-sum_doubles

@ =============================================================================
@ 函数: mixed_params
@ 功能: 验证混合整数和浮点参数传递
@
@ 原型: double mixed_params(int n, double x, int m, double y)
@ 参数（硬浮点模式）:
@   R0 = n (第1个整数参数)
@   D0 = x (第1个双精度参数)
@   R1 = m (第2个整数参数)
@   D1 = y (第2个双精度参数)
@ 返回: D0 = n * x + m * y
@ =============================================================================
    .global mixed_params
    .type mixed_params, %function

mixed_params:
    @ 将整数n转换为双精度浮点
    VMOV    S4, R0              @ S4 = n (作为整数)
    VCVT.F64.S32 D2, S4         @ D2 = (double)n
    
    @ 将整数m转换为双精度浮点
    VMOV    S4, R1              @ S4 = m (作为整数)
    VCVT.F64.S32 D3, S4         @ D3 = (double)m
    
    @ 计算 n*x + m*y
    VMUL.F64 D2, D2, D0         @ D2 = n * x
    VMUL.F64 D3, D3, D1         @ D3 = m * y
    VADD.F64 D0, D2, D3         @ D0 = n*x + m*y
    
    BX      LR                  @ 返回

    .size mixed_params, .-mixed_params

@ =============================================================================
@ 函数: asm_calls_c
@ 功能: 演示从汇编调用C函数
@
@ 原型: int asm_calls_c(int x, int y)
@ 参数: R0=x, R1=y
@ 返回: R0 = c_add(x, y) (C函数的返回值)
@
@ 本函数演示:
@ 1. 正确的栈帧设置
@ 2. 8字节栈对齐
@ 3. 调用C函数时的参数传递
@ =============================================================================
    .global asm_calls_c
    .type asm_calls_c, %function

asm_calls_c:
    @ 标准序言
    PUSH    {R11, LR}           @ 保存帧指针和返回地址
    MOV     R11, SP             @ 建立帧指针
    
    @ 参数已经在 R0 和 R1 中（直接传递）
    @ 调用 C 函数
    BL      c_add               @ 调用 c_add(x, y)
    
    @ 结果在 R0 中
    
    @ 清理并返回
    POP     {R11, PC}           @ 恢复帧指针并返回

    .size asm_calls_c, .-asm_calls_c

@ =============================================================================
@ 函数: get_magic_number
@ 功能: 验证32位整数返回值通过 R0
@
@ 原型: int get_magic_number(void)
@ 返回: R0 = 0x12345678
@ =============================================================================
    .global get_magic_number
    .type get_magic_number, %function

get_magic_number:
    LDR     R0, =0x12345678     @ 加载魔数
    BX      LR                  @ 返回

    .size get_magic_number, .-get_magic_number

@ =============================================================================
@ 函数: get_big_value
@ 功能: 验证64位整数返回值通过 R0-R1
@
@ 原型: long long get_big_value(void)
@ 返回: R0=低32位, R1=高32位 = 0x123456789ABCDEF0
@ =============================================================================
    .global get_big_value
    .type get_big_value, %function

get_big_value:
    LDR     R0, =0x9ABCDEF0     @ 低32位
    LDR     R1, =0x12345678     @ 高32位
    BX      LR                  @ 返回

    .size get_big_value, .-get_big_value

@ =============================================================================
@ 函数: get_pi_float
@ 功能: 验证单精度浮点返回值通过 S0
@
@ 原型: float get_pi_float(void)
@ 返回: S0 = 3.14159265...
@ =============================================================================
    .global get_pi_float
    .type get_pi_float, %function

get_pi_float:
    VLDR    S0, pi_float_value  @ 加载π值到S0
    BX      LR                  @ 返回

    .size get_pi_float, .-get_pi_float

@ =============================================================================
@ 函数: get_pi_double
@ 功能: 验证双精度浮点返回值通过 D0
@
@ 原型: double get_pi_double(void)
@ 返回: D0 = 3.14159265358979...
@ =============================================================================
    .global get_pi_double
    .type get_pi_double, %function

get_pi_double:
    VLDR    D0, pi_double_value @ 加载π值到D0
    BX      LR                  @ 返回

    .size get_pi_double, .-get_pi_double

@ =============================================================================
@ 函数: verify_callee_saved
@ 功能: 验证 callee-saved 寄存器保存（R4-R11）
@       同时演示正确的保存和恢复
@
@ 原型: int verify_callee_saved(int a, int b, int c, int d)
@ 参数: R0=a, R1=b, R2=c, R3=d
@ 返回: R0 = a + b + c + d
@
@ 本函数使用 callee-saved 寄存器（R4, R5, R6）来演示
@ 正确的保存和恢复
@ =============================================================================
    .global verify_callee_saved
    .type verify_callee_saved, %function

verify_callee_saved:
    @ 序言 - 保存 callee-saved 寄存器
    PUSH    {R4-R6, R11, LR}    @ 保存寄存器（5个 = 20字节）
    SUB     SP, SP, #4          @ 对齐到8字节（24字节总计）
    MOV     R11, SP             @ 建立帧指针
    
    @ 使用 callee-saved 寄存器进行计算
    MOV     R4, R0              @ R4 = a
    MOV     R5, R1              @ R5 = b
    MOV     R6, R2              @ R6 = c
    @ R3 仍然包含 d
    
    @ 使用保存的值计算总和
    MOV     R0, R4              @ R0 = a
    ADD     R0, R0, R5          @ R0 = a + b
    ADD     R0, R0, R6          @ R0 = a + b + c
    ADD     R0, R0, R3          @ R0 = a + b + c + d
    
    @ 尾声 - 恢复 callee-saved 寄存器
    ADD     SP, SP, #4          @ 恢复栈对齐
    POP     {R4-R6, R11, PC}    @ 恢复寄存器并返回

    .size verify_callee_saved, .-verify_callee_saved

@ =============================================================================
@ 函数: multiply_accumulate
@ 功能: 演示更复杂的计算，使用多个 callee-saved 寄存器
@
@ 原型: int multiply_accumulate(int a, int b, int c, int d, int e, int f)
@ 参数: R0=a, R1=b, R2=c, R3=d, [SP]=e, [SP+4]=f
@ 返回: R0 = (a*b) + (c*d) + (e*f)
@ =============================================================================
    .global multiply_accumulate
    .type multiply_accumulate, %function

multiply_accumulate:
    @ 序言
    PUSH    {R4-R7, R11, LR}    @ 保存寄存器（6个 = 24字节，已对齐）
    MOV     R11, SP
    
    @ 计算 a*b
    MUL     R4, R0, R1          @ R4 = a * b
    
    @ 计算 c*d
    MUL     R5, R2, R3          @ R5 = c * d
    
    @ 加载栈参数并计算 e*f
    LDR     R6, [SP, #24]       @ R6 = e (跳过保存的6个寄存器)
    LDR     R7, [SP, #28]       @ R7 = f
    MUL     R6, R6, R7          @ R6 = e * f
    
    @ 累加所有结果
    ADD     R0, R4, R5          @ R0 = (a*b) + (c*d)
    ADD     R0, R0, R6          @ R0 = (a*b) + (c*d) + (e*f)
    
    @ 尾声
    POP     {R4-R7, R11, PC}    @ 恢复并返回

    .size multiply_accumulate, .-multiply_accumulate

@ =============================================================================
@ 函数: many_float_params
@ 功能: 验证多个浮点参数传递
@
@ 原型: float many_float_params(float a, float b, float c, float d,
@                               float e, float f, float g, float h)
@ 参数: S0=a, S1=b, S2=c, S3=d, S4=e, S5=f, S6=g, S7=h
@ 返回: S0 = a + b + c + d + e + f + g + h
@ =============================================================================
    .global many_float_params
    .type many_float_params, %function

many_float_params:
    VADD.F32 S0, S0, S1         @ S0 = a + b
    VADD.F32 S0, S0, S2         @ S0 += c
    VADD.F32 S0, S0, S3         @ S0 += d
    VADD.F32 S0, S0, S4         @ S0 += e
    VADD.F32 S0, S0, S5         @ S0 += f
    VADD.F32 S0, S0, S6         @ S0 += g
    VADD.F32 S0, S0, S7         @ S0 += h
    BX      LR                  @ 返回

    .size many_float_params, .-many_float_params

@ =============================================================================
@ 数据段
@ =============================================================================
    .section .rodata
    .align 2

pi_float_value:
    .float 3.14159265358979323846

    .align 3
pi_double_value:
    .double 3.14159265358979323846

@ =============================================================================
@ 文件结束
@ =============================================================================
