.data
	arr: 	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	prompt:	.asciiz	"Please enter a positive integer (less than 2^30): "
	output: .asciiz "Number of unique digits: "
.text
.globl main
main: 
	li $t5, -1
	la $s6, arr	#base address
	# asks user to enter a positive number
	li, $v0, 4		# command for printing string
	la, $a0, prompt		# loads the string to print into the argument
	syscall			# executes the command
	# reads the number the user entered
	li, $v0, 5		# command for reading an integer
	syscall			# executes the command
	move $s0, $v0		# moves the num into $s0
	add $s1, $s0, $zero	# $s1 = userNum
	jal find_Num_Digits	# calls the procedure find_num_digits
	move $s7, $v0		# $s7 = numDigits, $v0
	li $t1, 10		# $t1 = 10
	# sets values of bits inside register $t3 to 1 if digit exists
	LOOP:
	   beq $s7, $zero, EXIT
	      divu $s1, $t1	# divide number by 10
	      mflo $t2		# quotient
	      mfhi $t3		# remainder
	      add $t3, $t3, $s6
	      lbu $t6 0($t3)
	      addi $t6, $t6, 1
	      sb  $t6, 0($t3)
	      addi $s7, $s7, -1
	      add $s1, $t2, $zero
	      j LOOP
	EXIT:
	   li $s7, 10	# $s7 = 10
	   li $s4, 0	# sets uniqueDigits to 0, $s4
	   LOOP2:
	      beq $s7, $t5, PRINT
	         add $t3, $s7, $s6
	         lbu $t2, 0($t3)
	         beq $t2, 1, UNIQUE
	            addi $s7, $s7, -1
	            j LOOP2    
	         UNIQUE:
	         addi $s4, $s4, 1	# increments $s4 by one, uniqueDigits++
	         addi $s7, $s7, -1
	         j LOOP2
	    PRINT:
	    li $v0, 4
	    la $a0, output
	    syscall
	    li $v0, 1
	    move $a0, $s4
	    syscall
	    #terminates the program
	    li $v0, 10	# command to terminate program
	    syscall		# executes the command
	      
	
# modifies the following registers:
	# $t0, $t1, $t2, $t3
find_Num_Digits:
	# $s0 = userNum
	# $t0 = numDigits
	# $t1 = n
	# $t2 = mod
	li $t0, 0	# sets $t0 to 0, numDigits = 0
	li $t1, 0	# sets $t1 to 0, n = 0
	li $t2, 1	# sets $t2 to 1, mod = 1
	WHILE_LOOP:
	   beq $s0, $t1, USERNUM_EQUALS_N
	      mulu $t2, $t2, 10	# multiplies mod by 10 each iteration
	      divu $s0, $t2	# divides $s0 by $t3, divides userNum by 10^count
	      mfhi $t1		# moves the remainder of the operation into $t1
	      addi $t0, $t0, 1	# adds one to $t0, numDigits++
	      j WHILE_LOOP
	USERNUM_EQUALS_N:
	move $v0, $t0	# sets $v0 to contents of $t1, $v0 = numDigits
	jr $ra	# returns to main
	
	
	
	
	