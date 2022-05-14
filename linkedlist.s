.globl makeLinkedlist
.globl freeLinkedlist
.globl pushLinkedlist
.globl atLinkedlist
.globl insertLinkedlist
.globl removeLinkedlist
.globl printLinkedlist
.globl itrLinkedlist
.globl clearLinkedlist

.text

# makeLinkedlist()
# returns pointer
makeLinkedlist:
	movq $16, %rdi
	call malloc
	addq $8, %rax
	movq $0, (%rax)
	subq $8, %rax
	ret

# pushLinkedlist(ptr, val)
pushLinkedlist:
	push %rbx
	push %rsi
	jmp _goToEnd

	# goes to end of linked list
	_goToEnd:

		movq %rdi, %rbx
		addq $8, %rbx
		cmp $0, (%rbx)
		je _pushEnd

		movq (%rbx), %rdi
		jmp _goToEnd

	_pushEnd:
		# replace dummy element
		# with new value
		pop %rsi
		movq %rsi, (%rdi)

		# make new dummy element
		movq %rdi, %rbx
		addq $8, %rbx
		movq $16, %rdi
		call malloc

		movq %rax, (%rbx)
		addq $8, %rax
		movq $0, (%rax)

		pop %rbx
		ret

# insertLinkedlist(ptr, index, val)
insertLinkedlist:
	push %rbx
	push %rax
	call _goToIndex

	# make new element
	movq %rdi, %rbx
	movq $16, %rdi
	call malloc

	movq (%rbx), %rcx
	movq %rcx, (%rax)
	addq $8, %rbx
	addq $8, %rax
	movq (%rbx), %rcx
	movq %rcx, (%rax)
	subq $8, %rax

	# set this element to inserted element
	movq %rax, (%rbx)
	subq $8, %rbx
	pop %rcx
	movq %rcx, (%rbx)

	pop %rbx
	ret
	

# atLinkedlist(ptr, index)
# returns val
atLinkedlist:
	call _goToIndex
	movq (%rdi), %rax
	ret

# removeLinkedlist(ptr, index)
removeLinkedlist:
	push %rbx

	# go to index
	call _goToIndex
	pushq (%rdi)
	movq %rdi, %rbx
	addq $8, %rbx
	movq (%rbx), %rbx

	# replace this element with
	# values from next element
	movq (%rbx), %rcx
	movq %rcx, (%rdi)
	addq $8, %rdi
	addq $8, %rbx
	movq (%rbx), %rcx
	movq %rcx, (%rdi)

	# free the element
	subq $8, %rbx
	movq %rbx, %rdi
	call free

	pop %rax
	pop %rbx
	ret

# freeLinkedlist(ptr)
freeLinkedlist:
	push %rbx
	jmp _freeLoop

	_freeLoop:

		# free each element
		movq %rdi, %rax
		addq $8, %rax
		movq (%rax), %rbx
		call free

		# check if there are more elements
		cmp $0, %rbx
		je _freeEnd
		movq %rbx, %rdi
		jmp _freeLoop

	_freeEnd:
		pop %rbx
		ret

# printLinkedlist(ptr)
printLinkedlist:
        push %rbx
        jmp _printLoop

        _printLoop:

                # check if this is dummy element
                movq %rdi, %rbx
                addq $8, %rbx
                movq (%rbx), %rbx

                cmp $0, %rbx
                je _printEnd

                # print value
                movq (%rdi), %rax
                call printInt

                # jump to next element
                movq %rbx, %rdi

                jmp _printLoop

        _printEnd:
                pop %rbx
                ret

# itrLinkedlist(*linkedlist, *function)
# runs function on each value in linked list
# value is in rax
itrLinkedlist:
	push %rbx
	jmp _itrLoop

	_itrLoop:

		# check if ptr is 0
		mov %rdi, %rbx
		add $8, %rbx
		mov (%rbx), %rbx
		cmp $0, %rbx
		je _itrEnd

		# run function with val in rax
		mov (%rdi), %rax
		pop %rbx
		push %rdi
		push %rsi
		call *%rsi
		pop %rsi
		pop %rdi
		push %rbx

		# jump to next element
		mov %rdi, %rbx
		add $8, %rbx
		mov (%rbx), %rdi
		jmp _itrLoop

	_itrEnd:
		pop %rbx
		ret

# clearLinkedlist(*ptr)
clearLinkedlist:
	push %rbx
	push %rdi

	# check if pointer is null

	# get pointer
	mov %rdi, %rbx
	add $8, %rbx
	mov (%rbx), %rbx

	# check pointer
	cmp $0, %rbx
	je _clearEnd

	# free other segments
	mov %rbx, %rdi
	call freeLinkedlist
	jmp _clearEnd

	_clearEnd:

		# set val and ptr to 0
		pop %rdi
		movq $0, (%rdi)
		add $8, %rdi
		movq $0, (%rdi)

		pop %rbx
		ret

_goToIndex:
	push %rbx
	movq %rsi, %rbx
	jmp _goToIndexLoop

	_goToIndexLoop:

		# check if rbx is 0
		cmp $0, %rbx
		je _goToIndexRet
		decq %rbx

		# jump to next element
		movq %rdi, %rax
		addq $8, %rax
		movq (%rax), %rdi
		
		jmp _goToIndexLoop

	_goToIndexRet:
		pop %rbx
		ret
