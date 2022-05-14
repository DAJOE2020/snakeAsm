.globl snakeInit
.globl snakeClose
.globl updateSnake
.globl writeSnake
.globl getDead
.globl snakeRestart

.data
listPointer: .quad 0 # pointer to snake body
len: .quad 0 # length of snake
dirx: .quad 0 # x direction
diry: .quad 0 # y direction
ndirx: .quad 0 # new x direction
ndiry: .quad 0 # new y direction
eating: .byte 0 # bool, if eating
dead: .byte 0 # if dead
fpm: .quad 0 # frames per move
mps: .quad 0 # moves per second
frameCount: .quad 0 # frame count
speedInc: .quad 0 # increment every time snake eats apple

format: .asciz "dir: (%ld, %ld), new dir: (%ld, %ld)\n\r"

.text

snakeInit:

	# init linkedlist
	call makeLinkedlist
	movq %rax, listPointer

	# init vals
	call _initVals

	# write first cell
	mov listPointer, %rdi
	mov $0, %rsi
	call pushLinkedlist
	mov listPointer, %rdi
	mov $0, %rsi
	call pushLinkedlist

	ret

snakeRestart:

	# clear body
	mov listPointer, %rdi
	call clearLinkedlist

	# add initial cell again
	mov listPointer, %rdi
	mov $0, %rsi
	call pushLinkedlist
	mov listPointer, %rdi
	mov $0, %rsi
	call pushLinkedlist

	# reset to initial vals
	call _initVals

	ret

_initVals:
	movq $1, len
	movq $1, dirx
	movq $0, diry
	mov dirx, %rax
	movq %rax, ndirx
	mov diry, %rax
	movq %rax, ndiry
	movb $0, eating
	movb $0, eating
	movb $0, dead
	movq $8, mps
	call _calFpm
	movq $0, frameCount
	movq $1, speedInc

	ret

# checks if framecount exceeds frames per movement
# updates the new direction based on keyboard input
# moves snake
# checks if head collides with snake
# eats apple
updateSnake:

	# checks for keyboard input

	# gets current char
	call getch
	andb $0b01011111, %al

	# checks char
	cmpb $87, %al # W
	je _moveUp
	cmpb $65, %al # A
	je _moveLeft
	cmpb $83, %al # S
	je _moveDown
	cmpb $68, %al # D
	je _moveRight
	jmp _checkUpdate

	# changes newdir
	_moveUp:
		movq $0, ndirx
		movq $-1, ndiry
		jmp _checkUpdate
	_moveLeft:
		movq $-1, ndirx
		movq $0, ndiry
		jmp _checkUpdate
	_moveDown:
		movq $0, ndirx
		movq $1, ndiry
		jmp _checkUpdate
	_moveRight:
		movq $1, ndirx
		movq $0, ndiry
		jmp _checkUpdate

	_checkUpdate:

		# check if frame count is less than frames per move
		incq frameCount
		mov frameCount, %rax
		cmp fpm, %rax
		jl _updateNop
		jmp _checkUpdateDir

		_updateNop:
			ret

	_checkUpdateDir:

		# checks if new direction is backward

		# checks if length is 1
		cmp $1, len
		je _updateDir

		# checks if new x is not inverse of old x
		mov ndirx, %eax
		imul $-1, %eax
		cmpl dirx, %eax
		jne _updateDir

		# checks if new y is not inverse of old y
		mov ndiry, %eax
		imul $-1, %eax
		cmpl diry, %eax
		jne _updateDir


		jmp _doUpdate # does not update direction

	_updateDir:
		mov ndirx, %rax # updates x coord
		movq %rax, dirx
		mov ndiry, %rax # updates y coord
		movq %rax, diry
		jmp _doUpdate

	_doUpdate:

		# push callee-safe registers
		push %rbx
		push %r12
		push %r13

		# get new head
		
		# get index of head
		mov len, %rbx
		dec %rbx
		imul $2, %rbx

		# get x of head
		mov listPointer, %rdi
		mov %rbx, %rsi
		call atLinkedlist
		mov %rax, %r12
		inc %rbx

		# get y of head
		mov listPointer, %rdi
		mov %rbx, %rsi
		call atLinkedlist
		mov %rax, %r13

		# move head
		add dirx, %r12
		add diry, %r13

		# mod x of new head
		xor %edx, %edx
		mov %r12, %rax
		add width, %rax
		idivq width
		mov %rdx, %r12

		# mod y of new head
		xor %edx, %edx
		mov %r13, %rax
		add height, %rax
		idivq height
		mov %rdx, %r13

		# check if head intersects with body
		mov listPointer, %rdi
		mov $_checkDead, %rsi
		xor %r14, %r14
		call itrLinkedlist

		# append new head

		# append new x
		mov listPointer, %rdi
		mov %r12, %rsi
		call pushLinkedlist

		# append new y
		mov listPointer, %rdi
		mov %r13, %rsi
		call pushLinkedlist

		# pop tail

		# check if eating
		cmpb $1, eating
		je _updateEat

		# pop tail x
		mov listPointer, %rdi
		mov $0, %rsi
		call removeLinkedlist

		# pop tail y
		mov listPointer, %rdi
		mov $0, %rsi
		call removeLinkedlist

		jmp _checkEating

		# dont pop tail
		_updateEat:
			incq len # increment length
			mov speedInc, %rax
			addq %rax, mps # increment moves per second

			call _calFpm # recalculate moves per frame
			jmp _checkEating

		# check if eating apple
		_checkEating:
			call getApple

			# check x
			cmp %r12, %rax
			jne _noEat

			# check y
			cmp %r13, %rdx
			jne _noEat

			movb $1, eating # set eating boolean
			call appleNewpos # generate new apple pos

			jmp _updateEnd

		_noEat:
			movb $0, eating
			jmp _updateEnd

		_updateEnd:

			# pop callee-safe registers
			movq $0, frameCount
			pop %r13
			pop %r12
			pop %rbx
			ret

