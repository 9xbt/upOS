[BITS 32]
[extern vga_clear]

section .text.prologue

jmp _start

global _start
_start:
    mov esp, 0x1000000

    call vga_clear
    mov al, 'W'
    out 0xe9, al

    mov byte [0xB8000], 'A' ; trying to remember here
    mov byte [0xB8001], 0x0F ; trying to remember here

    jmp $