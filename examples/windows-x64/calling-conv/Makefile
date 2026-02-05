# =============================================================================
# Makefile for Microsoft x64 Calling Convention Verification Examples
# =============================================================================
#
# This Makefile builds the calling convention verification examples using
# NASM and MinGW-w64 GCC on Windows.
#
# Requirements:
#   - NASM >= 2.15
#   - MinGW-w64 (GCC for Windows)
#
# Usage:
#   make          - Build the test executable
#   make test     - Build and run tests
#   make clean    - Remove build artifacts
#   make debug    - Build with debug symbols
#
# =============================================================================

# Toolchain configuration
NASM = nasm
CC = gcc
LD = gcc

# Output executable
TARGET = test_calling_conv.exe

# Source files
ASM_SRC = calling_conv.asm
C_SRC = main.c

# Object files
ASM_OBJ = calling_conv.obj
C_OBJ = main.obj
OBJS = $(ASM_OBJ) $(C_OBJ)

# Flags
NASMFLAGS = -f win64
CFLAGS = -Wall -Wextra -O2
LDFLAGS = 

# Debug flags
DEBUG_NASMFLAGS = -f win64 -g -F cv8
DEBUG_CFLAGS = -Wall -Wextra -g -O0
DEBUG_LDFLAGS = -g

# =============================================================================
# Default target
# =============================================================================

.PHONY: all
all: $(TARGET)

# =============================================================================
# Build rules
# =============================================================================

# Link object files to create executable
$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)
	@echo "Build complete: $(TARGET)"

# Assemble NASM source
$(ASM_OBJ): $(ASM_SRC)
	$(NASM) $(NASMFLAGS) -o $@ $<

# Compile C source
$(C_OBJ): $(C_SRC)
	$(CC) $(CFLAGS) -c -o $@ $<

# =============================================================================
# Debug build
# =============================================================================

.PHONY: debug
debug: NASMFLAGS = $(DEBUG_NASMFLAGS)
debug: CFLAGS = $(DEBUG_CFLAGS)
debug: LDFLAGS = $(DEBUG_LDFLAGS)
debug: clean $(TARGET)
	@echo "Debug build complete: $(TARGET)"

# =============================================================================
# Test target
# =============================================================================

.PHONY: test
test: $(TARGET)
	@echo ""
	@echo "Running tests..."
	@echo "================"
	./$(TARGET)

# =============================================================================
# Clean target
# =============================================================================

.PHONY: clean
clean:
	-rm -f $(OBJS) $(TARGET)
	@echo "Clean complete"

# =============================================================================
# Help target
# =============================================================================

.PHONY: help
help:
	@echo "Microsoft x64 Calling Convention Verification Examples"
	@echo ""
	@echo "Targets:"
	@echo "  all     - Build the test executable (default)"
	@echo "  test    - Build and run tests"
	@echo "  debug   - Build with debug symbols"
	@echo "  clean   - Remove build artifacts"
	@echo "  help    - Show this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - NASM >= 2.15"
	@echo "  - MinGW-w64 (GCC for Windows)"

# =============================================================================
# Dependency tracking
# =============================================================================

$(C_OBJ): $(C_SRC)
$(ASM_OBJ): $(ASM_SRC)
