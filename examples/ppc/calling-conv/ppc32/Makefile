# PowerPC 32-bit Calling Convention Example Makefile

CC = powerpc-linux-gnu-gcc
AS = powerpc-linux-gnu-as
LD = powerpc-linux-gnu-gcc

CFLAGS = -Wall -O2 -static
ASFLAGS = -a32

TARGET = test_calling_conv
OBJS = main.o calling_conv.o

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(CFLAGS) -o $@ $^

main.o: main.c
	$(CC) $(CFLAGS) -c -o $@ $<

calling_conv.o: calling_conv.s
	$(AS) $(ASFLAGS) -o $@ $<

run: $(TARGET)
	qemu-ppc ./$(TARGET)

clean:
	rm -f $(TARGET) $(OBJS)
