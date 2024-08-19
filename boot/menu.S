[BITS 16]

%include "video.inc"
%include "loader.inc"

%define ENTRY_COUNT  2
%define ENTRY_LENGTH 41

[global menu_entry]

menu_entry:
    ; clear the screen
    mov ax, 3
    int 0x10

    ; disable the text mode cursor
    mov dx, 0x3D4
    mov al, 0x0A
    out dx, al
    mov dx, 0x3D5
    mov al, 0x20
    out dx, al

    mov si, title_msg
    call print_string

    call show_list

    mov si, controls_msg
    call print_string
menu_entry.loop:
    ; get a keystroke
    mov ah, 0x00
    int 0x16

    cmp ah, 0x1C ; return
    je menu_entry.return
    cmp ah, 0x48 ; up arrow
    je menu_entry.up_arrow
    cmp ah, 0x50 ; down arrow
    je menu_entry.down_arrow
    
    jmp menu_entry.loop
menu_entry.render:
    ; set cursor position
    mov dx, 0x0400
    mov ax, 0x0200
    int 0x10

    call show_list

    jmp menu_entry.loop
menu_entry.return:
    mov al, [list.selected_entry]
    jmp load_os
menu_entry.up_arrow:
    cmp byte [list.selected_entry], 0
    jz menu_entry.reset_up

    dec byte [list.selected_entry]
    jmp menu_entry.render
menu_entry.down_arrow:
    cmp byte [list.selected_entry], ENTRY_COUNT - 1
    jz menu_entry.reset_down

    inc byte [list.selected_entry]
    jmp menu_entry.render
menu_entry.reset_up:
    mov byte [list.selected_entry], ENTRY_COUNT - 1
    jmp menu_entry.render
menu_entry.reset_down:
    mov byte [list.selected_entry], 0
    jmp menu_entry.render

show_list:
    xor cl, cl
show_list.loop:
    cmp cl, ENTRY_COUNT
    je show_list.done
    
    ; multiply by 2 since we're working with 16-bit addresses
    movzx bx, cl
    shl bx, 1

    push bx
    push cx

    mov bl, 0x07

    cmp [list.selected_entry], cl
    jne show_list.non_selected
show_list.selected:
    mov bl, 0x70
show_list.non_selected:
    mov cx, ENTRY_LENGTH
    mov ah, 0x09
    int 0x10

    pop cx
    pop bx

    mov si, [list + bx]
    call print_string

    inc cl
    jmp show_list.loop
show_list.done:
    ret

title_msg:
    db "upOS bootloader v0.4", 0x0D, 0x0A, 0x0A
    db "Please select the operating system to start:", 0x0D, 0x0A, 0x0A, 0x00

controls_msg:
    db 0x0A, "Use ", 0x18, " and ", 0x19, " to move the highlight to your choice.", 0x0D, 0x0A
    db "Press enter to choose.", 0x00

list:
    dw list.upOS.default
    dw list.upOS.debug
list.upOS.default:
    db "    upOS Version 0.4", 0x0D, 0x0A, 0x00
list.upOS.debug:
    db "    upOS Version 0.4 [QEMU debugging]", 0x0D, 0x0A, 0x00
list.selected_entry:
    db 0