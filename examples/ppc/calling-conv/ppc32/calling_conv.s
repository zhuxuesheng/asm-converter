# PowerPC 32-bit Calling Convention Examples
# 验证PPC32调用约定

    .text

# ============================================================================
# int asm_add(int a, int b)
# 参数: r3=a, r4=b
# 返回: r3=a+b
# ============================================================================
    .globl asm_add
    .type asm_add, @function
asm_add:
    add     r3, r3, r4          # r3 = a + b
    blr
    .size asm_add, .-asm_add

# ============================================================================
# int asm_sum_eight(int a, int b, int c, int d, int e, int f, int g, int h)
# 参数: r3-r10
# 返回: r3=sum
# ============================================================================
    .globl asm_sum_eight
    .type asm_sum_eight, @function
asm_sum_eight:
    add     r3, r3, r4          # a + b
    add     r3, r3, r5          # + c
    add     r3, r3, r6          # + d
    add     r3, r3, r7          # + e
    add     r3, r3, r8          # + f
    add     r3, r3, r9          # + g
    add     r3, r3, r10         # + h
    blr
    .size asm_sum_eight, .-asm_sum_eight

# ============================================================================
# int asm_sum_nine(int a, int b, int c, int d, int e, int f, int g, int h, int i)
# 参数: r3-r10, [SP+8]=i
# 返回: r3=sum
# ============================================================================
    .globl asm_sum_nine
    .type asm_sum_nine, @function
asm_sum_nine:
    add     r3, r3, r4
    add     r3, r3, r5
    add     r3, r3, r6
    add     r3, r3, r7
    add     r3, r3, r8
    add     r3, r3, r9
    add     r3, r3, r10
    lwz     r11, 8(r1)          # 从栈加载第9个参数
    add     r3, r3, r11
    blr
    .size asm_sum_nine, .-asm_sum_nine


# ============================================================================
# long long asm_add64(long long a, long long b)
# 参数: r3-r4=a, r5-r6=b (64位参数使用寄存器对)
# 返回: r3-r4=result
# ============================================================================
    .globl asm_add64
    .type asm_add64, @function
asm_add64:
    addc    r3, r3, r5          # 低32位相加，设置进位
    adde    r4, r4, r6          # 高32位相加（带进位）
    blr
    .size asm_add64, .-asm_add64

# ============================================================================
# double asm_sum_floats(double a, double b, double c, double d)
# 参数: f1=a, f2=b, f3=c, f4=d
# 返回: f1=sum
# ============================================================================
    .globl asm_sum_floats
    .type asm_sum_floats, @function
asm_sum_floats:
    fadd    f1, f1, f2          # a + b
    fadd    f1, f1, f3          # + c
    fadd    f1, f1, f4          # + d
    blr
    .size asm_sum_floats, .-asm_sum_floats

# ============================================================================
# double asm_mixed_params(int n, double x, int m, double y)
# 参数: r3=n, f1=x, r4=m, f2=y
# 返回: f1 = n + x + m + y
# ============================================================================
    .globl asm_mixed_params
    .type asm_mixed_params, @function
asm_mixed_params:
    stwu    r1, -32(r1)         # 分配栈帧
    
    # 将整数转换为浮点
    # 使用栈作为临时存储
    xoris   r3, r3, 0x8000      # 转换为无符号偏移
    stw     r3, 8(r1)
    lis     r0, 0x4330
    stw     r0, 12(r1)
    lfd     f3, 8(r1)
    lis     r0, 0x4330
    stw     r0, 16(r1)
    lis     r0, 0x8000
    stw     r0, 20(r1)
    lfd     f0, 16(r1)
    fsub    f3, f3, f0          # f3 = n (as double)
    
    xoris   r4, r4, 0x8000
    stw     r4, 8(r1)
    lis     r0, 0x4330
    stw     r0, 12(r1)
    lfd     f4, 8(r1)
    fsub    f4, f4, f0          # f4 = m (as double)
    
    # 计算 n + x + m + y
    fadd    f1, f3, f1          # n + x
    fadd    f1, f1, f4          # + m
    fadd    f1, f1, f2          # + y
    
    addi    r1, r1, 32          # 释放栈帧
    blr
    .size asm_mixed_params, .-asm_mixed_params
