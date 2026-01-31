	.global	_main
	.align 2
	.text
_main:
	//void  *mmap(void *addr, size_t len, int prot, int flags, int fd, off_t offset)
	mov x0, 0
	mov x1, 4096
	mov x2, 3
	mov x3, 0x1002
	mov x4, -1
	mov x5, 0

	ldr x16, =0x20000C5

	svc 0

	mov x19, x0

	// put 'A'(ascii->65) in buffer 
	mov w9, 65
	strb w9, [x19]

	mov w9, 10
	strb w9, [x19, 1]

	//write(int fd, const void *buf, size_t count)

	mov x0, 1
	mov x1, x19
	mov x2, 2
	ldr x16, =0x2000004
	svc 0

	//munmap(void *addr, size_t len)

	mov x0, x19
	mov x1, 4096
	ldr x16, =0x2000049
	svc 0

	//exit

	mov x0, 0
	ldr x16, =0x2000001
	svc 0
