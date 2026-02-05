# macOS 验证示例

本目录包含 macOS 平台的汇编调用约定验证脚本和示例。

## 调用约定

macOS 在 x64 架构上使用 **System V AMD64 ABI**（与 Linux 相同），但有一些 macOS 特有的差异：

- **参数寄存器**: RDI, RSI, RDX, RCX, R8, R9 (整数/指针), XMM0-XMM7 (浮点)
- **返回值**: RAX, RDX (整数), XMM0, XMM1 (浮点)
- **Red Zone**: RSP 以下 128 字节可用
- **栈对齐**: 16 字节对齐 (call 指令前)

### macOS 特有差异

1. **系统调用**: 使用 `syscall` 指令，但系统调用号需要加上 `0x2000000`
2. **Mach-O 格式**: 使用 Mach-O 可执行文件格式（非 ELF）
3. **段名称**: 使用 `__TEXT` 和 `__DATA` 段名
4. **位置无关代码**: 默认要求 PIC (Position Independent Code)

## 目录结构

```
macos/
├── calling-conv/    # System V ABI 验证示例
├── syscall/         # macOS 系统调用示例
├── interop/         # C/Go 互操作示例
└── Makefile         # 构建脚本
```

## 工具要求

- **Xcode Command Line Tools** (包含 clang, as, ld)
- **NASM** (可通过 Homebrew 安装: `brew install nasm`)
- **Go** >= 1.17 (用于 Go 汇编示例)

## 安装工具

```bash
# 安装 Xcode Command Line Tools
xcode-select --install

# 安装 NASM
brew install nasm

# 安装 Go
brew install go
```

## 构建方法

```bash
make all        # 构建所有示例
make test       # 运行测试
make clean      # 清理构建产物
```

## 示例说明

### calling-conv/
验证 System V AMD64 ABI 的示例：
- 参数传递
- Red Zone 使用
- 浮点参数处理

### syscall/
macOS 系统调用示例：
- Mach 系统调用
- BSD 系统调用 (syscall 号 + 0x2000000)
- 常用系统调用封装

### interop/
语言互操作示例：
- C 调用汇编函数
- 汇编调用 C 库函数
- Go 汇编示例

## macOS 汇编语法注意事项

### NASM (Intel 语法)
```nasm
; macOS 需要使用 macho64 格式
; nasm -f macho64 file.asm

section .text
global _main        ; macOS 符号需要下划线前缀

_main:
    ; 系统调用号需要加 0x2000000
    mov rax, 0x2000001  ; exit syscall
    mov rdi, 0
    syscall
```

### GAS (AT&T 语法)
```gas
.section __TEXT,__text
.globl _main

_main:
    movq $0x2000001, %rax
    xorq %rdi, %rdi
    syscall
```

## macOS vs Linux 差异

| 特性 | macOS | Linux |
|------|-------|-------|
| 可执行格式 | Mach-O | ELF |
| 符号前缀 | 需要 `_` | 不需要 |
| syscall 基址 | 0x2000000 | 0 |
| 段名称 | `__TEXT`, `__DATA` | `.text`, `.data` |
| 默认 PIC | 是 | 否 |

## 调试技巧

### 使用 LLDB
```bash
lldb ./program
(lldb) breakpoint set --name main
(lldb) run
(lldb) register read
(lldb) memory read --size 8 --count 8 $rsp
```

### 使用 dtruss 跟踪系统调用
```bash
sudo dtruss ./program
```

## ARM64 (Apple Silicon) 注意事项

对于 Apple Silicon (M1/M2) Mac：
- 使用 ARM64 调用约定 (AAPCS64)
- 参数寄存器: X0-X7
- 返回值: X0, X1
- 系统调用使用 `svc #0x80`

## 参考资料

- [macOS ABI 参考](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/LowLevelABI/000-Introduction/introduction.html)
- [Mach-O 格式参考](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/CodeFootprint/Articles/MachOOverview.html)
