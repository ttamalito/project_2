	.text
# User program 1: Output numbers
task1:	li	$a0, '0'
	li 	$v0, 11
	li 	$t0, 10
	la	$t7, task2
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

	li $t0, 1 
	sw $t0, id1 # giving the first program an id 
	
	li $t0 , 2 
	sw $t0 , id2 # giving the second program an id 
	
	la $t7 , task1
	sw $t7 , pc1  # storing the programm counter of program 1 
	
	la $t7 , task2
	sw $t7 , pc2  # storing the programm counter of program 2
	
	li $t1 , 0
	sw $t1 , state1 # saving the state of the program 1 
	
	li $t1 , 0
	sw $t1 , state2 # saving the state of the program 2		
	
	la $k0 ,  0x00400000
	mtc0 $k0, $14
	li $k1 ,100 
	mtc0 $k1 , $11 # setting the time stamp to 100 cycles 
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
	
	beq $v0 11 sys_eleven  # check for syscall 11 
# Exception code
# TODO Detect and implement system calls here. Here, you can reuse parts from problem 2.1
# Remember that an adjustment of the epc may be necessary.
add_four_to_epc:
	# add 4 to the EPC
	mfc0 $t6, $14
	addiu $t6, $t6, 4
	mtc0 $t6, $14
	j ret

sys_eleven: #code from task 2.1 
	la $t0, 0xffff0008 #address of the control port of the display
	la $t3, 0xffff000c 
	lw $t1, 0($t0)
	andi $t2, $t1, 1
	beqz $t2 , sys_eleven
	
	lw $t7, exc_a0
	#lb $t4, ($t7)
	
	sb $t7, ($t3)
	j add_four_to_epc

	

# Interrupt-specific code

interrupt:
# TODO For timer interrupts, call timint

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

# Internal kernel data
	.kdata
exc_v0:	.word 0
exc_a0:	.word 0
exc_t0: .word 0
exc_t1: .word 0
exc_t2: .word 0
exc_t3: .word 0
exc_t4: .word 0
exc_t5: .word 0
exc_t6: .word 0
exc_t7: .word 0
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
id1: .word 0 
state1: .word 0
pc1: .word 0
exc1_zero:   .word 0
exc1_at:     .word 0
exc1_v0:     .word 0
exc1_v1:     .word 0
exc1_a0:     .word 0
exc1_a1:     .word 0
exc1_a2:     .word 0
exc1_a3:     .word 0
exc1_t0:     .word 0
exc1_t1:     .word 0
exc1_t2:     .word 0
exc1_t3:     .word 0
exc1_t4:     .word 0
exc1_t5:     .word 0
exc1_t6:     .word 0
exc1_t7:     .word 0
exc1_s0:     .word 0
exc1_s1:     .word 0
exc1_s2:     .word 0
exc1_s3:     .word 0
exc1_s4:     .word 0
exc1_s5:     .word 0
exc1_s6:     .word 0
exc1_s7:     .word 0
exc1_t8:     .word 0
exc1_t9:     .word 0
exc1_k0:     .word 0
exc1_k1:     .word 0
exc1_gp:     .word 0
exc1_sp:     .word 0
exc1_fp:     .word 0
exc1_ra:     .word 0
# TODO Allocate space for the state of all registers here
pcb_task2:
.word task2
.word 0
id2: .word 0 
state2: .word 0
pc2: .word 0

# TODO Allocate space for the state of all registers here
exc2_zero:   .word 0
exc2_at:     .word 0
exc2_v0:     .word 0
exc2_v1:     .word 0
exc2_a0:     .word 0
exc2_a1:     .word 0
exc2_a2:     .word 0
exc2_a3:     .word 0
exc2_t0:     .word 0
exc2_t1:     .word 0
exc2_t2:     .word 0
exc2_t3:     .word 0
exc2_t4:     .word 0
exc2_t5:     .word 0
exc2_t6:     .word 0
exc2_t7:     .word 0
exc2_s0:     .word 0
exc2_s1:     .word 0
exc2_s2:     .word 0
exc2_s3:     .word 0
exc2_s4:     .word 0
exc2_s5:     .word 0
exc2_s6:     .word 0
exc2_s7:     .word 0
exc2_t8:     .word 0
exc2_t9:     .word 0
exc2_k0:     .word 0
exc2_k1:     .word 0
exc2_gp:     .word 0
exc2_sp:     .word 0
exc2_fp:     .word 0
exc2_ra:     .word 0