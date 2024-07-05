[BITS 32]
[extern gdtr]
[extern vga_clear]
[extern vga_puts]
[extern qemu_puts]
[extern qemu_putchar]

section .text.prologue

global _start
_start:
    jmp kmain

section .text

kmain:
    mov esp, stack_top

    call vga_clear

    mov edx, hello_world
    call qemu_puts
    
    ; wtf is that address
    ; 0x07ecb590
    ; hmm
    ; let me try something
    
    jmp $

section .rodata
hello_world: db "Hello, world!", 0

; yo whats up
; the sky
; lmao

; so printing works now?
; not exactly

;hmmm

section .bss

align 16
stack_bottom:
resb 4096
stack_top: