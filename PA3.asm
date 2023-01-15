# Pierre Visconti
# CSCI 341

.data
	arr: 	.word 7, 25, 12, -1, 25, 18, 15, -17, 34, 15, 2, 88, 1, -2147483648, 77, 180, 13, 7, 0, 25
	output: .asciiz "Non-repeating elements: "
	space:	.asciiz "  "
.text
.globl main
main:
	li $a1, 20	# size
	la $s0, arr	# base address	
# Your code 
	li, $t0, -1	# iterator i
	li, $t1, -1	# iterator j
	# prints: "Non-repeating elements: "
	li, $v0, 4	# command for printing a string
	la, $a0, output # loads the string into the argument
	syscall 	# executes the command
	# loop that prints elements in array that do not repeat
	LOOP_1:
	   addi $t0, $t0, 1	# i++
	   beq $t0, $a1, EXIT_1	# branch to EXIT_1 if $t0(i) == $a1(size of array)
	      li, $t4, 1	# sets $t4 to 1 (true)
	      li, $t1, -1	# reset j back to -1
	      sll $t2, $t0, 2	# $t2 = i * 4
	      add $t2, $t2, $s0	# $t2 = i*4 + base address
	      lw $t2, 0($t2)	# $t2 = arr[i] 
	   LOOP_2:
	      addi $t1, $t1, 1	# j++
	      beq $t1, $a1, EXIT_2	# branch to EXIT_2 if $t1(j) == $a1(size of array)
	         beq $t0, $t1, LOOP_2	# branch to LOOP_2 if i == j
	            sll $t3, $t1, 2	# $t3 = j * 4	
	            add $t3, $t3, $s0	# $t3 = j*4 + base address
	            lw $t3, 0($t3)	# $t3 = arr[j] 
	            bne $t2, $t3, LOOP_2	# branch to LOOP_2 if $t2 != $t3
	            li, $t4, 0	# sets $t4 to 0(false) since arr[i] and arr[j] are equal
	      	    j LOOP_2	# jumps to LOOP_2
	      EXIT_2:
	         bne $t4, 1, LOOP_1	# branch to LOOP_1 if $t4 != 1(true), (if false) 
	         # prints the non repeating integer in the array at index i
	            li, $v0, 1	# command for printing an integer
	            la, $a0, 0($t2)	# loads $t2 = arr[i] into the argument
	            syscall		# executes the command	 
	            # prints a space
	            li, $v0, 4	# command for printing a string
	            la, $a0, space	# loads the string into the argument
	            syscall		# executes the command     
	            j LOOP_1	# jumps to LOOP_1
	   EXIT_1:
	      # Exit
	      li $v0, 10
	      syscall
	 
