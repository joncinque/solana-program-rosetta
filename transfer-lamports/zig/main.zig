const sol = @import("solana-program-sdk");

export fn entrypoint(input: [*]u8) u64 {
    const context = sol.Context.load(input) catch return 1;
    const source = context.accounts[0];
    const destination = context.accounts[1];
    source.lamports().* -= 5;
    destination.lamports().* += 5;
    return 0;
}
