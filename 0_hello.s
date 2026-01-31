	.global _main
	.align 2
	.extern _printf
.text
_main:
	stp x29, x30, [sp, #-16]!
	mov x29, sp
	adrp x0, msg@PAGE
	add  x0, x0, msg@PAGEOFF
	bl _printf
	mov x0, 69
	ldp x29, x30, [sp], #16
	ret

.data
msg:
	.asciz "hello from arm\n"
