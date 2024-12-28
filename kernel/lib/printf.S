section .text

%include "vga.inc"

[global get_decimal_len]
[global parse_num]
[global parse_hex]
[global printf]

; get_decimal_len - returns the number of decimal digits in a number
; arguments:
;   eax - value
; returns:
;   ecx - number of digits
get_decimal_len:
    push eax
    xor ecx, ecx
get_decimal_len.loop:
    mov ebx, 10
    xor edx, edx
    idiv ebx
    inc ecx

    test eax, eax
    jg get_decimal_len.loop
get_decimal_len.done:
    pop eax
    ret

; print_padding - prints specified padding
; arguments:
;   al - padding character
;   ebx - padding count
print_padding:
    pushad
    call vga_putchar
    popad

    dec ecx
    test ecx, ecx
    jg print_padding
print_padding.done:
    ret

; parse_num - parses a decimal number
; arguments:
;   eax - value
parse_num:
    push eax
    mov ebx, 10
    xor edx, edx
    idiv ebx
    mov ecx, eax
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
    push edx
    call parse_num
    pop edx
    jmp parse_num.print

; parse_hex - parses a hexadecimal number
; arguments
;   eax - value
parse_hex:
    mov ecx, 8
parse_hex.loop:
    dec ecx
    
    push ecx
    push eax

    mov edx, ecx
    sal edx, 2
    mov cl, dl
    shr eax, cl
    and eax, 0xF

    mov ebx, hex_digits
    add ebx, eax
    mov al, [ebx]
    call vga_putchar

    pop eax
    pop ecx

    cmp ecx, 0
    jg parse_hex.loop
parse_hex.done:
    ret

; printf - prints a formatted string
; arguments:
;   [esp+4] - fmt
;   [esp+8] - args
printf:
    mov ebp, esp

    add ebp, 4
    mov esi, [ebp]
printf.loop:
    cmp byte [esi], 0
    je printf.done
    cmp byte [esi], "%"
    je printf.fmt

    mov al, byte [esi]
    call vga_putchar

    inc esi
    jmp printf.loop
printf.fmt:
    inc esi
    
    cmp byte [esi], 'd'
    je printf.num
    cmp byte [esi], 'x'
    je printf.hex
    cmp byte [esi], 's'
    je printf.str

    jmp printf.loop
printf.num:
    add ebp, 4
    mov eax, [ebp]
    call parse_num

    inc esi
    jmp printf.loop
printf.hex:
    add ebp, 4
    mov eax, [ebp]
    call parse_hex
    
    inc esi
    jmp printf.loop
printf.str:
    add ebp, 4
    push esi
    mov esi, [ebp]
    call vga_puts
    pop esi

    inc esi
    jmp printf.loop
printf.done:
    ret

section .rodata

hex_digits: db "0123456789abcdef"