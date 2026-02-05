# Linux x64 Interop Example Makefile

CC = gcc
AS = as

CFLAGS = -Wall -O2
ASFLAGS =

TARGET = test_interop
OBJS = main.o c_asm_interop.o

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

main.o: main.c
	$(CC) $(CFLAGS) -c -o $@ $<

c_asm_interop.o: c_asm_interop.s
	$(AS) $(ASFLAGS) -o $@ $<

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET) $(OBJS)
