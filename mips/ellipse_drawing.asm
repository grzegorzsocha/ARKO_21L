	.data
getx:	.asciiz "Enter x value.\n"
gety:	.asciiz "Enter y value.\n"
ferror:	.asciiz "File error occured.\n"
invxy:	.asciiz "Invalid axes values.\n"
pname:	.asciiz "picture.bmp"
	.align 2
tmp:	.space 4

	.text
get_data:
	li $v0, 4		# print getx messaage
	la $a0, getx
	syscall
	
	li  $v0, 5		# save x value to $s0
	syscall
	move $s0, $v0
	
	li $v0, 4		# print gety messaage
	la $a0, gety
	syscall
	
	li  $v0, 5		# save y value to $s1
	syscall
	move $s1, $v0
	
        la $a0, pname		# open file
        li $a1, 0
        li $a2, 0
        li $v0, 13	
        syscall
        
        move $t0, $v0		# check for file error
        bltz $t0, file_error
        la $a0, ($t0)

	la $a1, tmp		# pass unnecessary bytes
	li $a2, 2
	li $v0, 14 
	syscall
	
	la $a1, tmp		# get size
	li $a2, 4
	li $v0, 14
	syscall
	lw $s2, tmp 		# save size to $s2
	
	la $a1, tmp		# pass unnecessary bytes
	li $a2, 12
	li $v0, 14	
	syscall	

	la $a1, tmp		# get width
	li $a2, 4
	li $v0, 14
	syscall		
	lw $s3, tmp		# save width to $s3
	
	la $a1, tmp		# get height
	li $a2, 4
	li $v0, 14
	syscall		
	lw $s4, tmp		# save height to $s4
	
	move $a0, $t0		# close file
	li $v0, 16
        syscall
        
        ble $s0, $s1, inv_axes	# check for invalid axes values
        sll $t0, $s0, 1
        blt $s3, $t0, inv_axes
        sll $t0, $s1, 1
        blt $s4, $t0, inv_axes
        
        la $a0, pname		# open file again to read whole file
        li $a1, 0
        li $a2, 0
        li $v0, 13	
        syscall
        
        move $t0, $v0
        bltz $t0, file_error	# check for file error
	
	la $a0, ($s2)		# allocate memory to picture
	li $v0, 9
	syscall
	move $s5, $v0		# save alocated memory address to $s5
	
	addiu $s5, $s5, 54	# save address to first pixel to $s6
	move $s6, $s5
	subiu $s5, $s5, 54
	
	la $a0, ($t0)		# read file to allocated memory
	la $a1, ($s5)
	la $a2, ($s2)
	li $v0, 14
	syscall
	
	move $a0, $t0		# close file
	li $v0, 16
	syscall
        
        sll $t1, $s3 1		# save address of bitmap center to the $s7
	add $t1, $t1, $s3
	srl $t2, $s4, 1
	mul $t1, $t1, $t2
	srl $t2, $s3 1
	add $t2, $t2, $s3
	add $t1, $t1, $t2
	add $s7, $s6, $t1
        
	mul $t5, $s1, $s1	# create variable d = 4y^2 - 4x^2y + x^2 and save it to $t5
	sll $t5, $t5, 2
	mul $t4, $s0, $s0
	add $t5, $t5, $t4
	sll $t4, $t4, 2
	mul $t4, $t4, $s1
	sub $t5, $t5, $t4
	
	li $t6, 0		# save starting co-ordinates to $t6 and $t7
	la $t7, ($s1)

loop1:
	mul $t2, $t6, $t6	# check condition x^2 * (a^2 + b^2) <= a^4
	mul $t3, $s0, $s0
	mul $t4, $s1, $s1
	add $t4, $t4, $t3
	mul $t3, $t3, $t3
	mul $t2, $t2, $t4
	
	bgt $t2, $t3, flip	# branch if condition hasn't been met
	
	la $a0, ($t6)		# change pixel ($t6, $t7) and symetric one's to it
	la $a1, ($t7)
	jal change_pixel
	
	li $t1, 0
	sub $t1, $t1, $t6
	la $a0, ($t1)
	la $a1, ($t7)
	jal change_pixel
	
	li $t1, 0
	sub $t1, $t1, $t6
	li $t2, 0
	sub $t2, $t2, $t7
	la $a0, ($t1)
	la $a1, ($t2)
	jal change_pixel
	
	li $t2, 0
	sub $t2, $t2, $t7
	la $a0, ($t6)
	la $a1, ($t2)
	jal change_pixel
	
	bltz $t5, ifyes1	# branch if d < 0
	
	mul $t3, $s1, $s1	# update variable d to d +8b^2x + 12b^2 - 8a^2y + 8a^2
	sll $t2, $t3, 3
	mul $t2, $t2, $t6
	sll $t3, $t3, 2
	add $t2, $t2, $t3
	sll $t3, $t3, 1
	add $t2, $t2, $t3
	add $t5, $t5, $t2
	mul $t3, $s0, $s0
	sll $t3, $t3, 3
	add $t5, $t5, $t3
	mul $t3, $t3, $t7
	sub $t5, $t5, $t3
	
	
	addi $t6, $t6, 1	#increase x by 1 and decrease y by 1
	subi $t7, $t7, 1
	
	b loop1
	
