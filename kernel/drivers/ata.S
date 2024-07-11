section .text

%include "vga.inc"
%include "rtc.inc"
%include "serial.inc"

%define ATA_PRIMARY         0x1F0
%define ATA_SECONDARY       0x170

%define ATA_PRIMARY_CTRL    0x3F6
%define ATA_SECONDARY_CTRL  0x376

%define ATA_MASTER          0xA0
%define ATA_SLAVE           0xB0

%define ATA_WAIT            0x00
%define ATA_IDENTIFY        0xEC
%define ATA_READ            0x20
%define ATA_WRITE           0x30

%define ATA_OK              0x00
%define ATA_NO_DRIVES       0x01
%define ATA_DISK_ERR        0x02

[global ata_install]

; ata_400ns - waits roughly 400ns
; output:
;   al = error code
ata_400ns:
    xor cx, cx
    mov dx, [ata_base]
    add dx, 7
ata_400ns.loop:
    cmp cx, 15
    jg ata_400ns.done

    in al, dx
    
    inc cx
    jmp ata_400ns.loop
ata_400ns.done:
    ret

; ata_poll - polls from ata
; output:
;   al = error code
ata_poll:
    call ata_400ns
    mov dx, [ata_base]
    add dx, 7
ata_poll.loop:
    in al, dx
    mov [ata_status], al

    and al, 0x80
    cmp al, 0
    jz ata_poll.done

    mov al, [ata_status]
    and al, 0x08
    jnz ata_poll.done

    mov al, [ata_status]
    and al, 0x01
    jnz ata_poll.error
ata_poll.done:
    xor al, al
    ret
ata_poll.error:
    mov al, ATA_DISK_ERR
    ret

; ata_identify - identifies an ata disk
; arguments:
;   al = master or slave
;   dx = primary or secondary
; outputs:
;   al = error code
ata_identify:
    mov word [ata_base], dx
    mov byte [ata_type], al

    add dx, 6
    out dx, al

    xor al, al
    mov dx, 0x1F2
ata_identify.loop:
    cmp dx, 0x1F5
    je ata_identify.send_ident

    out dx, al

    inc dx
    jmp ata_identify.loop
ata_identify.send_ident:
    mov dx, [ata_base]
    add dx, 7
    mov al, ATA_IDENTIFY
    
    out dx, al
    in al, dx

    cmp al, 0
    jz ata_identify.no_drives

    call ata_poll
    cmp al, 0
    jnz ata_identify.disk_error

    mov ecx, 1
    xor esi, esi
    mov edi, ata_temp_buffer
    call ata_read

    mov esi, ata_temp_buffer
    add esi, 54
    mov edi, ata_drive_label
    xor ecx, ecx
ata_identify.label_loop:
    cmp ecx, 40
    je ata_identify.done

    lodsb
    mov [edi], al

    inc ecx
    add edi, 2
    jmp ata_identify.label_loop
ata_identify.done:
    ;mov esi, ata_drive_label
    ;call vga_puts

    xor al, al
    ret
ata_identify.no_drives:
    mov al, ATA_NO_DRIVES
    ret
ata_identify.disk_error:
    mov al, ATA_DISK_ERR
    ret

; ata_read - reads data from a drive
; arguments:
;   ecx = number of sectors to read
;   esi = starting lba address
;   edi = where to store the data
; outputs:
;   al = error code
ata_read:
    mov bl, [ata_type]
    add bl, 0x40

    mov eax, esi
    shr eax, 24
    and eax, 0x0F
    or al, bl

    ; set master/slave
    mov dx, [ata_base]
    add dx, 6
    out dx, al

    ; send wait
    mov al, ATA_WAIT
    sub dx, 5
    out dx, al

    ; send sector count
    mov al, cl
    inc dx
    out dx, al

    ; send lower 8 bits of lba
    mov eax, esi
    inc dx
    out dx, al

    ; send middle 8 bits of lba
    shr eax, 8
    inc dx
    out dx, al

    ; send high 8 bits of lba
    shr eax, 8
    inc dx
    out dx, al

    ; send read command
    mov al, ATA_READ
    add dx, 2
    out dx, al

    mov dx, ATA_PRIMARY
    mov ecx, 256
    rep insw

    call ata_400ns

    xor al, al
    ret

; ata_install - initializes the ata-pio driver
ata_install:
    mov al, ATA_MASTER
    mov dx, ATA_PRIMARY
    call ata_identify

    cmp al, 0
    jnz .error

    serial_println "ata_install: initialized ATA (00)"
    ret
ata_install.error:
    xor ebx, ebx
    mov bl, al
    mov eax, ebx
    
    mov edi, ata_error
    call int_to_str

    serial_print "ata_install: failed to initialize ATA ("

    mov esi, ata_error
    call serial_puts

    serial_println ")"
    ret

section .data

ata_base:
    dw 0x0000
ata_type:
    db 0x00
ata_drive_label:
    times 40 db 0x00

section .bss

ata_status:
    resb 1
ata_error:
    resb 3
ata_temp_buffer:
    resb 512