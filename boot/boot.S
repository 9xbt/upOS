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
    int 0x10

    mov si, version_msg
    call print_string

    call list_handler

    jmp $

show_list:
    mov cx, [list.len]
    mov bl, [list.upos.default.color]
    call set_color

    mov si, list.upos.default
    call print_string

    mov cx, [list.len]
    mov bl, [list.upos.qemu.color]
    call set_color

    mov si, list.upos.qemu
    call print_string

    ret

list_handler:
    mov si, select_msg
    call print_string

list_handler.loop:
    mov dx, 0x0400 ; x: 0, y: 4
    mov ah, 0x02
    int 0x10

    call show_list

    mov ah, 0x00
    int 0x16

    cmp ah, 0x48 ; up arrow
    je list_handler.arrowkey

    cmp ah, 0x50 ; down arrow
    jne list_handler.loop

list_handler.arrowkey:
    cmp byte [list.upos.default.color], 0x70
    jc list_handler.2

list_handler.1:
    mov byte [list.upos.default.color], 0x07
    mov byte [list.upos.qemu.color], 0x70
    jmp list_handler.loop

list_handler.2:
    mov byte [list.upos.default.color], 0x70
    mov byte [list.upos.qemu.color], 0x07
    jmp list_handler.loop

set_color:
    mov ah, 0x09
    int 0x10
    ret

load_os:
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
        
    mov ah, 0x0E
    int 0x10

    jmp print_string

    .done: ret

version_msg:
    db "upOS bootloader v0.2", 0x0D, 0x0A, 0x00

select_msg:
    db 0x0A, "Please select the operating system to start:", 0x0D, 0x0A, 0x0A, 0x00

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

list.upos.default:
    db "    upOS Version 0.2                   ", 0x0D, 0x0A, 0x00
list.upos.default.color:
    db 0x70
list.upos.qemu:
    db "    upOS Version 0.2 [QEMU serial]     ", 0x0D, 0x0A, 0x00
list.upos.qemu.color:
    db 0x07
list.len:
    db 38
 
times 510 - ($ - $$) db 0
dw 0xAA55