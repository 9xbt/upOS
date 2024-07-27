# upOS

<a><img src="https://img.shields.io/github/languages/code-size/Winksplorer/upOS?style=for-the-badge&logo=files"/></a>
<a href="https://github.com/Winksplorer/upOS/blob/master/LICENSE"><img src="https://img.shields.io/github/license/Winksplorer/upOS?style=for-the-badge&logo=mozilla"/></a>
<img src="https://img.shields.io/badge/pain_and_suffering-in_assembly-blue?style=for-the-badge&logo=intel">
<img src="https://img.shields.io/badge/please_just_let_me-write_some_c-blue?style=for-the-badge&logo=c">

> "Either the Up Operating System, or Unmanaged Process Operating System. Your choice."

upOS is a 32-bit DOS written completely in assembly.

## Features
- Fully custom bootloader (with a TUI & options)
- Both bootloader and kernel completely written in assembly
- 32-bit (x86)
- Fits entirely on a 1.44MB floppy disk

## Roadmap
- [X] GDT
- [X] IDT
- [X] PIC
- [X] Serial driver (QEMU debugcon only for now)
- [X] VGA driver
- [X] RTC driver
- [X] Keyboard driver
- [X] Basic shell
- [ ] PMM
- [ ] Heap
- [ ] ATA driver
- [ ] FAT32 filesystem
- [ ] ELF execution
