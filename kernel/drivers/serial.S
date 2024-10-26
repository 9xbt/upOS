[global serial_puts]
[extern boot_header.flags]

section .text

; serial_puts - Prints a string to the QEMU debugcon (0xE9)
; arguments:
;   esi: a pointer to the string
serial_puts:
    lodsb
    or al, al
    jz serial_puts.done
        
    out 0xe9, al

    jmp serial_puts
serial_puts.done:
    ret