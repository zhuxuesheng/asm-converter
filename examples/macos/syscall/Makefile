# macOS x64 Syscall Example Makefile

AS = as
LD = ld

TARGET = syscall_example
OBJS = syscall_example.o

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) -o $@ $^ -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _main

syscall_example.o: syscall_example.s
	$(AS) -o $@ $<

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET) $(OBJS)
