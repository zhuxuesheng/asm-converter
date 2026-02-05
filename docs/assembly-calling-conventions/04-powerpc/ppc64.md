# PPC64 调用约定详解

> PowerPC 64位架构过程调用标准完整规范，包含ELFv1和ELFv2 ABI差异、TOC指针、函数描述符

## 概述

PPC64调用约定是PowerPC 64位架构的标准过程调用约定。由于历史原因，存在两个主要的ABI版本：

- **ELFv1 ABI**：传统ABI，使用函数描述符，主要用于AIX和早期Linux（Big-Endian）
- **ELFv2 ABI**：现代ABI，简化设计，主要用于Linux（Little-Endian）和新版Big-Endian系统

### ABI版本对比概览

| 特性 | ELFv1 ABI | ELFv2 ABI |
|------|-----------|-----------|
| **字节序** | Big-Endian | Little-Endian（主要）/ Big-Endian |
| **函数描述符** | 必需 | 不使用 |
| **TOC指针** | r2（必须保存） | r2（调用者保存） |
| **全局入口点** | 通过描述符 | 函数地址 + 0 |
| **局部入口点** | 无 | 函数地址 + 8 |
| **参数保存区** | 必需（64字节） | 可选 |
| **栈对齐** | 16字节 | 16字节 |
| **Red Zone** | 288字节 | 512字节 |

### 核心特性概览

| 特性 | 规范 |
|------|------|
| **整数参数寄存器** | GPR3-GPR10（8个） |
| **浮点参数寄存器** | FPR1-FPR13（13个） |
| **向量参数寄存器** | VR2-VR13（12个） |
| **整数返回值** | GPR3（64位）/ GPR3-GPR4（128位） |
| **浮点返回值** | FPR1-FPR4 |
| **栈对齐** | 16字节 |
| **栈清理** | 调用者（Caller） |


---

## 寄存器分类

### 通用寄存器概览

PPC64提供32个64位通用寄存器（GPR）：

| 寄存器 | 别名 | 用途 | 保存责任 |
|--------|------|------|----------|
| GPR0 | r0 | 特殊用途（不可用于寻址基址） | Volatile |
| GPR1 | r1/SP | 栈指针 | 专用 |
| GPR2 | r2/TOC | TOC指针 | 专用（见ABI差异） |
| GPR3 | r3 | 参数1 / 返回值 | Volatile |
| GPR4 | r4 | 参数2 / 返回值（128位高位） | Volatile |
| GPR5 | r5 | 参数3 | Volatile |
| GPR6 | r6 | 参数4 | Volatile |
| GPR7 | r7 | 参数5 | Volatile |
| GPR8 | r8 | 参数6 | Volatile |
| GPR9 | r9 | 参数7 | Volatile |
| GPR10 | r10 | 参数8 | Volatile |
| GPR11 | r11 | 环境指针 | Volatile |
| GPR12 | r12 | 函数入口地址/临时 | Volatile |
| GPR13 | r13 | 线程指针 | 专用 |
| GPR14-GPR31 | r14-r31 | 被调用者保存寄存器 | Non-volatile |

### 调用者保存寄存器（Volatile）

```
Caller-saved 寄存器:
┌─────────────────────────────────────────────────────────────────────────────┐
│  r0   │  r3   │  r4   │  r5   │  r6   │  r7   │  r8   │  r9   │  r10  │     │
│ 特殊  │ 参数1 │ 参数2 │ 参数3 │ 参数4 │ 参数5 │ 参数6 │ 参数7 │ 参数8 │     │
├───────┴───────┴───────┴───────┴───────┴───────┴───────┴───────┴───────┤     │
│  r11  │  r12  │                                                       │     │
│ 环境  │ 入口  │                                                       │     │
└───────┴───────┴───────────────────────────────────────────────────────┴─────┘
```

### 被调用者保存寄存器（Non-volatile）

