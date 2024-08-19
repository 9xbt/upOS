[BITS 16]

[global print_string]

; print_string - prints string using BIOS interrupts.
; arguments:
;   si - pointer to the string
print_string:
    lodsb
    or al, al
    jz .done
        
    mov ah, 0x0E
    int 0x10

    jmp print_string

    .done: ret