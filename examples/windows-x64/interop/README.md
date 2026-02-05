# Windows x64 C/Assembly Interop Examples

本目录包含Windows x64平台C与汇编互操作的验证示例。

## 文件说明

- `c_asm_interop.asm` - NASM汇编函数实现
- `main.c` - C测试程序
- `Makefile` - 构建脚本

## 构建和运行

```cmd
make
test_interop.exe
```

## 验证内容

1. **整数参数传递** (RCX, RDX, R8, R9)
2. **浮点参数传递** (XMM0-XMM3)
3. **返回值** (RAX, XMM0)
4. **指针参数**

## 预期输出

```
=== Windows x64 C/ASM Interop Test ===

asm_add(10, 20) = 30 [PASS]
asm_multiply = 1000000000000 [PASS]
asm_add_doubles = 4.0 [PASS]
Before swap: x=10, y=20
After swap: x=20, y=10 [PASS]
```
