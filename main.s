.globl main

.data
deathMsg: .asciz "You died!\n\rPress enter to restart, or press escape to leave\n\r"

.text
main:
	call init
	jmp _tickLoop

	_tickLoop:


		# mark start
		sub $16, %rsp
		mov %rsp, %rdi
		xor %rsi, %rsi
		call gettimeofday

		# write snake to screen
		call windowClear
		call writeApple
		call writeSnake
		call windowShow

		# update snake
		call updateSnake

		# check if snake is dead
		call getDead
		cmp $1, %al
		je deathScreen

		# stabilize framerate
		jmp _sleep

		_sleep:

			# get end time
			sub $16, %rsp
			mov %rsp, %rdi
			xor %rsi, %rsi
			call gettimeofday
			popq %rcx # end sec
			popq %rdx # end usec
			popq %rax # start sec
			popq %rbx # start usec

			# get time diff from start to end
			sub %rax, %rcx
			sub %rbx, %rdx
			imul $1000000, %rcx
			add %rcx, %rdx

			# sleep for 16666us-diff
			mov frameDelay, %rax
			sub %rdx, %rax
			cmp $0, %rax
			jle _tickLoop
			#jle _end

			imul $1000, %rax
			push %rax
			pushq $0
			mov %rsp, %rdi
			xor %rsi, %rsi
			call nanosleep

			add $16, %rsp
			jmp _tickLoop
			#jmp _end

deathScreen:

	# print death message
	mov $deathMsg, %rdi
	xor %rsi, %rsi
	xor %rax, %rax
	call printf

	jmp _waitLoop

	# wait until action has been taken
	_waitLoop:
		push $0
		call getch
		add $8, %rsp
		cmp $-1, %al
		je _waitLoop

		cmp $10, %al
		je _restart

		cmp $27, %al
		je _end
		jmp _waitLoop

	_restart:
		add $16, %rsp
		call snakeRestart
		call appleNewpos
		jmp _tickLoop

	_end:
		add $16, %rsp
		call close
		ret
