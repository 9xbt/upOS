# Assembler
AS = nasm

# Automatically find sources
BOOT_SOURCES = $(shell cd boot && find -L * -type f -name '*.S')
KERNEL_SOURCES = $(shell cd kernel && find -L * -type f -name '*.S')

# Get object files
BOOT_OBJS := $(addprefix bin/boot/, $(BOOT_SOURCES:.S=.o))
KERNEL_OBJS := $(addprefix bin/kernel/, $(KERNEL_SOURCES:.S=.o))

# Flags
ASFLAGS = -f elf32 -Wall -g -F dwarf
QEMUFLAGS = -debugcon stdio -drive file=bin/$(IMAGE_NAME).hdd,format=raw | xxd

# Output image name
IMAGE_NAME = upOS

all: dirs boot kernel hdd

run: all
	qemu-system-i386 $(QEMUFLAGS)

run-gtk: all
	qemu-system-i386 $(QEMUFLAGS) -display gtk,zoom-to-fit=on

run-gdb: all
	qemu-system-i386 $(QEMUFLAGS) -S -s

dirs:
	mkdir -p bin

bin/boot/%.o: boot/%.S
	mkdir -p "$$(dirname $@)"
	$(AS) $(ASFLAGS) -o $@ $<

bin/kernel/%.o: kernel/%.S
	mkdir -p "$$(dirname $@)"
	$(AS) $(ASFLAGS) -I kernel/include -o $@ $<

boot: $(BOOT_OBJS)
	$(LD) -m elf_i386 -Ttext 0x7C00 --oformat=binary $^ -o bin/boot.bin

kernel: $(KERNEL_OBJS)
	$(LD) -m elf_i386 -Tkernel/linker.ld $^ -o bin/kernel.elf
	objcopy -O binary bin/kernel.elf bin/kernel.bin

hdd:
	dd if=/dev/zero of=bin/$(IMAGE_NAME).hdd bs=512 count=2880
	dd if=bin/boot.bin of=bin/$(IMAGE_NAME).hdd conv=notrunc bs=512 seek=0 count=3
	dd if=bin/kernel.bin of=bin/$(IMAGE_NAME).hdd conv=notrunc bs=512 seek=3 count=2046

clean:
	rm -f $(BOOT_OBJS) $(KERNEL_OBJS)
	rm -rf bin