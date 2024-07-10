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

%define ATA_IDENTIFY        0xEC

%define ATA_OK              0x00
%define ATA_NO_DRIVES       0x01

[global ata_install]

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
    jnz ata_identify.no_drive

    xor al, al
    vga_println "DRIVE FOUND"
    ret
ata_identify.no_drive:
    mov al, ATA_NO_DRIVES
    ret

; ata_install - initializes the ata-pio driver
ata_install:
    mov al, ATA_MASTER
    mov dx, ATA_PRIMARY
    call ata_identify

    cmp al, 0
    jnz .error

    serial_println "ata_install: initialized ATA"
    ret
ata_install.error:
    xor ebx, ebx
    mov bl, al
    mov eax, ebx
    
    mov edi, ata_error
    call int_to_str

    serial_print "ata_install: failed to initialize ata ("

    mov esi, ata_error
    call serial_puts

    serial_println ")"
    ret

section .data

ata_base:
    dw 0x0000
ata_type:
    db 0x00

section .bss

ata_error:
    resb 3