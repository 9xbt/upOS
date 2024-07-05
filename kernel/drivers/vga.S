[global vga_clear]
[global vga_puts]
[global vga_putchar]

section .text

vga_clear:
    mov edi, 0xB8000
    mov ecx, 80 * 25 * 2
    mov ax, 0x07
    rep stosw
    ret

vga_puts:
    pusha
vga_puts.loop:
    lodsb
    or al, al
    jz vga_puts.done
        
    call vga_putchar

    jmp vga_puts.loop
vga_puts.done:
    popa
    ret

vga_putchar:
    cmp al, 0x0A
    je .newline

    push ax

    ; vga_y * 160
    mov eax, [vga_y]
    mov ebx, 160
    mul ebx

    push eax

    ; vga_x * 2
    mov eax, [vga_x]
    mov ebx, 2
    mul ebx

    pop ebx

    ; vga_y * 160 + vga_x * 2
    add eax, ebx
    
    mov edi, eax
    pop ax

    add edi, 0xB8000

    mov byte [edi], al
    mov byte [edi + 1], 0x07

    inc byte [vga_x]

    ret
vga_putchar.newline:
    mov byte [vga_x], 0x00
    inc byte [vga_y]
    ret

section .data

vga_x:
    dq 0
vga_y:
    dq 0