```
Callee-saved 寄存器:
┌─────────────────────────────────────────────────────────────────────────────┐
│  r14  │  r15  │  r16  │  r17  │  r18  │  r19  │  r20  │  r21  │  r22  │     │
├───────┼───────┼───────┼───────┼───────┼───────┼───────┼───────┼───────┤     │
│  r23  │  r24  │  r25  │  r26  │  r27  │  r28  │  r29  │  r30  │  r31  │     │
└───────┴───────┴───────┴───────┴───────┴───────┴───────┴───────┴───────┴─────┘
```

### 浮点寄存器

| 寄存器 | 用途 | 保存责任 |
|--------|------|----------|
| f0 | 临时寄存器 | Volatile |
| f1-f13 | 参数传递/返回值 | Volatile |
| f14-f31 | 被调用者保存 | Non-volatile |

### 向量寄存器（VMX/Altivec）

| 寄存器 | 用途 | 保存责任 |
|--------|------|----------|
| v0-v1 | 临时寄存器 | Volatile |
| v2-v13 | 参数传递 | Volatile |
| v14-v19 | 临时寄存器 | Volatile |
| v20-v31 | 被调用者保存 | Non-volatile |

### 特殊寄存器

| 寄存器 | 全称 | 用途 | 保存责任 |
|--------|------|------|----------|
| **LR** | Link Register | 返回地址 | Volatile |
| **CTR** | Count Register | 循环计数/间接分支 | Volatile |
| **CR** | Condition Register | 条件码 | CR2-CR4: Non-volatile |
| **XER** | Exception Register | 溢出/进位标志 | Volatile |
| **VRSAVE** | Vector Save Register | 向量寄存器使用掩码 | Non-volatile |


---

## ELFv1 ABI 详解

### 函数描述符

ELFv1 ABI的核心特性是**函数描述符**（Function Descriptor）。每个函数通过一个24字节的描述符来引用：

```
函数描述符结构（24字节）:
┌─────────────────────────────────────────┐
│  +0:  函数入口地址（8字节）             │
├─────────────────────────────────────────┤
│  +8:  TOC指针值（8字节）                │
├─────────────────────────────────────────┤
│  +16: 环境指针（8字节，通常为0）        │
└─────────────────────────────────────────┘
```

### 函数调用流程（ELFv1）

```asm
# ELFv1 函数调用
# 假设 r11 指向目标函数的描述符

    ld      r0, 0(r11)          # 加载函数入口地址
    ld      r2, 8(r11)          # 加载目标函数的TOC
    mtctr   r0                  # 设置CTR为入口地址
    ld      r11, 16(r11)        # 加载环境指针（可选）
    bctrl                       # 调用函数
    
    # 调用返回后，必须恢复自己的TOC
    ld      r2, 40(r1)          # 从栈上恢复TOC
```

### TOC指针（r2）

TOC（Table of Contents）是PPC64用于访问全局数据的机制：

- **r2寄存器**：始终指向当前模块的TOC
- **TOC基址**：指向.got + 0x8000的位置
- **访问范围**：通过16位有符号偏移访问±32KB范围

```asm
# 通过TOC访问全局变量
    ld      r3, global_var@toc(r2)    # 加载全局变量
    
# TOC相对寻址
    addis   r3, r2, global_var@toc@ha  # 高位调整
    ld      r3, global_var@toc@l(r3)   # 低位偏移
```

### ELFv1 栈帧结构

