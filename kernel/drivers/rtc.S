%define RTC_CMD 0x70
%define RTC_DAT 0x71

[global bcd_to_bin]
[global int_to_str]
[global rtc_get_second]

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

; int_to_str - converts an integer to a string
; arguments:
;   eax = the integer to be converted
;   edi = pointer to the buffer where the string will be stored
; output:
;   edi = the converted string
int_to_str:
    mov ecx, 10             ; base 10 divisor

    ; check if the number is negative
    test eax, eax
    jge .positive
    mov byte [edi], '-'     ; add negative sign
    inc edi
    neg eax                 ; make eax positive

.positive:
    mov ebx, edi            ; store the start of the buffer in ebx

    ; convert the integer to string in reverse order
    .convert_loop:
        xor edx, edx        ; clear edx
        div ecx             ; divide eax by 10, quotient in eax, remainder in edx
        add dl, '0'         ; convert remainder to ASCII
        mov [edi], dl       ; store the character
        inc edi             ; move to next position
        test eax, eax       ; check if quotient is 0
        jnz .convert_loop

    ; null-terminate the string
    mov byte [edi], 0

    ; reverse the string
    mov esi, ebx            ; esi points to the start of the buffer
    dec edi                 ; edi points to the last character
    .reverse_loop:
        cmp esi, edi
        jge .done
        mov al, [esi]
        mov bl, [edi]
        mov [esi], bl
        mov [edi], al
        inc esi
        dec edi
        jmp .reverse_loop

    .done: ret

; rtc_get_second - gets the current second
; output:
;   eax = the current second
rtc_get_second:
    xor eax, eax
    mov al, 0
    out RTC_CMD, al

    in al, RTC_DAT
    call bcd_to_bin
    ret