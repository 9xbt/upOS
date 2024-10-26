section .text

%include "vga.inc"
%include "pic.inc"

[global idt_install]
[global irq_register]

; idt_install - sets up the interrupt descriptor table
idt_install:
    xor ecx, ecx
idt_install.loop:
    cmp ecx, 256
    jge idt_install.end_loop

    lea eax, [ecx * 8 + idt_base]       ; eax = &idt_base[i]
    lea ebx, [ecx * 4 + idt_int_table]  ; ebx = &idt_int_table[i]

    call idt_set_entry

    inc ecx
    jmp idt_install.loop
idt_install.end_loop:
    lidt [idtr]
    ret

; irq_register - registers an irq
; arguments:
;    ecx: interrupt vector
;    edx: interrupt handler
irq_register:
    add ecx, 32
    lea eax, [ecx * 4 + irq_handlers]
    mov dword [eax], edx
    ret

; idt_set_entry - sets an entry in the IDT
; arguments:
;   eax: pointer to the entry
;   ebx: offset
idt_set_entry:
    mov edx, [ebx]
    mov word [eax], dx          ; offset (low 16 bits)
    mov word [eax + 2], 0x08    ; selector
    mov byte [eax + 4], 0x00    ; reserved, must be 0
    mov byte [eax + 5], 0x8E    ; type
    shr edx, 16
    mov word [eax + 6], dx      ; offset (high 16 bits)
    ret

; isr_handler - handles an interrupt service routine 
isr_handler:
    pop ecx
    pop ecx

    cmp ecx, 0xFF
    je .spurious

    lea eax, [ecx * 4 + exceptions]

    push eax
    vga_print "x86 Fault: "
    pop eax

    mov esi, [eax]
    call vga_puts

    vga_print 0x0A
    cli
isr_handler.halt:
    hlt
    jmp isr_handler.halt
isr_handler.spurious:
    ret

; irq_handler - handles an interrupt request
irq_handler:
    add esp, 36
    pop ecx

    lea eax, [ecx * 4 + irq_handlers]

    cmp dword [eax], 0
    je irq_handler.eoi

    call [eax]
irq_handler.eoi:
    mov al, cl
    call pic_eoi

    sub esp, 40
    ret

section .rodata

exception_1:  db "division by zero", 0
exception_2:  db "debug", 0
exception_3:  db "non-maskable interrupt", 0
exception_4:  db "breakpoint", 0
exception_5:  db "detected overflow", 0
exception_6:  db "out-of-bounds", 0
exception_7:  db "invalid opcode", 0
exception_8:  db "no coprocessor", 0
exception_9:  db "double fault", 0
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
    %assign i 1
    %rep 32
        dd exception_%+i
        %assign i i+1
    %endrep

section .data

idtr:
    dw idt_end - idt_base - 1
    dd idt_base
idt_base:
    times 2040 db 0
idt_end:

irq_handlers: times 256 dd 0

current_irq: db 0

section .text

isrs:
    %macro isr_no_err_stub 1
    int_stub%+%1:
        push 0
        push dword %1

        call isr_handler

        add esp, 8

        iret
    %endmacro

    %macro isr_err_stub 1
    int_stub%+%1:
        push dword %1

        call isr_handler

        add esp, 8

        iret
    %endmacro

    %macro irq_stub 1
    int_stub%+%1:
        push 0
        push dword %1

        pushad

        call irq_handler

        popad
        add esp, 8

        iret
    %endmacro

    isr_no_err_stub 0
    isr_no_err_stub 1
    isr_no_err_stub 2
    isr_no_err_stub 3
    isr_no_err_stub 4
    isr_no_err_stub 5
    isr_no_err_stub 6
    isr_no_err_stub 7
    isr_err_stub    8
    isr_no_err_stub 9
    isr_err_stub    10
    isr_err_stub    11
    isr_err_stub    12
    isr_err_stub    13
    isr_err_stub    14
    isr_no_err_stub 15
    isr_no_err_stub 16
    isr_err_stub    17
    isr_no_err_stub 18
    isr_no_err_stub 19
    isr_no_err_stub 20
    isr_no_err_stub 21
    isr_no_err_stub 22
    isr_no_err_stub 23
    isr_no_err_stub 24
    isr_no_err_stub 25
    isr_no_err_stub 26
    isr_no_err_stub 27
    isr_no_err_stub 28
    isr_no_err_stub 29
    isr_err_stub    30
    isr_no_err_stub 31

%assign i 32
%rep 224
    irq_stub i
    %assign i i+1
%endrep

idt_int_table:
    %assign i 0
    %rep 256
        dd int_stub%+i
        %assign i i+1
    %endrep