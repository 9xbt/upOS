[BITS 32]

section .text

%include "multiboot.inc"

section .multiboot

MAGIC equ 0x1BADB002
FLAGS equ 0x00000003
CHECKSUM equ -(MAGIC + FLAGS)

dw 0x0F02
dd MAGIC
dd FLAGS
dd CHECKSUM

section .text.prologue

global _startz
_start:       ; (.text+0xC)
    jmp kmain
_debug_start: ; (.text+0x11)
    jmp kmain

section .text

kmain:
    mov esp, stack_top

    ;mov [mboot_magic], eax
    ;mov [mboot_header], ebx

    mov al, 'H'
    out 0xe9, al
    mov al, 'i'
    out 0xe9, al

    jmp $

section .bss

align 16
stack_bottom:
resb 4096
stack_top: