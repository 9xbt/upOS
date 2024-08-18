[BITS 32]

section .text

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

    jmp $

section .bss

align 16
stack_bottom:
resb 4096
stack_top: