# PowerShell Build Script for Assembly Syntax Comparison Examples
# Builds and tests Go Plan9, NASM (Intel), and GAS (AT&T) assembly examples
# Target platform: Windows x64

param(
    [Parameter(Position=0)]
    [ValidateSet("all", "go", "nasm", "gas", "test", "test-go", "test-nasm", "test-gas", "clean", "help")]
    [string]$Target = "all"
)

$ErrorActionPreference = "Stop"
$BuildDir = "build"

function Show-Help {
    Write-Host "Assembly Syntax Comparison Examples - Build System" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\build.ps1 [target]"
    Write-Host ""
    Write-Host "Targets:"
    Write-Host "  all       - Build all examples (default)" -ForegroundColor Green
    Write-Host "  go        - Build Go Plan9 assembly example"
    Write-Host "  nasm      - Build NASM (Intel syntax) example"
    Write-Host "  gas       - Build GAS (AT&T syntax) example"
    Write-Host "  test      - Run all tests"
    Write-Host "  test-go   - Run Go tests"
    Write-Host "  test-nasm - Run NASM tests"
    Write-Host "  test-gas  - Run GAS tests"
    Write-Host "  clean     - Remove build artifacts"
    Write-Host "  help      - Show this help message"
    Write-Host ""
    Write-Host "Requirements:"
    Write-Host "  - Go 1.17+ (for Go Plan9 assembly)"
    Write-Host "  - NASM 2.15+ (for Intel syntax)"
    Write-Host "  - MinGW-w64 GCC (for AT&T syntax and C compilation)"
}

function Ensure-BuildDir {
    if (-not (Test-Path $BuildDir)) {
        New-Item -ItemType Directory -Path $BuildDir | Out-Null
        Write-Host "Created build directory: $BuildDir"
    }
}

function Build-Go {
    Write-Host "`n=== Building Go Plan9 Assembly ===" -ForegroundColor Yellow
    Ensure-BuildDir
    
    Push-Location go
    try {
        Write-Host "Running: go build -o ../build/arith_go.exe ."
        go build -o "../$BuildDir/arith_go.exe" .
        if ($LASTEXITCODE -ne 0) { throw "Go build failed" }
        Write-Host "Go build complete: $BuildDir/arith_go.exe" -ForegroundColor Green
    }
    finally {
        Pop-Location
    }
}

function Test-Go {
    Write-Host "`n=== Testing Go Plan9 Assembly ===" -ForegroundColor Yellow
    
    Push-Location go
    try {
        Write-Host "Running: go test -v"
        go test -v
        if ($LASTEXITCODE -ne 0) { throw "Go tests failed" }
    }
    finally {
        Pop-Location
    }
}

function Build-NASM {
    Write-Host "`n=== Building NASM (Intel Syntax) Assembly ===" -ForegroundColor Yellow
    Ensure-BuildDir
    
    # Check if NASM is available
    $nasmPath = Get-Command nasm -ErrorAction SilentlyContinue
    if (-not $nasmPath) {
        Write-Host "Error: NASM not found. Please install NASM and add it to PATH." -ForegroundColor Red
        Write-Host "Install with: winget install NASM.NASM"
        return $false
    }
    
    # Check if GCC is available
    $gccPath = Get-Command gcc -ErrorAction SilentlyContinue
    if (-not $gccPath) {
        Write-Host "Error: GCC not found. Please install MinGW-w64 and add it to PATH." -ForegroundColor Red
        return $false
    }
    
    # Assemble NASM code
    Write-Host "Assembling: nasm -f win64 -o $BuildDir/arith_nasm.obj nasm/arith.asm"
    nasm -f win64 -o "$BuildDir/arith_nasm.obj" nasm/arith.asm
    if ($LASTEXITCODE -ne 0) { throw "NASM assembly failed" }
    
    # Compile C code
    Write-Host "Compiling: gcc -Wall -O2 -c -o $BuildDir/main_nasm.obj nasm/main.c"
    gcc -Wall -O2 -c -o "$BuildDir/main_nasm.obj" nasm/main.c
    if ($LASTEXITCODE -ne 0) { throw "C compilation failed" }
    
    # Link
    Write-Host "Linking: gcc -o $BuildDir/arith_nasm.exe $BuildDir/arith_nasm.obj $BuildDir/main_nasm.obj"
    gcc -o "$BuildDir/arith_nasm.exe" "$BuildDir/arith_nasm.obj" "$BuildDir/main_nasm.obj"
    if ($LASTEXITCODE -ne 0) { throw "Linking failed" }
    
    Write-Host "NASM build complete: $BuildDir/arith_nasm.exe" -ForegroundColor Green
    return $true
}

