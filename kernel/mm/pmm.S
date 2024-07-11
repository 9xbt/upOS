section .text

%include "serial.inc"

%define PMM_START_ADDR 0x100000
%define PMM_END_ADDR 0x200000
%define PMM_BITMAP_BYTES 32

[global pmm_install]
[global pmm_check_if_page_in_use]

; pmm_install - installs the Physical Memory Manager (PMM)
; Carry flag is high if error occurred
pmm_install:
    clc

    ; make sure the bitmap size actually is correct
    mov esi, PMM_START_ADDR
    ; get amount of bits
    mov eax, PMM_BITMAP_BYTES
    mov ebx, 8
    mul ebx
    ; get the byte amount
    mov ebx, 4096
    mul ebx
    ; actually check
    add esi, eax
    cmp esi, PMM_END_ADDR
    jne .what_the_fuck

    serial_println "pmm_install: initialized PMM"
    ret
pmm_install.what_the_fuck:
    serial_println "pmm_install: PMM_BITMAP_BYTES is too large/too small"
    stc
    ret

; pmm_check_if_page_in_use - checks if page is in use
; eax - page number
; Carry flag is high if it is in use OR is out of bounds. Carry flag is low if the page is free.
pmm_check_if_page_in_use:
    clc
    xor edx, edx
    ; div by 8 to get the byte offset
    mov ebx, 8 
    div ebx
    
    ; EAX = the bytes into the bitmap
    ; EDX = the bit offset

    mov esi, bitmap
    add esi, eax
    mov al, [esi]
    ;bt al, dh

    ret

section .bss
bitmap resb PMM_BITMAP_BYTES