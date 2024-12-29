; bitmap_set - sets a bit in a bitmap
; arguments;
;   edi - bitmap
;   esi - bit to set
bitmap_set:
    ; calculate bit index
    mov eax, esi
    shr eax, 3
    mov ebx, edi
    movzx edx, byte [ebx + eax]

    ; calculate bit mask
    mov eax, esi
    and eax, 7
    mov cl, al
    mov al, 1
    shl al, cl

    or dl, al ; set the bit

    mov [ebx + eax], dl ; store updated byte
    ret

; bitmap_set - sets a bit in a bitmap
; arguments;
;   edi - bitmap
;   esi - bit to set
bitmap_clear:
    ; calculate bit index
    mov eax, esi
    shr eax, 3
    mov ebx, edi
    movzx edx, byte [ebx + eax]

    ; calculate bit mask
    mov eax, esi
    and eax, 7
    mov cl, al
    mov al, 1
    shl al, cl
    not al

    and dl, al ; clear the bit

    mov [ebx + eax], dl ; store updated byte
    ret

; bitmap_set - sets a bit in a bitmap
; arguments;
;   edi - bitmap
;   esi - bit to set
bitmap_get:
    ; calculate bit index
    mov eax, esi
    shr eax, 3
    mov ebx, edi
    movzx edx, byte [ebx + eax]

    ; calculate bit mask
    mov eax, esi
    and eax, 7
    mov cl, al
    mov al, 1
    shl al, cl

    ; check if bit is set
    test dl, al
    jz .false

    mov eax, 1 ; bit is set
    ret
bitmap_get.false:
    xor eax, eax ; bit is not set
    ret