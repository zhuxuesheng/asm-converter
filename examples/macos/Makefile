# macOS 验证示例 Makefile
# macOS Verification Examples Makefile

# 工具链
NASM ?= nasm
CC ?= clang
AS ?= as
GO ?= go

# 编译标志
NASM_FLAGS := -f macho64 -g
CC_FLAGS := -Wall -g -O0
AS_FLAGS := -arch x86_64
LDFLAGS := -lSystem

# 目录
CALLING_CONV_DIR := calling-conv
SYSCALL_DIR := syscall
INTEROP_DIR := interop

# 源文件 (将在后续任务中添加)
# ASM_SOURCES := $(wildcard $(CALLING_CONV_DIR)/*.asm)
# C_SOURCES := $(wildcard $(CALLING_CONV_DIR)/*.c)

# 目标文件
# OBJECTS := $(ASM_SOURCES:.asm=.o)
# EXECUTABLES := $(C_SOURCES:.c=)

.PHONY: all clean test verify
.PHONY: calling-conv syscall interop

# 默认目标
all: calling-conv syscall interop
	@echo "macOS examples built successfully"

# 调用约定示例
calling-conv:
	@echo "Building calling convention examples..."
	@if [ -f $(CALLING_CONV_DIR)/Makefile ]; then \
		$(MAKE) -C $(CALLING_CONV_DIR) all; \
	else \
		echo "Calling convention examples not yet implemented"; \
	fi

# 系统调用示例
syscall:
	@echo "Building syscall examples..."
	@if [ -f $(SYSCALL_DIR)/Makefile ]; then \
		$(MAKE) -C $(SYSCALL_DIR) all; \
	else \
		echo "Syscall examples not yet implemented"; \
	fi

# 互操作示例
interop:
	@echo "Building interop examples..."
	@if [ -f $(INTEROP_DIR)/Makefile ]; then \
		$(MAKE) -C $(INTEROP_DIR) all; \
	else \
		echo "Interop examples not yet implemented"; \
	fi

# 测试
test: all
	@echo "Running macOS tests..."
	@echo "Tests will be added in subsequent tasks"

# 验证
verify:
	@echo "Verifying macOS build..."
	@find . -type f -perm +111 -not -name "*.sh" -not -name "Makefile" 2>/dev/null || echo "No executables found"

# 清理
clean:
	@echo "Cleaning macOS build artifacts..."
	@rm -f *.o 2>/dev/null || true
	@find . -type f -perm +111 -not -name "*.sh" -not -name "Makefile" -delete 2>/dev/null || true
	@if [ -f $(CALLING_CONV_DIR)/Makefile ]; then \
		$(MAKE) -C $(CALLING_CONV_DIR) clean; \
	fi
	@if [ -f $(SYSCALL_DIR)/Makefile ]; then \
		$(MAKE) -C $(SYSCALL_DIR) clean; \
	fi
	@if [ -f $(INTEROP_DIR)/Makefile ]; then \
		$(MAKE) -C $(INTEROP_DIR) clean; \
	fi

# 编译规则 (将在后续任务中使用)
# macOS 符号需要下划线前缀
# %.o: %.asm
# 	$(NASM) $(NASM_FLAGS) -o $@ $<

# %: %.c %.o
# 	$(CC) $(CC_FLAGS) $(LDFLAGS) -o $@ $^
