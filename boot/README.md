# upOS bootloader 0.2
This folder contains the source code to upOS' bootloader.

This is a simple 16-bit (real mode) bootloader written entirely in assembly. It supports booting 32-bit protected mode kernels with a simple boot protocol. The bootloader provides a menu to select which OS to boot (right now it's hard coded, so you either boot upOS or boot upOS with QEMU debugging enabled).

The bootloader uses its own simple boot protocol. Here's how the boot header looks like:

| Name    | Size    | Offset | Description                                     |
|---------|---------|--------|-------------------------------------------------|
| Magic   | 4 bytes | 0x0    | Boot header magic. Should always be 0x1BADB002. |
| Version | 4 bytes | 0x4    | Boot header version. Should be 0.2.             |
| Flags   | 4 bytes | 0x8    | Boot flags.                                     |

> [!IMPORTANT]
> The boot header *will* be expanded in the future, but we'll try to not break compatibility with older versions
