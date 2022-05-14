.globl windowInit
.globl windowShow
.globl windowClose
.globl writePix
.globl windowClear

.data

mapPointer: .quad 0
mapLength: .quad 0

snakeChar: .asciz "@ "
appleChar: .asciz "A "
offChar: .asciz "  "
endl: .asciz "\n\r"

clearCount: .word 100

.text

windowInit:
	push %rbx

	# gets bitmap length
	mov width, %rbx
	imul height, %rbx
	movq %rbx, mapLength

	# allocates bitmap memory
	mov mapLength,%rdi
	call malloc
	movq %rax, mapPointer

	mov $0, %ebx
	jmp _initMem

	# writes 0 to bitmap
	_initMem:

		cmp mapLength, %rbx
		je _initEnd

		mov mapPointer, %rcx
		add %rbx, %rcx
		movb $0, (%rcx)

		inc %rbx
		jmp _initMem

	_initEnd:
		pop %rbx
		ret
		
windowClose:
	mov mapPointer, %rdi
	call free
	ret

windowShow:
	push %rbx
	mov $0, %bx
	jmp _clearTerm

	_clearTerm:

		# check if counter is at clear count
		cmp clearCount, %bx
		je _writeStart

		# print endl
		mov $endl, %rdi
		xor %esi, %esi
		xor %eax, %eax
		call printf

		inc %bx
		jmp _clearTerm

	_writeStart:
		xor %rbx, %rbx
		jmp _writePix

	# writes pixel to screen
	_writePix:

		# check byte
		mov mapPointer, %rcx
		add %rbx, %rcx
		movb (%rcx), %al

		cmp $1, %al
		je _writeSnake
		cmp $2, %al
		je _writeApple
		jmp _writeOff

		_writeSnake:
			mov $snakeChar, %rdi
			xor %rsi, %rsi
			xor %rax, %rax
			call printf
			jmp _writeEndl
		_writeApple:
			mov $appleChar, %rdi
			xor %rsi, %rsi
			xor %rax, %rax
			call printf
			jmp _writeEndl
		_writeOff:
			mov $offChar, %rdi
			xor %rsi, %rsi
			xor %rax, %rax
			call printf
			jmp _writeEndl

	# writes endline to screen
	_writeEndl:

		# check if counter is at end of line
		xor %rdx, %rdx
		mov %rbx, %rax
		idivq width

		mov width, %rcx
		dec %rcx

		# if so write endline of not dont
		cmp %rcx, %rdx
		je _showEndl
		jmp _checkEnd

		# writes endline
		_showEndl:
			mov $endl, %rdi
			xor %rsi, %rsi
			xor %rax, %rax
			call printf
			jmp _checkEnd

	# checks if loop should close
	_checkEnd:
		inc %rbx
		cmp mapLength, %rbx
		jl _writePix

		pop %rbx
		ret

# writePix(x, y, val)
# writes pixel to bitmap
writePix:
	push %rdx

	# gets index of pixel
	mov $0, %rcx
	mov %rsi, %rcx
	imul width, %rcx
	add %rdi, %rcx

	# writes pixel
	pop %rdx
	add mapPointer, %rcx
	movb %dl, (%rcx)

	ret

windowClear:
	mov $0, %rax
	jmp _clearLoop

	_clearLoop:

		cmp mapLength, %rax
		je _clearEnd

		# write pix
		mov %rax, %rcx
		add mapPointer, %rcx
		movb $0, (%rcx)

		inc %rax
		jmp _clearLoop

	_clearEnd:
		ret
