	/***********************/
       /* factorial recursive */
      /***********************/

	.global _main
	.align 2
	
	.text
_main:	
	sub sp, sp, #48

	stp x29, x30, [sp, #32]
	mov x29, sp

	stp x19, x20, [sp, #16]

	cmp x0, #2
	blt no_args

	ldr x0, [x1, #8]
	bl _atoi
	mov x19, x0
	
	mov x0, x19
	bl factorial
	mov x20, x0

	str x19, [sp]
	str x20, [sp, #8]
	
	adrp x0, res_msg@PAGE
	add x0, x0, res_msg@PAGEOFF
	bl _printf
	b cleanup

no_args:
	adrp x0, err_msg@PAGE
	add x0, x0, err_msg@PAGEOFF
	bl _printf
	mov x0, #1
	bl _exit
	
cleanup:
	mov x0, 0
	ldp x19, x20, [sp, #16]
	ldp x29, x30, [sp, #32]
	add sp, sp, #48
	ret
	
factorial:
	cmp x0, #1
	b.le invaild_no

	stp x29, x30, [sp, #-16]!
	str x0, [sp, #-16]!

	sub x0, x0, 1
	bl factorial

	ldr x1, [sp], #16
	mul x0, x0, x1

	ldp x29, x30, [sp], #16
	ret
	
invaild_no:
	mov x0, #1
	ret

	.data
res_msg:
	.asciz "%ld! = %ld\n"
err_msg:
	.asciz "usage: ./bin/2_2_recursive <number>\n"
