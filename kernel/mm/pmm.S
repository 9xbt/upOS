section .text

%include "vga.inc"
%include "printf.inc"
%include "multiboot.inc"

%define PAGE_SIZE 4096

[global pmm_install]
[extern end]

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
pmm_install.scan_loop:
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
    mov [pmm_usable_mem], ebx               ; declare usable memory
    mov dword [pmm_bitmap], end             ; set bitmap address
    shr ebx, 12                             ; divide by 0x1000
    mov [pmm_page_count], ebx               ; save page count
    shr ebx, 3                              ; divide by 0x8
    mov [pmm_bitmap_size], ebx              ; save bitmap size

    ; clear the bitmap
    mov edi, [pmm_bitmap]
    mov al, 0xFF
    mov ecx, [pmm_bitmap_size]
    rep stosb

    mov eax, [kernel_mmmt]                  ; load memory map
    mov ebx, [eax + multiboot_mmap.len_low] ; mmmt->len_low
    sub ebx, [pmm_bitmap_size]              ; subtract the bitmap size
    mov [eax + multiboot_mmap.len_low], ebx ; save the value

    mov ebx, [pmm_bitmap]                    ; load bitmap address
    add ebx, [pmm_bitmap_size]               ; add bitmap size
    mov [eax + multiboot_mmap.addr_low], ebx ; save the value

    xor ecx, ecx
    ;jmp pmm_install.bitmap_loop
    jmp pmm_install.done
pmm_install.mmap_used:
    add ecx, multiboot_mmap_size
    jmp pmm_install.scan_loop
pmm_install.bitmap_loop:
    cmp ecx, [mmap_length]
    jge pmm_install.done

    ; (eax) mmmt = mbd->mmap_addr + i
    mov esi, [mboot_header]
    mov eax, [esi + multiboot_header.mmap_addr]
    add eax, ecx
    
    call pmm_install.bitmap_clear

    add ecx, multiboot_mmap_size
    jmp pmm_install.bitmap_loop
pmm_install.bitmap_clear:
    push ecx ; save ecx

    mov eax, [kernel_mmmt]                  ; load memory map
    mov edx, [eax + multiboot_mmap.len_low] ; mmmt->len_low

    xor ecx, ecx
pmm_install.bitmap_clear.loop:
    cmp ecx, edx ; mmmt->len_low
    jge pmm_install.bitmap_clear.done

    mov ebx, [eax + multiboot_mmap.type] ; mmmt->type
    cmp ebx, MULTIBOOT_MEMORY_AVAILABLE
    jne pmm_install.bitmap_clear.mmap_used ; memory region used

    mov ebx, [eax + multiboot_mmap.addr_low] ; mmmt->addr_low
    cmp ebx, 0x100000
    jb pmm_install.mmap_used ; not above 1M barrier

pmm_install.bitmap_clear.mmap_used:
    add ecx, PAGE_SIZE
    jmp pmm_install.bitmap_clear.loop
pmm_install.bitmap_clear.done:
    pop ecx ; restore ecx
    ret
pmm_install.done:
    mov eax, [pmm_usable_mem]
    shr eax, 20
    print `Usable mem: %dMB\n`, eax

    mov eax, [pmm_bitmap_size]
    print `Bitmap size: %d\n`, eax

    ret
pmm_install.bad_mmap:
    vga_println "Invalid multiboot memory map"
    ret

section .bss

pmm_bitmap:
    resd 1
pmm_page_count:
    resd 1
pmm_usable_mem:
    resd 1
pmm_bitmap_size:
    resd 1
mmap_length:
    resb 1
kernel_mmmt:
    resd 1