```
高地址
┌─────────────────────────────────────────────────────────────────────────────┐
│                        调用者栈帧                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                     参数保存区（64字节最小）                                │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  [SP+112]: 参数8 (r10)                                              │   │
│  │  [SP+104]: 参数7 (r9)                                               │   │
│  │  [SP+96]:  参数6 (r8)                                               │   │
│  │  [SP+88]:  参数5 (r7)                                               │   │
│  │  [SP+80]:  参数4 (r6)                                               │   │
│  │  [SP+72]:  参数3 (r5)                                               │   │
│  │  [SP+64]:  参数2 (r4)                                               │   │
│  │  [SP+56]:  参数1 (r3)                                               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────────────┤
│                        链接区（48字节）                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  [SP+40]: TOC保存位置                                               │   │
│  │  [SP+32]: 保留                                                      │   │
│  │  [SP+24]: 保留                                                      │   │
│  │  [SP+16]: LR保存位置                                                │   │
│  │  [SP+8]:  CR保存位置                                                │   │
│  │  [SP+0]:  回链指针                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘ ← SP
低地址
```


---

## ELFv2 ABI 详解

### 无函数描述符

ELFv2 ABI最大的改进是**取消了函数描述符**：

- 函数指针直接指向代码
- 简化了函数调用流程
- 减少了内存开销

### 双入口点机制

ELFv2引入了**全局入口点**和**局部入口点**：

```
函数布局:
┌─────────────────────────────────────────┐
│  全局入口点 (GEP)                       │  ← 函数地址 + 0
│  ┌─────────────────────────────────────┐│
│  │  addis r2, r12, .TOC.-func@ha      ││  # 计算TOC
│  │  addi  r2, r2, .TOC.-func@l        ││
│  └─────────────────────────────────────┘│
├─────────────────────────────────────────┤
│  局部入口点 (LEP)                       │  ← 函数地址 + 8
│  ┌─────────────────────────────────────┐│
│  │  # 函数体开始                       ││
│  │  ...                                ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

| 入口点 | 偏移 | 使用场景 |
|--------|------|----------|
| 全局入口点（GEP） | +0 | 跨模块调用、函数指针调用 |
| 局部入口点（LEP） | +8 | 同模块内部调用（TOC已知） |

### 函数调用流程（ELFv2）

```asm
# ELFv2 跨模块调用（通过PLT）
    bl      target_func         # 调用PLT桩
    nop                         # TOC恢复占位符
    
# PLT桩代码
target_func@plt:
    std     r2, 24(r1)          # 保存调用者TOC
    ld      r12, target@got(r2) # 加载目标函数地址
    mtctr   r12                 # 设置CTR
    bctr                        # 跳转到全局入口点

# ELFv2 同模块调用
    bl      local_func          # 直接调用局部入口点
    # 无需恢复TOC
```

### ELFv2 栈帧结构

```
高地址
┌─────────────────────────────────────────────────────────────────────────────┐
│                        调用者栈帧                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                     参数保存区（可选）                                      │
│                   (仅当参数超过寄存器时需要)                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                        链接区（32字节最小）                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  [SP+24]: TOC保存位置                                               │   │
│  │  [SP+16]: LR保存位置                                                │   │
│  │  [SP+8]:  CR保存位置                                                │   │
│  │  [SP+0]:  回链指针                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘ ← SP
低地址
```

### ELFv1 vs ELFv2 栈帧对比

| 区域 | ELFv1 偏移 | ELFv2 偏移 |
|------|------------|------------|
| 回链指针 | SP+0 | SP+0 |
| CR保存 | SP+8 | SP+8 |
| LR保存 | SP+16 | SP+16 |
| TOC保存 | SP+40 | SP+24 |
| 参数保存区起始 | SP+48 | SP+32 |
| 最小链接区大小 | 48字节 | 32字节 |


---

## 参数传递规则

### 整数参数

| 参数位置 | 寄存器 | 说明 |
|----------|--------|------|
| 第1个参数 | r3 | 64位 |
| 第2个参数 | r4 | 64位 |
| 第3个参数 | r5 | 64位 |
| 第4个参数 | r6 | 64位 |
| 第5个参数 | r7 | 64位 |
| 第6个参数 | r8 | 64位 |
| 第7个参数 | r9 | 64位 |
| 第8个参数 | r10 | 64位 |
| 第9个及以后 | 栈 | 参数保存区 |

### 浮点参数

| 参数位置 | 寄存器 | 说明 |
|----------|--------|------|
| 第1-13个浮点参数 | f1-f13 | 64位双精度 |
| 第14个及以后 | 栈 | 8字节对齐 |

### 向量参数

| 参数位置 | 寄存器 | 说明 |
|----------|--------|------|
| 第1-12个向量参数 | v2-v13 | 128位向量 |
| 第13个及以后 | 栈 | 16字节对齐 |

### 参数传递示例

```
函数: void func(long a, double b, long c, double d, __vector e)

