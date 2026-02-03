	.global _main
	.align 2

	.equ STDIN, 0
	.equ STDOUT, 1
	.equ SYSCALL_READ, 0x2000003
	.equ SYSCALL_WRITE, 0x2000004
	.equ SYSCALL_EXIT, 0x2000001
	.equ SYSCALL_MMAP, 0x20000C5
	.equ SYSCALL_MUNMAP, 0x2000049
	
	.text
_main:
	//void *mmap(void *addr, size_t len, int prot, int flags, int fd, off_t offset)
	
	mov x0, 0
	mov x1, 4096
	mov x2, 3
	mov x3, 0x1002
	mov x4, -1
	mov x5, 0
	ldr x16, =SYSCALL_MMAP
	svc 0
	mov x19, x0
	
	// print header

	adrp x0, header@PAGE
	add x0, x0, header@PAGEOFF
	bl _print_str

	// print prompt 1
starting:
	
	adrp x0, prompt1@PAGE
	add x0, x0, prompt1@PAGEOFF
	bl _print_str
	
	// read user operation
	
	mov x0, STDIN
	mov x1, x19
	mov x2, 100
	ldr x16, =SYSCALL_READ
	svc 0
	mov x20, x0
	ldrb w22, [x19]

	cmp w22, 91
	beq ending

	// print prompt 2
	
	adrp x0, prompt2@PAGE
	add x0, x0, prompt2@PAGEOFF
	bl _print_str
	
	// read no's
	
	mov x0, STDIN
	add x1, x19, x20
	mov x2, 4096
	sub x2, x2, x20
	ldr x16, =SYSCALL_READ
	svc 0

	// parse input to int
	add x0, x19, x20
	bl _atoi
	mov x23, x0
	mov x24, x1

	scvtf d0, x23
	
calc_loop:
	ldrb w2, [x24]
	cmp w2, 10
	beq calc_finish
	cbz w2, calc_finish

	add x0, x24, 1
	bl _atoi
	mov x24, x1

	scvtf d1, x0
	
	cmp w22, 43 // '+'
	beq do_add
	cmp w22, 45 // '-'
	beq do_sub
	cmp w22, 42 // '*'
	beq do_multi
	cmp w22, 47 // '/' 
	beq do_div
	b calc_loop

do_add:
	fadd d0, d0, d1
	b calc_loop
do_sub:
	fsub d0, d0, d1
	b calc_loop
do_multi:
	fmul d0, d0, d1
	b calc_loop
do_div:
	fdiv d0, d0, d1
	b calc_loop

calc_finish:
	adrp x0, prompt3@PAGE
	add x0, x0, prompt3@PAGEOFF
	bl _print_str

	fcmp d0, #0.0
	b.ge convert_int 

	mov w0, 45  // '-' -> 45
	adrp x1, buffer@PAGE
	add x1, x1, buffer@PAGEOFF
	strb w0, [x1]

	mov x2, 1
	mov x0, STDOUT
	ldr x16, =SYSCALL_WRITE
	svc 0

	fabs d0, d0

convert_int:	
	fcvtzs x9, d0

	mov x0, x9
	adrp x1, buffer@PAGE
	add x1, x1, buffer@PAGEOFF
	bl _itoa

	//print no string
	
	mov x2, x0
	adrp x1, buffer@PAGE
	add x1, x1, buffer@PAGEOFF
	mov x0, STDOUT
	ldr x16, =SYSCALL_WRITE
	svc 0

	adrp x0, dot@PAGE
	add x0, x0, dot@PAGEOFF
	mov x2, 1
	mov x1, x0
	mov x0, STDOUT
	ldr x16, =SYSCALL_WRITE
	svc 0

	scvtf d1, x9
	fsub d2, d0, d1

	mov x10, 10000
	scvtf d3, x10
	fmul d2, d2, d3

	fcvtzs x11, d2

	cmp x11, 0
	b.ge print_frac
	neg x11, x11

print_frac:
	mov x0, x11
	adrp x1, buffer@PAGE
	add x1, x1, buffer@PAGEOFF
	bl _itoa

	mov x2, x0
	adrp x1, buffer@PAGE
	add x1, x1, buffer@PAGEOFF
	mov x0, STDOUT
	ldr x16, =SYSCALL_WRITE
	svc 0
	
end_sequence:	
	adrp x0, newline@PAGE
	add x0, x0, newline@PAGEOFF
	mov x2, 1
	mov x1, x0
	mov x0, STDOUT
	ldr x16, =SYSCALL_WRITE
	svc 0

	b starting
	
ending:	
	//unmap
	
	mov x0, x19
	mov x1, 4096
	ldr x16, =SYSCALL_MUNMAP
	svc 0
	
	//exit 
	mov x0, 0
	ldr x16, =SYSCALL_EXIT
	svc 0


	//subbroutine
	
_print_str:
    mov x9, x30     
    mov x10, x0            
    bl _strlen
    mov x2, x0             
    mov x1, x10            
    mov x0, STDOUT
    ldr x16, =SYSCALL_WRITE
    svc 0
    mov x30, x9            
    ret

_strlen:
	mov x1, x0
	mov x2, 0
	
strlen_loop:
	ldrb w3, [x1, x2]
	cbz w3, strlen_finish
	add x2, x2, 1
	b strlen_loop
	
strlen_finish:
	mov x0, x2
	ret

	
_atoi:
	mov x2, 0 // acummalator
	mov x3, 0 // current byte
	mov x5, 1 // sign flag (1 | -1)
	
	ldrb w3, [x0] 
	cmp w3, 45
	b.ne atoi_loop

	mov x5, -1
	add x0, x0, 1
	
atoi_loop:
	ldrb w3, [x0]
	sub w3, w3, 48
	cmp w3, 9
	b.hi atoi_done

	mov x4, 10
	mul x2, x2, x4
	add x2, x2, x3
	add x0, x0, 1
	b atoi_loop

atoi_done:
	mul x2, x2, x5
	mov x1, x0 
	mov x0, x2
	ret

_itoa:
	mov x2, x1 //start address
	mov x3, 10 //divisor
	mov x4, 0 //counter

	cmp x0, 0 
	b.ne itoa_l
	mov w5, 48
	strb w5, [x1]  
	mov x0, 1
	ret

itoa_l:
	cbz x0, itoa_rev 
	udiv x5, x0, x3 //5 = val/10
	msub x6, x5, x3, x0
	add x6, x6, 48
	strb w6, [x1,x4]
	add x4, x4, 1
	mov x0, x5
	b itoa_l

//* YET TO EXPLORE ***/
itoa_rev:
	mov x0, x4
	mov x5, 0
	sub x4, x4, 1
rev_l:
	cmp x5, x4
	b.ge itoa_finish
	ldrb w6, [x2, x5]
	ldrb w7, [x2, x4]
	strb w7, [x2, x5]
	strb w6, [x2, x4]
	add x5, x5, 1
	sub x4, x4, 1
	b rev_l
	
itoa_finish:	
	ret
	
	.data
header:
	.asciz "ARM BASED CALCULATOR\n"
prompt1:
	.asciz "enter operation['[' to exit]: "
prompt2:
	.asciz "enter no (separated by space): "
prompt3:
	.asciz "Result: "
newline:
	.asciz "\n"
buffer:
	.space 32
dot:
	.asciz "."
