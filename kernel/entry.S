[BITS 32]

section .text

%include "vga.inc"
%include "idt.inc"
%include "pic.inc"
%include "kbd.inc"
%include "rtc.inc"
%include "ata.inc"
%include "shell.inc"
%include "serial.inc"
%include "pmm.inc"

extern gdt_install

section .multiboot

MAGIC equ 0x1BADB002
FLAGS equ 0
CHECKSUM equ -(MAGIC + FLAGS)

section .multiboot

dd MAGIC
dd FLAGS
dd CHECKSUM

global _start
_start:
    jmp kmain

section .text

kmain:
    mov esp, stack_top

    mov [mboot_magic], eax
    mov [mboot_header_ptr], ebx

    call vga_clear
    call vga_enable_cursor

    vga_println "Welcome to upOS v0.3 (build ", __DATE__, " ", __TIME__, ")!", 0x0A

    call gdt_install
    call idt_install
    call pic_install
    call ata_install
    call kbd_install
    call pmm_install

    jmp shell_entry

section .bss

align 16
stack_bottom:
resb 4096
stack_top:

mboot_magic:
    resb 4
mboot_header_ptr:
    resb 4