%include "vga.inc"
%include "kbd.inc"
%include "rtc.inc"

[global shell_entry]

section .text

; ctsjtrie - Compare Two Strings and Jump to Routine If Equal
%macro ctsjtrie 3
mov esi, %1
mov edi, %2
call cmp_string
jc %3
%endmacro

shell_entry:
shell_loop:
    call rtc_get_second
    mov edi, time_buffer
    call int_to_str
    mov esi, edi
    call vga_puts

    mov byte [vga_color], 0x0C
    vga_print "# "
    mov byte [vga_color], 0x07
    call kbd_get_string

    ;vga_print "Text typed: "
    ;mov esi, kbd_buffer
    ;call vga_puts
    ;vga_print 0x0A
    ctsjtrie kbd_buffer, about_cmd, about_cmd_impl
    ctsjtrie kbd_buffer, credits_cmd, credits_cmd_impl

    jmp shell_loop

about_cmd_impl:
    vga_println "upOS (build ", __DATE__, " ", __TIME__, ")", 0x0A, "upOS is a 32-bit operating system made entirely in assembly.", 0x0A, "Made by winksplorer & xrc2. Licensed under MPL-2.0."
    jmp shell_loop

credits_cmd_impl:
    call vga_clear
    mov byte [vga_color], 0x02
    vga_println "                                -- CREDITS --                                 ",0
    mov byte [vga_color], 0x0E
    vga_println "                   ___  ", 0xA, "               |__ \ ", 0xA, "__  ___ __ ___   ) | Role: upOS Owner", 0xA, "\ \/ / '__/ __| / /  Other projects: Medlar64, GoOS, WebWatcher, tinyboot", 0xA, " >  <| | | (__ / /_  About: Just an average coder that codes stuff.", 0xA, "/_/\_\_|  \___|____| Links: www.mobren.net",0xA,0xA,0
    mov byte [vga_color], 0x09
    vga_println "          _       _    ", 0xA, "__      _(_)_ __ | | __ Role: upOS Collaborator", 0xA, "\ \ /\ / / | '_ \| |/ / Other projects: malino, tefiti, moss, xfspy, ziOS",0xA, " \ V  V /| | | | |   <  About: Not a rust programmer. ",0xA,"  \_/\_/ |_|_| |_|_|\_\ Links: www.winksplorer.net",0xA,0xA,0
    mov byte [vga_color], 0x07
    jmp shell_loop

; cmp_string - compares strings
; arguments:
;   esi = first string to compare
;   edi = second string to compare
; output:
;   carry flag is set if they match
; PS: if you want to also jump to a routine if they're equal, then use ctsjtrie
cmp_string:
    cld
cmp_string.loop:
    lodsb
    scasb
    jne cmp_string.notequal

    test al, al
    jne cmp_string.loop
cmp_string.done:
    stc
    ret
cmp_string.notequal:
    clc
    ret

section .rodata

about_cmd: db "about", 0
credits_cmd: db "credits", 0

section .data

time_buffer: db 3