[BITS 32]

section .text

%include "vga.inc"
%include "idt.inc"
%include "pic.inc"
%include "kbd.inc"
%include "rtc.inc"
%include "ata.inc"
%include "shell.inc"
%include "serial.inc"
%include "pmm.inc"

section .text.prologue

global _start
_start:
    jmp kmain

section .text

kmain:
    mov esp, stack_top

    mov esi, eax
    mov edi, boot_header
    mov ecx, boot_header.length

    push ebp
    mov ebp, esp

    cld
    rep movsb

    pop ebp

    cmp dword [boot_header.magic], 0x1BADB002
    je .goodmagic
kmain.badmagic:
    vga_print "Invalid boot header!", 0x0A, "Cannot continue"
    jmp $
kmain.goodmagic:
    call vga_clear
    call vga_enable_cursor

    vga_println "Welcome to upOS (build ", __DATE__, " ", __TIME__, ")!", 0x0A

    cmp dword [boot_header.flags], 0x00000001
    jne kmain.nodebug
kmain.qemudebug:
    serial_println "Kernel booted with debugging enabled"
kmain.nodebug:
    call idt_install
    call pic_install
    call ata_install
    call kbd_install
    call pmm_install
kmain.loop:
    jmp shell_entry

section .data

global boot_header.flags
boot_header:
    .magic:
        dd 0x00000000
    .version:
        db "        "
    .flags:
        dd 0x00000000
    .length: equ $ - boot_header

section .bss

align 16
stack_bottom:
resb 4096
stack_top: