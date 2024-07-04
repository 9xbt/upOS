[BITS 32]
[extern vga_clear]
[extern vga_puts]
[extern qemu_puts]

section .text.prologue

jmp _start

global _start
_start:
    mov esp, 0x1000000

    call vga_clear
    
    mov esi, [hello_world] ;no brackets for ptr
    ; if it has no brackets then it throws this error:
    ; kernel/entry.S:(.text.prologue+0xe): relocation truncated to fit: R_386_16 against `.data'
    ; use the 32bit ver of si, aka esi
    ; now it just does not print anything...
    ;call vga_puts ; ah ; nope still does not work
    ;wtf
    
    call qemu_puts

    jmp $

section .data
hello_world: db "Hello, world!",0