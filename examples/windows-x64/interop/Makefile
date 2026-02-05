# Windows x64 Interop Example Makefile

CC = gcc
NASM = nasm

CFLAGS = -Wall -O2
NASMFLAGS = -f win64

TARGET = test_interop.exe
OBJS = main.o c_asm_interop.o

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

main.o: main.c
	$(CC) $(CFLAGS) -c -o $@ $<

c_asm_interop.o: c_asm_interop.asm
	$(NASM) $(NASMFLAGS) -o $@ $<

clean:
	del /Q $(TARGET) $(OBJS) 2>nul || true
