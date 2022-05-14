.globl printInt

.data
format: .asciz "%ld\n\r"
#format: .asciz "%X\n\r"

.text
printInt:

        push %rdi
        push %rsi
        push %rax
        push %rcx
        push %rdx

        movq $format, %rdi
        movq %rax, %rsi
        xor %rax, %rax
        call printf

        pop %rdx
        pop %rcx
        pop %rax
        pop %rsi
        pop %rdi

	ret
