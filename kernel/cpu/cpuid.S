section .text

[global cpu_get_vendor]
[global cpu_get_model]

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
    mov [esi + 12], byte 0

    ret

; cpu_get_model - gets the CPU model string
; outputs:
;   esi - model string pointer
cpu_get_model:
    mov eax, 0x80000002
    cpuid
    mov [cpu_brand_str], eax
    mov [cpu_brand_str + 4], ebx
    mov [cpu_brand_str + 8], ecx
    mov [cpu_brand_str + 12], edx

    mov eax, 0x80000003
    cpuid
    mov [cpu_brand_str + 16], eax
    mov [cpu_brand_str + 20], ebx
    mov [cpu_brand_str + 24], ecx
    mov [cpu_brand_str + 28], edx

    mov eax, 0x80000004
    cpuid
    mov [cpu_brand_str + 32], eax
    mov [cpu_brand_str + 36], ebx
    mov [cpu_brand_str + 40], ecx
    mov [cpu_brand_str + 44], edx

    mov byte [cpu_brand_str + 48], 0

    mov esi, cpu_brand_str
    ret

section .bss

cpu_vendor_str:
    resb 13
cpu_brand_str:
    resb 49