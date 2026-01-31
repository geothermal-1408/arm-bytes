	.global _main
	.align 2
	.extern _printf

	.text:
_main:
	sub sp, sp, #48
	stp x29, x30, [sp, #32]
	mov x29, sp
	stp x19, x20, [sp, #16]
	
	mov x19, 5 // given N -> 0 1 1 2 3
	mov x20, 0 // a
	mov x21, 1 // b
	
driver_loop:
	cbz x19, loop_end

	str x20, [sp]
	adrp x0, msg@PAGE
	add x0, x0, msg@PAGEOFF
	bl _printf

	add x22, x20, x21
	mov x20, x21
	mov x21,x22

	sub x19, x19, 1
	b driver_loop

loop_end:
	ldp x19, x20, [sp, #16]
	ldp x29, x30, [sp, #32]
	add sp, sp, #48
	mov x0, 0
	ret
	.data

msg:
	.asciz "%ld\n"
