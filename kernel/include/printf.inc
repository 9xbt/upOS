%ifndef __PRINTF_INC
%define __PRINTF_INC

[extern parse_num]
[extern printf]

%macro print 1-*
    section .text
%rep %0 
%rotate -1
%ifstr %1
    section .rodata
%%string:
    db %1, 0x00
    section .text
    push %%string
%else
    push %1
%endif
%endrep
    call printf
%endmacro

%endif