[global serial_puts]

section .text

; serial_puts - Prints a string to the QEMU debug console
; arguments:
;   esi: a pointer to the string
serial_puts:
    lodsb
    or al, al
    jz .done
        
    out 0xe9, al

    jmp serial_puts
serial_puts.done:
    ret