section .text

global _start
_start:
    mov al, 'A'
    mov ah, 0xE
    int 10h
    jmp 0x10000

; nothing to see here for now