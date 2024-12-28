section .text

%include "vga.inc"
%include "printf.inc"
%include "multiboot.inc"

[global pmm_install]

; pmm_install - initializes the physical memory manager
pmm_install:
    ; check bit 6 to see if we have a valid memory map
    mov esi, [mboot_header]
    mov eax, [esi + multiboot_header.flags]
    shr eax, 6
    and eax, 0x1
    test eax, eax
    jz pmm_install.bad_mmap

    ; store memory map header length
    mov eax, [esi + multiboot_header.mmap_length]
    mov [mmap_length], eax

    xor ecx, ecx
pmm_install.loop:
    cmp ecx, [mmap_length]
    jge pmm_install.done

    ; (eax) mmmt = mbd->mmap_addr + i
    mov esi, [mboot_header]
    mov eax, [esi + multiboot_header.mmap_addr]
    add eax, ecx
    
    mov ebx, [eax + multiboot_mmap.type] ; mmmt->type
    cmp ebx, MULTIBOOT_MEMORY_AVAILABLE
    jne pmm_install.mmap_used ; memory region used

    ; memory map available!
    mov ebx, [eax + multiboot_mmap.addr_low] ; mmmt->addr_low
    cmp ebx, 0x100000
    jb pmm_install.mmap_used ; not above 1M barrier

    mov [kernel_mmmt], eax                  ; save memory map
    mov ebx, [eax + multiboot_mmap.len_low] ; mmmt->len_low
    mov [pmm_usable_mem], ebx               ; set usable memory

    jmp pmm_install.done
pmm_install.mmap_used:
    add ecx, multiboot_mmap_size
    jmp pmm_install.loop
pmm_install.done:
    mov eax, [pmm_usable_mem]
    shr eax, 20
    print `Usable mem: %dMB\n`, eax

    ret
pmm_install.bad_mmap:
    vga_println "Invalid multiboot memory map"
    ret

section .bss

pmm_usable_mem:
    resd 1
mmap_length:
    resb 1
kernel_mmmt:
    resd 1