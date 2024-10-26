%ifndef __VGA_INC
%define __VGA_INC

[extern vga_clear]
[extern vga_puts]
[extern vga_putchar]
[extern vga_scroll]
[extern vga_enable_cursor]
[extern vga_x]
[extern vga_y]
[extern vga_color]

%macro vga_print 1+
    section .rodata
%%string:
    db %1, 0x00
    section .text

    mov esi, %%string
    call vga_puts
%endmacro

%macro vga_println 1+
    section .rodata
%%string:
    db %1, 0x0A, 0x00
    section .text

    mov esi, %%string
    call vga_puts
%endmacro

%endif