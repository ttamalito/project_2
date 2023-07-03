	.text
# user program
task:
	la      $a0, msg
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
	move $at, $k1
# Return to the EPC
	eret
#logic for handling syscall 4
sys_four:
	# load the control port of the display
	la $t0 0xffff0000 #address of the control port of the display
	
#logic for handlig syscall 11
sys_eleven:

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