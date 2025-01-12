section .text

%include "multiboot.inc"

[global console_init]

; console_init - initializes a framebuffer console
; arguments:
;   ebx - multiboot header address
console_init:
    mov edi, [ebx + multiboot_header.framebuffer_addr]
    mov [console_fb_addr], edi
    mov edi, [ebx + multiboot_header.framebuffer_width]
    mov [console_width], edi
    mov edi, [ebx + multiboot_header.framebuffer_height]
    mov [console_height], edi

    ;mov edi, [ebx + multiboot_header.framebuffer_addr]
    ;mov ecx, 1024 * 768
    ;mov eax, 0xff
    ;rep stosd

    mov al, 'A'
    call console_putchar

    ret

console_putchar:
    mov edi, [console_fb_addr]

    xor ecx, ecx
console_putchar.row:
    cmp ecx, 16
    jge console_putchar.done

    mov ebx, ecx
    mov esi, ecx

    push ecx
    call console_putchar.column
    pop ecx

    inc ecx
    jmp console_putchar.row
console_putchar.column:
    cmp ecx, 8
    jge console_putchar.done

    ; c * 16 + i
    ;add bl, al
    ;shl bl, 4
    ;mov ebx, [builtin_font + ebx]

    ; & (1 << (7 - o))
    ;mov edx, 7
    ;sub edx, ecx
    ;shl edx, 1
    
    ;and ebx, edx

    ;cmp ebx, 0 ; TODO: test ebx, ebx ?
    jmp console_putchar.point
console_putchar.column.continue:
    inc ecx
    jmp console_putchar.column
console_putchar.point:
    mov edx, esi   ; i
    ;add ecx, 0     ; y
    ;imul edx, 1024 ; (y + i) * 1024
    ;add edx, 0     ; x
    ;add edx, ecx

    add edi, edx
    mov dword [edi], 0xffffffff

    jmp console_putchar.column.continue
console_putchar.done:
    ret

section .rodata

builtin_font: incbin "kernel/assets/font.bin"

section .data

console_x: dd 0
console_y: dd 0

section .bss

console_width: resd 1
console_height: resd 1
console_fb_addr: resd 1