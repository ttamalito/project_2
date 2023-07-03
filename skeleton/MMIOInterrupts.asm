.text

usefultask:
	# Program which can perform useful computations, whereas
	# the exception handler takes care of input/output.
	# Unlike polling, with interrupts it is very easy to perform
	# useful computations in addition to handling input/output and
	# not waste computing time with unnecessary waiting.
	# This shall remain unchanged!
	b usefultask

# Bootup code
.ktext
# TODO Implement the system initialization here. What do you need to do for this?

# TODO Jump to our useful task
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

# Exception code. For problem 2.3, it is not required to handle exceptions.
	j ret

# Interrupt-specific code
# TODO Implement handlers for keyboard and display interrupts here.
# You may outsource the actual functionality to functions (similar to problem 2.2).
interrupt:
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

# TODO Allocate your 16-byte buffer here