ifyes1:
	mul $t3, $s1, $s1	# update variable d to d +8b^2x + 12b^2
	sll $t2, $t3, 3
	mul $t2, $t2, $t6
	sll $t3, $t3, 2
	add $t2, $t2, $t3
	sll $t3, $t3, 1
	add $t2, $t2, $t3
	add $t5, $t5, $t2

	addi $t6, $t6, 1	#increase x by 1
	
	b loop1

loop2:
	mul $t2, $t6, $t6	# check condition x^2 <= a^4 / (a^2 + b^2)
	mul $t3, $s0, $s0
	mul $t4, $s1, $s1
	add $t4, $t4, $t3
	mul $t3, $t3, $t3
	mul $t2, $t2, $t4
	
	bgt $t2, $t3, flip	# branch if condition hasn't been met
	
	la $a0, ($t7)		# change pixel ($t6, $t7) and symetric one's to it
	la $a1, ($t6)
	jal change_pixel
	
	li $t1, 0
	sub $t1, $t1, $t6
	la $a0, ($t7)
	la $a1, ($t1)
	jal change_pixel
	
	li $t1, 0
	sub $t1, $t1, $t6
	li $t2, 0
	sub $t2, $t2, $t7
	la $a0, ($t2)
	la $a1, ($t1)
	jal change_pixel
	
	li $t2, 0
	sub $t2, $t2, $t7
	la $a0, ($t2)
	la $a1, ($t6)
	jal change_pixel
	
	bltz $t5, ifyes2 	# branch if d < 0
	
	mul $t3, $s1, $s1	# update variable d to d +8b^2x + 12b^2 - 8a^2y + 8a^2
	sll $t2, $t3, 3
	mul $t2, $t2, $t6
	sll $t3, $t3, 2
	add $t2, $t2, $t3
	sll $t3, $t3, 1
	add $t2, $t2, $t3
	add $t5, $t5, $t2
	mul $t3, $s0, $s0
	sll $t3, $t3, 3
	add $t5, $t5, $t3
	mul $t3, $t3, $t7
	sub $t5, $t5, $t3
	
	
	addi $t6, $t6, 1	#increase x by 1 and decrease y by 1
	subi $t7, $t7, 1
	
	b loop2
	
ifyes2:
	mul $t3, $s1, $s1	# update variable d to d +8b^2x + 12b^2
	sll $t2, $t3, 3
	mul $t2, $t2, $t6
	sll $t3, $t3, 2
	add $t2, $t2, $t3
	sll $t3, $t3, 1
	add $t2, $t2, $t3
	add $t5, $t5, $t2

	addi $t6, $t6, 1	#increase x by 1
	
	b loop2

change_pixel:
	sub $sp, $sp, 4		# save return adress
	sw $ra,4($sp)
		
	li $a2, 0x00
	
	la $t2, ($s7)		# calculate pixel address
	sll $t1, $s3, 1
	add $t1, $t1, $s3
	mul $t1, $t1, $a1
	add $t2, $t2, $t1
	sll $t1, $a0, 1
	add $t1, $t1, $a0
	add $t2, $t2, $t1
	
	sb $a2, ($t2)		# change pixel color
	sb $a2, 1($t2)
	sb $a2, 2($t2)

	jr $ra			# return to the loop

flip:	
	la $t2, ($s0)		# swap axes values
	la $s0, ($s1)
	la $s1, ($t2)
	
	li $t6, 0		# save starting co-ordinates to $t6 and $t7
	la $t7, ($s1)
	
	bgt $s1, $s0, loop2
	
save_file:
	li $v0, 13		# open file to write
	la $a1, 1
	la $a2, 0
	la $a0, pname
	syscall
	
	move $t0, $v0		# check for file error
        bltz $t0, file_error
        
        li $v0, 15		# write to file
        la $a0, ($t0)
        la $a1, ($s5)
        la $a2, ($s2)
        syscall
        	
	move $a0, $t0		# close file
	li $v0, 16
	syscall
	
exit:
	li $v0, 10
	syscall

file_error:
	li $v0, 4
	la $a0, ferror
	syscall
	
	li $v0, 10
	syscall
	
inv_axes:
	li $v0, 4
	la $a0, invxy
	syscall
	
	li $v0, 10
	syscall
