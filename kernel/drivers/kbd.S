section .text

%include "idt.inc"
%include "vga.inc"
%include "serial.inc"

[global kbd_install]
[global kbd_get_string]
[global kbd_buffer]

; kbd_install - sets up the PS/2 keyboard driver
kbd_install:
    mov ecx, 1
    mov edx, kbd_handler
    call irq_register

    serial_println "kbd_install: initialized keyboard driver"
    ret

kbd_get_string:
    xor al, al
    mov ecx, 64
    mov edi, kbd_buffer

    cld
    rep stosb

    mov dword [kbd_current_idx], 0
kbd_get_string.loop:
    mov al, [kbd_char]
    cmp al, 0
    je .repeat
    
    cmp al, 0x0A
    je kbd_get_string.return

    cmp al, 0x08
    je kbd_get_string.backspace

    cmp al, 0x09
    je kbd_get_string.tab

    cmp dword [kbd_current_idx], 64
    jge .repeat


    mov edx, kbd_buffer
kbd_get_string.test:
    add edx, [kbd_current_idx]
    mov cl, [kbd_char]
    mov [edx], cl
    inc dword [kbd_current_idx]
    call vga_putchar
kbd_get_string.loop.repeat:
    mov byte [kbd_char], 0
    jmp kbd_get_string.loop
kbd_get_string.return:
    vga_print 0x0A
    mov byte [kbd_char], 0
    ret
kbd_get_string.backspace:
    cmp dword [kbd_current_idx], 0
    je .no

    dec dword [kbd_current_idx]
    vga_print 0x08, 0x20, 0x08
kbd_get_string.backspace.no:
    jmp kbd_get_string.loop.repeat
kbd_get_string.tab:
    vga_print 0x09
    add dword [kbd_current_idx], 4
    jmp kbd_get_string.loop.repeat

; kbd_handler - handles keyboard interrupts
kbd_handler:
    ;vga_println "Keyboard!"
    xor eax, eax
    in al, 0x60

    mov bl, al
    and bl, 0x80
    cmp bl, 0
    jnz .release

    ; shift down
    cmp al, 0x2a
    je kbd_handler.shift_down
    cmp al, 0x36
    je kbd_handler.shift_down
    
    ; control down
    cmp al, 0x1d
    je kbd_handler.ctrl_down

    ; caps lock
    cmp al, 0x3a
    je kbd_handler.caps
kbd_handler.char:
    cmp byte [kbd_shift], 1
    je .shift

    cmp byte [kbd_caps], 1
    je .caps

    jmp .nothing
kbd_handler.char.shift:
    mov ebx, kbd_map_keys_shift
    jmp kbd_handler.char.print
kbd_handler.char.caps:
    mov ebx, kbd_map_keys_caps
    jmp kbd_handler.char.print
kbd_handler.char.nothing:
    mov ebx, kbd_map_keys
kbd_handler.char.print:
    add ebx, eax
    mov al, [ebx]
    mov [kbd_char], al
    ret
    ;call vga_putchar
    ;ret
kbd_handler.release:
    ; shift up
    cmp al, 0xaa
    je kbd_handler.shift_rel
    cmp al, 0xb6
    je kbd_handler.shift_rel

    ; control up
    cmp al, 0x9d
    je kbd_handler.ctrl_rel

    mov byte [kbd_char], 0
    ret
kbd_handler.shift_rel:
    mov byte [kbd_shift], 0
    ret
kbd_handler.shift_down:
    mov byte [kbd_shift], 1
    ret
kbd_handler.ctrl_rel:
    mov byte [kbd_ctrl], 0
    ret
kbd_handler.ctrl_down:
    mov byte [kbd_ctrl], 1
    ret
kbd_handler.caps:
    cmp byte [kbd_caps], 0
    jz .off
    mov byte [kbd_caps], 0
    ret
kbd_handler.caps.off:
    mov byte [kbd_caps], 1
    ret

section .rodata

kbd_map_keys:
    db 0, 27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', `\b`
    db `\t`, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', `\n`
    db 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', `\'`, '`', 0
    db `\\`, 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' '
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '-', 0, 0, 0, '+', 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

kbd_map_keys_shift:
    db 0,  27, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', `\b`,
    db `\t`, 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', `\n`,
    db 0, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', '~', 0,
    db `\\`, 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?', 0, '*', 0, ' ',
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '-', 0, 0, 0, '+', 0, 0,
    db 0, 0, 0, 0, 0, 0, 0, 0, 0

kbd_map_keys_caps:
    db 0, 27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', `\b`,
    db `\t`, 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']', `\n`,
    db 0, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', `\'`, '`', 0,
    db `\\`, 'Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/', 0, '*', 0, ' ',
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '-', 0, 0, 0, '+', 0, 0,
    db 0, 0, 0, 0, 0, 0, 0, 0, 0

section .data

kbd_char:
    db 0
kbd_caps:
    db 0
kbd_ctrl:
    db 0
kbd_shift:
    db 0
kbd_buffer:
    times 64 db 0
; kbd_current_idx - current position of kdb_get_string in the buffer
kbd_current_idx:
    dd 0