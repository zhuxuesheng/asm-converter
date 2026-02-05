# Linux x64 验证示例

本目录包含 Linux x64 平台的汇编调用约定验证脚本和示例。

## 调用约定

Linux x64 使用 **System V AMD64 ABI**：

- **参数寄存器**: RDI, RSI, RDX, RCX, R8, R9 (整数/指针), XMM0-XMM7 (浮点)
- **返回值**: RAX, RDX (整数), XMM0, XMM1 (浮点)
- **Red Zone**: RSP 以下 128 字节可用，无需调整栈指针
- **栈对齐**: 16 字节对齐 (call 指令前)
- **Caller-saved**: RAX, RCX, RDX, RSI, RDI, R8-R11, XMM0-XMM15
- **Callee-saved**: RBX, RBP, R12-R15

## 目录结构

```
linux-x64/
├── calling-conv/    # System V ABI 验证示例
├── syscall/         # Linux 系统调用示例
├── interop/         # C/Go 互操作示例
└── Makefile         # 构建脚本
```

## 工具要求

- **NASM** 或 **GAS** (GNU Assembler)
- **GCC** >= 9.0
- **Go** >= 1.17 (用于 Go 汇编示例)
- **Make**

## 构建方法

```bash
make all        # 构建所有示例
make test       # 运行测试
make clean      # 清理构建产物
```

## 在 Windows 上验证 (WSL)

如果在 Windows 上开发，可以使用 WSL (Windows Subsystem for Linux)：

```bash
# 在 WSL 中
cd /mnt/c/path/to/examples/linux-x64
make all
make test
```

## 示例说明

### calling-conv/
验证 System V AMD64 ABI 的示例：
- 参数传递顺序 (RDI, RSI, RDX, RCX, R8, R9)
- 浮点参数 (XMM0-XMM7)
- Red Zone 使用
- 大型返回值处理

### syscall/
Linux 系统调用示例：
- 使用 syscall 指令
- 系统调用号 (RAX)
- 参数传递 (RDI, RSI, RDX, R10, R8, R9)

### interop/
语言互操作示例：
- C 调用汇编函数
- 汇编调用 C 库函数
- Go 汇编示例

## System V vs Microsoft x64 对比

| 特性 | System V AMD64 | Microsoft x64 |
|------|----------------|---------------|
| 参数寄存器 | RDI, RSI, RDX, RCX, R8, R9 | RCX, RDX, R8, R9 |
| 浮点参数 | XMM0-XMM7 | XMM0-XMM3 |
| Red Zone | 128 字节 | 无 |
| Shadow Space | 无 | 32 字节 |
| Callee-saved | RBX, RBP, R12-R15 | RBX, RBP, RDI, RSI, R12-R15 |

## 调试技巧

### 使用 GDB
```bash
gdb ./program
(gdb) break main
(gdb) run
(gdb) info registers
(gdb) x/8xg $rsp
```

### 使用 strace 跟踪系统调用
```bash
strace ./program
```

## 参考资料

- [System V AMD64 ABI](https://gitlab.com/x86-psABIs/x86-64-ABI)
- [Linux 系统调用表](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/)
