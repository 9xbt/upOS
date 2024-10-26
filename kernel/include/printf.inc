%ifndef __PRINTF_INC
%define __PRINTF_INC

[extern parse_num]
[extern printf]

%macro va_arg 1
%ifstr %1
    section .rodata
%%string%+i:
    db %1, 0x00
    section .text
    push %%string%+i
%else
    push %1
%endif
%endmacro

%macro print 1-*
    section .text
%assign i 0
%rep %0
%rotate -1
va_arg %1
%endrep
    call printf
%rep %0
    add esp, 4
%endrep
%endmacro

%endif