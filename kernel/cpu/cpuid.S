section .text

[global cpu_get_vendor]

; cpu_get_vendor - gets the CPU vendor string
; outputs:
;   esi - vendor string pointer
cpu_get_vendor:
    mov eax, 0x0
    cpuid

    mov esi, cpu_vendor_str
    mov [esi], ebx
    mov [esi + 4], edx
    mov [esi + 8], ecx

    ret

section .bss

cpu_vendor_str:
    resb 13