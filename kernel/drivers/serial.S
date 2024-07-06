[global serial_puts]
[extern boot_header.flags]

section .text

; serial_puts - Prints a string to the QEMU debugcon (0xE9)
; arguments:
;   esi: a pointer to the string
serial_puts:
    cmp dword [boot_header.flags], 0x00000001
    jne .no

    pusha
serial_puts.loop:
    lodsb
    or al, al
    jz serial_puts.done
        
    out 0xe9, al

    jmp serial_puts.loop
serial_puts.done:
    popa
    ret
serial_puts.no:
    ret