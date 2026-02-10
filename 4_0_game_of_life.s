	.global _main
	.align 2
	
	.data
	
	.equ COLS, 10
	.equ ROWS, 10
	.equ SIZE, 100
str_clear:
	.asciz "\033[H\033[J"

grid:		.zero 100
next_grid:	.zero 100
str_alive:	.asciz "# "
str_dead:	.asciz ". "
str_nl:		.asciz "\n"

	.text
_main:
	stp x29, x30, [sp, #-16]!
	mov x29, sp

	//glider
	// . # .
	// . . #
	// # # #

	adrp x0, grid@PAGE
	add x0, x0, grid@PAGEOFF

	/*** extract '#' ***/

	mov w1, #1
	strb w1, [x0, #1]
	strb w1, [x0, #12]
	strb w1, [x0, #20]
	strb w1, [x0, #21]
	strb w1, [x0, #22]

	bl _print_grid

game_loop:
	adrp x0, str_clear@PAGE
	add x0, x0, str_clear@PAGEOFF
	bl _printf

	bl _print_grid
	bl _update_grid
	
	ldr x0, =200000
	bl _usleep

	b game_loop

	mov x0, #0
	ldp x29, x30, [sp], #16
	ret
	
_print_grid:
	stp x29, x30, [sp, #-32]!
	mov x29, sp
	stp x19, x20, [sp,16]

	adrp x19, grid@PAGE
	add x19, x19, grid@PAGEOFF
	mov x20, #0 // loop counter

print_loop:
	cmp x20, SIZE
	b.ge print_done

	ldrb w1, [x19, x20]
	cbnz w1, print_alive

print_dead:
	adrp x0, str_dead@PAGE
	add x0, x0, str_dead@PAGEOFF
	bl _printf
	b check_newline

print_alive:
	adrp x0, str_alive@PAGE
	add x0, x0, str_alive@PAGEOFF
	bl _printf

check_newline:
	add x21, x20, #1	// x21	= counter + 1
	mov x22, COLS
	udiv x23, x21, x22	// x23	= x21 / COLS
	msub x24, x23, x22, x21 //x24	= reminder
	cbnz x24, next_iter

	adrp x0, str_nl@PAGE
	add x0, x0, str_nl@PAGEOFF
	bl _printf

next_iter:
	add x20, x20, #1
	b print_loop

print_done:
	ldp x19, x20, [sp, #16]
	ldp x29, x30, [sp], #32
	ret
	
_count_neighbour:
	stp x29, x30, [sp, #-16]!
	mov x29, sp
	adrp x1, grid@PAGE
	add x1, x1, grid@PAGEOFF

	mov x2, #0

	mov x10, COLS
	udiv x5, x0, x10 // x5 = row
	msub x6, x5, x10, x0 // x6 = col

	//bound check 

	//top-left
	sub x7, x5, #1 // nr = row - 1
	sub x8, x6, #1 // nc = col - 1 
	bl _check_add_neighbour

	//top
	sub x7, x5, #1
	mov x8, x6
	bl _check_add_neighbour

	//top-right
	sub x7, x5, #1
	add x8, x6, #1
	bl _check_add_neighbour

	//left
	mov x7, x5
	sub x8, x6, #1
	bl _check_add_neighbour

	//right
	mov x7, x5
	add x8, x6, #1
	bl _check_add_neighbour

	//Bottom-left
	add x7, x5, #1
	sub x8, x6, #1
	bl _check_add_neighbour

	//Bottom-center
	add x7, x5, #1
	mov x8, x6
	bl _check_add_neighbour

	//Bottom-right
	add x7, x5, #1
	add x8, x6, #1
	bl _check_add_neighbour

	mov x0, x2
	ldp x29, x30, [sp], #16
	ret

_check_add_neighbour:
	cmp x7, #0
	b.lt _skip_neighbour
	cmp x7, ROWS
	b.ge _skip_neighbour
	cmp x8, #0
	b.lt _skip_neighbour
	cmp x8, COLS
	b.ge _skip_neighbour
	
	mov x9, COLS
	mul x4, x7, x9
	add x4, x4, x8
	ldrb w3, [x1, x4]
	add x2, x2, x3

_skip_neighbour:
	ret

_update_grid:
	stp x29, x30, [sp, #-48]!
	mov x29, sp
	stp x19, x20, [sp, #16]  // x19=index, x20=grid_base
	stp x21, x22, [sp, #32]  // x21 = next_grid x22 = cell_state

	adrp x20, grid@PAGE
	add x20, x20, grid@PAGEOFF
	adrp x21, next_grid@PAGE
	add x21, x21, next_grid@PAGEOFF

	mov x19, #0

clear_next_loop:
	cmp x19, SIZE
	b.ge clear_next_done
	strb wzr, [x21, x19]
	add x19, x19, #1
	b clear_next_loop
	
clear_next_done:
	mov x19, #0

update_loop:
	cmp x19, SIZE
	b.ge update_apply_swap

	ldrb w22, [x20, x19]

	mov x0, x19
	bl _count_neighbour
	mov x3, x0

	/*
	    Rule: Alive(1) and Neighbors < 2 -> Dead
	    Rule: Alive(1) and Neighbors > 3 -> Dead
	    Rule: Alive(1) and Neighbors == 2 or 3 -> Alive
	    Rule: Dead(0)  and Neighbors == 3 -> Alive
	 */

	cmp w22, #1
	b.eq case_alive

case_dead:
	cmp x3, #3
	b.eq become_alive
	b store_dead

case_alive:
	cmp x3, #2
	b.eq stay_alive
	cmp x3, #3
	b.eq stay_alive
	b become_dead

become_alive:
	mov w4, #1
	b store_cell

stay_alive:
	mov w4, #1
	b store_cell

become_dead:
	mov w4, #0
	b store_cell

store_dead:
	mov w4, #0

store_cell:
	strb w4, [x21, x19]
	add x19, x19, #1
	b update_loop

update_apply_swap:
	mov x19, #0

copy_loop:
	cmp x19, SIZE
	b.ge update_done
	ldrb w0, [x21, x19]
	strb w0, [x20, x19]
	add x19, x19, #1
	b copy_loop

update_done:
	ldp x21, x22, [sp, #32]
	ldp x19, x20, [sp, #16]
	ldp x29, x30, [sp], #48
	ret
