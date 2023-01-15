# Pierre Visconti
# CSCI 341
.data
	input:			.asciiz	"Enter the input for Hexman: "
	invalid:		.asciiz "Invalid Hexman input!\n"
	already_guessed:	.byte 0,0,0,0,0,0
	starting:		.asciiz "Starting Hexman with: "
	enter:			.asciiz "\nEnter decimal in range [A, F]hex: "
	not_in_range:		.asciiz	"Number is not in range!"
	hex_string:		.asciiz "Hexstring: "
	lives:			.asciiz " Lives remaining: "
	won:			.asciiz "\nYou won!\n"
	lost:			.asciiz "\nYou lost!\n"
.text
.globl main
main:
	la $s6, already_guessed
	li $s1, 0	# $s1 = 0 (num of valid digits)
	li $s0, 3	# $s0 = 3 (lives)
	li $t7, 1	# $t7 = 1
	li $s2, 0
	li $s4, 0
	WHILE_LOOP_0:
	beq $t7, 0, EXIT_0	
	   # asks user to enter an input
	   li $v0, 4	# command for printing a string
	   la $a0, input	# loads prompt into the argument
	   syscall		# executes the command
	   # reads the number user entered
	   li, $v0, 5	# command for reading an integer
	   syscall		# executes the command
	   move $a0, $v0
	   add $s3, $a0, $zero	# $s3 = decimal number
	   jal check_value	# calls procedure
	   move $s1, $v0	# moves $v0 into $s1, $s1 = num of valid digits
	   beq $s1, 8, EXIT_0
	      li $v0, 4
	      la, $a0, invalid
	      syscall		# prints invalid
	      j WHILE_LOOP_0      
	EXIT_0:
	# prints string
	li $v0, 4
	la $a0, starting
	syscall
	# prints number in hex
	li $v0, 34
	move $a0, $s3
	syscall 
	WHILE_LOOP_2:
	# prints string
	li $v0, 4
	la $a0, enter
	syscall
	# reads the number user entered
	li, $v0, 5	# command for reading an integer
	syscall		# executes the command
	move $s5, $v0	# $s5 = guess
	blt $s5, 10, LOOP_0
	   bgt $s5, 15, LOOP_0
	      j LOOP_1
	LOOP_0:
           # print string
           li $v0, 4
           la, $a0, not_in_range
           syscall
           j WHILE_LOOP_2
	LOOP_1:
	   addi $t2, $s5, -10	# guess - 10
	   add $t0, $t2, $s6	# adds base address of array to (guess - 10)
	   lb $t1, 0($t0)	# loads byte at address $t0 in already_guessed[]
	   beq $t1, 0, EXIT_2
	      move $a0, $s2
	      move $a1, $s0
	      jal print_function
	      j WHILE_LOOP_2
	EXIT_2:
	move $a0, $s3	# decimal
	move $a1, $s2	# value
	move $a2, $s5	# guess
	jal compute_value
	move $t2, $v0	# $t2 = new value
	bne $t2, $s2, ELSE_0
	   addi $s0, $s0, -1	# lives--
	   move $a0, $s2	# value
	   move $a1, $s0	# lives
	   jal print_function
	   j SKIP_IF
	ELSE_0:
	addi $t3, $s5, -10	# guess - 10
	add $t0, $t3, $s6	# adds base address of array to (guess - 10)
	li $t1, 1		# $t1 = 1
	sb $t1, 0($t0)		# stores byte at address $t0 in already_guessed[]
	move $s2, $t2		# value = newValue
	move $a0, $s2		# value
	move $a1, $s0		# lives
	jal print_function
	SKIP_IF:
	bne $s2, $s3, NEXT_IF
	   li $v0, 4
	   la $a0, won
	   syscall
	   j END
	NEXT_IF:
	bne $s0, 0, TO_WLOOP_2
	   li $v0, 4
	   la $a0, lost
	   syscall
	   j END
	TO_WLOOP_2:
	j WHILE_LOOP_2	
	END:
	#terminates the program
	li $v0, 10	# command to terminate program
	syscall		# executes the command

check_value:
	li $v0, 0
	li $t2, 16
	bge $a0, 0, RETURN_0
	   add $t1, $a0, $zero
	   WHILE_LOOP_1:
	   beq $t1, 0, RETURN_0
	      divu $t1, $t2	# n % 16
	      mflo $t1		# quotient
	      mfhi $t4		# remainder 
	      blt $t4, 10, RETURN_0
	         addi $v0, $v0, 1	# increments $v0 by 1
	         j WHILE_LOOP_1
	RETURN_0:
	jr $ra

print_function:
	move $t6, $a0	# value
	move $t7, $a1	# number of lives
	# print string
	li $v0, 4
	la $a0, hex_string
	syscall
	# print value
	li $v0, 34
	move $a0, $t6
	syscall
	# print string
	li $v0, 4
	la $a0, lives
	syscall
	# print value
	li $v0, 1
	move $a0, $t7
	syscall
	jr $ra

compute_value:
	li $t0, 0	# index
	move $t5, $a0	# decimal
	move $t6, $a1	# value
	move $t7, $a2	# guess
	li $t8, 16
	WHILE_LOOP_3:
	li $t3, 0
	li $t9, 0
	beq $t5, 0, EXIT_3
	   divu $t5, $t8	# n % 16
	   mflo $t5		# quotient
	   mfhi $t4		# remainder
	   li $t9, 1
	   bne $t4, $t7, SKIP
	      move $t2, $t7	# $t2 = $t7, n = guess
	      sll $t1, $t0, 2	# $t1 = index * 4
	      FOR_LOOP_0:
	      beq $t3, $t1, EXIT_FOR_0
	         sll $t2, $t2, 1
	         addi $t3, $t3, 1 
	         j FOR_LOOP_0
	      EXIT_FOR_0:
	      or $t6, $t6, $t2
	   SKIP:
	   beq $t9, 1, DIVIDED
	      srl $t5, $t5, 4
	   DIVIDED:  
	   addi $t0, $t0, 1	# $t0++
	   j WHILE_LOOP_3
	EXIT_3:
	move $v0, $t6
	jr $ra
	   
