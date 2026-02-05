# 术语表

本术语表包含汇编语言调用约定文档中使用的专业术语定义。

---

## A

### ABI (Application Binary Interface / 应用二进制接口)

定义二进制程序模块之间接口的规范，包括数据类型大小、对齐方式、调用约定、系统调用接口等。不同操作系统和架构有不同的ABI规范。

**参见**: [System V AMD64 ABI](../02-x86-x64/x64-sysv.md), [Microsoft x64 ABI](../02-x86-x64/x64-microsoft.md)

### AAPCS (ARM Architecture Procedure Call Standard)

ARM架构的过程调用标准，定义了ARM32架构下函数调用的参数传递、返回值处理和寄存器使用规则。

**参见**: [ARM32 AAPCS](../03-arm/arm32-aapcs.md)

### AAPCS64

ARM64架构的过程调用标准，是AAPCS的64位版本。

**参见**: [ARM64 AAPCS64](../03-arm/arm64-aapcs64.md)

### Alignment (对齐)

数据在内存中的地址必须是特定值的倍数。例如，16字节对齐意味着地址必须是16的倍数。栈对齐对于SIMD指令和性能优化至关重要。

### AT&T Syntax (AT&T语法)

一种汇编语法风格，由AT&T贝尔实验室开发，被GNU汇编器(GAS)采用。特点是源操作数在前、目标操作数在后，寄存器名前加%，立即数前加$。

**参见**: [AT&T语法](../01-syntax-comparison/att.md)

---

## B

### Base Pointer

