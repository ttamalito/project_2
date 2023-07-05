	.text
# user program
task:
	la      $a0, msg
	#this was from us
	lb 	$t0, ($a0) #delete this
	li	$v0, 4
	syscall
	li	$a0, 'B'
	li 	$v0, 11
loop:	syscall
	li	$a0, 'C'
	b	loop

# Data
	.data
msg: .asciiz "Hello!"

# Bootup code
	.ktext 
# TODO implement the bootup code
	la $k0 ,  0x00400000
	mtc0 $k0, $14
# The final exception return (eret) should jump to the beginning of the user program
eret

# Exception handler
# Here, you may use $k0 and $k1
# Other registers must be saved first
.ktext 0x80000180
	# Save all registers that we will use in the exception handler
	move $k1, $at
	sw $v0 exc_v0
	sw $a0 exc_a0
	sw $t0 exc_t0
	sw $t1 exc_t1
	sw $t2 exc_t2
	sw $t3 exc_t3
	sw $t4 exc_t4
	sw $t5 exc_t5
	sw $t6 exc_t6
	sw $t7 exc_t7
	mfc0 $k0 $13		# Cause register

# The following case can serve you as an example for detecting a specific exception:
# test if our PC is mis-aligned; in this case the machine hangs
	bne $k0 0x18 okpc	# Bad PC exception
	mfc0 $a0 $14		# EPC
	andi $a0 $a0 0x3	# Is EPC word aligned?
	beq $a0 0 okpc
fail:	j fail			# PC is not aligned -> processor hangs

# The PC is ok, test for further exceptions/interrupts
okpc:
	andi $a0 $k0 0x7c
	beq $a0 0 interrupt	# 0 means interrupt

# Exception code
# TODO Detect and implement system calls here.
# Remember that an adjustment of the epc may be necessary.

# check if the element stored in $v0 is equal to 4
# we can check it directly from the register...
	beq $v0 4 sys_four
	#if we didn't branch check if it is 11
	beq $v0 11 sys_eleven
	# if it is not 4 or 11 go to special case
	j not_four_eleven

	j ret

# Interrupt-specific code (nothing to do here for this exercise)
interrupt:
	j ret
ret:
# Restore used registers
	lw $v0 exc_v0
	lw $a0 exc_a0
	lw $t0 exc_t0
	lw $t1 exc_t1
	lw $t2 exc_t2
	lw $t3 exc_t3
	lw $t4 exc_t4
	lw $t5 exc_t5
	lw $t6 exc_t6
	lw $t7 exc_t7
	move $at, $k1
# Return to the EPC
	eret
#logic for handling syscall 4
sys_four:
	# load the control port of the display
	la $t0, 0xffff0008 #address of the control port of the display
	#load the address data port of the display
	la $t3, 0xffff000c
	
	lw $t7, exc_a0
	# now load the "word" from the address stored in $t0 (Control port)
	# so that we can check if the display is ready to receive data
	lw $t1, 0($t0) #do we need an offset here? 
	# now we need to check if the lowest bit is "ready" i.e., 1
	andi $t2, $t1, 1 #least significant bit of $t1 will be put in $t2 
	#now check if ready or not
	beq $t2, 1, display_ready #branch if the display is ready to print a character
	# else the display is not ready, so
	j display_not_ready
	


add_four_to_epc:
	# add 4 to the EPC
	mfc0 $t6, $14
	addiu $t6, $t6, 4
	mtc0 $t6, $14
	j ret
	
	
display_ready:
	#logic to be executed when the display is ready
	# store into the lower byte the next ASCII character to be displayed
	#but first, load the address of the character(s) to be displayed
	
	lb $t4, ($t7)
	# load one byte and store it in the Data port of the display
	
	#here increment $t7
	addiu $t7, $t7 ,1
	
	#check if we reached the end of the string
	beqz $t4, add_four_to_epc
	#store this byte in the Data port of the display
	
	sb $t4, ($t3) #this is storing the byte in $t5 into the address saved in $t3
	 
display_not_ready:

	#logic to be executed when the display is not ready
	lw $t1, 0($t0) #do we need an offset here? 
	# now we need to check if the lowest bit is "ready" i.e., 1
	andi $t2, $t1, 1 #least significant bit of $t1 will be put in $t2 
	#now check if ready or not
	beq $t2, 1, display_ready #branch if the display is ready to print a character
	j display_not_ready
#logic for handlig syscall 11
sys_eleven:
	la $t0, 0xffff0000 #address of the control port of the display
	mfc0 $t1, $14
	addiu $t1, $t1, 4
	mtc0 $t1, $14
	eret
#logic for returning to the user program
not_four_eleven:
	j ret
# Internal kernel data
	.kdata
exc_v0:	.word 0
exc_a0:	.word 0
# TODO Additional space for registers you want to save temporarily in the exception handler
#lets use t0, t1, t2
exc_t0: .word 0
exc_t1: .word 0
exc_t2: .word 0
exc_t3: .word 0
exc_t4: .word 0
exc_t5: .word 0
exc_t6: .word 0
exc_t7: .word 0
