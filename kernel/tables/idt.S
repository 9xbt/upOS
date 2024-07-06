section .text

%include "vga.inc"
%include "pic.inc"
%include "serial.inc"

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

    serial_println "[idt] initialized IDT!"
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
    mov word [eax], dx
    mov word [eax + 2], 0x08
    mov byte [eax + 4], 0x00
    mov byte [eax + 5], 0x8E
    shr edx, 16
    mov word [eax + 6], dx
    ret

; isr_handler - handles an interrupt service routine 
isr_handler:
    pop ecx
    pop ecx

    cmp ecx, 0xFF
    je .spurious

    lea eax, [ecx * 4 + exceptions]
    
    vga_print "x86 Fault: "

    mov esi, [eax]
    call vga_puts
    cli
isr_handler.halt:
    hlt
    jmp isr_handler.halt
isr_handler.spurious:
    ret

; irq_handler - handles IRQ.
irq_handler:
    add esp, 36
    pop ecx

    lea eax, [ecx * 4 + irq_handlers]

    cmp dword [eax], 0
    je irq_handler.eoi

    mov byte [current_irq], cl
    call [eax]
    mov cl, [current_irq]
irq_handler.eoi:
    mov al, cl
    call pic_eoi
    ;call pic_eoi
    ;mov al, 0x20
    ;out 0x20, al

    sub esp, 40
    ret

section .rodata

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

irq_handlers: times 256 dd 0

current_irq: db 0

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

    int_stub%+%1_retire:
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

    irq_stub 32
    irq_stub 33
    irq_stub 34
    irq_stub 35
    irq_stub 36
    irq_stub 37
    irq_stub 38
    irq_stub 39
    irq_stub 40
    irq_stub 41
    irq_stub 42
    irq_stub 43
    irq_stub 44
    irq_stub 45
    irq_stub 46
    irq_stub 47
    irq_stub 48
    irq_stub 49
    irq_stub 50
    irq_stub 51
    irq_stub 52
    irq_stub 53
    irq_stub 54
    irq_stub 55
    irq_stub 56
    irq_stub 57
    irq_stub 58
    irq_stub 59
    irq_stub 60
    irq_stub 61
    irq_stub 62
    irq_stub 63
    irq_stub 64
    irq_stub 65
    irq_stub 66
    irq_stub 67
    irq_stub 68
    irq_stub 69
    irq_stub 70
    irq_stub 71
    irq_stub 72
    irq_stub 73
    irq_stub 74
    irq_stub 75
    irq_stub 76
    irq_stub 77
    irq_stub 78
    irq_stub 79
    irq_stub 80
    irq_stub 81
    irq_stub 82
    irq_stub 83
    irq_stub 84
    irq_stub 85
    irq_stub 86
    irq_stub 87
    irq_stub 88
    irq_stub 89
    irq_stub 90
    irq_stub 91
    irq_stub 92
    irq_stub 93
    irq_stub 94
    irq_stub 95
    irq_stub 96
    irq_stub 97
    irq_stub 98
    irq_stub 99
    irq_stub 100
    irq_stub 101
    irq_stub 102
    irq_stub 103
    irq_stub 104
    irq_stub 105
    irq_stub 106
    irq_stub 107
    irq_stub 108
    irq_stub 109
    irq_stub 110
    irq_stub 111
    irq_stub 112
    irq_stub 113
    irq_stub 114
    irq_stub 115
    irq_stub 116
    irq_stub 117
    irq_stub 118
    irq_stub 119
    irq_stub 120
    irq_stub 121
    irq_stub 122
    irq_stub 123
    irq_stub 124
    irq_stub 125
    irq_stub 126
    irq_stub 127
    irq_stub 128
    irq_stub 129
    irq_stub 130
    irq_stub 131
    irq_stub 132
    irq_stub 133
    irq_stub 134
    irq_stub 135
    irq_stub 136
    irq_stub 137
    irq_stub 138
    irq_stub 139
    irq_stub 140
    irq_stub 141
    irq_stub 142
    irq_stub 143
    irq_stub 144
    irq_stub 145
    irq_stub 146
    irq_stub 147
    irq_stub 148
    irq_stub 149
    irq_stub 150
    irq_stub 151
    irq_stub 152
    irq_stub 153
    irq_stub 154
    irq_stub 155
    irq_stub 156
    irq_stub 157
    irq_stub 158
    irq_stub 159
    irq_stub 160
    irq_stub 161
    irq_stub 162
    irq_stub 163
    irq_stub 164
    irq_stub 165
    irq_stub 166
    irq_stub 167
    irq_stub 168
    irq_stub 169
    irq_stub 170
    irq_stub 171
    irq_stub 172
    irq_stub 173
    irq_stub 174
    irq_stub 175
    irq_stub 176
    irq_stub 177
    irq_stub 178
    irq_stub 179
    irq_stub 180
    irq_stub 181
    irq_stub 182
    irq_stub 183
    irq_stub 184
    irq_stub 185
    irq_stub 186
    irq_stub 187
    irq_stub 188
    irq_stub 189
    irq_stub 190
    irq_stub 191
    irq_stub 192
    irq_stub 193
    irq_stub 194
    irq_stub 195
    irq_stub 196
    irq_stub 197
    irq_stub 198
    irq_stub 199
    irq_stub 200
    irq_stub 201
    irq_stub 202
    irq_stub 203
    irq_stub 204
    irq_stub 205
    irq_stub 206
    irq_stub 207
    irq_stub 208
    irq_stub 209
    irq_stub 210
    irq_stub 211
    irq_stub 212
    irq_stub 213
    irq_stub 214
    irq_stub 215
    irq_stub 216
    irq_stub 217
    irq_stub 218
    irq_stub 219
    irq_stub 220
    irq_stub 221
    irq_stub 222
    irq_stub 223
    irq_stub 224
    irq_stub 225
    irq_stub 226
    irq_stub 227
    irq_stub 228
    irq_stub 229
    irq_stub 230
    irq_stub 231
    irq_stub 232
    irq_stub 233
    irq_stub 234
    irq_stub 235
    irq_stub 236
    irq_stub 237
    irq_stub 238
    irq_stub 239
    irq_stub 240
    irq_stub 241
    irq_stub 242
    irq_stub 243
    irq_stub 244
    irq_stub 245
    irq_stub 246
    irq_stub 247
    irq_stub 248
    irq_stub 249
    irq_stub 250
    irq_stub 251
    irq_stub 252
    irq_stub 253
    irq_stub 254
    irq_stub 255

idt_int_table:
    %assign i 0
    %rep 256
        dd int_stub%+i
        %assign i i+1
    %endrep