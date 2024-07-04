[BITS 32]

global _start
_start:
    mov byte [0xB8000], 'A' ; trying to remember here
    mov byte [0xB8001], 0x0F ; trying to remember here

    jmp $