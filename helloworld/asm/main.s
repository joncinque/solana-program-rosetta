.globl entrypoint
entrypoint:
	lddw r1, .message
	mov64 r2, 12
	call sol_log_
	exit
.extern sol_log_
.rodata 
	message: .ascii "Hello world!"
