	.text
# User program 1: Output numbers
task1:	li	$a0, '0'
	li 	$v0, 11
	li 	$t0, 10
loop1:	syscall
	addiu   $a0, $a0, 1
	divu    $t1, $a0, ':'
	multu   $t1, $t0
	mflo    $t1
	subu    $a0, $a0, $t1
	b	loop1

# User program 2: Output D
task2:	li	$a0, 'D'
	li	$v0, 11
loop2:  syscall
	b	loop2

# Bootup code
	.ktext
# TODO Implement the bootup code
# Initialize all required data structures
# The final exception return (eret) shall jump to the beginning of program 1
eret

# Exception handler
# Here, you may use $k0 and $k1
# Other registers must be saved first
.ktext 0x80000180
	# Save all registers that we will use in the exception handler
	move $k1, $at
	sw $v0 exc_v0
	sw $a0 exc_a0

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
# TODO Detect and implement system calls here. Here, you can reuse parts from problem 2.1
# Remember that an adjustment of the epc may be necessary.

	j ret

# Interrupt-specific code

interrupt:
# TODO For timer interrupts, call timint

	j ret
ret:
# Restore used registers
	lw $v0 exc_v0
	lw $a0 exc_a0
	move $at, $k1
# Return to the EPC
	eret

# Internal kernel data
	.kdata
exc_v0:	.word 0
exc_a0:	.word 0
# TODO Additional space for registers you want to save temporarily in the exception handler

	.ktext
# Helper functions
timint:
# TODO Process the timer interrupt here, and call this function from the exception handler
	j	ret

# Process control blocks
# Location 0: the program counter
# Location 1: state of the process; here 0 -> idle, 1 -> running
# Location 2-..: state of the registers
	.kdata
pcb_task1:
.word task1
.word 0
# TODO Allocate space for the state of all registers here
pcb_task2:
.word task2
.word 0
# TODO Allocate space for the state of all registers here
