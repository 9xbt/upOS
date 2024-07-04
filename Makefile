# Assembler
AS = nasm

# Automatically find sources
BOOT_SOURCES = $(shell cd boot && find -L * -type f -name '*.S')
KERNEL_SOURCES = $(shell cd kernel && find -L * -type f -name '*.S')

# Get object files
BOOT_OBJS := $(addprefix bin/boot/, $(BOOT_SOURCES:.S=.o))
KERNEL_OBJS := $(addprefix bin/kernel/, $(KERNEL_SOURCES:.S=.o))

# Assembler flags
ASFLAGS = -f elf32

# Output image name
IMAGE_NAME = upOS

all: dirs boot kernel hdd run

run:
	qemu-system-i386 -debugcon stdio -drive file=bin/$(IMAGE_NAME).hdd,format=raw

dirs:
	mkdir -p bin

bin/boot/%.o: boot/%.S
	mkdir -p "$$(dirname $@)"
	$(AS) $(ASFLAGS) -o $@ $<

bin/kernel/%.o: kernel/%.S
	mkdir -p "$$(dirname $@)"
	$(AS) $(ASFLAGS) -o $@ $<

boot: $(BOOT_OBJS)
	$(LD) -m elf_i386 -Ttext 0x7C00 --oformat=binary $^ -o bin/bootsect.bin

kernel: $(KERNEL_OBJS)
	$(LD) -m elf_i386 -T kernel/linker.ld $^ -o bin/kernel.bin

hdd:
	cat bin/bootsect.bin bin/kernel.bin > bin/$(IMAGE_NAME).hdd

clean:
	rm -f $(BOOT_OBJS) $(KERNEL_OBJS)
	rm -rf bin