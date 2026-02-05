# PowerPC 调用约定验证示例

本目录包含PowerPC调用约定的验证示例代码。

## 目录结构

```
ppc/calling-conv/
├── ppc32/
│   ├── calling_conv.s    # PPC32汇编实现
│   ├── main.c            # C测试程序
│   └── Makefile          # 构建脚本
├── ppc64/
│   ├── calling_conv.s    # PPC64汇编实现（ELFv2）
│   ├── main.c            # C测试程序
│   └── Makefile          # 构建脚本
└── README.md
```

## 验证内容

### PPC32
- GPR3-GPR10参数传递
- 64位参数对齐规则
- 浮点参数传递（FPR1-FPR8）
- 返回值规则
- 栈帧结构

### PPC64 (ELFv2)
- GPR3-GPR10参数传递
- 浮点参数传递（FPR1-FPR13）
- TOC指针使用
- 双入口点机制
- Red Zone使用

## 构建要求

### 交叉编译工具链

```bash
# Ubuntu/Debian
sudo apt-get install gcc-powerpc-linux-gnu      # PPC32
sudo apt-get install gcc-powerpc64le-linux-gnu  # PPC64 LE

# Fedora
sudo dnf install gcc-powerpc64-linux-gnu
sudo dnf install gcc-powerpc64le-linux-gnu
```

### QEMU用户模式

```bash
# Ubuntu/Debian
sudo apt-get install qemu-user qemu-user-static

# Fedora
sudo dnf install qemu-user qemu-user-static
```

## 构建和运行

### PPC32

```bash
cd ppc32
make
# 使用QEMU运行
qemu-ppc ./test_calling_conv
```

### PPC64 (Little-Endian)

```bash
cd ppc64
make
# 使用QEMU运行
qemu-ppc64le ./test_calling_conv
```

## 验证函数

| 函数 | 说明 |
|------|------|
| `asm_add` | 基本整数加法 |
| `asm_sum_eight` | 8个寄存器参数求和 |
| `asm_sum_nine` | 9个参数求和（含栈参数） |
| `asm_add64` | 64位整数加法 |
| `asm_sum_floats` | 浮点参数求和 |
| `asm_mixed_params` | 混合整数和浮点参数 |

## 预期输出

```
=== PowerPC Calling Convention Test ===
asm_add(10, 20) = 30 [PASS]
asm_sum_eight(1,2,3,4,5,6,7,8) = 36 [PASS]
asm_sum_nine(1,2,3,4,5,6,7,8,9) = 45 [PASS]
asm_add64(0x100000000, 0x200000000) = 0x300000000 [PASS]
asm_sum_floats(1.0, 2.0, 3.0, 4.0) = 10.0 [PASS]
All tests passed!
```
