section .text

%include "vga.inc"
%include "printf.inc"
%include "multiboot.inc"

[global pmm_install]

; pmm_install - initializes the physical memory manager
pmm_install:
    mov esi, [mboot_header]
    mov eax, [esi + multiboot_header.flags]
    shr eax, 6
    and eax, 0x1
    test eax, eax
    jz pmm_install.bad_mmap

    mov eax, [esi + multiboot_header.mmap_length]
    mov [mmap_length], eax

    xor ecx, ecx
pmm_install.loop:
    cmp ecx, [mmap_length]
    jge pmm_install.done

    push ecx
    print `%x\n`, ecx
    pop ecx

    ;inc ecx
    add ecx, multiboot_mmap_size
    jmp pmm_install.loop
pmm_install.done:
    ret
pmm_install.bad_mmap:
    vga_println "Invalid multiboot memory map"
    ret

section .bss

mmap_length:
    resb 1