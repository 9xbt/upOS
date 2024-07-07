[global vga_clear]
[global vga_puts]
[global vga_putchar]
[global vga_scroll]
[global vga_enable_cursor]

section .text

; vga_clear - clears the VGA console
vga_clear:
    mov edi, 0xB8000
    mov ecx, 80 * 25 * 2
    mov ax, 0x07
    rep stosw
    ret

; vga_puts - Prints a string to the VGA console
; arguments:
;   esi: a pointer to the string
vga_puts:
    lodsb
    or al, al
    jz .done
        
    call vga_putchar

    jmp vga_puts
vga_puts.done:
    ret

; vga_putchar - Prints a character to the VGA console
; arguments:
;   al: the character to be printed
vga_putchar:
    cmp al, 0x0A
    je .newline

    cmp al, 0x08
    je .backspace

    cmp byte [vga_x], 80
    jge .newline

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
    
    mov edi, 0xB8000
    add edi, eax
    pop ax

    mov byte [edi], al
    mov byte [edi + 1], 0x0F

    inc dword [vga_x]

    ret
vga_putchar.newline:
    mov dword [vga_x], 0x00
    inc dword [vga_y]

    cmp dword [vga_y], 25
    jge vga_scroll
    ret
vga_putchar.backspace:
    cmp dword [vga_x], 0
    je .no

    dec dword [vga_x]
vga_putchar.backspace.no:
    ret

; vga_scroll - scrolls the vga framebuffer up
vga_scroll:
    push esi
    mov esi, 0xB80A0
    mov edi, 0xB8000
    mov ecx, 3840

    cld
    rep movsw

    mov ax, 0x0007
    mov ecx, 80
    mov edi, 0xB8F00
    rep stosw

    dec dword [vga_y]
    pop esi
    ret

; vga_enable_cursor - enables the vga text mode cursor
vga_enable_cursor:
    ; outb(0x3D4, 0x0A);
    mov dx, 0x3D4
    mov al, 0x0A
    out dx, al

    ; outb(0x3D5, (inb(0x3D5) & 0xC0) | 14);
    mov dx, 0x3D5
    in al, dx
    and al, 0xC0
    or al, 14
    out dx, al

    ; outb(0x3D4, 0x0B);
    mov dx, 0x3D4
    mov al, 0x0B
    out dx, al

    ; outb(0x3D5, (inb(0x3D5) & 0xE0) | 15);
    mov dx, 0x3D5
    in al, dx
    and al, 0xE0
    or al, 15
    out dx, al

    ret

section .data

vga_x:
    dd 0
vga_y:
    dd 0