function Test-NASM {
    Write-Host "`n=== Testing NASM (Intel Syntax) Assembly ===" -ForegroundColor Yellow
    
    if (-not (Test-Path "$BuildDir/arith_nasm.exe")) {
        if (-not (Build-NASM)) { return }
    }
    
    Write-Host "Running: $BuildDir/arith_nasm.exe"
    & "$BuildDir/arith_nasm.exe"
    if ($LASTEXITCODE -ne 0) { throw "NASM tests failed" }
}

function Build-GAS {
    Write-Host "`n=== Building GAS (AT&T Syntax) Assembly ===" -ForegroundColor Yellow
    Ensure-BuildDir
    
    # Check if GCC is available
    $gccPath = Get-Command gcc -ErrorAction SilentlyContinue
    if (-not $gccPath) {
        Write-Host "Error: GCC not found. Please install MinGW-w64 and add it to PATH." -ForegroundColor Red
        return $false
    }
    
    # Assemble GAS code
    Write-Host "Assembling: gcc -c -o $BuildDir/arith_gas.obj gas/arith.s"
    gcc -c -o "$BuildDir/arith_gas.obj" gas/arith.s
    if ($LASTEXITCODE -ne 0) { throw "GAS assembly failed" }
    
    # Compile C code
    Write-Host "Compiling: gcc -Wall -O2 -c -o $BuildDir/main_gas.obj gas/main.c"
    gcc -Wall -O2 -c -o "$BuildDir/main_gas.obj" gas/main.c
    if ($LASTEXITCODE -ne 0) { throw "C compilation failed" }
    
    # Link
    Write-Host "Linking: gcc -o $BuildDir/arith_gas.exe $BuildDir/arith_gas.obj $BuildDir/main_gas.obj"
    gcc -o "$BuildDir/arith_gas.exe" "$BuildDir/arith_gas.obj" "$BuildDir/main_gas.obj"
    if ($LASTEXITCODE -ne 0) { throw "Linking failed" }
    
    Write-Host "GAS build complete: $BuildDir/arith_gas.exe" -ForegroundColor Green
    return $true
}

function Test-GAS {
    Write-Host "`n=== Testing GAS (AT&T Syntax) Assembly ===" -ForegroundColor Yellow
    
    if (-not (Test-Path "$BuildDir/arith_gas.exe")) {
        if (-not (Build-GAS)) { return }
    }
    
    Write-Host "Running: $BuildDir/arith_gas.exe"
    & "$BuildDir/arith_gas.exe"
    if ($LASTEXITCODE -ne 0) { throw "GAS tests failed" }
}

function Clean-Build {
    Write-Host "`n=== Cleaning Build Artifacts ===" -ForegroundColor Yellow
    
    if (Test-Path $BuildDir) {
        Remove-Item -Recurse -Force $BuildDir
        Write-Host "Removed: $BuildDir"
    }
    
    if (Test-Path "go/arith.exe") {
        Remove-Item -Force "go/arith.exe"
        Write-Host "Removed: go/arith.exe"
    }
    
    Write-Host "Clean complete." -ForegroundColor Green
}

# Main execution
switch ($Target) {
    "help" { Show-Help }
    "go" { Build-Go }
    "nasm" { Build-NASM | Out-Null }
    "gas" { Build-GAS | Out-Null }
    "test-go" { Build-Go; Test-Go }
    "test-nasm" { Test-NASM }
    "test-gas" { Test-GAS }
    "test" {
        Build-Go; Test-Go
        Test-NASM
        Test-GAS
        Write-Host "`n=== All Tests Completed ===" -ForegroundColor Cyan
    }
    "clean" { Clean-Build }
    "all" {
        Build-Go
        Build-NASM | Out-Null
        Build-GAS | Out-Null
        Write-Host "`n=== All Builds Completed ===" -ForegroundColor Cyan
    }
}
