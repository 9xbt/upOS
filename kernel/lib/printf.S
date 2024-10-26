section .text

%include "vga.inc"

[global parse_num]

; parse_num - parses a decimal number
; arguments:
;   eax - value
parse_num:
    push eax

    mov ebx, 10
    xor edx, edx
    idiv ebx
    mov ecx, eax
    ; (n) ecx = value / base;
    ; (r) edx = value % base;

    pop eax

    cmp edx, 0
    jl parse_num.zero

parse_num.check:
    cmp eax, 10
    jge parse_num.loop

parse_num.print:
    mov al, dl
    add al, '0'

    push edx
    call vga_putchar
    pop edx

    ret
parse_num.zero:
    add edx, 10
    dec ecx
    jmp parse_num.check

parse_num.loop:
    mov eax, ecx
    pushad
    call parse_num
    popad
    jmp parse_num.print