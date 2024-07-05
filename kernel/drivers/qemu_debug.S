[global qemu_putchar]
[global qemu_puts]

section .text

qemu_putchar:
    out 0xE9, al
    ret

qemu_puts:
    mov al, [edx]
    or al, al
    jz .done
        
    out 0xe9, al

    inc edx
    jmp qemu_puts

    .done: ret

;    ^ the screams of the damned
; WAIT I CAN USE GDB
; OH YEAH