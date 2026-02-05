# 参考资料

本文档收集了汇编语言调用约定相关的官方规范文档和扩展阅读资源。

---

## 官方规范文档

### x86/x64 架构

#### Intel 官方文档

- **Intel® 64 and IA-32 Architectures Software Developer Manuals**
  - [完整手册下载](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)
  - Volume 1: 基本架构
  - Volume 2: 指令集参考
  - Volume 3: 系统编程指南

#### AMD 官方文档

- **AMD64 Architecture Programmer's Manual**
  - [Volume 1: Application Programming](https://www.amd.com/content/dam/amd/en/documents/processor-tech-docs/programmer-references/24592.pdf)
  - [Volume 2: System Programming](https://www.amd.com/content/dam/amd/en/documents/processor-tech-docs/programmer-references/24593.pdf)
  - [Volume 3: General-Purpose and System Instructions](https://www.amd.com/content/dam/amd/en/documents/processor-tech-docs/programmer-references/24594.pdf)

#### System V ABI

- **System V Application Binary Interface - AMD64 Architecture Processor Supplement**
  - [官方规范 (PDF)](https://gitlab.com/x86-psABIs/x86-64-ABI/-/jobs/artifacts/master/raw/x86-64-ABI/abi.pdf?job=build)
  - [GitLab 仓库](https://gitlab.com/x86-psABIs/x86-64-ABI)
  - 定义了Linux/Unix x64调用约定

#### Microsoft x64 ABI

- **x64 calling convention**
  - [Microsoft Learn 文档](https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention)
  - [x64 software conventions](https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions)
  - [x64 stack usage](https://learn.microsoft.com/en-us/cpp/build/stack-usage)

---

### ARM 架构

#### ARM 官方文档

- **Arm Architecture Reference Manual**
  - [Arm A-profile A64 Instruction Set Architecture](https://developer.arm.com/documentation/ddi0602/latest)
  - [Arm A-profile A32/T32 Instruction Set Architecture](https://developer.arm.com/documentation/ddi0597/latest)

- **Procedure Call Standard for the Arm Architecture (AAPCS)**
  - [AAPCS32](https://github.com/ARM-software/abi-aa/blob/main/aapcs32/aapcs32.rst)
  - [AAPCS64](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst)
  - [ARM ABI 官方仓库](https://github.com/ARM-software/abi-aa)

- **ARM Developer Documentation**
  - [ARM Developer 主页](https://developer.arm.com/documentation)
  - [Cortex-A Series Programmer's Guide](https://developer.arm.com/documentation/den0024/latest)

---

### PowerPC 架构

#### IBM 官方文档

- **Power ISA (Instruction Set Architecture)**
  - [Power ISA 官方页面](https://openpowerfoundation.org/specifications/isa/)
  - 定义了PowerPC指令集和架构

- **64-bit ELF V2 ABI Specification**
  - [ELFv2 ABI 规范](https://openpowerfoundation.org/specifications/64bitelfabi/)
  - 定义了PPC64 Linux调用约定

- **Power Architecture 32-bit ABI Supplement**
  - [32位ABI补充](https://refspecs.linuxfoundation.org/elf/elfspec_ppc.pdf)

#### AIX 文档

- **AIX Assembler Language Reference**
  - [IBM AIX 文档](https://www.ibm.com/docs/en/aix)

---

### 操作系统相关

#### Linux

- **Linux Kernel Documentation**
  - [syscall(2) man page](https://man7.org/linux/man-pages/man2/syscall.2.html)
  - [Linux System Call Table](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md)

- **Linux Foundation Referenced Specifications**
  - [ELF Specification](https://refspecs.linuxfoundation.org/elf/elf.pdf)
  - [System V ABI](https://refspecs.linuxfoundation.org/)

#### Windows

- **Windows SDK Documentation**
  - [Windows API Index](https://learn.microsoft.com/en-us/windows/win32/apiindex/windows-api-list)
  - [Structured Exception Handling](https://learn.microsoft.com/en-us/windows/win32/debug/structured-exception-handling)
  - [PE Format](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format)

#### macOS

- **Apple Developer Documentation**
  - [Writing 64-bit Intel Code for Apple Platforms](https://developer.apple.com/documentation/xcode/writing-64-bit-intel-code-for-apple-platforms)
  - [Mach-O Programming Topics](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/MachOTopics/)
  - [macOS ABI Function Call Guide](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/LowLevelABI/)

---

### 语言互操作

#### Go 语言

- **Go Assembler Guide**
  - [A Quick Guide to Go's Assembler](https://go.dev/doc/asm)
  - 官方Go汇编文档

- **Go Internal ABI Specification**
  - [Go Internal ABI](https://github.com/golang/go/blob/master/src/cmd/compile/abi-internal.md)
  - Go 1.17+寄存器调用约定

- **Go Runtime Source**
  - [runtime/asm_amd64.s](https://github.com/golang/go/blob/master/src/runtime/asm_amd64.s)
  - [runtime/asm_arm64.s](https://github.com/golang/go/blob/master/src/runtime/asm_arm64.s)

#### C/C++

- **GCC Inline Assembly**
  - [Extended Asm](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html)
  - [Constraints for asm Operands](https://gcc.gnu.org/onlinedocs/gcc/Constraints.html)

- **MSVC Inline Assembly**
  - [Inline Assembler](https://learn.microsoft.com/en-us/cpp/assembler/inline/inline-assembler)
  - [__asm Keyword](https://learn.microsoft.com/en-us/cpp/assembler/inline/asm)

- **C++ ABI**
  - [Itanium C++ ABI](https://itanium-cxx-abi.github.io/cxx-abi/abi.html)
  - 定义了C++名称修饰规则

---

## 汇编器文档

### NASM

- **NASM Documentation**
  - [NASM Manual](https://www.nasm.us/doc/)
  - [NASM 官网](https://www.nasm.us/)

### GAS (GNU Assembler)

- **GNU Assembler Documentation**
  - [Using as](https://sourceware.org/binutils/docs/as/)
  - [GAS Syntax](https://sourceware.org/binutils/docs/as/Syntax.html)

### MASM

- **Microsoft Macro Assembler Reference**
  - [MASM Reference](https://learn.microsoft.com/en-us/cpp/assembler/masm/microsoft-macro-assembler-reference)

---

## 扩展阅读

### 书籍推荐

- **x86/x64 汇编**
  - "Professional Assembly Language" - Richard Blum
  - "Assembly Language Step-by-Step" - Jeff Duntemann
  - "Modern X86 Assembly Language Programming" - Daniel Kusswurm

- **ARM 汇编**
  - "ARM Assembly Language" - William Hohl
  - "Programming with 64-Bit ARM Assembly Language" - Stephen Smith

- **系统编程**
  - "Computer Systems: A Programmer's Perspective" - Bryant & O'Hallaron
  - "Low-Level Programming" - Igor Zhirkov

### 在线资源

- **OSDev Wiki**
  - [Calling Conventions](https://wiki.osdev.org/Calling_Conventions)
  - [System V ABI](https://wiki.osdev.org/System_V_ABI)

- **Agner Fog's Optimization Resources**
  - [Calling Conventions](https://www.agner.org/optimize/calling_conventions.pdf)
  - [Instruction Tables](https://www.agner.org/optimize/instruction_tables.pdf)
  - 非常详细的调用约定和优化指南

- **Compiler Explorer (Godbolt)**
  - [godbolt.org](https://godbolt.org/)
  - 在线查看编译器生成的汇编代码

- **x86 and amd64 instruction reference**
  - [felixcloutier.com/x86](https://www.felixcloutier.com/x86/)
  - 便于查阅的x86指令参考

---

## 工具

### 调试器

- **GDB (GNU Debugger)**
  - [GDB Documentation](https://sourceware.org/gdb/current/onlinedocs/gdb/)

- **LLDB**
  - [LLDB Documentation](https://lldb.llvm.org/)

- **WinDbg**
  - [WinDbg Documentation](https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/)

### 反汇编器

- **objdump**
  - [objdump man page](https://sourceware.org/binutils/docs/binutils/objdump.html)

- **IDA Pro**
  - [Hex-Rays](https://hex-rays.com/ida-pro/)

- **Ghidra**
  - [Ghidra](https://ghidra-sre.org/)
  - NSA开源的逆向工程工具

### 模拟器

- **QEMU**
  - [QEMU Documentation](https://www.qemu.org/documentation/)
  - 用于跨平台测试

---

## 参见

- [术语表](glossary.md)
- [寄存器快速参考](register-reference.md)
- [主索引](../00-index.md)
