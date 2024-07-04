[global vga_clear]
[global vga_putchar]
[global vga_puts]

section .text

vga_clear:
    mov edi, 0xB8000
    mov ecx, 80 * 25 * 2
    mov ax, 0x07
    rep stosw
    ret

vga_putchar:
    xor edi, edi
    xor ebx, ebx

    push ax

    mov al, [vga_x]
    mov bl, 2
    mul bl
    
    mov di, ax
    pop ax

    add edi, 0xB8000

    mov byte [edi], al
    mov byte [edi + 1], 0x07

    mov al, [vga_x]
    inc al
    mov byte [vga_x], al

    ret

vga_puts:
    lodsb
    or al, al
    jz .done
        
    call vga_putchar

    jmp vga_puts

    .done: ret

section .data

vga_x:
    db 0x00
vga_y:
    db 0x00