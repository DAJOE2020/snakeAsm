.globl init
.globl close

.globl width
.globl height
.globl frameDelay

.data
#width: .quad 166
#height: .quad 42

width: .quad 83
height: .quad 42

#width: .quad 611
#width: .quad 305

#width: .quad 305
#height: .quad 118

#width: .quad 10
#height: .quad 7

frameDelay: .quad 16666

.text
init:

	# ncurses init
	call initscr
	mov stdscr, %rdi
	mov $1, %rsi
	call nodelay

	# set random seed
	xor %edi, %edi
	call time
	mov %rax, %rdi
	call srand

	call snakeInit
	call appleInit
	call windowInit
	ret
close:
	call windowClose
	call snakeClose
	call endwin
	ret
