	.global _main
	.align 2
	.text
_main:
	//1.void *mmap(void *addr, size_t len, int prot, int flags, int fd, off_t offset)
	mov x0, 0
	mov x1, 4096
	mov x2, 3
	mov x3, 0x1002
	mov x4, -1
	mov x5, 0
	ldr x16, =0x2000C5
	svc 0
	mov x19, x0

	//2. print header(write)

	mov x0, 1
	adrp x1, header@PAGE
	add x1, x1, header@PAGEOFF
	mov x2, 18
	ldr x16, =0x2000004
	svc 0

	//3. print prompt
driver:	
	mov x0, 1
	adrp x1, prompt@PAGE
	add x1, x1, prompt@PAGEOFF
	mov x2, 18
	ldr x16, =0x2000004
	svc 0

	//4. ssize_t read(int fd, void *buf, size_t count)
	
	mov x0, 0
	mov x1, x19
	mov x2, 4096
	ldr x16, =0x2000003
	svc 0
	mov x20, x0

	//check for ".exit" cmd

	cmp x20, 6
	b.ne echo_print

	adrp x21, exit_cmd@PAGE
	add x21, x21, exit_cmd@PAGEOFF

	ldr w22, [x19]
	ldr w23, [x21]
	cmp w22, w23
	b.ne echo_print

	ldrh w22, [x19, 4]
	ldrh w23, [x21, 4]
	cmp w22, w23
	b.eq finish
	
echo_print:	
	//5. print echoed

	mov x0, 1
	adrp x1, echoed@PAGE
	add x1, x1, echoed@PAGEOFF
	mov x2, 7
	ldr x16, =0x2000004
	svc 0
	
	//6.write(int fd, const void *buf, size_t count)
	mov x0, 1
	mov x1, x19
	mov x2, x20
	ldr x16, =0x2000004
	svc 0

	b driver
	
	//7.munmap(void *addr, size_t len)
finish:	
	mov x0, x19
	mov x1, 4096
	ldr x16, =0x2000049
	svc 0

	//8.exit

	mov x0, 0
	ldr x16, =0x2000001
	svc 0

	.data
header:
	.asciz "welcome echo back\n"
prompt:
	.asciz "enter something:> "
echoed:
	.asciz "echo:> "
exit_cmd:
	.ascii ".exit\n"
