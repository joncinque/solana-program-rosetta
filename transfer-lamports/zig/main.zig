const sol = @import("solana-program-sdk");

export fn entrypoint(input: [*]u8) u64 {
    const context = sol.Context.load(input) catch return 1;
    const accounts = context.loadRawAccounts(sol.allocator) catch return 1;
    defer accounts.deinit();

    const source = accounts.items[0];
    const destination = accounts.items[1];
    source.lamports().* -= 5;
    destination.lamports().* += 5;

    return 0;
}
