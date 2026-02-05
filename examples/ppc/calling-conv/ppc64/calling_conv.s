# PowerPC 64-bit (ELFv2) Calling Convention Examples
# 验证PPC64 ELFv2调用约定

    .abiversion 2
    .text

# ============================================================================
# long asm_add(long a, long b)
# 参数: r3=a, r4=b
# 返回: r3=a+b
# ============================================================================
    .globl asm_add
    .type asm_add, @function
asm_add:
0:  addis   r2, r12, .TOC.-0b@ha
    addi    r2, r2, .TOC.-0b@l
.Lasm_add_lep:
    .localentry asm_add, .-asm_add
    add     r3, r3, r4
    blr
    .size asm_add, .-asm_add

# ============================================================================
# long asm_sum_eight(long a-h)
# 参数: r3-r10
# 返回: r3=sum
# ============================================================================
    .globl asm_sum_eight
    .type asm_sum_eight, @function
asm_sum_eight:
0:  addis   r2, r12, .TOC.-0b@ha
    addi    r2, r2, .TOC.-0b@l
.Lasm_sum_eight_lep:
    .localentry asm_sum_eight, .-asm_sum_eight
    add     r3, r3, r4
    add     r3, r3, r5
    add     r3, r3, r6
    add     r3, r3, r7
    add     r3, r3, r8
    add     r3, r3, r9
    add     r3, r3, r10
    blr
    .size asm_sum_eight, .-asm_sum_eight

# ============================================================================
# long asm_sum_nine(long a-i)
# 参数: r3-r10, [SP+32]=i (ELFv2)
# 返回: r3=sum
# ============================================================================
    .globl asm_sum_nine
    .type asm_sum_nine, @function
asm_sum_nine:
0:  addis   r2, r12, .TOC.-0b@ha
    addi    r2, r2, .TOC.-0b@l
.Lasm_sum_nine_lep:
    .localentry asm_sum_nine, .-asm_sum_nine
    add     r3, r3, r4
    add     r3, r3, r5
    add     r3, r3, r6
    add     r3, r3, r7
    add     r3, r3, r8
    add     r3, r3, r9
    add     r3, r3, r10
    ld      r11, 32(r1)         # ELFv2: 参数保存区从SP+32开始
    add     r3, r3, r11
    blr
    .size asm_sum_nine, .-asm_sum_nine


# ============================================================================
# double asm_sum_floats(double a, double b, double c, double d)
# 参数: f1=a, f2=b, f3=c, f4=d
# 返回: f1=sum
# ============================================================================
    .globl asm_sum_floats
    .type asm_sum_floats, @function
asm_sum_floats:
0:  addis   r2, r12, .TOC.-0b@ha
    addi    r2, r2, .TOC.-0b@l
.Lasm_sum_floats_lep:
    .localentry asm_sum_floats, .-asm_sum_floats
    fadd    f1, f1, f2
    fadd    f1, f1, f3
    fadd    f1, f1, f4
    blr
    .size asm_sum_floats, .-asm_sum_floats

# ============================================================================
# long asm_call_helper(long x)
# 演示函数调用和TOC保存
# ============================================================================
    .globl asm_call_helper
    .type asm_call_helper, @function
asm_call_helper:
0:  addis   r2, r12, .TOC.-0b@ha
    addi    r2, r2, .TOC.-0b@l
.Lasm_call_helper_lep:
    .localentry asm_call_helper, .-asm_call_helper
    
    mflr    r0
    std     r0, 16(r1)
    stdu    r1, -48(r1)
    std     r2, 24(r1)          # 保存TOC
    
    # 调用 asm_add(x, x)
    mr      r4, r3              # r4 = x
    bl      asm_add
    nop                         # TOC恢复占位符
    
    ld      r2, 24(r1)          # 恢复TOC
    
    addi    r1, r1, 48
    ld      r0, 16(r1)
    mtlr    r0
    blr
    .size asm_call_helper, .-asm_call_helper

# ============================================================================
# 使用Red Zone的叶子函数示例
# long asm_leaf_redzone(long a, long b, long c)
# ============================================================================
    .globl asm_leaf_redzone
    .type asm_leaf_redzone, @function
asm_leaf_redzone:
0:  addis   r2, r12, .TOC.-0b@ha
    addi    r2, r2, .TOC.-0b@l
.Lasm_leaf_redzone_lep:
    .localentry asm_leaf_redzone, .-asm_leaf_redzone
    
    # 使用Red Zone保存寄存器（无需分配栈帧）
    std     r14, -8(r1)
    std     r15, -16(r1)
    
    mr      r14, r3
    mr      r15, r4
    add     r3, r14, r15
    add     r3, r3, r5
    
    ld      r14, -8(r1)
    ld      r15, -16(r1)
    blr
    .size asm_leaf_redzone, .-asm_leaf_redzone
