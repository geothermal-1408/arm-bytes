	.global _main
	.align 2

.text
_main:
	mov x19, 1

loop_start:
	cmp x19, 10
	b.eq loop_end

	mov x10, x19
	add x10, x10,48

	adrp x1, buffer@PAGE
	add x1, x1, buffer@PAGEOFF
	strb w10, [x1]

	mov x0, 1
	mov x2, 2
	ldr x16, =0x2000004
	svc 0

	add x19, x19, 1
	b loop_start

loop_end:
	mov x0,0
	ldr x16, =0x2000001
	svc 0
.data
buffer:
	.ascii " \n"
