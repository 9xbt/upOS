section .text

%include "vga.inc"
%include "serial.inc"

[global idt_install]

idt_install:
    xor ecx, ecx
idt_install.loop:
    cmp ecx, 32
    jge idt_install.end_loop

    lea eax, [ecx * 8 + idt_base]       ; eax = &idt_base[i]
    lea ebx, [ecx * 4 + idt_int_table]  ; ebx = &idt_int_table[i]

    call idt_set_entry

    inc ecx
    jmp idt_install.loop
idt_install.end_loop:
    lidt [idtr]

    serial_print "[idt] initialized IDT!"
    ret

idt_set_entry:
    mov edx, [ebx]
    mov word [eax], dx
    mov word [eax + 2], 0x08
    mov byte [eax + 4], 0x00
    mov byte [eax + 5], 0x8E
    shr edx, 16
    mov word [eax + 6], dx
    ret

isr_handler:
    pop ecx
    pop ecx
    lea eax, [ecx * 4 + exceptions]

    push eax
    
    vga_print "x86 Fault! " ; brb i gotta eat dinner

    pop eax

    mov esi, [eax]
    call vga_puts

    ;serial_print "[isr] It's me, the ISR!"

    cli
isr_handler.halt:
    hlt
    jmp isr_handler.halt

section .rodata

; what i'm doing here is basically just
;   char *exception_messages[];
; but in assembly

exception_1: db "division by zero", 0
exception_2: db "debug", 0
exception_3: db "non-maskable interrupt", 0
exception_4: db "breakpoint", 0
exception_5: db "detected overflow", 0
exception_6: db "out-of-bounds", 0
exception_7: db "invalid opcode", 0
exception_8: db "no coprocessor", 0
exception_9: db "double fault", 0
exception_10: db "coprocessor segment overrun", 0
exception_11: db "bad TSS", 0
exception_12: db "segment not present", 0
exception_13: db "stack fault", 0
exception_14: db "general protection fault", 0
exception_15: db "page fault", 0
exception_16: db "unknown interrupt", 0
exception_17: db "coprocessor fault", 0
exception_18: db "alignment check", 0
exception_19: db "machine check", 0
exception_20: db "reserved", 0
exception_21: db "reserved", 0
exception_22: db "reserved", 0
exception_23: db "reserved", 0
exception_24: db "reserved", 0
exception_25: db "reserved", 0
exception_26: db "reserved", 0
exception_27: db "reserved", 0
exception_28: db "reserved", 0
exception_29: db "reserved", 0
exception_30: db "reserved", 0
exception_31: db "reserved", 0
exception_32: db "reserved", 0

exceptions:
    dd exception_1
    dd exception_2
    dd exception_3
    dd exception_4
    dd exception_5
    dd exception_6
    dd exception_7
    dd exception_8
    dd exception_9
    dd exception_10
    dd exception_11
    dd exception_12
    dd exception_13
    dd exception_14
    dd exception_15
    dd exception_16
    dd exception_17
    dd exception_18
    dd exception_19
    dd exception_20
    dd exception_21
    dd exception_22
    dd exception_23
    dd exception_24
    dd exception_25
    dd exception_26
    dd exception_27
    dd exception_28
    dd exception_29
    dd exception_30
    dd exception_31
    dd exception_32

section .data

idtr:
    dw idt_end - idt_base - 1
    dd idt_base
idt_base:
    times 2040 db 0
idt_end:

isrs:
    %macro isr_stub 1
    int_stub%+%1:
        push 0
        push %1

        call isr_handler

        iret
    %endmacro

    %assign i 0
    %rep 32
        isr_stub i
        %assign i i+1
    %endrep

idt_int_table:
    %assign i 0
    %rep 32
        dd int_stub%+i
        %assign i i+1
    %endrep