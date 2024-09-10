	.text
	.globl	entrypoint
entrypoint:
	lddw r1, .message
	mov64 r2, 12
	call sol_log_
	exit
	.section	.rodata
.message:
	.asciz	"Hello world!"
