# PowerPC 64-bit (ELFv2) Calling Convention Example Makefile

CC = powerpc64le-linux-gnu-gcc
AS = powerpc64le-linux-gnu-as
LD = powerpc64le-linux-gnu-gcc

CFLAGS = -Wall -O2 -static -mabi=elfv2
ASFLAGS = -a64 -mpower8

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
	qemu-ppc64le ./$(TARGET)

clean:
	rm -f $(TARGET) $(OBJS)
