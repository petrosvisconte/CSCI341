# Pierre Visconti
# CSCI 341

.data
	prompt:		.asciiz "Enter 32-bit number to translate to instruction: "
	and_string:	.asciiz "and $##, $##, $##"
	or_string: 	.asciiz " or $##, $##, $##"
	lw_string: 	.asciiz "lw $##, 0x####($##)"
	sw_string: 	.asciiz "sw $##, 0x####(S##)"
	beq_string: 	.asciiz "beq $##, $##, "
	jump_string: 	.asciiz "j "
	unsupported: 	.asciiz "Unsupported Instruction"
	registers: 	.asciiz "00atv0v1a0a1a2a3t0t1t2t3t4t5t6t7s0s1s2s3s4s5s6s7t8t9k0k1gpspfpra"
	hex: 		.asciiz "0123456789abcdef"
.text
.globl main

main:
	# asks user to enter a 32 bit number
	li $v0, 4	# command for printing a string
	la $a0, prompt	# loads prompt into the argument
	syscall		# executes the command
	# reads the number user enter
	li, $v0, 5	# command for reading an integer
	syscall		# executes the command
	move $s0, $v0	# moves direction value read from user into register $s0
	# Isolates 6 MSB in 32-bit number representing the OPCODE
	srl $s1, $s0, 26	# shifts $t0 26 bits to the left to save the 6 MSB into $t1 
	# Determines instruction type based on OPCODE
	bne $s1, 0, OP_NOT_ZERO	# branch to OP_NOT_ZERO if OPCODE ($t1) isn't equal to 0
	   # if OPCODE is 0 then calls the procedure r_type
	   j r_type	# goes to the procedure that deals with r type instructions
	OP_NOT_ZERO:
	   slti $s2, $s1, 4	# set $t2 to 1 if OPCODE is less than 4, otherwise set to 0
	   bne $s2, 1, I_TYPE	# branch to I_TYPE if $t2 is not equal to 1 (If OPCODE is not less than 4)
	      # J- Type instructions here
	      j j_type	# goes to the procedure that deals with j type instructions
	I_TYPE:
	   # I-type instruction here
	   j i_type   
	UNSUPPORTED:
	   jal not_supported

# handles all r-type instructions, opcode 0
r_type:
	# Saves the 5 LSB of the 32bit num to $t0 to find the value of the func
	sll $t0, $s0, 26	# saves 6 LSB of $s0 into the 5 MSB of $t0
	srl $t0, $t0, 26	# shifts the 6 MSB to the place of the 6 LSB, $t0 now represent the func
	# finds value for rs, bits 25-21
	sll $t1, $s0, 6		# 31 - 25 = 6
	srl $t1, $t1, 27	# 32 - 6 = 26
	# finds value for rt, bits 20-16
	sll $t2, $s0, 11	# 31 - 20 = 11
	srl $t2, $t2, 27	# 32 - 11 = 21
	# finds value for rd, bits 15-11
	sll $t3, $s0, 16	# 31 - 15 = 16
	srl $t3, $t3, 27	# 32 - 16 = 16
		
	bne $t0, 36, NEXT_INSTRUCTION	# branch to NEXT_INSTRUCTION, if $t0 != 36, if the func does not represent the <and> instruction
	   # code for <and> instruction
	   la $a0, and_string	
	   j r_print
	NEXT_INSTRUCTION:
	   bne $t0, 37, UNSUPPORTED1	# branch to UNSUPPORTED, if $t0 != 37, if the func does not represent the <or> instruction
	      # code for <or> instruction
	      la $a0, or_string
	      j r_print
	UNSUPPORTED1:
	   j not_supported	# jumps to not_supported, because the 32-bit num isnt a <and>, <or> instruction

# handles all j-type instructions, opcode 1-3
j_type:
	# branches to not_supported if the opcode does not equal 2
	bne $s1, 2, UNSUPPORTED2
	   # finds the values for address, bits 25-0
	   sll $t3, $s0, 6	# 31 - 25 = 6
	   srl $t3, $t3, 4
	   addi $t3, $t3, 0x40000000
	   j j_print
	UNSUPPORTED2:
	   j not_supported

