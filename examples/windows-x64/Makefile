# Windows x64 验证示例 Makefile
# Windows x64 Verification Examples Makefile

# 工具链
NASM ?= nasm
GCC ?= gcc
GO ?= go
CL ?= cl

# 编译标志
NASM_FLAGS := -f win64 -g
GCC_FLAGS := -Wall -g -O0
LDFLAGS := 

# 目录
CALLING_CONV_DIR := calling-conv
SYSCALL_DIR := syscall
INTEROP_DIR := interop

# 源文件 (将在后续任务中添加)
# ASM_SOURCES := $(wildcard $(CALLING_CONV_DIR)/*.asm)
# C_SOURCES := $(wildcard $(CALLING_CONV_DIR)/*.c)

# 目标文件
# OBJECTS := $(ASM_SOURCES:.asm=.obj)
# EXECUTABLES := $(C_SOURCES:.c=.exe)

.PHONY: all clean test verify
.PHONY: calling-conv syscall interop

# 默认目标
all: calling-conv syscall interop
	@echo "Windows x64 examples built successfully"

# 调用约定示例
calling-conv:
	@echo "Building calling convention examples..."
	@if exist $(CALLING_CONV_DIR)\Makefile ( \
		cd $(CALLING_CONV_DIR) && $(MAKE) all \
	) else ( \
		echo "Calling convention examples not yet implemented" \
	)

# 系统调用示例
syscall:
	@echo "Building syscall examples..."
	@if exist $(SYSCALL_DIR)\Makefile ( \
		cd $(SYSCALL_DIR) && $(MAKE) all \
	) else ( \
		echo "Syscall examples not yet implemented" \
	)

# 互操作示例
interop:
	@echo "Building interop examples..."
	@if exist $(INTEROP_DIR)\Makefile ( \
		cd $(INTEROP_DIR) && $(MAKE) all \
	) else ( \
		echo "Interop examples not yet implemented" \
	)

# 测试
test: all
	@echo "Running Windows x64 tests..."
	@echo "Tests will be added in subsequent tasks"

# 验证
verify:
	@echo "Verifying Windows x64 build..."
	@dir /B *.exe 2>nul || echo "No executables found"

# 清理
clean:
	@echo "Cleaning Windows x64 build artifacts..."
	@del /Q /F *.obj *.exe 2>nul || echo "Nothing to clean"
	@if exist $(CALLING_CONV_DIR)\Makefile ( \
		cd $(CALLING_CONV_DIR) && $(MAKE) clean \
	)
	@if exist $(SYSCALL_DIR)\Makefile ( \
		cd $(SYSCALL_DIR) && $(MAKE) clean \
	)
	@if exist $(INTEROP_DIR)\Makefile ( \
		cd $(INTEROP_DIR) && $(MAKE) clean \
	)

# 编译规则 (将在后续任务中使用)
# %.obj: %.asm
# 	$(NASM) $(NASM_FLAGS) -o $@ $<

# %.exe: %.c %.obj
# 	$(GCC) $(GCC_FLAGS) -o $@ $^
