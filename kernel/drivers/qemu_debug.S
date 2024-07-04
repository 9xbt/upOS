[global qemu_putchar]
[global qemu_puts]

section .text

qemu_putchar:
    out 0xE9, al
    ret

qemu_puts:
    ;mov al, [esi] ; hmmm
    lodsb
    or al, al
    jz .done
        
    out 0xe9, al

    jmp qemu_puts

    .done: ret