参数分配:
┌─────────────────────────────────────────────────────────────────────────────┐
│ 整数参数:                                                                   │
│   a → r3                                                                    │
│   c → r4                                                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ 浮点参数:                                                                   │
│   b → f1                                                                    │
│   d → f2                                                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ 向量参数:                                                                   │
│   e → v2                                                                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 代码示例

```asm
# 函数: long sum_params(long a, long b, long c, long d,
#                       long e, long f, long g, long h, long i)
# 参数: r3-r10=a-h, [SP+参数保存区]=i

    .text
    .globl sum_params
    .type sum_params, @function

sum_params:
    # ELFv2 局部入口点
.Lsum_params_lep:
    # 寄存器参数相加
    add     r3, r3, r4          # r3 = a + b
    add     r3, r3, r5          # r3 += c
    add     r3, r3, r6          # r3 += d
    add     r3, r3, r7          # r3 += e
    add     r3, r3, r8          # r3 += f
    add     r3, r3, r9          # r3 += g
    add     r3, r3, r10         # r3 += h
    
    # 栈参数（ELFv2偏移）
    ld      r11, 32(r1)         # r11 = i
    add     r3, r3, r11         # r3 += i
    
    blr

    .size sum_params, .-sum_params
```


---

## 返回值规则

### 整数返回值

| 返回类型 | 寄存器 | 说明 |
|----------|--------|------|
| ≤64位整数 | r3 | 零扩展或符号扩展 |
| 128位整数 | r3-r4 | r3=低64位，r4=高64位 |
| 指针 | r3 | 64位地址 |

### 浮点返回值

| 返回类型 | 寄存器 | 说明 |
|----------|--------|------|
| float/double | f1 | 单个浮点值 |
| 复数 | f1-f2 | 实部+虚部 |
| 多返回值 | f1-f4 | 最多4个浮点值 |

### 向量返回值

| 返回类型 | 寄存器 | 说明 |
|----------|--------|------|
| 128位向量 | v2 | 单个向量 |

### 结构体返回值

| 结构体大小 | 返回方式 |
|------------|----------|
| ≤16字节（同质浮点） | 浮点寄存器 |
| ≤16字节（同质向量） | 向量寄存器 |
| ≤16字节（其他） | r3-r4 |
| >16字节 | 隐藏指针（r3传入） |

### 返回值代码示例

```asm
# 返回64位整数
# long get_value(void)
get_value:
    li      r3, 42
    blr

# 返回128位整数
# __int128 get_big(void)
get_big:
    li      r3, -1              # 低64位
    li      r4, 0x7FFF          # 高64位
    blr

# 返回浮点数
# double get_pi(void)
get_pi:
    addis   r3, r2, .LC_pi@toc@ha
    lfd     f1, .LC_pi@toc@l(r3)
    blr

.section .rodata
.LC_pi:
    .double 3.14159265358979
```

---

## Red Zone

### Red Zone 定义

Red Zone是栈指针以下的一段内存区域，叶子函数可以使用而无需调整栈指针：

| ABI版本 | Red Zone 大小 |
|---------|---------------|
| ELFv1 | 288字节 |
| ELFv2 | 512字节 |

