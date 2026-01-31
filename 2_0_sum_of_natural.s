
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

	
	/*
	.global _main
	.align 2

.text
_main:
	// ---------------------------------------------------------
	// 1. SETUP: Allocate Heap Memory (Once)
	// ---------------------------------------------------------
	mov x0, 0
	mov x1, 4096
	mov x2, 3
	mov x3, 0x1002
	mov x4, -1
	mov x5, 0
	ldr x16, =0x20000C5 ; mmap
	svc 0
	mov x19, x0         ; x19 = Heap Buffer Address

	// Print Intro (Once)
	mov x0, 1
	adrp x1, intro@PAGE
	add x1, x1, intro@PAGEOFF
	mov x2, 18
	ldr x16, =0x2000004
	svc 0

// =========================================================
// THE MAIN LOOP STARTS HERE
// =========================================================
loop_start:

	// ---------------------------------------------------------
	// 2. PRINT PROMPT
	// ---------------------------------------------------------
	mov x0, 1
	adrp x1, prompt@PAGE
	add x1, x1, prompt@PAGEOFF
	mov x2, 18
	ldr x16, =0x2000004
	svc 0

	// ---------------------------------------------------------
	// 3. READ INPUT
	// ---------------------------------------------------------
	mov x0, 0
	mov x1, x19         ; Read into Heap
	mov x2, 4096
	ldr x16, =0x2000003
	svc 0
	
	mov x20, x0         ; x20 = Length of input

	// ---------------------------------------------------------
	// 4. CHECK IF INPUT IS ".exit"
	// ---------------------------------------------------------
	
	// Step A: Check Length
	// ".exit" + Enter key = 6 bytes
	cmp x20, 6
	b.ne not_exit       ; If length is not 6, it can't be ".exit"

	// Step B: Check Content (Manual String Compare)
	// We need to compare Heap Data (x19) vs ".exit" string in Data
	adrp x21, exit_cmd@PAGE     ; Load address of ".exit" string
	add x21, x21, exit_cmd@PAGEOFF
	
	// We will load all 6 bytes at once for efficiency (using 64-bit register)
	// Note: This loads 8 bytes, so we get 2 extra bytes of junk, 
	// but since we checked length, we can often get away with it or mask it.
	// For strict safety, let's just compare the first 4 bytes, then the next 2.
	
	ldr w22, [x19]      ; Load first 4 bytes of INPUT (user)
	ldr w23, [x21]      ; Load first 4 bytes of EXIT_CMD (".exi")
	cmp w22, w23
	b.ne not_exit       ; If first 4 chars don't match, not exit

	ldrh w22, [x19, 4]  ; Load next 2 bytes of INPUT ("t\n")
	ldrh w23, [x21, 4]  ; Load next 2 bytes of EXIT_CMD
	cmp w22, w23
	b.eq loop_end       ; MATCH! Jump to exit code.

not_exit:
	// ---------------------------------------------------------
	// 5. PRINT ECHO (If not exiting)
	// ---------------------------------------------------------
	
	// Print "echo:> "
	mov x0, 1
	adrp x1, echoed@PAGE
	add x1, x1, echoed@PAGEOFF
	mov x2, 7
	ldr x16, =0x2000004
	svc 0

	// Print User's Text
	mov x0, 1
	mov x1, x19         ; Buffer
	mov x2, x20         ; Length
	ldr x16, =0x2000004
	svc 0

	// JUMP BACK TO START
	b loop_start

// =========================================================
// THE EXIT BLOCK
// =========================================================
loop_end:
	// Optional: Print a "Goodbye" message
	mov x0, 1
	adrp x1, bye@PAGE
	add x1, x1, bye@PAGEOFF
	mov x2, 9
	ldr x16, =0x2000004
	svc 0

	// Free Memory
	mov x0, x19
	mov x1, 4096
	ldr x16, =0x2000049
	svc 0

	// Exit Process
	mov x0, 0
	ldr x16, =0x2000001
	svc 0

.data
intro:    .asciz "welcome echo back\n"
prompt:   .asciz "enter something:> "
echoed:   .asciz "echo:> "
exit_cmd: .ascii ".exit\n"   // Note: .ascii so we don't count the null terminator in logic
bye:      .asciz "Goodbye!\n"
	*/
