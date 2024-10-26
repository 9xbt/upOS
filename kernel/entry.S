[BITS 32]

section .text

%include "vga.inc"
%include "gdt.inc"
%include "idt.inc"
%include "printf.inc"
%include "multiboot.inc"

section .multiboot

MAGIC equ 0x1BADB002
FLAGS equ 0x00000003
CHECKSUM equ -(MAGIC + FLAGS)

dd MAGIC
dd FLAGS
dd CHECKSUM

section .text.prologue

global _start
_start:
    jmp kmain

section .text

kmain:
    mov esp, stack_top

    mov [mboot_magic], eax
    mov [mboot_header], ebx

    cmp eax, 0x2BADB002
    je kmain.goodmagic
kmain.badmagic:
    vga_print "Invalid boot header!", 0x0A, "Cannot continue"
    jmp $
kmain.goodmagic:
    call vga_clear
    call vga_enable_cursor

    vga_println "Welcome to upOS v0.3 (build ", __DATE__, " ", __TIME__, ")!", 0x0A

    call gdt_install
    call idt_install

    print `Testing %d\n`, 123

    jmp $

section .bss

align 16
stack_bottom:
resb 4096
stack_top: