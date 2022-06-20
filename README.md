# Arm64 M1 shellcode
This is an effort to write an Arm64 shellcode for MacOS M1 chip and document it along the way

# Syscall list for APPLE's XNU Kernel
https://github.com/apple/darwin-xnu/blob/main/bsd/kern/syscalls.master

# Folder structure
## shelcode
Contains C code for spawning a new shell.
Build with:
```
clang spawn_shell.c -o spawn_shell
```
Run with:
```
./spawn_shell
```

### Debuggin the C process
Run the `spawn_shell` in a debugger. I like using lldb.
```
lldb spawn_shell
```
Get a breakpoint at the `main` function
```
b main
```
Run the process using `r`

### The Manual Assembly
You can find the shellcode written from scratch in the file `spawn_shell.s`.
You can assemble it using `as` command
```
as spawn_shell -o spawn_shell_asm.o
```
And link it using `clang`
```
clang spawn_shell_asm.o -o spawn_shell_asm
```

### Assembling
Glossary:
`_main`: symbol that is considered the entrypoint by default if nothing explicit is specified to
the linker
`normal_label:`: a string with no special characters followed by a colon is considered a label
`.global`: any symbol declared global is an external symbol
`.align`: specifies alignment of the code
`.asciz`: specifies a null terminated character


# Assembly breakdown

```
<+0>:   stp     x29, x30, [sp, #-0x10]!     ; pushing the stack frame, more info below
<+4>:   mov     x29, sp                     ; copy stack pointer into the FP register
<+8>:   adrp    x0, 0                       ; load the lower 4KiB bound of this page
<+12>:  add     x0, x0, #0xfac              ; add 0xfac to x0, this should be the address of our
                                            ; `execve` target
<+16>:  mov     x1, #0x0                    ; make x1, 0, efectively, making the second argument
                                            ; of `execve` NULL
<+20>:  bl      0x100003fa0                 ; put next instruction into LR and branch to address
```
# Arm64 Registers
All registers starting with `x` will have a 32-bit counterpart starting with `w`
x0 -> x7 (inclusive) -> Paramter and result registers
x16(IP0) and x17(IP1) -> Intr-procedure call temporary registers. Use them for syscalls
x29 -> Frame Pointer Register(FP)
x30 -> Procedure Link Register(LR)
x31 -> Stack Register (SP)


# Arm Instructions
All ARMv7 / ARMv8 instructions are 4 bytes long. This in in large contrast to x86 where instruction
widths are variable.

## ADR Xd, #imm
Simple PC-relative address calculation. You give it a destination register and an immediate offset
and it computer the current PC + imm in the destination register.
Example:
```
adr x0, #5
```
Lets say that this instruction is at address 0x1004000.
After the instruction is executed, x0 = 0x1004005

ADR instruction used at most 21 bits jumps, 20 bit + 1 for the sign, which allows for +- 1MiB jumps

## ADRP Xd, #imm
Similar to ADR, but it shifts pages relative to the current pages insted of just bytes
It also zeroes out the 12 lower bits.
Example:
```
0x100003f80 <+12>: adrp x0, 1
```
Lets take the above example, x0 will be 0x100003f80 + 1 and after we zero out the lower 12 bits,
meaning the last 3 bytes, we remain with x0 = 0x100003000.

On MacOS platforms, since the MachO file format does not support relocation types, the combination
of and `adrp` intruction + an `add` instruction is preffered.

## BL label
Branch with Link to label
Will copy the address of the next instruction into the Link Register(LR, X30) and go to `label`

## BR Xn
Branched unconditionally to an address in the register `Xn`

## SVC{cond}, #imm
SuperVisor Call
Formerly SWI(Software interrupt)

# Pushing an popping stack frames
## Pushing the stack frame
`stp x29, x30, [sp, #-0x10]!`
`stp` -> store pair. Pushes x29 and x30 on the stack using a pre-index variant
that modified the address before storing.

`!` means "Register write-back".
The base register is used to calculate the address of the transfer and is updated.
in the example above, sp becomes sp = sp - 0x10

## Popping the stack frame
`ldp x29, x30, [sp], #0x10`
`ldp` Load Pair of Registers. The notation above uses post-index, meaning after the operation
is successful, sp = sp + 0x10

## Resources
### ARM Registers
https://developer.arm.com/documentation/den0024/a/The-ABI-for-ARM-64-bit-Architecture/Register-use-in-the-AArch64-Procedure-Call-Standard/Parameters-in-general-purpose-registers
### ARM pushing and popping the stack info
https://stackoverflow.com/questions/64638627/explain-arm64-instruction-stp
https://stackoverflow.com/questions/39780289/what-does-the-exclamation-mark-mean-in-the-end-of-an-a64-instruction
### Latest ARM reference manual
https://developer.arm.com/documentation/ddi0487/latest
### ADR instruction explained
https://stackoverflow.com/questions/41906688/what-are-the-semantics-of-adrp-and-adrl-instructions-in-arm-assembly
### Using LDR over MOV
https://stackoverflow.com/questions/14046686/why-use-ldr-over-mov-or-vice-versa-in-arm-assembly
### PIE explained
https://stackoverflow.com/questions/2463150/what-is-the-fpie-option-for-position-independent-executables-in-gcc-and-ld/51308031#51308031
### Specifying strings
https://developer.arm.com/documentation/100067/0612/armclang-Integrated-Assembler/String-definition-directives
### Why ADR does not work when assemblying on MacOS
https://stackoverflow.com/questions/65351533/apple-clang12-llvm-unknown-aarch64-fixup-kind
### Linking a Mach-O object file
https://stackoverflow.com/questions/69557383/how-to-link-mach-o-format-object-files-on-linux
### ARM64 alignment
https://patchwork.kernel.org/project/linux-arm-kernel/patch/1504173383-8367-1-git-send-email-yamada.masahiro@socionext.com/
### Nice ARM Guide
https://modexp.wordpress.com/2018/10/30/arm64-assembly/
