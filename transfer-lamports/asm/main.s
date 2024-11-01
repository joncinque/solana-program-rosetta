	.globl	entrypoint
entrypoint:
	ldxdw r2, [r1 + 0] # get number of accounts
	jne r2, 2, error # error if not 2 accounts

	ldxb r2, [r1 + 8] # get first account
	# can check this, but isn't necessary
	# jne r2, 0xff, error
	ldxdw r2, [r1 + 8 + 8 + 32 + 32] # get source lamports
	ldxdw r3, [r1 + 8 + 8 + 32 + 32 + 8] # get account data size
	mov64 r4, r1
	add64 r4, 8 + 8 + 32 + 32 + 8 + 8 + 10240 + 8 # calculate end of account data
	add64 r4, r3
	mov64 r5, r4 # check how much padding we need to add
	and64 r5, -8 # clear low bits
	jeq r5, r4, 1 # no low bits set, jump ahead
	add64 r4, 8 # add 8 for truncation if needed
	and64 r4, -8 # clear low bits

	ldxb r5, [r4 + 0] # get second account
	jne r5, 0xff, error # we don't allow duplicates
	ldxdw r5, [r4 + 8 + 32 + 32] # get destination lamports
	ldxdw r6, [r4 + 8 + 32 + 32 + 8] # get account data size
	mov64 r7, r4
	add64 r7, 8 + 32 + 32 + 8 + 8 + 10240 + 8 # calculate end of account data
	add64 r7, r6
	mov64 r8, r7 # check how much padding we need to add
	and64 r8, -8 # clear low bits
	jeq r8, r7, 1 # no low bits set, jump ahead
	add64 r7, 8 # add 8 for truncation if low bits are set
	ldxdw r8, [r7 + 0] # get instruction data size
	jne r8, 0x08, error # need 8 bytes of instruction data
	ldxdw r8, [r7 + 8] # get instruction data as little-endian u64

	sub64 r2, r8 # subtract lamports
	add64 r5, r8 # add lamports
	stxdw [r1 + 8 + 8 + 32 + 32], r2 # write the new values back
	stxdw [r4 + 8 + 32 + 32], r5
	exit
error:
	mov64 r0, 1
	exit
