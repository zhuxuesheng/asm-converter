# =============================================================================
# Makefile for System V AMD64 ABI Calling Convention Verification Examples
# =============================================================================
#
# This Makefile builds and runs the calling convention verification examples
# using GAS (GNU Assembler) and GCC on Linux.
#
# Requirements:
#   - GCC (GNU Compiler Collection)
#   - GNU as (GNU Assembler, usually included with GCC)
#
# Usage:
#   make          - Build the test program
#   make test     - Build and run tests
#   make clean    - Clean build artifacts
#   make debug    - Build with debug symbols
#   make V=1      - Verbose output (show commands)
#
# =============================================================================

# Configuration
TARGET = test_calling_conv
ASM_SRC = calling_conv.s
C_SRC = main.c
ASM_OBJ = calling_conv.o
C_OBJ = main.o

# Compiler and assembler
CC = gcc
AS = as

# Flags
CFLAGS = -Wall -Wextra -O2
ASFLAGS = 
LDFLAGS = -lm

# Debug flags
DEBUG_CFLAGS = -Wall -Wextra -g -O0
DEBUG_ASFLAGS = -g

# Verbose mode
V ?= 0
ifeq ($(V),0)
    Q = @
    ECHO = @echo
else
    Q =
    ECHO = @echo
endif

# =============================================================================
# Default target
# =============================================================================
.PHONY: all
all: $(TARGET)

# =============================================================================
# Build rules
# =============================================================================

$(TARGET): $(ASM_OBJ) $(C_OBJ)
	$(ECHO) "[LD] Linking $@"
	$(Q)$(CC) $(LDFLAGS) -o $@ $^

$(ASM_OBJ): $(ASM_SRC)
	$(ECHO) "[AS] Assembling $<"
	$(Q)$(AS) $(ASFLAGS) -o $@ $<

$(C_OBJ): $(C_SRC)
	$(ECHO) "[CC] Compiling $<"
	$(Q)$(CC) $(CFLAGS) -c -o $@ $<

# =============================================================================
# Debug build
# =============================================================================
.PHONY: debug
debug: CFLAGS = $(DEBUG_CFLAGS)
debug: ASFLAGS = $(DEBUG_ASFLAGS)
debug: clean $(TARGET)
	$(ECHO) "Debug build complete. Use 'gdb ./$(TARGET)' for debugging."

# =============================================================================
# Test target
# =============================================================================
.PHONY: test
test: $(TARGET)
	$(ECHO) ""
	$(ECHO) "Running tests..."
	$(ECHO) "================"
	$(ECHO) ""
	$(Q)./$(TARGET)

# =============================================================================
# Clean target
# =============================================================================
.PHONY: clean
clean:
	$(ECHO) "[CLEAN] Removing build artifacts"
	$(Q)rm -f $(TARGET) $(ASM_OBJ) $(C_OBJ)

# =============================================================================
# Help target
# =============================================================================
.PHONY: help
help:
	@echo "System V AMD64 ABI Calling Convention Verification Examples"
	@echo ""
	@echo "Usage:"
	@echo "  make          - Build the test program"
	@echo "  make test     - Build and run tests"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make debug    - Build with debug symbols"
	@echo "  make V=1      - Verbose output (show commands)"
	@echo "  make help     - Show this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - GCC (GNU Compiler Collection)"
	@echo "  - GNU as (GNU Assembler)"
	@echo ""
	@echo "Files:"
	@echo "  $(ASM_SRC)  - GAS assembly source (AT&T syntax)"
	@echo "  $(C_SRC)       - C test program"
	@echo "  $(TARGET)      - Output executable"

# =============================================================================
# Check tools
# =============================================================================
.PHONY: check
check:
	@echo "Checking for required tools..."
	@which $(CC) > /dev/null 2>&1 && echo "  GCC: OK ($(shell $(CC) --version | head -n1))" || echo "  GCC: NOT FOUND"
	@which $(AS) > /dev/null 2>&1 && echo "  AS:  OK ($(shell $(AS) --version | head -n1))" || echo "  AS:  NOT FOUND"

# =============================================================================
# Disassembly (for debugging)
# =============================================================================
.PHONY: disasm
disasm: $(TARGET)
	$(ECHO) "Disassembling $(TARGET)..."
	$(Q)objdump -d $(TARGET) | less

.PHONY: disasm-obj
disasm-obj: $(ASM_OBJ)
	$(ECHO) "Disassembling $(ASM_OBJ)..."
	$(Q)objdump -d $(ASM_OBJ)

# =============================================================================
# End of Makefile
# =============================================================================