# handles all i-type instructions, opcode > 3
i_type:
	# finds value for rs, bits 25-21
	sll $t1, $s0, 6	# 31 - 25 = 6
	srl $t1, $t1, 27	
	# finds value for rt, bits 20-16
	sll $t2, $s0, 11	# 31 - 20 = 11
	srl $t2, $t2, 27	
	
	bne $s1, 4, NEXT_INSTRUCTIONS
	   # code for <beq> instruction
	   sll $t3, $s0, 16	# 31 - 15 = 16
	   sra $t3, $t3, 16
	   sll $t3, $t3, 2	# multiplies by 2
	   addi $t3, $t3, 0x4000C008	# adds PC+4 to address*4
	   sub $sp, $sp, 4
	   sw $t3, 0($sp)
	   la $a0, beq_string
	   la $a1, registers		
	   la $a2, hex
	   # adds rs into string
	   sll $t1, $t1, 1	# multiplies by 2
	   add $a1, $a1, $t1	# adds value of rs to $a0
	   ulhu $t4, 0($a1)	# loading rs from the register array
	   ush $t4, 5($a0)	# stores register rs into _string 
	   # adds rt into string
	   la $a1, registers
	   sll $t2, $t2, 1	# multiplies by 2
	   add $a1, $a1, $t2	# adds value of rt to $a0
	   ulhu $t4, 0($a1)	# loading rt from the register array
	   ush $t4, 10($a0)	# stores register rt into _string 
	   # prints string
	   li $v0, 4		# print our modified string
	   syscall
	   # prints address
	   lw $t3, 0($sp)
	   add $sp, $sp, 4
	   move $a0, $t3
	   li $v0, 34
	   syscall	
	   #terminates the program
	   li $v0, 10		# command to terminate program
	   syscall		# executes the command
	NEXT_INSTRUCTIONS:
	   bne, $s1, 35, FINAL_INSTRUCTION
	      # finds the values for address, bits 15-0
	      sll $t3, $s0, 16	# 31 - 15 = 16
	      srl $t3, $t3, 16
	      la $a0, lw_string
	      j i_print
	FINAL_INSTRUCTION:
	   bne, $s1, 43, UNSUPPORTED3
	      # finds the values for address, bits 15-0
	      sll $t3, $s0, 16	# 31 - 15 = 16
	      srl $t3, $t3, 16
	      la $a0, sw_string
	      j i_print
	UNSUPPORTED3:
	   j not_supported
	
# handles all instructions that weren't needed or that don't exist
not_supported:
	# prints not supported
	li, $v0, 4
	la, $a0, unsupported
	syscall
	#terminates the program
	li $v0, 10	# command to terminate program
	syscall		# executes the command

# handles printing of the r-type instructions
r_print:
	la $a1, registers		
	la $a2, hex
	# adds rd into string
	sll $t3, $t3, 1		# multiplies by 2
	add $a1, $a1, $t3	# adds value of rd to $a1
	ulhu $t4, 0($a1)	# loading rd from the register array
	ush $t4, 5($a0)		# stores register rd into _string 
	# adds rs into string
	la $a1, registers
	sll $t1, $t1, 1		# multiplies by 2
	add $a1, $a1, $t1	# adds value of rs to $a0
	ulhu $t4, 0($a1)	# loading rs from the register array
	ush $t4, 10($a0)	# stores register rs into _string 
	# adds rt into string
	la $a1, registers
	sll $t2, $t2, 1		# multiplies by 2
	add $a1, $a1, $t2	# adds value of rt to $a0
	ulhu $t4, 0($a1)	# loading rt from the register array
	ush $t4, 15($a0)	# stores register rt into _string 
	# prints string
	li $v0, 4		# print our modified string
	syscall	
	#terminates the program
	li $v0, 10	# command to terminate program
	syscall		# executes the command

# handles the printing of j-type instructions
j_print:
	# prints jump_string
	li $v0, 4
	la $a0, jump_string
	syscall	
	# prints the address in hex
	li, $v0, 34
	move $a0, $t3
	syscall
	#terminates the program
	li $v0, 10	# command to terminate program
	syscall		# executes the command

# handles the printing of i-type instructions
i_print:
	la $a1, registers		
	la $a2, hex
	# adds rs into string
	sll $t1, $t1, 1		# multiplies by 2
	add $a1, $a1, $t1	# adds value of rs to $a1
	ulhu $t4, 0($a1)	# loading rs from the register array
	ush $t4, 16($a0)		# stores register rs into _string 
	# adds rt into string
	la $a1, registers
	sll $t2, $t2, 1		# multiplies by 2
	add $a1, $a1, $t2	# adds value of rt to $a1
	ulhu $t4, 0($a1)	# loading rt from the register array
	ush $t4, 4($a0)		# stores register rt into _string 
	# adds address to string
	# adds digit 1 in hex
	andi $t7, $t3, 0xf000
	srl $t7, $t7, 12
	add $a2, $a2, $t7
	ulhu $t4, 0($a2)
	sb $t4, 10($a0)
	# adds digit 2 in hex
	la $a2, hex
	andi $t7, $t3, 0xf00
	srl $t7, $t7, 8
	add $a2, $a2, $t7
	ulhu $t4, 0($a2)
	sb $t4, 11($a0)
	# adds digit 3 in hex
	la $a2, hex
	andi $t7, $t3, 0xf0
	srl $t7, $t7, 4
	add $a2, $a2, $t7
	ulhu $t4, 0($a2)
	sb $t4, 12($a0)
	# adds digit 4 in hex
	la $a2, hex
	andi $t7, $t3, 0xf
	add $a2, $a2, $t7
	ulhu $t4, 0($a2)
	sb $t4, 13($a0)
	# prints string
	li $v0, 4		# print our modified string
	syscall
	#terminates the program
	li $v0, 10	# command to terminate program
	syscall		# executes the command
	
