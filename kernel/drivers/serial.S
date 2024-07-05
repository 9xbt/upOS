[global serial_puts]

section .text

serial_puts:
    lodsb
    or al, al
    jz .done
        
    out 0xe9, al

    jmp serial_puts

    .done: ret