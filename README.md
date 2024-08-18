# upOS

<a><img src="https://img.shields.io/github/languages/code-size/Winksplorer/upOS?style=for-the-badge&logo=files"/></a>
<a href="https://github.com/Winksplorer/upOS/blob/master/LICENSE"><img src="https://img.shields.io/github/license/Winksplorer/upOS?style=for-the-badge&logo=mozilla"/></a>
<img src="https://img.shields.io/badge/pain_and_suffering-in_assembly-blue?style=for-the-badge&logo=intel">
<img src="https://img.shields.io/badge/please_just_let_me-write_some_c-blue?style=for-the-badge&logo=c">

> "Either the Up Operating System, or Unmanaged Process Operating System. Your choice."

upOS is a 32-bit DOS written completely in assembly.

## Rewrite plan

### Bootloader

This is going to be a multiboot compatible bootloader.

#### Stage 1

1. Set up segmentation
2. Get into unreal mode
3. Load the next phase using int 13h at address 10000h
4. Jump to the next stage

#### Stage 2

1. Display a TUI with boot options
2. Load kernel with int 13h (in unreal mode)
3. Get into protected mode
4. Set `eax` and `ebx` to multiboot stuff
5. Jump to kernel