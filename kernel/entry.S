[BITS 32]

section .text

%include "vga.inc"
%include "serial.inc"

section .text.prologue

global _start
_start:
    jmp kmain

section .text

kmain:
    mov esp, stack_top

    call vga_clear

    mov esi, hello_world
    call vga_puts
    
    jmp $

section .rodata
hello_world: db "Hello, world!", 0

section .bss

align 16
stack_bottom:
resb 4096
stack_top: