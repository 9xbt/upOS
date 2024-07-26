section .text

%include "vga.inc"

%define RTC_CMD 0x70
%define RTC_DAT 0x71

[global bcd_to_bin]
[global int_to_str]
[global rtc_get_century]
[global rtc_get_year]
[global rtc_get_month]
[global rtc_get_day]
[global rtc_get_hour]
[global rtc_get_minute]
[global rtc_get_second]
[global rtc_print_date]

%macro rtc_print 1
call %1
mov edi, time_buffer
mov ecx, 2
call int_to_str
mov esi, edi
call vga_puts
%endmacro

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
;   ecx = max string length
;   edi = pointer to the buffer where the string will be stored
; output:
;   edi = the converted string
int_to_str:
    push ecx

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

    pop edx
.more_digits:
    ; ensure at least two digits
    mov eax, edi
    sub eax, ebx            ; calculate the length of the string (excluding null terminator)
    cmp eax, edx            ; compare the length with 2 (at least two digits including null terminator)
    jae .at_least_two

    ; if the length is less than 2, add leading zero
    mov byte [edi], '0'
    inc edi

    jmp .more_digits

.at_least_two:
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

; rtc_get_century - gets the current century
; output:
;   eax = the current century
rtc_get_century:
    mov eax, 0x32
    out RTC_CMD, al

    in al, RTC_DAT
    call bcd_to_bin
    ret

; rtc_get_year - gets the current year
; output:
;   eax = the current year
rtc_get_year:
    mov eax, 0x09
    out RTC_CMD, al

    in al, RTC_DAT
    call bcd_to_bin
    ret

; rtc_get_month - gets the current month
; output:
;   eax = the current month
rtc_get_month:
    mov eax, 0x08
    out RTC_CMD, al

    in al, RTC_DAT
    call bcd_to_bin
    ret

; rtc_get_day - gets the current day of the month
; output:
;   eax = the current day of the month
rtc_get_day:
    mov eax, 0x07
    out RTC_CMD, al

    in al, RTC_DAT
    call bcd_to_bin
    ret

; rtc_get_hour - gets the current hour
; output:
;   eax = the current hour
rtc_get_hour:
    mov eax, 0x04
    out RTC_CMD, al

    in al, RTC_DAT
    call bcd_to_bin
    ret

; rtc_get_minute - gets the current minute
; output:
;   eax = the current minute
rtc_get_minute:
    mov eax, 0x02
    out RTC_CMD, al

    in al, RTC_DAT
    call bcd_to_bin
    ret

; rtc_get_second - gets the current second
; output:
;   eax = the current second
rtc_get_second:
    xor eax, eax
    out RTC_CMD, al

    in al, RTC_DAT
    call bcd_to_bin
    ret

; rtc_print_date - prints the date and time
; output:
;   the date and time printed on the terminal
rtc_print_date:
    rtc_print rtc_get_century
    rtc_print rtc_get_year
    vga_print "-"
    rtc_print rtc_get_month
    vga_print "-"
    rtc_print rtc_get_day
    vga_print " "
    rtc_print rtc_get_hour
    vga_print ":"
    rtc_print rtc_get_minute
    vga_print ":"
    rtc_print rtc_get_second
    vga_print 0xA
    ret

section .bss

time_buffer:
    resb 3