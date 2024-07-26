struc multiboot_header
    .magic: resd 1
    .flags: resd 1
    .checksum:  resd 1
    .mem_lower: resd 1
    .mem_upper: resd 1
    .boot_device: resd 1
    .cmdline: resd 1
    .mods_count: resd 1
    .mods_addr: resd 1
    .syms: resd 1
    .elf_sec: resd 1
    .mmu: resd 1
    .drives: resd 1
    .config_table: resd 1
    .boot_loader_name: resd 1
    .apm_table: resd 1
endstruc