[global bcd_to_bin]

; bcd_to_bin - converts a binary-coded decimal value to binary
; arguments:
;   eax - the bcd value
; output:
;   eax - the binary value
bcd_to_bin:
    mov ecx, eax
    and ecx, 15
    shr eax, 4
    imul eax, eax, 10
    add eax, ecx
    ret