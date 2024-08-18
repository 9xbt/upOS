[BITS 16]
[global _start]

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

    ; save real mode data segment
    push ds

    ; enable A20
    in al, 0x92
    or al, 2
    out 0x92, al

    ; load the GDT with the tweaked descriptor limits
    lgdt [gdtr]
    
    ; enable protected mode
    mov eax, cr0
    or al, 1
    mov cr0, eax

    jmp 0x08:pmode

pmode:
    ; setup segmentation
    mov bx, 0x10
    mov ds, bx

    ; disable protected mode
    and al, 0xFE
    mov cr0, eax

    jmp 0x0:unreal

unreal:
    ; get back old segment
    pop ds

    mov ebx, 0x0F690F48
    mov eax, 0xB8000
    mov [ds:eax], ebx

    jmp $

boot_disk:
    db 0x00

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
    db 10011010b    ; Access
    db 00000000b    ; Granularity
    db 0x00         ; Base (high 8 bits)

    ; 32-bit data
    dw 0xFFFF       ; Limit
    dw 0x0000       ; Base (low 16 bits)
    db 0x00         ; Base (mid 8 bits)
    db 10010010b    ; Access
    db 11001111b    ; Granularity
    db 0x00         ; Base (high 8 bits)
gdt_end:

times 510 - ($ - $$) db 0
dw 0xAA55