	.globl	entrypoint
entrypoint:
	ldxdw r2, [r1 + 0] # get number of accounts
	jne r2, 2, error # error if not 2 accounts
	ldxb r2, [r1 + 8] # get first account
	jne r2, 0xff, error # shouldn't be a duplicate, but check
	ldxdw r2, [r1 + 8 + 8 + 32 + 32] # get source lamports
	ldxdw r3, [r1 + 8 + 8 + 32 + 32 + 8] # get account data size
	mov64 r4, r1
	add64 r4, 8 + 8 + 32 + 32 + 8 + 8 + 10240 + 8 # calculate end of account data
	add64 r4, r3
	mov64 r5, r4 # check how much padding we need to add
	and64 r5, 7 # clear high bits
	jeq r5, 0, 1 # no low bits set, jump ahead
	add64 r4, 8 # add 8 for truncation if needed
	and64 r4, -8 # clear low bits
	ldxb r5, [r4 + 0] # get second account
	jne r5, 0xff, error # we don't allow duplicates
	ldxdw r5, [r4 + 8 + 32 + 32] # get destination lamports
	sub64 r2, 5 # subtract lamports
	add64 r5, 5 # add lamports
	stxdw [r1 + 8 + 8 + 32 + 32], r2 # write the new values back
	stxdw [r4 + 8 + 32 + 32], r5
	exit
error:
	mov64 r0, 1
	exit
