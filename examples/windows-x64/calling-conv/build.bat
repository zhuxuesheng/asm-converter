@echo off
REM =============================================================================
REM Build script for Microsoft x64 Calling Convention Verification Examples
REM =============================================================================
REM
REM This script builds and runs the calling convention verification examples
REM using NASM and MinGW-w64 GCC on Windows.
REM
REM Requirements:
REM   - NASM >= 2.15 (in PATH)
REM   - MinGW-w64 GCC (in PATH)
REM
REM Usage:
REM   build.bat          - Build and run tests
REM   build.bat build    - Build only
REM   build.bat clean    - Clean build artifacts
REM   build.bat debug    - Build with debug symbols
REM
REM =============================================================================

setlocal enabledelayedexpansion

REM Configuration
set TARGET=test_calling_conv.exe
set ASM_SRC=calling_conv.asm
set C_SRC=main.c
set ASM_OBJ=calling_conv.obj
set C_OBJ=main.obj

REM Parse command line argument
set ACTION=%1
if "%ACTION%"=="" set ACTION=test

REM =============================================================================
REM Clean action
REM =============================================================================
if "%ACTION%"=="clean" (
    echo Cleaning build artifacts...
    if exist %ASM_OBJ% del %ASM_OBJ%
    if exist %C_OBJ% del %C_OBJ%
    if exist %TARGET% del %TARGET%
    echo Clean complete.
    goto :end
)

REM =============================================================================
REM Check for required tools
REM =============================================================================
echo Checking for required tools...

where nasm >nul 2>&1
if errorlevel 1 (
    echo ERROR: NASM not found in PATH
    echo Please install NASM and add it to your PATH
    exit /b 1
)

where gcc >nul 2>&1
if errorlevel 1 (
    echo ERROR: GCC not found in PATH
    echo Please install MinGW-w64 and add it to your PATH
    exit /b 1
)

echo   NASM: OK
echo   GCC:  OK
echo.

REM =============================================================================
REM Build action
REM =============================================================================
echo Building Microsoft x64 Calling Convention Examples...
echo.

REM Set flags based on build type
set NASMFLAGS=-f win64
set CFLAGS=-Wall -Wextra -O2
set LDFLAGS=

if "%ACTION%"=="debug" (
    echo [DEBUG BUILD]
    set NASMFLAGS=-f win64 -g -F cv8
    set CFLAGS=-Wall -Wextra -g -O0
    set LDFLAGS=-g
)

REM Assemble NASM source
echo [1/3] Assembling %ASM_SRC%...
nasm %NASMFLAGS% -o %ASM_OBJ% %ASM_SRC%
if errorlevel 1 (
    echo ERROR: NASM assembly failed
    exit /b 1
)
echo       Created %ASM_OBJ%

REM Compile C source
echo [2/3] Compiling %C_SRC%...
gcc %CFLAGS% -c -o %C_OBJ% %C_SRC%
if errorlevel 1 (
    echo ERROR: C compilation failed
    exit /b 1
)
echo       Created %C_OBJ%

REM Link
echo [3/3] Linking...
gcc %LDFLAGS% -o %TARGET% %ASM_OBJ% %C_OBJ%
if errorlevel 1 (
    echo ERROR: Linking failed
    exit /b 1
)
echo       Created %TARGET%

echo.
echo Build successful!
echo.

REM =============================================================================
REM Test action (default)
REM =============================================================================
if "%ACTION%"=="test" (
    echo Running tests...
    echo ================
    echo.
    %TARGET%
    echo.
    if errorlevel 1 (
        echo Some tests failed!
        exit /b 1
    )
)

if "%ACTION%"=="build" (
    echo Build complete. Run '%TARGET%' to execute tests.
)

if "%ACTION%"=="debug" (
    echo Debug build complete. Run '%TARGET%' to execute tests.
    echo Use x64dbg or gdb for debugging.
)

:end
endlocal
