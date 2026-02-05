# Windows x64 验证示例

本目录包含 Windows x64 平台的汇编调用约定验证示例。

## 调用约定

Windows x64 使用 **Microsoft x64 调用约定**：

- **参数寄存器**: RCX, RDX, R8, R9 (整数/指针), XMM0-XMM3 (浮点)
- **返回值**: RAX (整数), XMM0 (浮点)
- **Shadow Space**: 调用者必须分配 32 字节影子空间
- **栈对齐**: 16 字节对齐 (call 指令前)
- **Caller-saved**: RAX, RCX, RDX, R8-R11, XMM0-XMM5
- **Callee-saved**: RBX, RBP, RDI, RSI, R12-R15, XMM6-XMM15

## 目录结构

```
windows-x64/
├── calling-conv/    # 调用约定验证示例
├── syscall/         # Windows 系统调用示例
├── interop/         # C/C++/Go 互操作示例
└── Makefile         # 本地构建脚本
```

## 工具要求

- **NASM** >= 2.15 (推荐)
- **MinGW-w64** 或 **MSVC**
- **Go** >= 1.17 (用于 Go 汇编示例)

## 构建方法

### 使用 Make (MinGW)
```bash
make all        # 构建所有示例
make test       # 运行测试
make clean      # 清理
```

### 使用 MSVC
```cmd
nmake /f Makefile.msvc
```

## 示例说明

### calling-conv/
验证 Microsoft x64 调用约定的示例：
- 参数传递 (整数、浮点、结构体)
- Shadow Space 使用
- 寄存器保存规则

### syscall/
Windows 系统调用示例：
- 使用 syscall 指令
- NT API 调用

### interop/
语言互操作示例：
- C 调用汇编函数
- 汇编调用 C 函数
- Go 汇编示例

## 调试技巧

### 使用 x64dbg
1. 加载可执行文件
2. 在函数入口设置断点
3. 检查 RCX, RDX, R8, R9 参数
4. 验证 Shadow Space 分配

### 使用 WinDbg
```
bp module!function
g
r rcx rdx r8 r9
dq rsp L8
```

## 常见问题

### Q: Shadow Space 是什么？
A: Windows x64 要求调用者在栈上为前 4 个参数预留 32 字节空间，即使参数通过寄存器传递。被调用者可以使用这个空间保存参数。

### Q: 为什么需要 16 字节栈对齐？
A: SSE 指令要求 16 字节对齐。在 call 指令执行前，RSP 必须是 16 的倍数。

## 参考资料

- [Microsoft x64 调用约定](https://docs.microsoft.com/en-us/cpp/build/x64-calling-convention)
- [x64 软件约定](https://docs.microsoft.com/en-us/cpp/build/x64-software-conventions)
