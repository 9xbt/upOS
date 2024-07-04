[global vga_clear]

section .text

vga_clear:
    mov edi, 0xB8000
    mov ecx, 80 * 25 * 2
    mov ax, 0x0F
    rep stosw
    ret