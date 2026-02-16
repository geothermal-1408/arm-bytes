	.global _main
	.align 2
	
	.section __TEXT,__cstring
	
str_clear:
	.asciz "\033[H\033[J"
str_alive:
	.asciz "# "
str_dead:
	.asciz ". "
str_nl:
	.asciz "\n"
str_usage:
	.asciz "Usage: ./bin/4_0_game_of_life <rows> <cols>\n"
str_menu:
	.asciz "Select Pattern:\n1. Glider\n2. Spaceship\n3. Pulsator\nEnter choice: "
fmt_scan:
	.asciz "%d"

	.section __DATA,__data
	.align 3
g_rows:
	.quad 20
g_cols:
	.quad 20
g_size:
	.quad 400
g_grid:
	.quad 0
g_next_grid:
	.quad 0

	.text
_main:
	stp x29, x30, [sp, #-48]!
	mov x29, sp
	stp x19, x20, [sp, #16]
	stp x21, x22, [sp, #32]

	mov x19, #20
	mov x20, #20

	cmp x0, #3
	b.lt show_usage

	//parse rows
	mov x21, x1
	ldr x0, [x21, #8]
	bl _atoi
	mov x19, x0

	//parse cols
	ldr x0, [x21, #16]
	bl _atoi
	mov x20, x0

	cmp x19, #3
	b.lt show_usage
	cmp x20, #3
	b.lt show_usage

use_defaults:
	adrp x10, g_rows@PAGE
	add x10, x10, g_rows@PAGEOFF
	str x19, [x10]

	adrp x10, g_cols@PAGE
	add x10, x10, g_cols@PAGEOFF
	str x20, [x10]

	mul x21, x19, x20 // size = rows*cols
	adrp x10, g_size@PAGE
	add x10, x10, g_size@PAGEOFF
	str x21, [x10]

	//malloc
	mov x0, x21
	bl _malloc
	adrp x10, g_grid@PAGE
	add x10, x10, g_grid@PAGEOFF
	str x0, [x10]
	mov x19, x0
	
	adrp x10, g_size@PAGE
	add x10, x10, g_size@PAGEOFF
	ldr x1, [x10]
	mov x11, #0

zero_grid:
	cmp x11, x1
	b.ge zero_grid_done
	strb wzr, [x19, x11]
	add x11, x11, #1
	b zero_grid

zero_grid_done:
	adrp x10, g_size@PAGE
	add x10, x10, g_size@PAGEOFF
	ldr x0, [x10]
	bl _malloc

	adrp x10, g_next_grid@PAGE
	add x10, x10, g_next_grid@PAGEOFF
	str x0, [x10]
	mov x20, x0

	adrp x10, g_size@PAGE
	add x10, x10, g_size@PAGEOFF
	ldr x1, [x10]
	mov x11, #0

zero_next:
	cmp x11, x1
	b.ge zero_next_done
	strb wzr, [x20, x11]
	add x11, x11, #1
	b zero_next

zero_next_done:
	//menu
	adrp x0, str_menu@PAGE
	add x0, x0, str_menu@PAGEOFF
	bl _printf

	sub sp, sp, #16
	//str wzr, [sp]
	
	adrp x0, fmt_scan@PAGE
	add x0, x0, fmt_scan@PAGEOFF
	add x1, sp, #16
	str x1, [sp]
	bl _scanf
	
	ldr w1, [sp, #16]
	str x1, [sp]

	cmp w1, #3
	b.eq init_pulsator

	cmp w1, #2
	b.eq init_spaceship

	b init_glider

init_glider:
	//glider
	// . # .
	// . . #
	// # # #
	
	mov w1, #1
	
	strb w1, [x19, #1]

	adrp x10, g_cols@PAGE
	add x10, x10, g_cols@PAGEOFF
	ldr x12, [x10]
	add x13, x12, #2
	strb w1, [x19, x13]
	
	lsl x14, x12, #1
	strb w1, [x19, x14]
	add x15, x14, #1
	strb w1, [x19, x15]
	add x15, x14, #2
	strb w1, [x19, x15]

	b start_game
	
init_spaceship:

	// Shape:
	// . # . . #
	// # . . . .
	// # . . . #
	// # # # # .

	adrp x10, g_rows@PAGE
	add x10, x10, g_rows@PAGEOFF
	ldr x10, [x10]
	
	adrp x11, g_cols@PAGE
	add x11, x11, g_cols@PAGEOFF
	ldr x12, [x11]
	
	//start_row
	sub x13, x10, #4
	lsr x13, x13, #1
	mul x15, x13, x12
	add x19, x19, x15
	
	mov w1, #1
	
	//row 0
	strb w1, [x19, #1]
	strb w1, [x19, #4]

	//row 1
	add x13, x12, #0
	strb w1, [x19, x13]

	//row 2
	lsl x14, x12, #1
	strb w1, [x19, x14]
	add x15, x14, #4
	strb w1, [x19, x15]

	//row 3
	add x16, x14, x12
	strb w1, [x19, x16]
	add x15, x16, #1
	strb w1, [x19, x15]
	add x15, x16, #2
	strb w1, [x19, x15]
	add x15, x16, #3
	strb w1, [x19, x15]

	b start_game

init_pulsator:
	// Pulsating Shape:
	
	// . . . # # . # . . . . .
	// # . . . . . . # . . . .
	// # . . # . . . # # . . .
	// . # # . . . . . # . # #
	// . # # . . . . . # . # #
	// # . . # . . . # # . . .
	// # . . . . . . # . . . .
	// . . . # # . # . . . . .

	
	adrp x10, g_rows@PAGE
	add x10, x10, g_rows@PAGEOFF
	ldr x10, [x10]

	adrp x11, g_cols@PAGE
	add x11, x11, g_cols@PAGEOFF
	ldr x12, [x11]

	sub x13, x10, #8
	lsr x13, x13, #1

	mul x15, x13, x12

	add x19, x19, x15
	
	mov w1, #1

	//row 0
	strb w1, [x19, #3]
	strb w1, [x19, #4]
	strb w1, [x19, #6]

	//row 1
	mov x13, x12
	strb w1, [x19, x13]
	add x14, x13, #7
	strb w1, [x19, x14]

	//row 2
	lsl x13, x12, #1
	strb w1, [x19, x13]
	add x14, x13, #3
	strb w1, [x19, x14]
	add x14, x13, #7
	strb w1, [x19, x14]
	add x14, x13, #8
	strb w1, [x19, x14]

	//row3 (Cols: 1, 2, 8, 10, 11)
	add x13, x13, x12
	add x14, x13, #1
	strb w1, [x19, x14]
	add x14, x13, #2
	strb w1, [x19, x14]
	add x14, x13, #8
	strb w1, [x19, x14]
	add x14, x13, #10
	strb w1, [x19, x14]
	add x14, x13, #11
	strb w1, [x19, x14]

	//row4 (Cols: 1, 2, 8, 10, 11)
	lsl x13, x12, #2
	add x14, x13, #1
	strb w1, [x19, x14]
	add x14, x13, #2
	strb w1, [x19, x14]
	add x14, x13, #8
	strb w1, [x19, x14]
	add x14, x13, #10
	strb w1, [x19, x14]
	add x14, x13, #11
	strb w1, [x19, x14]

	//row5 (Cols: 0, 3, 7, 8)
	add x13, x13, x12
	strb w1, [x19, x13]
	add x14, x13, #3
	strb w1, [x19, x14]
	add x14, x13, #7
	strb w1, [x19, x14]
	add x14, x13, #8
	strb w1, [x19, x14]

	//row6 (Cols: 0, 7)
	add x13, x13, x12   
	strb w1, [x19, x13]
	add x14, x13, #7
	strb w1, [x19, x14]

	//row7 (Cols: 3, 4, 6)
	add x13, x13, x12
	add x14, x13, #3
	strb w1, [x19, x14]
	add x14, x13, #4
	strb w1, [x19, x14]
	add x14, x13, #6
	strb w1, [x19, x14]

	b start_game
	
start_game:	
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

show_usage:
	adrp x0, str_usage@PAGE
	add x0, x0, str_usage@PAGEOFF
	bl _printf
	mov x0, #1
	ldp x21, x22, [sp, #32]
	ldp x19, x20, [sp, #16]
	ldp x29, x30, [sp], #48
	ret
	
_print_grid:
	stp x29, x30, [sp, #-48]!
	mov x29, sp
	stp x19, x20, [sp, #16]
	stp x21, x22, [sp, #32]

	adrp x10, g_grid@PAGE
	add x10, x10, g_grid@PAGEOFF
	ldr x19, [x10]

	adrp x10, g_size@PAGE
	add x10, x10, g_size@PAGEOFF
	ldr x21, [x10] // loop counter

	adrp x10, g_cols@PAGE
	add x10, x10, g_cols@PAGEOFF
	ldr x22, [x10] // loop counter
		
	mov x20, #0

print_loop:
	cmp x20, x21
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
	add x10, x20, #1
	udiv x11, x10, x22
	msub x12, x11, x22, x10
	cbnz x12, next_iter

	adrp x0, str_nl@PAGE
	add x0, x0, str_nl@PAGEOFF
	bl _printf

next_iter:
	add x20, x20, #1
	b print_loop

print_done:
	ldp x21, x22, [sp, #32]
	ldp x19, x20, [sp, #16]
	ldp x29, x30, [sp], #48
	ret
	
_count_neighbour:
	stp x29, x30, [sp, #-16]!
	mov x29, sp
	
	adrp x10, g_grid@PAGE
	add x10, x10, g_grid@PAGEOFF
	ldr x1, [x10]

	adrp x10, g_cols@PAGE
	add x10, x10, g_cols@PAGEOFF
	ldr x10, [x10]
	
	mov x2, #0

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
	adrp x9, g_rows@PAGE
	add x9, x9, g_rows@PAGEOFF
	ldr x9, [x9]

	cmp x7, #0
	b.ge check_row_max
	add x7, x7, x9
	b done_row_wrap
	
check_row_max:
	cmp x7, x9
	b.lt done_row_wrap
	sub x7, x7, x9

done_row_wrap:
	adrp x10, g_cols@PAGE
	add x10, x10, g_cols@PAGEOFF
	ldr x10, [x10]

	cmp x8, #0
	b.ge check_col_max
	add x8, x8, x10
	b done_col_wrap

check_col_max:
	cmp x8, x10
	b.lt done_col_wrap
	sub x8, x8, x10

done_col_wrap:
	mul x4, x7, x10
	add x4, x4, x8

	ldrb w3, [x1, x4]
	add x2, x2, x3

	ret

_update_grid:
	stp x29, x30, [sp, #-48]!
	mov x29, sp
	stp x19, x20, [sp, #16]  // x19=index, x20=grid_base
	stp x21, x22, [sp, #32]  // x21 = next_grid x22 = cell_state

	adrp x10, g_grid@PAGE
	add x10, x10, g_grid@PAGEOFF
	ldr x20, [x10]

	adrp x10, g_next_grid@PAGE
	add x10, x10, g_next_grid@PAGEOFF
	ldr x21, [x10]

	adrp x10, g_size@PAGE
	add x10, x10, g_size@PAGEOFF
	ldr x22, [x10]
	
	mov x19, #0

clear_next_loop:
	cmp x19, x22
	b.ge clear_next_done
	strb wzr, [x21, x19]
	add x19, x19, #1
	b clear_next_loop
	
clear_next_done:
	mov x19, #0

update_loop:
	cmp x19, x22
	b.ge update_apply_swap

	ldrb w23, [x20, x19]

	mov x0, x19
	bl _count_neighbour
	mov x3, x0

	/*
	    Rule: Alive(1) and Neighbors < 2 -> Dead
	    Rule: Alive(1) and Neighbors > 3 -> Dead
	    Rule: Alive(1) and Neighbors == 2 or 3 -> Alive
	    Rule: Dead(0)  and Neighbors == 3 -> Alive
	 */

	cmp w23, #1
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
stay_alive:
	mov w4, #1
	b store_cell

become_dead:
store_dead:
	mov w4, #0

store_cell:
	strb w4, [x21, x19]
	add x19, x19, #1
	b update_loop

update_apply_swap:
	mov x19, #0

copy_loop:
	cmp x19, x22
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
