section .text

%include "serial.inc"

%define PIC1            0x20        ; IO base address for master PIC
%define PIC2            0x20        ; IO base address for slave PIC
%define PIC1_CMD        PIC1
%define PIC1_DAT        (PIC1+1)
%define PIC2_CMD        PIC2
%define PIC2_DAT        (PIC2+1)

%define ICW1_ICW4       0x01        ; Indicates that ICW4 will be present
%define ICW1_SINGLE     0x02        ; Single (cascade) mode
%define ICW1_INTERLVAL4 0x04        ; Call address interval 4 (8)
%define ICW1_LEVEL      0x08        ; Level triggered (edge) mode
%define ICW1_INIT       0x10        ; Initialization

%define ICW4_8086       0x01        ; 8086/88 (MCS-80/85) mode
%define ICW4_AUTO       0x02        ; Auto (normal) EOI
%define ICW4_BUF_SLAVE  0x08        ; Buffered mode/slave
%define ICW4_BUF_MASTER 0x0C        ; Buffered mode/master
%define ICW4_SFNM       0x10        ; Special fully nested (not)

%define PIC_EOI         0x20        ; PIC end of interrupt

[global pic_install]
[global pic_eoi]

; pic_install - sets up the two programmable interrupt controllers
; this will start the init sequence in cascade mode
pic_install:
    mov al, ICW1_INIT | ICW1_ICW4
    mov dx, PIC1_CMD
    out dx, al
    mov al, ICW1_INIT | ICW1_ICW4
    mov dx, PIC2_CMD
    out dx, al
    mov al, 0x20
    mov dx, PIC1_DAT
    out dx, al          ; Master PIC offset
    mov al, 0x28
    mov dx, PIC2_DAT
    out dx, al          ; Slave PIC offset
    mov al, 0x04
    mov dx, PIC1_DAT
    out dx, al          ; Tell master PIC there's a slave PIC at IRQ2
    mov al, 0x02
    mov dx, PIC2_DAT
    out dx, al          ; Tell slave PIC its cascade identity
    mov al, ICW4_8086
    mov dx, PIC1_DAT
    out dx, al          ; Use 8086 PIC
    mov al, ICW4_8086
    mov dx, PIC2_DAT
    out dx, al          ; Same thing

    mov al, 0x00
    mov dx, PIC1_DAT
    out dx, al          ; Master PIC mask
    mov al, 0x00
    mov dx, PIC2_DAT
    out dx, al          ; Slave PIC mask

    sti                 ; Enable interrupts

    serial_println "[pic] pic initialized"
    ret

; pic_eoi - PIC end of interrupt
; arguments:
;   al: interrupt number
pic_eoi:
    cmp al, 8
    jge .pic2

    mov al, PIC_EOI
    mov dx, PIC1
    out dx, al
    ret

pic_eoi.pic2:
    mov al, PIC_EOI
    mov dx, PIC2
    out dx, al
    ret