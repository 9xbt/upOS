%ifndef __MULTIBOOT_INC
%define __MULTIBOOT_INC

[extern mboot_magic]
[extern mboot_header]

struc multiboot_header
    .flags: resd 1
    .mem_lower: resd 1
    .mem_upper: resd 1
    .boot_device: resd 1
    .cmdline: resd 1
    .mods_count: resd 1
    .mods_addr: resd 1
    .syms: resd 4
    .mmap_length: resd 1
    .mmap_addr: resd 1
    .drives_length: resd 1
    .drives_addr: resd 1
    .config_table: resd 1
    .boot_loader_name: resd 1
    .apm_table: resd 1
endstruc

struc multiboot_mmap
    .size: resd 1
    .addr_low: resd 1
    .addr_high: resd 1
    .len_low: resd 1
    .len_high: resd 1
    .type: resd 1
endstruc

%endif