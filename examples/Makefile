# 汇编调用约定验证示例 - 主 Makefile
# Assembly Calling Conventions Verification Examples - Main Makefile

# 检测操作系统
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    SHELL := cmd.exe
    RM := del /Q /F
    RMDIR := rmdir /S /Q
    MKDIR := mkdir
    SEP := \\
else
    DETECTED_OS := $(shell uname -s)
    RM := rm -f
    RMDIR := rm -rf
    MKDIR := mkdir -p
    SEP := /
endif

# 工具链配置
NASM ?= nasm
GCC ?= gcc
GO ?= go
AS ?= as
LD ?= ld

# 交叉编译工具链 (用于 ARM)
ARM32_CC ?= arm-linux-gnueabihf-gcc
ARM64_CC ?= aarch64-linux-gnu-gcc
ARM32_AS ?= arm-linux-gnueabihf-as
ARM64_AS ?= aarch64-linux-gnu-as

# QEMU 模拟器
QEMU_ARM32 ?= qemu-arm
QEMU_ARM64 ?= qemu-aarch64

# 编译标志
NASM_FLAGS_WIN64 := -f win64
NASM_FLAGS_ELF64 := -f elf64
NASM_FLAGS_MACHO64 := -f macho64
GCC_FLAGS := -Wall -g
GO_FLAGS := 

# 目标目录
WINDOWS_DIR := windows-x64
LINUX_DIR := linux-x64
MACOS_DIR := macos
ARM_DIR := arm

# 默认目标
.PHONY: all clean test verify help
.PHONY: windows linux macos arm
.PHONY: check-tools

all: check-platform
	@echo "Building examples for detected platform: $(DETECTED_OS)"
ifeq ($(DETECTED_OS),Windows)
	$(MAKE) windows
else ifeq ($(DETECTED_OS),Linux)
	$(MAKE) linux
else ifeq ($(DETECTED_OS),Darwin)
	$(MAKE) macos
endif

# 平台特定构建
windows:
	@echo "=== Building Windows x64 examples ==="
	@if exist $(WINDOWS_DIR)$(SEP)Makefile ( \
		cd $(WINDOWS_DIR) && $(MAKE) all \
	) else ( \
		echo "Windows examples not yet implemented" \
	)

linux:
	@echo "=== Building Linux x64 examples ==="
	@if [ -f $(LINUX_DIR)/Makefile ]; then \
		$(MAKE) -C $(LINUX_DIR) all; \
	else \
		echo "Linux examples not yet implemented"; \
	fi

macos:
	@echo "=== Building macOS examples ==="
	@if [ -f $(MACOS_DIR)/Makefile ]; then \
		$(MAKE) -C $(MACOS_DIR) all; \
	else \
		echo "macOS examples not yet implemented"; \
	fi

arm: arm32 arm64

arm32:
	@echo "=== Building ARM32 examples (cross-compile) ==="
	@if [ -f $(ARM_DIR)/arm32/Makefile ]; then \
		$(MAKE) -C $(ARM_DIR)/arm32 CC=$(ARM32_CC) AS=$(ARM32_AS); \
	else \
		echo "ARM32 examples not yet implemented"; \
	fi

arm64:
	@echo "=== Building ARM64 examples (cross-compile) ==="
	@if [ -f $(ARM_DIR)/arm64/Makefile ]; then \
		$(MAKE) -C $(ARM_DIR)/arm64 CC=$(ARM64_CC) AS=$(ARM64_AS); \
	else \
		echo "ARM64 examples not yet implemented"; \
	fi

# 测试目标
test: all
	@echo "=== Running tests ==="
ifeq ($(DETECTED_OS),Windows)
	@if exist $(WINDOWS_DIR)$(SEP)Makefile ( \
		cd $(WINDOWS_DIR) && $(MAKE) test \
	)
else ifeq ($(DETECTED_OS),Linux)
	@if [ -f $(LINUX_DIR)/Makefile ]; then \
		$(MAKE) -C $(LINUX_DIR) test; \
	fi
