# Makefile for Assembly Syntax Comparison Examples
# Builds and tests Go Plan9, NASM (Intel), and GAS (AT&T) assembly examples
# Target platform: Windows x64

# Tools
GO = go
NASM = nasm
GCC = gcc

# Flags
NASM_FLAGS = -f win64
GCC_FLAGS = -Wall -O2

# Output directories
BUILD_DIR = build

# Phony targets
.PHONY: all clean go nasm gas test test-go test-nasm test-gas help

# Default target
all: go nasm gas

# Help
help:
	@echo "Assembly Syntax Comparison Examples - Build System"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Build all examples (default)"
	@echo "  go        - Build Go Plan9 assembly example"
	@echo "  nasm      - Build NASM (Intel syntax) example"
	@echo "  gas       - Build GAS (AT&T syntax) example"
	@echo "  test      - Run all tests"
	@echo "  test-go   - Run Go tests"
	@echo "  test-nasm - Run NASM tests"
	@echo "  test-gas  - Run GAS tests"
	@echo "  clean     - Remove build artifacts"
	@echo ""
	@echo "Requirements:"
	@echo "  - Go 1.17+ (for Go Plan9 assembly)"
	@echo "  - NASM 2.15+ (for Intel syntax)"
	@echo "  - MinGW-w64 GCC (for AT&T syntax and C compilation)"

# Create build directory
$(BUILD_DIR):
	@if not exist $(BUILD_DIR) mkdir $(BUILD_DIR)

# ============================================================
# Go Plan9 Assembly
# ============================================================
go: $(BUILD_DIR)
	@echo "Building Go Plan9 assembly example..."
	cd go && $(GO) build -o ../$(BUILD_DIR)/arith_go.exe .
	@echo "Go build complete: $(BUILD_DIR)/arith_go.exe"

test-go: go
	@echo "Running Go tests..."
	cd go && $(GO) test -v

# ============================================================
# NASM (Intel Syntax) Assembly
# ============================================================
nasm: $(BUILD_DIR) $(BUILD_DIR)/arith_nasm.exe
	@echo "NASM build complete: $(BUILD_DIR)/arith_nasm.exe"

$(BUILD_DIR)/arith_nasm.obj: nasm/arith.asm | $(BUILD_DIR)
	@echo "Assembling NASM code..."
	$(NASM) $(NASM_FLAGS) -o $@ $<

$(BUILD_DIR)/main_nasm.obj: nasm/main.c nasm/arith.h common/test_cases.h | $(BUILD_DIR)
	@echo "Compiling NASM test program..."
	$(GCC) $(GCC_FLAGS) -c -o $@ $<

$(BUILD_DIR)/arith_nasm.exe: $(BUILD_DIR)/arith_nasm.obj $(BUILD_DIR)/main_nasm.obj
	@echo "Linking NASM executable..."
	$(GCC) -o $@ $^

test-nasm: nasm
	@echo "Running NASM tests..."
	$(BUILD_DIR)/arith_nasm.exe

# ============================================================
# GAS (AT&T Syntax) Assembly
# ============================================================
gas: $(BUILD_DIR) $(BUILD_DIR)/arith_gas.exe
	@echo "GAS build complete: $(BUILD_DIR)/arith_gas.exe"

$(BUILD_DIR)/arith_gas.obj: gas/arith.s | $(BUILD_DIR)
	@echo "Assembling GAS code..."
	$(GCC) -c -o $@ $<

$(BUILD_DIR)/main_gas.obj: gas/main.c gas/arith.h common/test_cases.h | $(BUILD_DIR)
	@echo "Compiling GAS test program..."
	$(GCC) $(GCC_FLAGS) -c -o $@ $<

$(BUILD_DIR)/arith_gas.exe: $(BUILD_DIR)/arith_gas.obj $(BUILD_DIR)/main_gas.obj
	@echo "Linking GAS executable..."
	$(GCC) -o $@ $^

test-gas: gas
	@echo "Running GAS tests..."
	$(BUILD_DIR)/arith_gas.exe

# ============================================================
# Run all tests
# ============================================================
test: test-go test-nasm test-gas
	@echo ""
	@echo "All tests completed!"

# ============================================================
# Clean
# ============================================================
clean:
	@echo "Cleaning build artifacts..."
	@if exist $(BUILD_DIR) rmdir /s /q $(BUILD_DIR)
	@if exist go\arith.exe del /q go\arith.exe
	@echo "Clean complete."
