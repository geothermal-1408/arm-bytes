
	/********************/
       /* 2_sum_of_natural */
      /********************/

	
	.global _main
	.align 2
	.extern _printf, _atoi

	.text   
_main:
	stp x29, x30, [sp, -48]!  
	mov x29, sp
	stp x19, x20, [sp, 16]
	stp x21, x22, [sp, 32]

	cmp x0, 2
	b.lt no_args
	
	ldr x0, [x1, 8]
	bl _atoi
	sxtw x19, w0 //given N 
	
	mov x20, 0 //sum result     
	mov x21, 1 // iterator i    
	
sum_loop:
	cmp x21, x19
	b.gt print_res
	add x20, x20, x21
	add x21, x21, 1
	b sum_loop

print_res:
	sub sp, sp, #16
	str x19, [sp]
	str x20, [sp, 8]
	
	adrp x0, res_msg@PAGE
	add x0, x0, res_msg@PAGEOFF
	bl _printf
	
	add sp, sp, #16
	b exit_prog

no_args:
	adrp x0, err_msg@PAGE
	add x0, x0, err_msg@PAGEOFF
	bl _printf

exit_prog:
	mov x0, 0
	ldp x19, x20, [sp, 16]
	ldp x21, x22, [sp, 32]
	ldp x29, x30, [sp], 48
	ret

	.data
err_msg: .asciz "Please provide a number\n"
res_msg: .asciz "Sum of 1..%d is %ld\n"
