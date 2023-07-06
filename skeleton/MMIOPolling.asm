.text

# Bootup code
# Since we only implement input/output with polling here and do no computations, all your code can be here.

.ktext
start:
	la $t1, 0xffff0000 #store the address of the control port of the keyboard
	la $t2 , 0xffff0004 # store the address of the data port of the keyboard
	la $t5 0xffff000c #only store the address of the data port of the display since we dont
			  # need to check if the display is ready because we dont have any user code
loop:
	lw $t3, ($t1) #
	beq $t3, $zero, loop
	lw $t4, ($t2)
	sw $t4, ($t5)
	j loop
	# TODO Implement input/output with polling
	b start
	
