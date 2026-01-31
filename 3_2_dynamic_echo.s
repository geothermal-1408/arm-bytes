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


	/*

	.global _main
    .align 2

    .equ STDIN, 0
    .equ STDOUT, 1
    .equ SYSCALL_EXIT, 0x2000001
    .equ SYSCALL_READ, 0x2000003
    .equ SYSCALL_WRITE, 0x2000004
    .equ SYSCALL_MMAP, 0x20000C5
    .equ SYSCALL_MUNMAP, 0x2000049

    .text
_main:
    // ---------------------------------------------------------
    // 1. Allocate Memory (mmap)
    // ---------------------------------------------------------
    mov x0, 0
    mov x1, 4096
    mov x2, 3
    mov x3, 0x1002
    mov x4, -1
    mov x5, 0
    ldr x16, =SYSCALL_MMAP
    svc 0
    
    // SAVE BUFFER ADDRESS
    mov x19, x0            // x19 is our Base Pointer

    // ---------------------------------------------------------
    // 2. Print Header & Prompt 1
    // ---------------------------------------------------------
    adrp x0, header@PAGE
    add x0, x0, header@PAGEOFF
    bl _print_str

    adrp x0, prompt1@PAGE
    add x0, x0, prompt1@PAGEOFF
    bl _print_str

    // ---------------------------------------------------------
    // 3. Read Operation (e.g., "+")
    // ---------------------------------------------------------
    mov x0, STDIN
    mov x1, x19            // Read into start of buffer
    mov x2, 10             // Read a few bytes
    ldr x16, =SYSCALL_READ
    svc 0
    mov x20, x0            // x20 = Length of Op input (includes \n)

    // Save the Operation Character for later
    ldrb w22, [x19]        // w22 now holds '+', '-', '*', or '/'

    // ---------------------------------------------------------
    // 4. Print Prompt 2
    // ---------------------------------------------------------
    adrp x0, prompt2@PAGE
    add x0, x0, prompt2@PAGEOFF
    bl _print_str

    // ---------------------------------------------------------
    // 5. Read Numbers
    // ---------------------------------------------------------
    mov x0, STDIN
    add x1, x19, x20       // New Address = Base + Offset
    
    // Calculate remaining space: 4096 - x20
    mov x2, 4096
    sub x2, x2, x20        
    
    ldr x16, =SYSCALL_READ
    svc 0
    // We don't strictly need to save length here for parsing logic

    // ---------------------------------------------------------
    // 6. CALCULATION LOGIC
    // ---------------------------------------------------------
    
    // A. Parse FIRST number to initialize the Result
    add x0, x19, x20       // Point x0 to start of numbers
    bl _atoi
    mov x23, x0            // x23 = ACCUMULATOR (Result)
    mov x24, x1            // x24 = Current Pointer (points to space or \n)

calc_loop:
    // B. Check if we are done (Newline or Null)
    ldrb w2, [x24]
    cmp w2, 10             // Check for Newline (\n)
    beq calc_finish
    cbz w2, calc_finish    // Check for Null terminator

    // C. Move to next number (Skip space)
    add x0, x24, 1         // Skip the space
    
    // D. Parse NEXT number
    bl _atoi
    // x0 now holds the Next Number
    // x1 now holds the new pointer address

    mov x24, x1            // Update our pointer for the next round

    // E. Perform Math based on stored Op (w22)
    cmp w22, 43            // '+'
    beq do_add
    cmp w22, 45            // '-'
    beq do_sub
    cmp w22, 42            // '*'
    beq do_mul
    cmp w22, 47            // '/'
    beq do_div
    b calc_loop            // Unknown op, skip (or handle error)

do_add:
    add x23, x23, x0
    b calc_loop
do_sub:
    sub x23, x23, x0
    b calc_loop
do_mul:
    mul x23, x23, x0
    b calc_loop
do_div:
    // Check divide by zero if you want, skipping for brevity
    sdiv x23, x23, x0
    b calc_loop

calc_finish:

    // ---------------------------------------------------------
    // 7. Print Result
    // ---------------------------------------------------------
    
    // Print "Result: "
    adrp x0, prompt3@PAGE
    add x0, x0, prompt3@PAGEOFF
    bl _print_str

    // Convert Result (x23) to String
    mov x0, x23
    adrp x1, buffer@PAGE
    add x1, x1, buffer@PAGEOFF
    bl _itoa

    // Print the Number String
    mov x2, x0             // Length from itoa
    adrp x1, buffer@PAGE
    add x1, x1, buffer@PAGEOFF
    mov x0, STDOUT
    ldr x16, =SYSCALL_WRITE
    svc 0

    // Print a final newline for cleanliness
    adrp x0, newline@PAGE
    add x0, x0, newline@PAGEOFF
    mov x2, 1
    mov x1, x0
    mov x0, STDOUT
    ldr x16, =SYSCALL_WRITE
    svc 0

    // ---------------------------------------------------------
    // 8. Cleanup and Exit
    // ---------------------------------------------------------
    mov x0, x19
    mov x1, 4096
    ldr x16, =SYSCALL_MUNMAP
    svc 0
    
    mov x0, 0
    ldr x16, =SYSCALL_EXIT
    svc 0

// =========================================================
// SUBROUTINES
// =========================================================

// Helper: Print null-terminated string in x0
_print_str:
    mov x9, x30            // Save Link Register
    mov x10, x0            // Save String Address
    bl _strlen
    mov x2, x0             // Length
    mov x1, x10            // Address
    mov x0, STDOUT
    ldr x16, =SYSCALL_WRITE
    svc 0
    mov x30, x9            // Restore Link Register
    ret

_strlen:
    mov x1, x0
    mov x2, 0
strlen_l:
    ldrb w3, [x1, x2]
    cbz w3, strlen_f
    add x2, x2, 1
    b strlen_l
strlen_f:
    mov x0, x2
    ret

_atoi:
    mov x2, 0              // Accumulator
    mov x3, 0              // Digit
atoi_l:
    ldrb w3, [x0]
    sub w3, w3, 48
    cmp w3, 9
    b.hi atoi_end          // Stop if not 0-9
    mov x4, 10
    mul x2, x2, x4
    add x2, x2, x3
    add x0, x0, 1
    b atoi_l
atoi_end:
    mov x1, x0             // Return end pointer
    mov x0, x2             // Return Integer
    ret

_itoa:
    mov x2, x1             // Start Address
    mov x3, 10             // Divisor
    mov x4, 0              // Counter
    
    cmp x0, 0              // Handle 0
    b.ne itoa_l
    mov w5, 48
    strb w5, [x1]
    mov x0, 1
    ret
    
itoa_l:
    cbz x0, itoa_rev
    udiv x5, x0, x3        // x5 = Val / 10
    msub x6, x5, x3, x0    // x6 = Remainder
    add x6, x6, 48         // To ASCII
    strb w6, [x1, x4]
    add x4, x4, 1
    mov x0, x5
    b itoa_l

itoa_rev:
    mov x0, x4             // Save length return
    mov x5, 0              // Start
    sub x4, x4, 1          // End
rev_l:
    cmp x5, x4
    b.ge itoa_fin
    ldrb w6, [x2, x5]
    ldrb w7, [x2, x4]
    strb w7, [x2, x5]
    strb w6, [x2, x4]
    add x5, x5, 1
    sub x4, x4, 1
    b rev_l
itoa_fin:
    ret

    .data
header:  .asciz "\n--- ARM CALCULATOR ---\n"
prompt1: .asciz "Enter Operation (+ - * /): "
prompt2: .asciz "Enter numbers (e.g. 10 5 2): "
prompt3: .asciz "Result: "
newline: .asciz "\n"
buffer:  .space 32       // Small buffer for printing the number
	*/
