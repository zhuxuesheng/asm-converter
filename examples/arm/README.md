# ARM 平台验证示例

本目录包含 ARM 平台（ARM32 和 ARM64）的汇编调用约定验证脚本和示例。

## 调用约定

### ARM32 (AAPCS - ARM Architecture Procedure Call Standard)

- **参数寄存器**: R0-R3 (前 4 个参数)
- **返回值**: R0 (32位), R0-R1 (64位)
- **栈对齐**: 8 字节对齐
- **Caller-saved**: R0-R3, R12
- **Callee-saved**: R4-R11, LR

### ARM64 (AAPCS64)

- **参数寄存器**: X0-X7 (整数/指针), V0-V7 (浮点/SIMD)
- **返回值**: X0 (整数), V0 (浮点)
- **栈对齐**: 16 字节对齐
- **Caller-saved**: X0-X18, V0-V7, V16-V31
- **Callee-saved**: X19-X28, V8-V15

## 目录结构

```
arm/
├── arm32/           # ARM32 (AAPCS) 示例
│   ├── calling-conv/
│   └── Makefile
├── arm64/           # ARM64 (AAPCS64) 示例
│   ├── calling-conv/
│   └── Makefile
└── Makefile         # 主构建脚本
```

## 验证方式

由于大多数开发环境是 x86/x64，ARM 示例需要通过以下方式验证：

### 1. 交叉编译 + QEMU 模拟

```bash
# 安装交叉编译工具链
# Ubuntu/Debian:
sudo apt install gcc-arm-linux-gnueabihf    # ARM32
sudo apt install gcc-aarch64-linux-gnu       # ARM64

# 安装 QEMU
sudo apt install qemu-user qemu-user-static

# 编译并运行
make CROSS_COMPILE=arm-linux-gnueabihf- arm32
qemu-arm ./arm32/program

make CROSS_COMPILE=aarch64-linux-gnu- arm64
qemu-aarch64 ./arm64/program
```

### 2. 原生 ARM 设备

在 Raspberry Pi 或其他 ARM 设备上直接编译运行：

```bash
make all
make test
```

### 3. Apple Silicon Mac (ARM64)

在 M1/M2 Mac 上可以原生运行 ARM64 示例：

```bash
cd arm64
make all
make test
```

## 工具要求

### 交叉编译环境 (x86/x64 主机)
- **arm-linux-gnueabihf-gcc**: ARM32 交叉编译器
- **aarch64-linux-gnu-gcc**: ARM64 交叉编译器
- **QEMU**: 用户态模拟器

### 原生 ARM 环境
- **GCC**: GNU Compiler Collection
- **GAS**: GNU Assembler
- **Make**

## 安装交叉编译工具

### Ubuntu/Debian
```bash
# ARM32
sudo apt install gcc-arm-linux-gnueabihf binutils-arm-linux-gnueabihf

# ARM64
sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu

# QEMU
sudo apt install qemu-user qemu-user-static
```

### Windows (WSL)
在 WSL 中使用与 Ubuntu 相同的命令。

### macOS (Homebrew)
```bash
# ARM64 交叉编译器
brew install aarch64-elf-gcc

# 或使用 Docker
docker run --rm -v $(pwd):/work -w /work arm64v8/gcc make
```

## 示例说明

### arm32/calling-conv/
验证 AAPCS 的示例：
- R0-R3 参数传递
- 栈参数传递
- 返回值处理
- 寄存器保存规则

### arm64/calling-conv/
验证 AAPCS64 的示例：
- X0-X7 参数传递
- 浮点参数 (V0-V7)
- 返回值处理
- 栈帧结构

## ARM 汇编语法

### ARM32 示例
```asm
.text
.global main
.type main, %function

main:
    push {lr}           @ 保存返回地址
    mov r0, #42         @ 第一个参数
    mov r1, #10         @ 第二个参数
    bl add_numbers      @ 调用函数
    pop {pc}            @ 返回

add_numbers:
    add r0, r0, r1      @ r0 = r0 + r1
    bx lr               @ 返回
```

### ARM64 示例
```asm
.text
.global main
.type main, %function

main:
    stp x29, x30, [sp, #-16]!   // 保存帧指针和返回地址
    mov x29, sp
    
    mov x0, #42                  // 第一个参数
    mov x1, #10                  // 第二个参数
    bl add_numbers               // 调用函数
    
    ldp x29, x30, [sp], #16     // 恢复并返回
    ret

add_numbers:
    add x0, x0, x1              // x0 = x0 + x1
    ret
```

## 调试技巧

### 使用 QEMU + GDB
```bash
# 启动 QEMU 调试服务器
qemu-arm -g 1234 ./program

# 在另一个终端连接 GDB
arm-linux-gnueabihf-gdb ./program
(gdb) target remote localhost:1234
(gdb) break main
(gdb) continue
(gdb) info registers
```

### 使用 GDB (原生)
```bash
gdb ./program
(gdb) break main
(gdb) run
(gdb) info registers
```

## ARM32 vs ARM64 对比

| 特性 | ARM32 (AAPCS) | ARM64 (AAPCS64) |
|------|---------------|-----------------|
| 参数寄存器 | R0-R3 | X0-X7 |
| 浮点参数 | S0-S15/D0-D7 | V0-V7 |
| 返回值 | R0(-R1) | X0(-X1) |
| 栈对齐 | 8 字节 | 16 字节 |
| 链接寄存器 | LR (R14) | LR (X30) |
| 帧指针 | FP (R11) | FP (X29) |

## 参考资料

- [ARM AAPCS](https://developer.arm.com/documentation/ihi0042/latest)
- [ARM AAPCS64](https://developer.arm.com/documentation/ihi0055/latest)
- [ARM 指令集参考](https://developer.arm.com/documentation/ddi0487/latest)
