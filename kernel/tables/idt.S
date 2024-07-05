section .text

%include "serial.inc"

[global idt_install]

idt_install:
    xor ecx, ecx
idt_install.loop:
    cmp ecx, 256
    jge idt_install.end_loop

    lea eax, [ecx * 8 + idt_base] ; eax = &idt_int_table[i]
    
    mov ebx, ecx
    mov edx, 16
    imul ebx, edx
    add ebx, isrs

    call idt_set_entry

    inc ecx
    jmp idt_install.loop
idt_install.end_loop:
    lidt [idtr]

    serial_print "[idt] initialized IDT!"
    ret

idt_set_entry:
    mov word [eax], bx
    mov word [eax + 2], 0x08
    mov byte [eax + 4], 0x00
    mov byte [eax + 5], 0x8E
    shr ebx, 16
    mov word [eax + 6], bx
    ret

isr_handler:
    serial_print "[isr] It's me, the ISR!"
    ret

section .data

idtr:
    dw idt_end - idt_base - 1
    dd idt_base
idt_base:
    times 2040 db 0
idt_end:

align 16
isrs:
    %macro isr_stub 1
    align 16
    int_stub%+%1:
        call isr_handler
        iret
    %endmacro

    int_stub_len: equ $ - int_stub0

    %assign i 0
    %rep 32
        isr_stub i
        %assign i i+1
    %endrep