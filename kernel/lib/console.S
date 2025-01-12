section .text

%include "multiboot.inc"

[global console_init]

; console_init - initializes a framebuffer console
; arguments:
;   ebx - multiboot header address
console_init:
    mov edi, [ebx + multiboot_header.framebuffer_addr]
    mov [console_fb_addr], edi
    mov edi, [ebx + multiboot_header.framebuffer_pitch]
    mov [console_pitch], edi
    mov edi, [ebx + multiboot_header.framebuffer_width]
    mov [console_width], edi
    mov edi, [ebx + multiboot_header.framebuffer_height]
    mov [console_height], edi

    mov esi, hello
    call console_puts

    ret

hello: db "Hello, world!", 0

; console_puts - Prints a string to the framebuffer console
; arguments:
;   esi: a pointer to the string
console_puts:
    lodsb
    or al, al
    jz .done
    
    call console_putchar

    jmp console_puts
console_puts.done:
    ret

; console_putchar - prints a character to the framebuffer console
; arguments:
;   al - character to print
console_putchar:
    mov edi, [console_fb_addr]
    mov edx, [console_y]
    shl edx, 12
    add edi, edx
    mov edx, [console_x]
    lea edx, [edx * 8]
    shl edx, 2
    add edi, edx
   
    mov ecx, 0
console_putchar.loop:
    push ecx
    mov ecx, 8
    call console_putchar.row_loop
    pop ecx
   
    add edi, [console_pitch]
    inc ecx
    cmp ecx, 15
    jl console_putchar.loop
    inc dword [console_x]
    mov ebx, [console_width]
    shr ebx, 3
    cmp dword [console_x], ebx
    jl console_putchar.scroll_check
    mov dword [console_x], 0
    inc dword [console_y]
console_putchar.scroll_check:
    mov ebx, [console_height]
    shr ebx, 4
    cmp dword [console_y], ebx
    jl console_scroll
    ret
console_putchar.row_loop:
    xor ebx, ebx
    mov bl, al
    shl ebx, 4
    add ebx, [esp + 4]
    movzx ebx, byte [builtin_font + ebx]
   
    mov edx, 0
console_putchar.bit_loop:
    bt ebx, edx
    jnc console_putchar.skip_pixel
   
    push edx
    mov edx, 7
    sub edx, [esp]
    shl edx, 2
    mov ecx, [console_color]
    mov dword [edi + edx], ecx
    pop edx
console_putchar.skip_pixel:
    inc edx
    cmp edx, 8
    jl console_putchar.bit_loop
    ret

; console_scroll - scrolls the console up
console_scroll:
    ret

section .rodata

builtin_font: incbin "kernel/assets/font.bin"

section .data

console_x: dd 0
console_y: dd 0
console_color: dd 0xffffffff

section .bss

console_width: resd 1
console_pitch: resd 1
console_height: resd 1
console_fb_addr: resd 1