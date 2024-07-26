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
QEMUFLAGS = -debugcon stdio -cdrom bin/upOS.iso

# Output image name
IMAGE_NAME = upOS

all: dirs boot kernel iso

run: all
	qemu-system-i386 $(QEMUFLAGS)

run-gtk: all
	qemu-system-i386 $(QEMUFLAGS) -display gtk,zoom-to-fit=on

run-sdl:
	qemu-system-i386 $(QEMUFLAGS) -display sdl

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

iso:
	grub-file --is-x86-multiboot bin/kernel.elf
	mkdir -p iso_root/boot/grub/
	cp bin/kernel.elf iso_root/boot/kernel.elf
	cp boot/grub.cfg iso_root/boot/grub/grub.cfg
	grub-mkrescue -o bin/upOS.iso iso_root/

clean:
	rm -f $(BOOT_OBJS) $(KERNEL_OBJS)
	rm -rf bin