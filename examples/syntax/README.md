# 汇编语法对比验证示例

本目录包含三种汇编语法（Go Plan9、Intel/NASM、AT&T/GAS）的等效功能示例代码，用于验证语法对比文档的准确性。

## 目录结构

```
syntax/
├── README.md           # 本文件
├── Makefile            # 构建脚本
├── go/                 # Go Plan9 汇编示例
│   ├── arith.go        # Go接口定义
│   ├── arith_amd64.s   # 汇编实现
│   └── arith_test.go   # 测试文件
├── nasm/               # NASM (Intel语法) 示例
│   ├── arith.asm       # 汇编实现
│   ├── arith.h         # C头文件
│   └── main.c          # C测试程序
├── gas/                # GAS (AT&T语法) 示例
│   ├── arith.s         # 汇编实现
│   ├── arith.h         # C头文件
│   └── main.c          # C测试程序
└── common/             # 共享测试数据
    └── test_cases.h    # 测试用例定义
```

## 功能说明

所有三种语法实现相同的功能：

### 1. 基本算术运算
- `add_numbers(a, b)` - 两数相加
- `sub_numbers(a, b)` - 两数相减
- `mul_numbers(a, b)` - 两数相乘

### 2. 内存访问
- `sum_array(arr, len)` - 数组求和
- `find_max(arr, len)` - 查找最大值

### 3. 函数调用
- `factorial(n)` - 递归计算阶乘（演示函数调用）

## 构建要求

### Windows x64
- **Go**: Go 1.17+ (支持寄存器调用约定)
- **NASM**: NASM 2.15+ 
- **GCC**: MinGW-w64 GCC 10+

### 安装工具

```powershell
# 安装 Go
winget install GoLang.Go

# 安装 NASM
winget install NASM.NASM

# 安装 MinGW-w64 (包含 GCC 和 GAS)
winget install mingw
```

## 构建和运行

### 使用 Makefile

```bash
# 构建所有示例
make all

# 仅构建 Go 示例
make go

# 仅构建 NASM 示例
make nasm

# 仅构建 GAS 示例
make gas

# 运行所有测试
make test

# 清理构建产物
make clean
```

### 手动构建

#### Go Plan9 汇编

```powershell
cd go
go build -o arith.exe .
go test -v
```

#### NASM (Intel 语法)

```powershell
cd nasm
# 汇编
nasm -f win64 -o arith.obj arith.asm
# 编译 C 代码并链接
gcc -c main.c -o main.obj
gcc main.obj arith.obj -o arith_nasm.exe
# 运行
.\arith_nasm.exe
```

#### GAS (AT&T 语法)

```powershell
cd gas
# 汇编和编译
gcc -c arith.s -o arith.obj
gcc -c main.c -o main.obj
gcc main.obj arith.obj -o arith_gas.exe
# 运行
.\arith_gas.exe
```

## 语法对比要点

### 操作数顺序

| 操作 | Go Plan9 | Intel (NASM) | AT&T (GAS) |
|------|----------|--------------|------------|
| a + b → a | `ADDQ BX, AX` | `add rax, rbx` | `addq %rbx, %rax` |

### 寄存器命名

| Go Plan9 | Intel | AT&T |
|----------|-------|------|
| `AX` | `rax` | `%rax` |
| `BX` | `rbx` | `%rbx` |

### 内存访问

| Go Plan9 | Intel | AT&T |
|----------|-------|------|
| `8(AX)` | `[rax+8]` | `8(%rax)` |
| `(AX)(BX*8)` | `[rax+rbx*8]` | `(%rax,%rbx,8)` |

### 立即数

| Go Plan9 | Intel | AT&T |
|----------|-------|------|
| `$42` | `42` | `$42` |

## 调用约定

### Windows x64 (Microsoft ABI)
- 参数寄存器: RCX, RDX, R8, R9
- 返回值: RAX
- 调用者保存: RAX, RCX, RDX, R8, R9, R10, R11
- 被调用者保存: RBX, RBP, RDI, RSI, R12-R15
- Shadow Space: 32 字节

### Go 1.17+ 寄存器调用约定
- 参数寄存器: AX, BX, CX, DI, SI, R8, R9, R10, R11
- 返回值: AX, BX, ...
- 详见 Go 内部 ABI 规范

## 验证结果

运行测试后，所有三种实现应产生相同的结果：

```
=== 算术运算测试 ===
add_numbers(10, 20) = 30
sub_numbers(50, 30) = 20
mul_numbers(6, 7) = 42

=== 内存访问测试 ===
sum_array([1,2,3,4,5]) = 15
find_max([3,1,4,1,5,9,2,6]) = 9

=== 函数调用测试 ===
factorial(5) = 120
factorial(10) = 3628800
```

## 参考资料

- [Go Assembler Guide](https://go.dev/doc/asm)
- [NASM Manual](https://www.nasm.us/doc/)
- [GNU Assembler Manual](https://sourceware.org/binutils/docs/as/)
- [Microsoft x64 Calling Convention](https://docs.microsoft.com/en-us/cpp/build/x64-calling-convention)

## 相关文档

- [语法对比表格](../../docs/assembly-calling-conventions/01-syntax-comparison/comparison-tables.md)
- [Go Plan9 汇编详解](../../docs/assembly-calling-conventions/01-syntax-comparison/go-plan9.md)
- [Intel 汇编详解](../../docs/assembly-calling-conventions/01-syntax-comparison/intel.md)
- [AT&T 汇编详解](../../docs/assembly-calling-conventions/01-syntax-comparison/att.md)
