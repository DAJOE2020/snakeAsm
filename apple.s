.globl appleInit
.globl appleNewpos
.globl writeApple
.globl getApple

.data
x: .quad 0
y: .quad 0

.text
appleInit:
	call appleNewpos # init pos for apple
	ret

getApple:
	mov x, %rax
	mov y, %rdx
	ret

writeApple:
	mov x, %rdi
	mov y, %rsi
	mov $2, %rdx
	call writePix
	ret

# generate new random pos
appleNewpos:

	# generate random y
	call rand
	xor %edx, %edx
	idivq width
	mov %rdx, x

	# generate random y
	call rand
	xor %edx, %edx
	idivq height
	mov %rdx, y

	ret
