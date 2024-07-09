%include "vga.inc"
%include "kbd.inc"

[global shell_entry]

section .text

shell_entry:
shell_loop:
    vga_print "> "
    call kbd_get_string

    vga_print "Text typed: "
    mov esi, kbd_buffer
    call vga_puts
    vga_print 0x0A

    jmp shell_loop