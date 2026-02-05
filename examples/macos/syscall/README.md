# macOS x64 System Call Examples

本目录包含macOS x64系统调用的验证示例。

## 文件说明

- `syscall_example.s` - 基本系统调用示例
- `Makefile` - 构建脚本

## 构建和运行

```bash
make
./syscall_example
```

## 预期输出

```
Hello from macOS syscall!
```

## macOS系统调用特点

1. **系统调用号需要加前缀**：Unix调用使用0x2000000前缀
2. **错误使用CF标志**：而非Linux的负返回值
3. **Mach-O格式**：段和节命名不同

## 系统调用号

| 调用 | 号码 |
|------|------|
| exit | 0x2000001 |
| write | 0x2000004 |
| getpid | 0x2000014 |
