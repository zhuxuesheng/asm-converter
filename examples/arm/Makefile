# ARM 验证示例 Makefile
# ARM Verification Examples Makefile

# 检测是否在原生 ARM 环境
UNAME_M := $(shell uname -m)
IS_ARM := $(filter arm% aarch64,$(UNAME_M))

# 工具链配置
ifdef IS_ARM
    # 原生 ARM 环境
    ARM32_CC ?= gcc
    ARM64_CC ?= gcc
    ARM32_AS ?= as
    ARM64_AS ?= as
    QEMU_ARM32 ?= 
    QEMU_ARM64 ?= 
else
    # 交叉编译环境
    ARM32_CC ?= arm-linux-gnueabihf-gcc
    ARM64_CC ?= aarch64-linux-gnu-gcc
    ARM32_AS ?= arm-linux-gnueabihf-as
    ARM64_AS ?= aarch64-linux-gnu-as
    QEMU_ARM32 ?= qemu-arm
    QEMU_ARM64 ?= qemu-aarch64
endif

# 编译标志
ARM32_CFLAGS := -Wall -g -O0 -march=armv7-a
ARM64_CFLAGS := -Wall -g -O0 -march=armv8-a
ARM32_ASFLAGS := -march=armv7-a
ARM64_ASFLAGS := -march=armv8-a

# 目录
ARM32_DIR := arm32
ARM64_DIR := arm64

.PHONY: all clean test verify
.PHONY: arm32 arm64 check-tools

# 默认目标
all: arm32 arm64
	@echo "ARM examples built successfully"

# ARM32 示例
arm32:
	@echo "Building ARM32 examples..."
	@if [ -f $(ARM32_DIR)/Makefile ]; then \
		$(MAKE) -C $(ARM32_DIR) CC=$(ARM32_CC) AS=$(ARM32_AS) CFLAGS="$(ARM32_CFLAGS)" ASFLAGS="$(ARM32_ASFLAGS)"; \
	else \
		echo "ARM32 examples not yet implemented"; \
	fi

# ARM64 示例
arm64:
	@echo "Building ARM64 examples..."
	@if [ -f $(ARM64_DIR)/Makefile ]; then \
		$(MAKE) -C $(ARM64_DIR) CC=$(ARM64_CC) AS=$(ARM64_AS) CFLAGS="$(ARM64_CFLAGS)" ASFLAGS="$(ARM64_ASFLAGS)"; \
	else \
		echo "ARM64 examples not yet implemented"; \
	fi

# 测试 (使用 QEMU 或原生运行)
test: all
	@echo "Running ARM tests..."
ifdef IS_ARM
	@echo "Running on native ARM..."
	@if [ -f $(ARM32_DIR)/Makefile ]; then \
		$(MAKE) -C $(ARM32_DIR) test; \
	fi
	@if [ -f $(ARM64_DIR)/Makefile ]; then \
		$(MAKE) -C $(ARM64_DIR) test; \
	fi
else
	@echo "Running with QEMU..."
	@if [ -f $(ARM32_DIR)/Makefile ] && [ -n "$(QEMU_ARM32)" ]; then \
		$(MAKE) -C $(ARM32_DIR) test QEMU=$(QEMU_ARM32); \
	fi
	@if [ -f $(ARM64_DIR)/Makefile ] && [ -n "$(QEMU_ARM64)" ]; then \
		$(MAKE) -C $(ARM64_DIR) test QEMU=$(QEMU_ARM64); \
	fi
endif

# 验证
verify:
	@echo "Verifying ARM build..."
	@find . -name "*.out" -o -name "*.elf" 2>/dev/null || echo "No executables found"

# 检查工具
check-tools:
	@echo "=== Checking ARM tools ==="
ifdef IS_ARM
	@echo "Running on native ARM ($(UNAME_M))"
	@$(ARM64_CC) --version 2>/dev/null | head -1 || echo "GCC not found"
else
	@echo "Cross-compilation environment"
	@echo "Checking ARM32 cross-compiler..."
	@$(ARM32_CC) --version 2>/dev/null | head -1 || echo "ARM32 cross-compiler not found"
	@echo "Checking ARM64 cross-compiler..."
	@$(ARM64_CC) --version 2>/dev/null | head -1 || echo "ARM64 cross-compiler not found"
	@echo "Checking QEMU ARM32..."
	@$(QEMU_ARM32) --version 2>/dev/null | head -1 || echo "QEMU ARM32 not found"
	@echo "Checking QEMU ARM64..."
	@$(QEMU_ARM64) --version 2>/dev/null | head -1 || echo "QEMU ARM64 not found"
endif

# 清理
clean:
	@echo "Cleaning ARM build artifacts..."
	@if [ -f $(ARM32_DIR)/Makefile ]; then \
		$(MAKE) -C $(ARM32_DIR) clean; \
	fi
	@if [ -f $(ARM64_DIR)/Makefile ]; then \
		$(MAKE) -C $(ARM64_DIR) clean; \
	fi
	@rm -f *.o *.out *.elf 2>/dev/null || true