```
栈布局（含Red Zone）:
高地址
┌─────────────────────────────────────────┐
│           栈帧内容                      │
├─────────────────────────────────────────┤ ← SP
│                                         │
│           Red Zone                      │
│        (ELFv2: 512字节)                 │
│                                         │
└─────────────────────────────────────────┘
低地址
```

### Red Zone 使用规则

1. **仅叶子函数可用**：不调用其他函数的函数
2. **信号安全**：内核保证不会破坏Red Zone
3. **无需调整SP**：可直接使用负偏移访问

```asm
# 使用Red Zone的叶子函数
leaf_func:
    # 无需分配栈帧
    std     r14, -8(r1)         # 保存到Red Zone
    std     r15, -16(r1)
    
    # 函数体...
    
    ld      r14, -8(r1)         # 从Red Zone恢复
    ld      r15, -16(r1)
    blr
```


---

## 函数序言和尾声

### ELFv2 标准函数

```asm
# ELFv2 标准函数模板
    .text
    .globl my_function
    .type my_function, @function

my_function:
    # 全局入口点 (GEP) - 用于跨模块调用
0:  addis   r2, r12, .TOC.-0b@ha
    addi    r2, r2, .TOC.-0b@l
    
    # 局部入口点 (LEP) - 用于模块内调用
.Lmy_function_lep:
    .localentry my_function, .-my_function
    
    # ===== 函数序言 =====
    mflr    r0                  # 获取LR
    std     r0, 16(r1)          # 保存LR
    stdu    r1, -64(r1)         # 分配栈帧，更新回链
    
    # 保存被调用者保存寄存器（如需要）
    std     r14, 32(r1)
    std     r15, 40(r1)
    
    # ===== 函数体 =====
    # ...
    
    # ===== 函数尾声 =====
    ld      r14, 32(r1)         # 恢复寄存器
    ld      r15, 40(r1)
    
    addi    r1, r1, 64          # 释放栈帧
    ld      r0, 16(r1)          # 恢复LR
    mtlr    r0
    blr                         # 返回

    .size my_function, .-my_function
```

### ELFv1 标准函数

```asm
# ELFv1 标准函数模板
    .section ".opd", "aw"
    .globl my_function
my_function:
    .quad   .my_function, .TOC.@tocbase, 0
    .type   my_function, @function

    .text
.my_function:
    # ===== 函数序言 =====
    mflr    r0                  # 获取LR
    std     r0, 16(r1)          # 保存LR
    std     r2, 40(r1)          # 保存TOC（ELFv1特有）
    stdu    r1, -112(r1)        # 分配栈帧（含参数保存区）
    
    # ===== 函数体 =====
    # ...
    
    # ===== 函数尾声 =====
    addi    r1, r1, 112         # 释放栈帧
    ld      r0, 16(r1)          # 恢复LR
    mtlr    r0
    blr                         # 返回

    .size .my_function, .-.my_function
```

### 跨模块调用示例

```asm
# ELFv2 调用外部函数
call_external:
    mflr    r0
    std     r0, 16(r1)
    stdu    r1, -48(r1)
    std     r2, 24(r1)          # 保存TOC
    
    # 准备参数
    li      r3, 42
    
    # 调用外部函数
    bl      external_func
    nop                         # TOC恢复占位符（链接器可能修改）
    
    ld      r2, 24(r1)          # 恢复TOC
    
    addi    r1, r1, 48
    ld      r0, 16(r1)
    mtlr    r0
    blr
```

---

## 可变参数函数

### ELFv2 可变参数处理

