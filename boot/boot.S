[BITS 16]

[global _start]
[global boot_disk]
[extern menu_entry]

jmp 0x0:_start

_start:
    ; disable interrupts
    cli

    ; save disk number
    mov [boot_disk], dl

    ; setup segmentation
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; setup stack
    mov sp, 0x7c00

    ; re-enable interrupts
    sti

    ; load the next stage
    mov ah, 0x42
    mov dl, [boot_disk]
    mov si, disk_packet
    int 0x13

    jmp menu_entry

disk_packet:
    db 0x10         ; size of packet
    db 0x00         ; reserved/unused
    dw 0x0007       ; sectors to read
    dw 0x7E00       ; offset (low 16 bits of the address)
    dw 0x0000       ; segment (high 16 bits of the address)
    dq 0x00000001   ; LBA (second sector, LBA 1)

times 510 - ($ - $$) db 0
dw 0xAA55

section .bss

boot_disk:
    resb 1