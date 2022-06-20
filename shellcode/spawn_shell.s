.section __TEXT,__text          ; Specify where the following code should go in our program
; Specify that main is an external symbol
.global _main
; 4 is enough
.align 4

_main:
    adrp x0, bash@PAGE          ; Get the page for `bash` symbol in the x0 register
    add x0, x0, bash@PAGEOFF    ; Add the offset in the page to the register
    mov x1, #0x0                ; NULL for the second argument
    mov x2, #0x0                ; NULL for the 3rd argument
    mov x16, #0x3b              ; execve syscall code
    svc #0x80                   ; supervisor call

.section __DATA,__data:         ; Specify the data section for our string
bash:
    .asciz "/bin/bash"