else ifeq ($(DETECTED_OS),Darwin)
	@if [ -f $(MACOS_DIR)/Makefile ]; then \
		$(MAKE) -C $(MACOS_DIR) test; \
	fi
endif

# 验证目标 (仅检查编译是否成功)
verify:
	@echo "=== Verifying build ==="
	@echo "Platform: $(DETECTED_OS)"
	@echo "Checking compiled outputs..."
ifeq ($(DETECTED_OS),Windows)
	@dir /B $(WINDOWS_DIR)$(SEP)*.exe 2>nul || echo "No Windows executables found"
else
	@find . -name "*.out" -o -name "*.exe" 2>/dev/null || echo "No executables found"
endif

# 清理目标
clean:
	@echo "=== Cleaning all build artifacts ==="
ifeq ($(DETECTED_OS),Windows)
	@if exist $(WINDOWS_DIR)$(SEP)Makefile ( \
		cd $(WINDOWS_DIR) && $(MAKE) clean \
	)
else
	@for dir in $(WINDOWS_DIR) $(LINUX_DIR) $(MACOS_DIR) $(ARM_DIR); do \
		if [ -f $$dir/Makefile ]; then \
			$(MAKE) -C $$dir clean; \
		fi; \
	done
endif
	@echo "Clean complete"

# 检查平台
check-platform:
	@echo "Detected OS: $(DETECTED_OS)"

# 检查工具
check-tools:
	@echo "=== Checking available tools ==="
	@echo "Checking NASM..."
	@$(NASM) -v 2>/dev/null || echo "NASM not found"
	@echo "Checking GCC..."
	@$(GCC) --version 2>/dev/null | head -1 || echo "GCC not found"
	@echo "Checking Go..."
	@$(GO) version 2>/dev/null || echo "Go not found"
ifeq ($(DETECTED_OS),Linux)
	@echo "Checking ARM32 cross-compiler..."
	@$(ARM32_CC) --version 2>/dev/null | head -1 || echo "ARM32 cross-compiler not found"
	@echo "Checking ARM64 cross-compiler..."
	@$(ARM64_CC) --version 2>/dev/null | head -1 || echo "ARM64 cross-compiler not found"
	@echo "Checking QEMU..."
	@$(QEMU_ARM32) --version 2>/dev/null | head -1 || echo "QEMU ARM32 not found"
	@$(QEMU_ARM64) --version 2>/dev/null | head -1 || echo "QEMU ARM64 not found"
endif

# 帮助信息
help:
	@echo "汇编调用约定验证示例 - Makefile 帮助"
	@echo "========================================"
	@echo ""
	@echo "可用目标:"
	@echo "  all          - 构建当前平台的所有示例"
	@echo "  windows      - 构建 Windows x64 示例"
	@echo "  linux        - 构建 Linux x64 示例"
	@echo "  macos        - 构建 macOS 示例"
	@echo "  arm          - 构建 ARM 示例 (需要交叉编译器)"
	@echo "  arm32        - 仅构建 ARM32 示例"
	@echo "  arm64        - 仅构建 ARM64 示例"
	@echo "  test         - 运行测试"
	@echo "  verify       - 验证构建结果"
	@echo "  clean        - 清理构建产物"
	@echo "  check-tools  - 检查可用工具"
	@echo "  help         - 显示此帮助信息"
	@echo ""
	@echo "变量:"
	@echo "  NASM         - NASM 汇编器路径 (默认: nasm)"
	@echo "  GCC          - GCC 编译器路径 (默认: gcc)"
	@echo "  GO           - Go 工具链路径 (默认: go)"
	@echo "  ARM32_CC     - ARM32 交叉编译器 (默认: arm-linux-gnueabihf-gcc)"
	@echo "  ARM64_CC     - ARM64 交叉编译器 (默认: aarch64-linux-gnu-gcc)"
	@echo ""
	@echo "示例:"
	@echo "  make all                    # 构建当前平台示例"
	@echo "  make windows                # 构建 Windows 示例"
	@echo "  make arm QEMU_ARM64=qemu-aarch64  # 使用指定 QEMU"
	@echo "  make check-tools            # 检查工具链"
