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

# Pushing an popping stack frames
## Pushing the stack frame
`stp x29, x30, [sp, #-0x10]!`
`stp` -> store pair. Pushes x29 and x30 on the stack using a pre-index variant
that modified the address before storing.
x29 -> Frame Pointer Register(FP)
x30 -> Procedure Link Register(LR)

`!` means "Register write-back".
The base register is used to calculate the address of the transfer and is updated.
in the example above, sp becomes sp = sp - 0x10

## Popping the stack frame
`ldp x29, x30, [sp], #0x10`
`ldp` Load Pair of Registers. The notation above uses post-index, meaning after the operation
is successful, sp = sp + 0x10

## Resources
https://stackoverflow.com/questions/64638627/explain-arm64-instruction-stp
https://stackoverflow.com/questions/39780289/what-does-the-exclamation-mark-mean-in-the-end-of-an-a64-instruction
https://developer.arm.com/documentation/ddi0487/latest
