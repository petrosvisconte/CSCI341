.data
	prompt_HI:	.asciiz "Enter integer value for HI register: "
	prompt_LO:	.asciiz "Enter integer value for LO register: "
	prompt_ROL:	.asciiz "Enter direction rotation (0 to quit): "
	prompt_HI_Val:	.asciiz "Value of HI: "
	prompt_LO_Val:	.asciiz "Value of LO: "
	newline:		.asciiz "\n"
  .text
 .globl main
main: 
	#Loads various immediate values needed in the program to temp registers
	li, $t3, 1		#loads immediate value, 1, to register $t3
	li, $t4, -1		#loads immediate value, -1, to register $t4	
  	
  	#asks user to enter value for HI register
	li, $v0, 4		#command for printing string
	la, $a0, prompt_HI	#loads the string to print into the argument
	syscall			#executes the command
	#reads the HI value from the user
	li, $v0, 5		#command for reading an integer
	syscall			#executes the command
	move $t0, $v0		#moves HI value read from user into register $t0
	#asks the user the enter the value for LO register
	li, $v0, 4		#command for printing string
	la, $a0, prompt_LO	#loads the string to print into the argument
	syscall			#executes the command
	#reads the LO value from the user
	li, $v0, 5		#command for reading an integer
	syscall			#executes the command
	move $t1, $v0		#moves LO value read from user into register $t1
	
	#Loop that will ask user for rotation direction and rotate the 64 bit register
	LOOP:
	   #asks the user for the direction of rotation
	   li, $v0, 4		#command for printing string
	   la, $a0, prompt_ROL	#loads the string to print into the argument
	   syscall 		#executes the command
	   #reads the value for direction of rotation from user
	   li, $v0, 5		#command for reading an integer
	   syscall			#executes the command
	   move $t2, $v0		#moves direction value read from user into register $t2
	
	   #loop that will ask user for rotation direction and rotate the 64 bit register
	   beq $t2, $zero, EXIT	#Branch to EXIT if $t2 is equal to zero
	      beq, $t2, $t3, ROL_L	#Branch to ROL_L if $t2 is equal to $t3, where $t3 = 1
	      beq $t2, $t4, ROL_R	#Branch to ROL_R if $t2 is equal to $t4, where $t4 = -1 
	      #rotates the 64 bit register left by 1
	      ROL_L:
	         sll $s0, $t0, 1	#$s0 = HI_shift
	         srl $s1, $t0, 31	#$s1 = HI_rotate
	         sll $s2, $t1, 1	#$s2 = LO_shift
	         srl $s3, $t1, 31	#$s3 = LO_rotate
	         or $t0, $s0, $s3	#HI = HI_shift OR LO_rotate
	         or $t1, $s2, $s1	#LO = LO_shift OR HI_rotate 
	         j LOOP
	      #rotates the 64 bit register right by 1
	      ROL_R:
	         srl $s0, $t0, 1	#$s0 = HI_shift
	         sll $s1, $t0, 31	#$s1 = HI_rotate
	         srl $s2, $t1, 1	#$s2 = LO_shift
	         sll $s3, $t1, 31	#$s3 = LO_rotate
	         or $t0, $s0, $s3	#HI = HI_shift OR LO_rotate
	         or $t1, $s2, $s1	#LO = LO_shift OR HI_rotate
	         j LOOP
	   EXIT:
	      #prints string stating final value of HI
	      li $v0, 4			#command for printing string
	      la $a0, prompt_HI_Val	#loads the string to print into the argument
	      syscall			#executes the command
	      #prints final value of HI
	      move $a0, $t0	#moves value of $t0 = HI into the argument
	      li $v0, 34	#command for printing in hex
	      syscall		#executes the command
	      #prints a newline
	      li, $v0, 4	#command for printing string
	      la $a0, newline	#loads the string to the argument
	      syscall		#executes the command
	      #prints string stating final value of LO
	      li $v0, 4			#command for printing string
	      la $a0, prompt_LO_Val	#loads the string to print into the argument
	      syscall			#executes the command
	      #prints final value of LO
	      move $a0, $t1	#moves value of $t0 = LO into the argument
	      li $v0, 34	#command for printing in hex
	      syscall		#executes the command
	      #terminates the program
	      li $v0, 10	#command to terminate program
	      syscall		#executes the command