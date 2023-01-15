#Pierre Visconti
#CSCI 341

.data
	prompt:	.asciiz "Enter a positive integer: "
	plus:	.asciiz " + "
	equal:	.asciiz " = "
.text
.globl main
main:
	# prompt user to enter a positive int	
	li $v0, 4	# command for printing a string
	la $a0, prompt	# loads address of string to argument
	syscall		# executes the command
	
	# reads input from user
	li $v0, 5	# command for reading an integer value
	syscall		# executes the command
	move $t0, $v0	# moves value to $t0
	
	add $a0, $t0, $zero
	jal digisum	# calls procedure digisum
	
	move $t4, $v0	# moves value of $v0 into $t4
	
	# prints " = "
	li $v0, 4	# command for printing a string
	la $a0, equal	# loads address of string to argument
	syscall		# executes the command
	
	# prints digisum(n)
	li $v0, 1	# command for printing an int
	move $a0, $t4	# moves $t4 into argument
	syscall		# executes the command
	
	#terminates the program
	li $v0, 10	# command to terminate program
	syscall		# executes the command
digisum:	
	slti $t0, $a0, 10
	beq $t0, 1, IF	# branch is n < 10
	   addi $t1, $t1, 10	# $t1 = 10
	   div $a0, $t1		# $a0(n) / 10
  	   mfhi $v0 		# $v0 = remainder, or (n%10)
  	   mflo $a0 		# $a0 = result of n/10
  	   addi $t1, $t1, -10   # sets $t1 back to 0 
  	   
  	   sub $sp, $sp, 8	# creates 8 bytes of space on the stack to store 2 registers
  	   sw $ra, 0($sp)	# saves $ra, return address
  	   sw $v0, 4($sp)	# saves $v0, n%10
  	   jal digisum		# calls procedure digisum
	   
	   move $s0, $v0	# $s0 = restSum
	   lw $s1, 4($sp)	# $s1 = n%10
	   add $s0, $s1, $s0	# $s0 = n%10 + restsum
	   
	   # prints " + "
	   li $v0, 4		# command for printing a string
	   la $a0, plus 	# loads address of string to argument
	   syscall		# executes the command
	   # prints value of n%10
	   li $v0, 1		# command for printing an integer
	   move $a0, $s1	# moves $s1 into argument
	   syscall		# executes the command
	   
	   move $v0, $s0	# moves $s0 to $v0
	   
	   lw $ra, 0($sp)	# retrieve return address
	   addi $sp, $sp, 8	# restoring stack pointer
	   jr $ra		# return contents of $v0 
	   
	   IF:
	      # prints $a0 (n)
	      li $v0, 1		# command for printing an integer
	      move $a0, $a0
	      syscall		# executes the command
	      # return statement
	      move $v0, $a0	# sets value of $a0 (n) to $v0
	      jr $ra		# return contents of $v0
	     