```asm
# int sum_varargs(int count, ...)
# ELFv2 ABI

    .text
    .globl sum_varargs
    .type sum_varargs, @function

sum_varargs:
0:  addis   r2, r12, .TOC.-0b@ha
    addi    r2, r2, .TOC.-0b@l
.Lsum_varargs_lep:
    .localentry sum_varargs, .-sum_varargs
    
    mflr    r0
    std     r0, 16(r1)
    stdu    r1, -96(r1)
    
    # 将寄存器参数保存到参数保存区
    std     r4, 40(r1)          # 第2个参数
    std     r5, 48(r1)          # 第3个参数
    std     r6, 56(r1)          # 第4个参数
    std     r7, 64(r1)          # 第5个参数
    std     r8, 72(r1)          # 第6个参数
    std     r9, 80(r1)          # 第7个参数
    std     r10, 88(r1)         # 第8个参数
    
    # 初始化
    li      r11, 0              # sum = 0
    mr      r12, r3             # count
    addi    r4, r1, 40          # 指向第一个可变参数
    
.Lloop:
    cmpdi   r12, 0
    beq     .Ldone
    
    ld      r5, 0(r4)           # 加载参数
    add     r11, r11, r5        # sum += 参数
    addi    r4, r4, 8           # 下一个参数
    addi    r12, r12, -1        # count--
    b       .Lloop

.Ldone:
    mr      r3, r11             # 返回sum
    
    addi    r1, r1, 96
    ld      r0, 16(r1)
    mtlr    r0
    blr

    .size sum_varargs, .-sum_varargs
```


---

## 与C语言互操作

### C调用汇编（ELFv2）

```c
// C代码
extern long asm_add(long a, long b);
extern __int128 asm_add128(__int128 a, __int128 b);

int main() {
    long result = asm_add(10, 20);
    return 0;
}
```

```asm
# 汇编实现（ELFv2）
    .text
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

    .globl asm_add128
    .type asm_add128, @function

asm_add128:
0:  addis   r2, r12, .TOC.-0b@ha
    addi    r2, r2, .TOC.-0b@l
.Lasm_add128_lep:
    .localentry asm_add128, .-asm_add128
    
    # 参数: r3-r4=a, r5-r6=b
    # 返回: r3-r4
    addc    r3, r3, r5          # 低64位
    adde    r4, r4, r6          # 高64位（带进位）
    blr

    .size asm_add128, .-asm_add128
```

### 汇编调用C（ELFv2）

```asm
# 从汇编调用C函数
    .text
    .globl asm_caller
    .type asm_caller, @function

asm_caller:
0:  addis   r2, r12, .TOC.-0b@ha
    addi    r2, r2, .TOC.-0b@l
.Lasm_caller_lep:
    .localentry asm_caller, .-asm_caller
    
    mflr    r0
    std     r0, 16(r1)
    stdu    r1, -48(r1)
    std     r2, 24(r1)          # 保存TOC
    
    # 调用 printf("Hello %d\n", 42)
    addis   r3, r2, .LC_fmt@toc@ha
    addi    r3, r3, .LC_fmt@toc@l
    li      r4, 42
    bl      printf
    nop
    
    ld      r2, 24(r1)          # 恢复TOC
    
    li      r3, 0               # 返回0
    addi    r1, r1, 48
    ld      r0, 16(r1)
    mtlr    r0
    blr

    .size asm_caller, .-asm_caller

    .section .rodata
.LC_fmt:
    .string "Hello %d\n"
```

---

## 参考资料

### 官方规范

- [64-bit PowerPC ELF Application Binary Interface Supplement 1.9](https://refspecs.linuxfoundation.org/ELF/ppc64/PPC-elf64abi.html) (ELFv1)
- [Power Architecture 64-Bit ELF V2 ABI Specification](https://openpowerfoundation.org/specifications/64bitelfabi/) (ELFv2)
- [IBM AIX 64-bit PowerPC ABI](https://www.ibm.com/docs/en/aix)

### 相关文档

- 参见: [PowerPC概述](./overview.md)
- 参见: [PPC32调用约定](./ppc32.md)
- 参见: [PowerPC寄存器参考](./registers.md)
- 参见: [栈帧结构](../07-stack-frames/ppc-frames.md)

### 交叉引用

- [术语表](../appendix/glossary.md)
- [寄存器快速参考](../appendix/register-reference.md)
