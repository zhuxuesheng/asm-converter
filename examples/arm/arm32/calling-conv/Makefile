# =============================================================================
# Makefile for ARM32 AAPCS Calling Convention Verification Examples
# =============================================================================
#
# 本 Makefile 使用 ARM 交叉编译工具链构建调用约定验证示例，
# 并使用 QEMU 用户模式模拟器运行测试。
#
# 前置要求:
#   - arm-linux-gnueabihf-gcc (ARM32 交叉编译器)
#   - arm-linux-gnueabihf-as  (ARM32 汇编器)
#   - qemu-arm (QEMU 用户模式模拟器)
#
# 安装 (Ubuntu/Debian):
#   sudo apt-get install gcc-arm-linux-gnueabihf qemu-user qemu-user-static
#
# 使用方法:
#   make          - 构建测试程序
#   make test     - 构建并运行测试
#   make clean    - 清理构建产物
#   make debug    - 构建调试版本
#   make V=1      - 显示详细编译信息
#
# =============================================================================

# 配置
TARGET = test_calling_conv
ASM_SRC = calling_conv.s
C_SRC = main.c
ASM_OBJ = calling_conv.o
C_OBJ = main.o

# 交叉编译工具链
CROSS_COMPILE = arm-linux-gnueabihf-
CC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)gcc
OBJDUMP = $(CROSS_COMPILE)objdump

# QEMU 配置
QEMU = qemu-arm
QEMU_FLAGS = -L /usr/arm-linux-gnueabihf

# 编译标志 (硬浮点模式)
ARCH_FLAGS = -march=armv7-a -mfpu=vfpv3 -mfloat-abi=hard
CFLAGS = $(ARCH_FLAGS) -Wall -Wextra -O2
ASFLAGS = -march=armv7-a -mfpu=vfpv3 -mfloat-abi=hard
LDFLAGS = $(ARCH_FLAGS) -lm

# 调试标志
DEBUG_CFLAGS = $(ARCH_FLAGS) -Wall -Wextra -g -O0
DEBUG_ASFLAGS = -march=armv7-a -mfpu=vfpv3 -mfloat-abi=hard -g

# 详细模式
V ?= 0
ifeq ($(V),0)
    Q = @
    ECHO = @echo
else
    Q =
    ECHO = @echo
endif

# =============================================================================
# 默认目标
# =============================================================================
.PHONY: all
all: $(TARGET)

# =============================================================================
# 构建规则
# =============================================================================

$(TARGET): $(ASM_OBJ) $(C_OBJ)
	$(ECHO) "[LD] Linking $@"
	$(Q)$(LD) $(LDFLAGS) -o $@ $^

$(ASM_OBJ): $(ASM_SRC)
	$(ECHO) "[AS] Assembling $<"
	$(Q)$(AS) $(ASFLAGS) -o $@ $<

$(C_OBJ): $(C_SRC)
	$(ECHO) "[CC] Compiling $<"
	$(Q)$(CC) $(CFLAGS) -c -o $@ $<

# =============================================================================
# 调试构建
# =============================================================================
.PHONY: debug
debug: CFLAGS = $(DEBUG_CFLAGS)
debug: ASFLAGS = $(DEBUG_ASFLAGS)
debug: clean $(TARGET)
	$(ECHO) "Debug build complete."
	$(ECHO) "To debug with GDB:"
	$(ECHO) "  Terminal 1: $(QEMU) -g 1234 $(QEMU_FLAGS) ./$(TARGET)"
	$(ECHO) "  Terminal 2: $(CROSS_COMPILE)gdb ./$(TARGET)"
	$(ECHO) "              (gdb) target remote localhost:1234"

# =============================================================================
# 测试目标
# =============================================================================
.PHONY: test
test: $(TARGET)
	$(ECHO) ""
	$(ECHO) "Running tests with QEMU..."
	$(ECHO) "==========================="
	$(ECHO) ""
	$(Q)$(QEMU) $(QEMU_FLAGS) ./$(TARGET)

# =============================================================================
# 清理目标
# =============================================================================
.PHONY: clean
clean:
	$(ECHO) "[CLEAN] Removing build artifacts"
	$(Q)rm -f $(TARGET) $(ASM_OBJ) $(C_OBJ)

# =============================================================================
# 帮助目标
# =============================================================================
.PHONY: help
help:
	@echo "ARM32 AAPCS Calling Convention Verification Examples"
	@echo ""
	@echo "Usage:"
	@echo "  make          - Build the test program"
	@echo "  make test     - Build and run tests with QEMU"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make debug    - Build with debug symbols"
	@echo "  make V=1      - Verbose output (show commands)"
	@echo "  make check    - Check for required tools"
	@echo "  make disasm   - Disassemble the executable"
	@echo "  make help     - Show this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - ARM cross-compiler: $(CC)"
	@echo "  - ARM assembler:      $(AS)"
	@echo "  - QEMU user mode:     $(QEMU)"
	@echo ""
	@echo "Install on Ubuntu/Debian:"
	@echo "  sudo apt-get install gcc-arm-linux-gnueabihf qemu-user qemu-user-static"
	@echo ""
	@echo "Files:"
	@echo "  $(ASM_SRC)  - ARM32 assembly source"
	@echo "  $(C_SRC)       - C test program"
	@echo "  $(TARGET)      - Output executable"

# =============================================================================
# 检查工具
# =============================================================================
.PHONY: check
check:
	@echo "Checking for required tools..."
	@which $(CC) > /dev/null 2>&1 && echo "  $(CC): OK" || echo "  $(CC): NOT FOUND"
	@which $(AS) > /dev/null 2>&1 && echo "  $(AS): OK" || echo "  $(AS): NOT FOUND"
	@which $(QEMU) > /dev/null 2>&1 && echo "  $(QEMU): OK" || echo "  $(QEMU): NOT FOUND"
	@echo ""
	@echo "If tools are missing, install with:"
	@echo "  sudo apt-get install gcc-arm-linux-gnueabihf qemu-user qemu-user-static"

# =============================================================================
# 反汇编 (用于调试)
# =============================================================================
.PHONY: disasm
disasm: $(TARGET)
	$(ECHO) "Disassembling $(TARGET)..."
	$(Q)$(OBJDUMP) -d $(TARGET) | less

.PHONY: disasm-obj
disasm-obj: $(ASM_OBJ)
	$(ECHO) "Disassembling $(ASM_OBJ)..."
	$(Q)$(OBJDUMP) -d $(ASM_OBJ)

# =============================================================================
# GDB 调试会话
# =============================================================================
.PHONY: gdb-server
gdb-server: $(TARGET)
	$(ECHO) "Starting QEMU GDB server on port 1234..."
	$(ECHO) "Connect with: $(CROSS_COMPILE)gdb ./$(TARGET)"
	$(ECHO) "              (gdb) target remote localhost:1234"
	$(Q)$(QEMU) -g 1234 $(QEMU_FLAGS) ./$(TARGET)

# =============================================================================
# 文件结束
# =============================================================================
