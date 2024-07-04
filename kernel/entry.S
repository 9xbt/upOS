[BITS 16]

global _start
_start:
    pop ax
    mov ah, 0xE
    int 10h

    ;mov esi, welcome_msg
    ;call print_string
    
    mov esi, flags_msg
    call print_string

    jmp $

print_string:
    mov al, byte [esi]
    or al, al
    jz .done
        
    mov ah, 0x0E
    int 0x10

    inc esi
    jmp print_string

    .done: ret

welcome_msg:
    db "Welcome to upOS 0.2!", 0x0D, 0x0A, 0x00

flags_msg:
    db "Flags: ", 0x00