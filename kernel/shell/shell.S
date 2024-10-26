section .text

%include "vga.inc"
%include "kbd.inc"
%include "rtc.inc"
%include "ata.inc"
%include "cpuid.inc"

%define RUST_USER_BRAIN_SIZE 0

[global shell_entry]

; ctsjtrie - Compare Two Strings and Jump to Routine If Equal
%macro ctsjtrie 3
mov esi, %1
mov edi, %2
call cmp_string
jc %3
%endmacro

; shell_cmp - only compares first argument
%macro shell_cmp 1
mov esi, kbd_buffer
call command_name.clear
call command_name.get
ctsjtrie command_name, %1, %1.handler
%endmacro

shell_entry:
shell_loop:
    mov byte [vga_color], 0x0C
    vga_print "# "
    mov byte [vga_color], 0x07
    call kbd_get_string

    shell_cmp about_cmd
    shell_cmp credits_cmd
    shell_cmp date_cmd
    shell_cmp clear_cmd
    shell_cmp help_cmd
    shell_cmp echo_cmd
    shell_cmp reboot_cmd
    shell_cmp cpuid_cmd
    shell_cmp atainfo_cmd

    cmp byte [kbd_buffer], RUST_USER_BRAIN_SIZE
    jz shell_loop

    mov byte [vga_color], 0x0C
    mov esi, kbd_buffer
    call vga_puts
    vga_println ": command not found"

    jmp shell_loop

about_cmd.handler:
    vga_println "upOS (build ", __DATE__, " ", __TIME__, ")", 0x0A, "upOS is a 32-bit operating system written entirely in assembly.", 0x0A, "Made by winksplorer & xrc2. Licensed under MPL-2.0."
    jmp shell_loop

credits_cmd.handler:
    mov byte [vga_color], 0x02
    vga_println "                                -- CREDITS --                                 ",0
    mov byte [vga_color], 0x0E
    vga_println "                  ___   ", 0xA, "               |__ \ ", 0xA, "__  ___ __ ___   ) | Role: upOS Owner", 0xA, "\ \/ / '__/ __| / /  Other projects: Medlar64, WebWatcher, 9xVM, SVGAIITerminal", 0xA, " >  <| | | (__ / /_  About: Just an average coder that codes stuff.", 0xA, "/_/\_\_|  \___|____| Links: www.mobren.net",0xA,0xA,0
    mov byte [vga_color], 0x09
    vga_println "          _       _    ", 0xA, "__      _(_)_ __ | | __ Role: upOS Collaborator", 0xA, "\ \ /\ / / | '_ \| |/ / Other projects: malino, tefiti, moss, xfspy, ziOS",0xA, " \ V  V /| | | | |   <  About: Not a rust programmer. ",0xA,"  \_/\_/ |_|_| |_|_|\_\ Links: www.winksplorer.net",0xA,0xA,0
    mov byte [vga_color], 0x07
    jmp shell_loop

date_cmd.handler:
    call rtc_print_date
    jmp shell_loop

clear_cmd.handler:
    call vga_clear
    jmp shell_loop

help_cmd.handler:
    vga_println "Available commands:", 0x0A, "about - Shows info about upOS", 0x0A, "credits - ASCII names of the people who created upOS", 0x0A, "date - Shows the date & time", 0x0A, "clear - Clears the screen.", 0x0A, "echo - Echos back the arguments (akin to the voices in your head)", 0x0A, "help - Shows this screen.", 0x0A, "cpuid - Displays CPU info", 0x0A, "atainfo - Displays hard drive info (ATA)"
    jmp shell_loop

echo_cmd.handler:
    mov esi, kbd_buffer+5
    call vga_puts
    vga_print 0x0A
    jmp shell_loop

reboot_cmd.handler:
    ; What are the Mario Bros views on rebooting?
    ;
    ; Mario says: You should properly ask the power management unit to restart the CPU
    ; Luigi says: To turn it off, just triple fault
    lidt [0]
    int 0

cpuid_cmd.handler:
    call cpu_get_vendor
    cmp byte [esi], 'G'
    je cpuid_cmd.handler.is_intel
cpuid_cmd.handler.is_amd:
    vga_print `              *@@@@@@@@@@@@@@@      `
    call cpu_get_vendor
    call vga_puts
    vga_print `\n                 @@@@@@@@@@@@@      `
    call cpu_get_model
    call vga_puts
    vga_println `\n               @%       @@@@@    \n              @@@%       @@@@@    \n             @@@@&       @@@@@    \n             @@@@@@@@@     @@@    \n             #######              \n\n            @@     @\\ /@  @@@@*   \n           @..@    @ @ @  @.   @  \n          @    @   @   @  @@@@*   `
    
    jmp shell_loop
cpuid_cmd.handler.is_intel:
    vga_print `88                              88  `
    call cpu_get_vendor
    call vga_puts
    vga_print `\n\"\"              ,d              88  `
    call cpu_get_model
    call vga_puts
    vga_println `\n                88              88\n88 8b,dPPYba, MM88MMM ,adPPYba, 88\n88 88P'   \`\"8a  88   a8P_____88 88\n88 88       88  88   8PP\"\"\"\"\"\"\" 88\n88 88       88  88,  \"8b,   ,aa 88\n88 88       88  \"Y888 \`\"Ybbd8\"' 88`

    jmp shell_loop

atainfo_cmd.handler:
    vga_print "Drive label: "
    mov esi, ata_drive_label
    call vga_puts

    vga_print 0x0A, "Drive S/N: "
    mov esi, ata_drive_sn
    call vga_puts

    vga_print 0x0A, "Drive size: "
    mov eax, [ata_disk_size]
    shr eax, 1
    mov edi, atainfo_cmd.drive_size
    xor ecx, ecx
    call int_to_str

    mov esi, atainfo_cmd.drive_size
    xor ecx, ecx
atainfo_cmd.handler.loop:
    lodsb
    or al, al
    jz atainfo_cmd.handler.done

    inc ecx
    jmp atainfo_cmd.handler.loop
atainfo_cmd.handler.done:
    mov esi, atainfo_cmd.drive_size
    sub ecx, 3
    push ecx
    call vga_putnchars

    vga_print ","

    mov esi, atainfo_cmd.drive_size
    pop ecx
    add esi, ecx
    mov ecx, 3
    call vga_putnchars

    vga_println " KB"

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

; get_command_name - gets the first argument of a command, i.e. the name of the command.
; arguments:
;   esi = the string to get the first command name of
; output:
;   command_name is set
command_name.get:
    mov edi, command_name
command_name.get.loop:
    lodsb
    cmp al, ' '
    je  command_name.get.end
    test al, al
    jz  command_name.get.end
    stosb
    jmp command_name.get.loop
command_name.get.end:
    mov byte [edi], 0
    ret
command_name.clear:
    mov edi, command_name
    mov ecx, 10
    xor eax, eax
    rep stosb
    ret

section .rodata

about_cmd:
    db "about", 0x00
credits_cmd:
    db "credits", 0x00
date_cmd:
    db "date", 0x00
clear_cmd:
    db "clear", 0x00
help_cmd:
    db "help", 0x00
echo_cmd:
    db "echo", 0x00
reboot_cmd:
    db "reboot", 0x00
cpuid_cmd:
    db "cpuid", 0x00
atainfo_cmd:
    db "atainfo", 0x00

section .bss

time_buffer:
    resb 3

command_name:
    resb 10

atainfo_cmd.drive_size:
    resb 10