_checkDead:
	push %rax

	# check if counter is even

	# divide counter by 2
	mov %r14, %rax 
	mov $2, %rcx
	xor %edx, %edx
	idiv %rcx

	# conditional jump
	cmpb $0, %dl
	je _checkX
	jmp _checkY

	# compares val with r12 (x)
	_checkX:
		pop %rbx
		jmp _checkEnd

	# check if x is same and y is same
	_checkY:

		# check x
		pop %rax
		cmp %r12, %rbx
		jne _checkEnd

		# check y
		cmp %r13, %rax
		jne _checkEnd
		jmp _amDead

	# writes dead boolean to 1
	_amDead:
		movb $1, dead
		jmp _checkEnd

	# ends function
	_checkEnd:
		inc %r14
		ret

getDead:
	xor %eax, %eax
	movb dead, %al
	ret

# writes snake to window
writeSnake:
	mov listPointer, %rdi # select snake body linkedlist
	mov $_writeCell, %rsi # select write cell function for iteration
	mov $0, %rbx # set counter to 0
	call itrLinkedlist # iterate over linkedlist
	ret

# write cell function called on each element of body;
# writes cell to window
_writeCell:
        push %rax

	# check if counter is even

	# divide counter by 2
        mov %rbx, %rax # divide the counter
        xor %rdx, %rdx # empty rdx
        mov $2, %rcx # divide by 2
        idivq %rcx

	# check if remainder is 0
        cmp $0, %rdx
        je _writex
        jmp _writey

	# save x to r12
        _writex:
		pop %r12
		jmp _writeEnd

	# save y to r13 then write to window
        _writey:
		pop %r13
                jmp _memWrite

        _memWrite:

		# write 1 on window at x, y of cell
                mov %r12, %rdi # write at x
                mov %r13, %rsi # write at y
                mov $1, %rdx # write a 1
                call writePix
                jmp _writeEnd

        _writeEnd:
                inc %rbx # increment counter
                ret

# frees body
snakeClose:

	# free linked list
	mov listPointer, %rdi
	call freeLinkedlist
	ret

# calculates the frames per move
_calFpm:
	mov mps, %rcx # set rcx (denominator) to moves per second
	imul frameDelay, %rcx # multiply denominator by length of frame
	mov $1000000, %rax # set rax (numberator) to 1000000
	xor %edx, %edx # zero out rdx
	idiv %rcx
	movq %rax, fpm # update frames per move
	ret
