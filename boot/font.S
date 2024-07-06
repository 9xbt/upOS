global load_font
; load_font - loads font.
load_font:
    mov ax, 1130h    ; BIOS function to load 8x16 font
    mov bx, 0000h    ; Font number (0)
    mov cx, 256      ; Number of characters to load
    int 10h          ; Call BIOS video interrupt

    ret