# Linux x64 System Call Examples

本目录包含Linux x64系统调用的验证示例。

## 文件说明

- `syscall_example.s` - 基本系统调用示例（write, getpid, exit）
- `Makefile` - 构建脚本

## 构建和运行

```bash
make
./syscall_example
```

## 预期输出

```
Hello from Linux syscall!
```

## 验证内容

1. **syscall指令使用**
2. **系统调用号传递（RAX）**
3. **参数寄存器（RDI, RSI, RDX, R10, R8, R9）**
4. **返回值和错误处理**

## 系统调用寄存器

| 用途 | 寄存器 |
|------|--------|
| 系统调用号 | RAX |
| 参数1 | RDI |
| 参数2 | RSI |
| 参数3 | RDX |
| 参数4 | R10 |
| 参数5 | R8 |
| 参数6 | R9 |
| 返回值 | RAX |
