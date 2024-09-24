.globl entrypoint
entrypoint:
	lddw r1, .message
	mov64 r2, 12
	call sol_log_
	exit
.rodata 
	message: .ascii "Hello world!"
