# upOS

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
- [ ] RTC driver
- [X] Keyboard driver
- [ ] Basic shell
- [ ] FAT32 filesystem
- [ ] ELF execution