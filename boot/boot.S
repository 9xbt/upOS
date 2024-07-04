[BITS 16]
[global _start]

jmp 0x0:_start

_start:
    mov [boot_disk], dl

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov sp, 0x7c00

    mov ax, 3
    int 10h

    mov si, boot_msg
    call print_string

    call read_disk

    mov si, success_msg
    call print_string

    jmp 0x1000:0x0000

read_disk:
    mov ah, 0x42
    mov dl, [boot_disk]
    mov si, dap
    int 0x13
    jc .failed
    ret
    
    .failed:
        mov si, fail_msg
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

boot_msg:
    db "upOS bootloader v0.1", 0x0D, 0x0A, "Loading upOS...", 0x00

success_msg:
    db " SUCCESS!", 0x0D, 0x0A, 0x00

fail_msg:
    db " failed.", 0x00

boot_disk:
    db 0x00

dap:
    db 0x10         ; size of packet
    db 0x00         ; reserved/unused
    dw 0x0001       ; sectors to read
    dw 0x0000       ; offset (low 16 bits of the address)
    dw 0x1000       ; segment (high 16 bits of the address)
    dq 0x00000001   ; LBA (second sector, LBA 1)

times 510 - ($ - $$) db 0
dw 0xAA55