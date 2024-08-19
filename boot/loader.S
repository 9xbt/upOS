[BITS 16]

%include "multiboot.inc"

[global load_os]
[extern boot_disk]

load_os:
    ; disable interrupts
    cli

    ; save real mode data segment
    push es
    push ds

    ; enable A20
    in al, 0x92
    or al, 2
    out 0x92, al

    ; load the GDT with the tweaked descriptor limits
    lgdt [voodoo_gdtr]
    
    ; enable protected mode
    mov eax, cr0
    or al, 1
    mov cr0, eax

    jmp 0x08:voodoo_pmode

[BITS 32]

voodoo_pmode:
    ; setup segmentation
    mov bx, 0x10
    mov ds, bx
    mov es, bx

    ; disable protected mode
    and al, 0xFE
    mov cr0, eax

    jmp 0x0:unreal

[BITS 16]

unreal:
    ; get back old data segment
    pop ds
    pop es

    mov esp, 0x10000

    ;xor cx, cx
;read_loop:
    ;cmp cx, 32
    ;jge read_loop.done
    
    mov ah, 0x42
    mov dl, 0x80
    mov si, voodoo_dap
    int 0x13
 
    ;push ecx

    mov esi, 0x10000
    mov edi, 0x100000
    mov ecx, 64 * 512

    rep movsb

    ;pop ecx

    ;inc cx
    ;jmp read_loop
read_loop.done:
    mov bx, 0x0f01
    mov eax, 0xb8000
    mov [ds:eax], bx

    lgdt [gdtr]

    mov eax, cr0
    or al, 1
    mov cr0, eax

    jmp 0x08:pmode

[BITS 32]

pmode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    mov word [0xb8002], 0x0f02

    jmp 0x10000C

voodoo_dap:
    db 0x18         ; size of packet
    db 0x00         ; reserved/unused
    dw 0x0040       ; sectors to read
    dw 0x0000       ; offset (low 16 bits of the address)
    dw 0x1000       ; segment (high 16 bits of the address)
    dq 0x00000008   ; LBA (ninth sector, LBA 8)

voodoo_gdtr:
    dw voodoo_gdt_end - voodoo_gdt_base - 1
    dd voodoo_gdt_base
voodoo_gdt_base:
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
voodoo_gdt_end:

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

section .bss

multiboot:
    resb multiboot_header_size