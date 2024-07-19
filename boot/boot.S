[BITS 16]
[global _start]
[global boot_disk]
[extern list_handler]

jmp 0x0:_start

; _start - basically the first piece of code that is in our control. Loads the rest of the loader.
_start:
    mov [boot_disk], dl

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov sp, 0x7c00

    mov ax, 3
    int 0x10

; read_disk - reads disk.
read_disk:
    mov ah, 0x42
    mov si, dap
    int 0x13
    jnc list_handler
.disk_error:
    ; TODO: maybe print an error
    jmp $

boot_disk:
    db 0x00

dap:
    db 0x10         ; size of packet
    db 0x00         ; reserved/unused
    dw 0x0002       ; sectors to read
    dw 0x7E00       ; offset (low 16 bits of the address)
    dw 0x0000       ; segment (high 16 bits of the address)
    dq 0x00000001   ; LBA (second sector, LBA 1)
 
times 510 - ($ - $$) db 0
dw 0xAA55