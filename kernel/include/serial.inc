%ifndef __SERIAL_INC
%define __SERIAL_INC

[extern serial_puts]

%macro serial_print 1+
    section .rodata
%%string:
    db %1, 0x00
    section .text

    mov esi, %%string
    call serial_puts
%endmacro

%macro serial_println 1+
    section .rodata
%%string:
    db %1, 0x0A, 0x00
    section .text

    mov esi, %%string
    call serial_puts
%endmacro

%endif