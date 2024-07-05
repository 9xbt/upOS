[BITS 16]
[extern boot_disk]
[global list_handler]

jmp list_handler

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

    mov si, controls_msg
    call print_string

    ret

list_handler:
    mov ah, 0x01
    mov cx, 0x2607
    int 0x10

    mov si, version_msg
    call print_string
    mov si, select_msg
    call print_string
list_handler.loop:
    mov dx, 0x0400 ; x: 0, y: 4
    mov ah, 0x02
    int 0x10

    call show_list

    mov ah, 0x00 ; get keystroke
    int 0x16

    cmp ah, 0x1C ; return/enter
    je load_os
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

read_disk:
    mov ah, 0x42
    mov dl, [boot_disk]
    mov si, dap
    int 0x13
    jc .failed
    ret
read_disk.failed:
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

load_os:
    mov si, loading_msg.1
    call print_string

    cmp byte [list.upos.default.color], 0x70
    jne load_os.2
load_os.1:
    mov si, load_os.entry1
    call print_string

    mov dword [boot_header.flags], 0x00000000
    jmp load_os.actually_load
load_os.2:
    mov si, load_os.entry2
    call print_string

    mov dword [boot_header.flags], 0x00000001
load_os.actually_load:
    mov si, loading_msg.2
    call print_string

    call read_disk

    cli             ; disable interrupts

    in al, 0x92
    or al, 2
    out 0x92, al    ; enable the A20 line

    lgdt [gdtr]

    mov eax, cr0
    or al, 1
    mov cr0, eax    ; enable protected mode

    jmp 0x08:pmode_main

[BITS 32]

pmode_main:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    mov eax, boot_header
    jmp 0x10000

[BITS 16]

version_msg:
    db "upOS bootloader v0.3", 0x0D, 0x0A, 0x00

select_msg:
    db 0x0A, "Please select the operating system to start:", 0x0D, 0x0A, 0x0A, 0x00

loading_msg.1:
    db "Loading ", '"', 0x00
loading_msg.2:
    db '"', "...", 0x0D, 0x0A, 0x00

fail_msg:
    db " failed.", 0x00

controls_msg:
    db 0x0A, "Use ", 0x18, " and ", 0x19, " to move the highlight to your choice.", 0x0D, 0x0A
    db "Press enter to choose.", 0x0D, 0x0A, 0x0A, 0x00

list.upos.default:
    db "    upOS Version 0.2                   ", 0x0D, 0x0A, 0x00
list.upos.default.color:
    db 0x70
list.upos.qemu:
    db "    upOS Version 0.2 [QEMU serial]     ", 0x0D, 0x0A, 0x00
list.upos.qemu.color:
    db 0x07
list.len:
    dw 38

load_os.entry1:
    db "upOS Version 0.2", 0x00
load_os.entry2:
    db "upOS Version 0.2 [QEMU serial]", 0x00

boot_header:
    .magic:
        dq 0x1BADB002
    .version:
        db "0.3     "
    .flags:
        dq 0x00000000

dap:
    db 0x10         ; size of packet
    db 0x00         ; reserved/unused
    dw 0x0040       ; sectors to read
    dw 0x0000       ; offset (low 16 bits of the address)
    dw 0x1000       ; segment (high 16 bits of the address)
    dq 0x00000003   ; LBA (fourth sector, LBA 3)

gdtr:
    dw gdt_end - gdt_base - 1
    dd gdt_base

gdt_base:
    ; null segment
    dw 0x0000       ; Limit
    dw 0x0000       ; Base (low 16 bits)
    db 0x00         ; Base (mid 8 bits)
    db 00000000b    ; Access
    db 00000000b    ; Granularity
    db 0x00         ; Base (high 8 bits)

    ; 32-bit code
    dw 0xFFFF       ; Limit
    dw 0x0000       ; Base (low 16 bits)
    db 0x00         ; Base (mid 8 bits)
    db 10011011b    ; Access
    db 11001111b    ; Granularity
    db 0x00         ; Base (high 8 bits)

    ; 32-bit data
    dw 0xFFFF       ; Limit
    dw 0x0000       ; Base (low 16 bits)
    db 0x00         ; Base (mid 8 bits)
    db 10010011b    ; Access
    db 11001111b    ; Granularity
    db 0x00         ; Base (high 8 bits)
gdt_end: