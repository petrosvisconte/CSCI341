# Pierre Visconti
# CSCI 341

.data 
	string0: .asciiz	"Enter the first number: "
	string1: .asciiz	"Enter the second number: "
	result: .asciiz 	"Result: "
  .text
 .globl main
main: 
	li $v0, 4		# Command for printing strings
	la $a0, string0
	syscall 		# executes the command
	
	li $v0, 5 		# command for reading an integer 
	syscall
	move $t0, $v0		# $t0 = first input
	
	li $v0, 4		# Command for printing strings
	la $a0, string1	
	syscall 		# executes the command
	
	li $v0, 5 		# command for reading an integer 
	syscall
	move $t1, $v0		# $t1 = second input
	
	add $t0, $t0, $t1	# Adds both inputs together and saves to $t0
	
	li $v0, 4		# Command for printing strings
	la $a0, result
	syscall 		# executes the command
	
	li $v0, 1 		# command to print register value
	la $a0, ($t0)		# saves value of $t0 to $a0
	syscall
	
	li $v0, 10		# terminates program