参见 [Frame Pointer](#fp-frame-pointer--帧指针)

---

## C

### Callee (被调用者)

被调用的函数。在调用约定中，callee负责保存和恢复callee-saved寄存器。

### Callee-Saved Register (被调用者保存寄存器)

也称为"非易失性寄存器"(non-volatile register)。被调用函数如果使用这些寄存器，必须在函数入口保存其值，并在返回前恢复。

**x64 System V**: RBX, RBP, R12-R15  
**x64 Microsoft**: RBX, RBP, RDI, RSI, R12-R15

### Caller (调用者)

发起函数调用的代码。在调用约定中，caller负责传递参数、保存caller-saved寄存器，以及（在某些约定中）清理栈。

### Caller-Saved Register (调用者保存寄存器)

也称为"易失性寄存器"(volatile register)。调用者如果需要在函数调用后继续使用这些寄存器的值，必须在调用前保存。被调用函数可以自由修改这些寄存器。

**x64 System V**: RAX, RCX, RDX, RSI, RDI, R8-R11  
**x64 Microsoft**: RAX, RCX, RDX, R8-R11

### Calling Convention (调用约定)

定义函数调用时参数传递、返回值处理、寄存器使用和栈管理的规则集合。不同的调用约定有不同的规则。

**常见调用约定**: cdecl, stdcall, fastcall, System V AMD64, Microsoft x64

**参见**: [x86调用约定](../02-x86-x64/x86-conventions.md)

### cdecl

C语言默认的调用约定（主要用于x86）。参数从右到左压栈，调用者负责清理栈。

**参见**: [x86调用约定](../02-x86-x64/x86-conventions.md)

### CTR (Count Register)

PowerPC架构的计数寄存器，用于循环计数和间接分支。

**参见**: [PowerPC寄存器](../04-powerpc/registers.md)

### CR (Condition Register)

PowerPC架构的条件寄存器，存储比较和算术运算的结果标志。

**参见**: [PowerPC寄存器](../04-powerpc/registers.md)

---

## E

### ELFv1 / ELFv2

PowerPC 64位架构的两种ELF ABI版本。ELFv2是较新的版本，主要用于little-endian系统，简化了函数描述符的使用。

**参见**: [PPC64调用约定](../04-powerpc/ppc64.md)

### Epilogue (函数尾声)

函数结束时执行的代码，通常包括恢复callee-saved寄存器、释放栈空间、恢复帧指针和返回等操作。与Prologue相对。

### extern "C"

C++中用于禁用名称修饰的声明，使函数使用C语言的链接约定。在C++与汇编或C代码互操作时必须使用。

**参见**: [C/C++互操作](../06-interop/c-cpp.md)

---

## F

### fastcall

一种x86调用约定，前两个参数通过ECX和EDX寄存器传递，其余参数压栈。

**参见**: [x86调用约定](../02-x86-x64/x86-conventions.md)

### FP (Frame Pointer / 帧指针)

指向当前栈帧基址的寄存器。在Go汇编中，FP是一个伪寄存器，指向函数参数的起始位置。

**x86/x64**: EBP/RBP  
**ARM**: R11 (ARM32), X29 (ARM64)

**参见**: [栈帧结构](../07-stack-frames/overview.md)

### FPR (Floating-Point Register / 浮点寄存器)

用于浮点运算的寄存器。

**PowerPC**: F0-F31  
**x64**: XMM0-XMM15 (也用于SIMD)

---

## G

### GPR (General-Purpose Register / 通用寄存器)

可用于多种用途的寄存器，包括整数运算、地址计算等。

**x64**: RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP, R8-R15  
**ARM64**: X0-X30  
**PowerPC**: R0-R31

---

## H

### Home Space

参见 [Shadow Space](#shadow-space-影子空间)

---

## I

### Inline Assembly (内联汇编)

在高级语言源代码中直接嵌入汇编指令的技术。GCC使用扩展asm语法，MSVC使用__asm关键字。

**参见**: [内联汇编](../06-interop/inline-assembly.md)

### Intel Syntax (Intel语法)

一种汇编语法风格，由Intel开发。特点是目标操作数在前、源操作数在后，不需要寄存器前缀，内存操作使用方括号。NASM和MASM使用此语法。

**参见**: [Intel语法](../01-syntax-comparison/intel.md)

---

## L

### Leaf Function (叶函数)

不调用其他函数的函数。叶函数通常可以进行优化，如省略帧指针或使用Red Zone。

### LR (Link Register / 链接寄存器)

存储函数返回地址的寄存器。

**ARM**: LR (R14/X30)  
**PowerPC**: LR

---

## M

### Mach-O

macOS和iOS使用的可执行文件格式。与Linux的ELF格式有不同的段命名和符号约定。

**参见**: [macOS调用约定](../05-os-differences/macos.md)

### MASM (Microsoft Macro Assembler)

Microsoft的汇编器，使用Intel语法。主要用于Windows平台开发。

### Memory Operand (内存操作数)

汇编指令中引用内存位置的操作数。不同语法有不同的表示方式：
- Intel: `[base + index*scale + displacement]`
- AT&T: `displacement(base, index, scale)`

---

## N

### Name Mangling (名称修饰)

C++编译器对函数名进行编码以支持函数重载的技术。不同编译器的修饰规则不同。

**参见**: [C/C++互操作](../06-interop/c-cpp.md)

### Non-Volatile Register

参见 [Callee-Saved Register](#callee-saved-register-被调用者保存寄存器)

### NASM (Netwide Assembler)

一种流行的开源汇编器，使用Intel语法。支持多种输出格式，可在多个平台上使用。

---

## O

### Operand (操作数)

汇编指令操作的数据，可以是寄存器、立即数或内存位置。

---

## P

### PC (Program Counter / 程序计数器)

存储下一条要执行指令地址的寄存器。在Go汇编中，PC是一个伪寄存器。

**x64**: RIP  
**ARM**: PC (R15/PC)

### Plan9 Assembly (Plan9汇编)

Go语言使用的汇编语法，源自Plan 9操作系统。具有独特的伪寄存器和语法规则。

**参见**: [Go Plan9汇编](../01-syntax-comparison/go-plan9.md)

### Prologue (函数序言)

函数开始时执行的代码，通常包括保存帧指针、分配栈空间、保存callee-saved寄存器等操作。

### Pseudo-Register (伪寄存器)

Go汇编中的虚拟寄存器，由汇编器转换为实际的内存地址或寄存器。

**Go伪寄存器**: FP, SP, SB, PC

**参见**: [Go汇编](../06-interop/go-assembly.md)

---

## R

### Red Zone (红区)

栈指针以下的一段内存区域（通常128字节），某些ABI允许叶函数使用而无需调整栈指针。这是一种优化，可以减少栈指针调整的开销。

**支持Red Zone**: System V AMD64 ABI (Linux, macOS)  
**不支持Red Zone**: Microsoft x64 ABI (Windows)

**参见**: [System V AMD64 ABI](../02-x86-x64/x64-sysv.md)

### Register (寄存器)

CPU内部的高速存储单元，用于存储操作数和中间结果。不同架构有不同数量和类型的寄存器。

**参见**: [寄存器快速参考](register-reference.md)

### Return Address (返回地址)

函数调用时保存的地址，指向调用指令的下一条指令。函数返回时跳转到此地址继续执行。

---

## S

### SB (Static Base / 静态基址)

Go汇编中的伪寄存器，用于引用全局符号。

**参见**: [Go汇编](../06-interop/go-assembly.md)

### Shadow Space (影子空间)

Windows x64调用约定中，调用者必须在栈上为前四个参数预留的32字节空间，即使参数通过寄存器传递。被调用函数可以使用这个空间保存寄存器参数。

**参见**: [Microsoft x64调用约定](../02-x86-x64/x64-microsoft.md)

### SP (Stack Pointer / 栈指针)

指向当前栈顶的寄存器。

**x64**: RSP  
**ARM64**: SP  
**Go汇编**: SP是伪寄存器，指向栈帧底部

### Stack Frame (栈帧)

函数调用时在栈上分配的内存区域，包含局部变量、返回地址、保存的寄存器和传递给被调用函数的参数。

**参见**: [栈帧结构](../07-stack-frames/overview.md)

### stdcall

Windows API常用的调用约定（x86）。参数从右到左压栈，被调用者负责清理栈。

**参见**: [x86调用约定](../02-x86-x64/x86-conventions.md)

### syscall

系统调用指令，用于从用户态切换到内核态执行操作系统服务。

**x64**: `syscall` 指令  
**x86**: `int 0x80` 或 `sysenter`

**参见**: [操作系统差异](../05-os-differences/overview.md)

### System V AMD64 ABI

Unix-like系统（Linux、macOS、BSD等）在x64架构上使用的标准ABI。定义了参数传递使用RDI、RSI、RDX、RCX、R8、R9，支持128字节Red Zone。

**参见**: [System V AMD64 ABI](../02-x86-x64/x64-sysv.md)

---

## T

### TOC (Table of Contents)

PowerPC架构中用于访问全局数据的机制。TOC指针（通常在R2寄存器）指向一个包含全局变量和函数地址的表。

**参见**: [PPC64调用约定](../04-powerpc/ppc64.md)

---

## U

### Unwind Information (展开信息)

用于异常处理和调试的元数据，描述如何从当前栈帧恢复到调用者的栈帧。包括保存的寄存器位置、栈帧大小等信息。

**参见**: [栈帧结构](../07-stack-frames/overview.md)

---

## V

### Variadic Function (可变参数函数)

接受可变数量参数的函数，如C语言的`printf`。可变参数函数有特殊的调用约定要求。

**参见**: [C/C++互操作](../06-interop/c-cpp.md)

### Volatile Register

参见 [Caller-Saved Register](#caller-saved-register-调用者保存寄存器)

---

## 数字和符号

### 16字节对齐

x64架构要求在函数调用时栈指针必须16字节对齐。这对于SIMD指令的正确执行至关重要。

---

## W

### Windows x64 Calling Convention (Windows x64调用约定)

Microsoft为64位Windows定义的调用约定。使用RCX、RDX、R8、R9传递前四个整数参数，要求32字节Shadow Space，不支持Red Zone。

**参见**: [Microsoft x64调用约定](../02-x86-x64/x64-microsoft.md)

---

## X

### XMM Register (XMM寄存器)

x86/x64架构的128位SIMD寄存器，用于SSE指令和浮点运算。x64有XMM0-XMM15共16个寄存器。

**参见**: [x86/x64寄存器](../02-x86-x64/registers.md)

---

## Y

### YMM Register (YMM寄存器)

x86/x64架构的256位SIMD寄存器，用于AVX指令。YMM寄存器是XMM寄存器的扩展，低128位与对应的XMM寄存器共享。

---

## Z

### Zero Register (零寄存器)

ARM64架构中的特殊寄存器（XZR/WZR），读取时总是返回0，写入时丢弃数据。用于优化某些操作。

### ZMM Register (ZMM寄存器)

x86/x64架构的512位SIMD寄存器，用于AVX-512指令。ZMM寄存器是YMM寄存器的扩展。

---

## 数字和符号

### 16字节对齐

x64架构要求在函数调用时栈指针必须16字节对齐。这对于SIMD指令的正确执行至关重要。

### 128字节 Red Zone

System V AMD64 ABI定义的Red Zone大小。叶函数可以使用RSP以下128字节的空间而无需调整栈指针。

### 32字节 Shadow Space

Windows x64调用约定要求调用者在栈上预留的空间大小，用于被调用函数保存寄存器参数。

---

## 参见

- [寄存器快速参考](register-reference.md)
- [参考资料](references.md)
