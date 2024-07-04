section .text

global _start
_start:
    mov al, 'A'
    mov ah, 0xE
    int 10h
    jmp $

; nothing to see here for now