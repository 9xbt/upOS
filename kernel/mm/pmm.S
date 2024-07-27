section .text

%include "rtc.inc"
%include "serial.inc"
%include "multiboot.inc"

%define PMM_START_ADDR 0x100000
%define PMM_END_ADDR 0x200000
%define PMM_BITMAP_BYTES 32

[global pmm_install]
[global pmm_check_if_page_in_use]

; pmm_install - sets up the Physical Memory Manager (PMM)
pmm_install:
    mov esi, [mboot_header]
    mov eax, [esi + multiboot_header.flags]

    shr eax, 6
    and eax, 0x1
    test eax, eax
    jz pmm_install.no_memory_map

    xor ecx, ecx
pmm_install.loop:
    ; mbd->mmap_length
    cmp ecx, [esi + multiboot_header.mmap_length]
    jge pmm_install.done

    pushad

    serial_print "Start Addr: "

    ; (mbd->mmap-addr + i)->addr
    mov eax, [esi + multiboot_header.mmap_addr + ecx + multiboot_mmap.addr_low]

    mov edi, pmm_num_buf
    call hex_to_str
    mov esi, pmm_num_buf
    call serial_puts

    popad
    pushad

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    serial_print " | Length: "

    ; (mbd->mmap-addr + i)->len
    mov eax, [esi + multiboot_header.mmap_addr + ecx + multiboot_mmap.len_low]

    mov edi, pmm_num_buf
    call hex_to_str
    mov esi, pmm_num_buf
    call serial_puts

    popad
    pushad

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    serial_print " | Size: "

    ; (mbd->mmap-addr + i)->size
    mov eax, [esi + multiboot_header.mmap_addr + ecx + multiboot_mmap.size]

    mov edi, pmm_num_buf
    call hex_to_str
    mov esi, pmm_num_buf
    call serial_puts

    popad
    pushad

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    serial_print " | Type: "

    ; (mbd->mmap-addr + i)->type
    mov eax, [esi + multiboot_header.mmap_addr + ecx + multiboot_mmap.type]

    mov edi, pmm_num_buf
    call hex_to_str
    mov esi, pmm_num_buf
    call serial_puts
    serial_print 0x0A

    popad
    
    add ecx, 24
    jmp pmm_install.loop
pmm_install.done:
    serial_println "pmm_install: initialized PMM"
    ret
pmm_install.no_memory_map:
    serial_println "pmm_install: got invalid memory map"
    jmp $

section .bss

pmm_num_buf:
    resb 32