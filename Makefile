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
QEMUFLAGS = -debugcon stdio -m 256M -cdrom bin/upOS.iso -drive file=bin/fat32.hdd,format=raw -boot d

# Output image name
IMAGE_NAME = upOS

all: dirs boot kernel iso fs

run: all
	qemu-system-i386 $(QEMUFLAGS)

run-gtk: all
	qemu-system-i386 $(QEMUFLAGS) -display gtk,zoom-to-fit=on

run-sdl:
	qemu-system-i386 $(QEMUFLAGS) -display sdl

run-gdb: all
	qemu-system-i386 $(QEMUFLAGS) -S -s

run-amd:
	qemu-system-i386 $(QEMUFLAGS) -cpu phenom,model_id="Testing AMD processor (phenom)",vendor=AuthenticAMD

run-intel:
	qemu-system-i386 $(QEMUFLAGS) -cpu Snowridge,model_id="Testing Intel processor (Snowridge)",vendor=GenuineIntel

dirs:
	mkdir -p bin

bin/boot/%.o: boot/%.S
	mkdir -p "$$(dirname $@)"
	$(AS) $(ASFLAGS) -I boot/include -I kernel/include -o $@ $<

bin/kernel/%.o: kernel/%.S
	mkdir -p "$$(dirname $@)"
	$(AS) $(ASFLAGS) -I boot/include -I kernel/include -o $@ $<

kernel: $(BOOT_OBJS) $(KERNEL_OBJS)
	$(LD) -m elf_i386 -Tkernel/linker.ld $^ -o bin/kernel.elf

iso:
	grub-file --is-x86-multiboot bin/kernel.elf
	mkdir -p iso_root/boot/grub/
	cp bin/kernel.elf iso_root/boot/kernel.elf
	cp boot/grub.cfg iso_root/boot/grub/grub.cfg
	grub-mkrescue -o bin/upOS.iso iso_root/
	rm -rf iso_root/

fs:
	dd if=/dev/zero of=bin/fat32.hdd bs=1M count=64
	mkfs.fat -F 32 bin/fat32.hdd

clean:
	rm -f $(BOOT_OBJS) $(KERNEL_OBJS)
	rm -rf bin