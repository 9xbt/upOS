[BITS 16]
[global _start]

jmp 0x0:_start

_start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov sp, 0x7c00

    mov ax, 3
    int 10h

    mov si, boot_msg
    call print_string

    jmp $

print_string:
    lodsb
    or al, al
    jz .done
        
    mov ah, 0x0e
    int 0x10

    jmp print_string

    .done: ret

; probably not the best idea to have hard-coded version numbers
; fair enough but will do for now
; 👍️
; also didn't you count the first ver as 0.2
; personally i find 0.1 as the like the proof that the toolchain works and like the first ever test
; 0.2 is the actual foundation for my programs

boot_msg: db "upOS v0.2", 0x0D, 0x0A, 0x00

times 510 - ($ - $$) db 0
dw 0xAA55