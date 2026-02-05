# 汇编调用约定验证示例

本目录包含用于验证汇编调用约定文档中技术内容的代码示例。

## 目录结构

```
examples/
├── windows-x64/     # Windows x64 平台验证示例
├── linux-x64/       # Linux x64 平台验证脚本
├── macos/           # macOS 平台验证脚本
├── arm/             # ARM 平台验证脚本
└── Makefile         # 批量构建和验证脚本
```

## 平台支持

| 平台 | 架构 | 验证方式 |
|------|------|----------|
| Windows | x64 | 直接编译运行 |
| Linux | x64 | 原生或 WSL |
| macOS | x64/ARM64 | 原生或交叉编译 |
| ARM | ARM32/ARM64 | QEMU 或交叉编译 |

## 工具要求

### Windows x64 (主要开发平台)
- **NASM**: Netwide Assembler (Intel 语法)
- **GCC/MinGW**: GNU Compiler Collection
- **Go**: Go 语言工具链
- **MSVC** (可选): Microsoft Visual C++ 编译器

### Linux x64
- **NASM** 或 **GAS**: 汇编器
- **GCC**: GNU Compiler Collection
- **Go**: Go 语言工具链

### macOS
- **Xcode Command Line Tools**: 包含 clang 和 as
- **NASM**: 可通过 Homebrew 安装
- **Go**: Go 语言工具链

### ARM (交叉编译)
- **arm-linux-gnueabihf-gcc**: ARM32 交叉编译器
- **aarch64-linux-gnu-gcc**: ARM64 交叉编译器
- **QEMU**: 用于模拟运行

## 使用方法

### 构建所有示例 (当前平台)
```bash
make all
```

### 构建特定平台示例
```bash
make windows    # Windows x64 示例
make linux      # Linux x64 示例
make macos      # macOS 示例
make arm        # ARM 示例 (需要交叉编译工具)
```

### 运行验证测试
```bash
make test       # 运行所有可执行的测试
make verify     # 验证编译结果
```

### 清理构建产物
```bash
make clean
```

## 示例分类

每个平台目录下按功能分类组织示例：

- `calling-conv/` - 调用约定验证
- `syscall/` - 系统调用验证
- `interop/` - 语言互操作验证
- `syntax/` - 语法示例

## 验证流程

1. **编译验证**: 确保代码能够正确编译
2. **运行验证**: 执行程序并检查输出
3. **调试验证**: 使用调试器检查寄存器和栈状态

## 注意事项

- Windows 示例使用 Microsoft x64 调用约定
- Linux/macOS 示例使用 System V AMD64 ABI
- ARM 示例需要交叉编译环境或 QEMU
- 部分示例可能需要管理员/root 权限

## 参考文档

- [汇编调用约定文档](../docs/assembly-calling-conventions/00-index.md)
- [Microsoft x64 调用约定](https://docs.microsoft.com/en-us/cpp/build/x64-calling-convention)
- [System V AMD64 ABI](https://gitlab.com/x86-psABIs/x86-64-ABI)
