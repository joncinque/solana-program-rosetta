const std = @import("std");
const sol = @import("solana-program-sdk");

export fn entrypoint(input: [*]u8) u64 {
    const context = sol.Context.load(input) catch return 1;
    const source = context.accounts[0];
    const destination = context.accounts[1];
    const transfer_amount = std.mem.bytesToValue(u64, context.data[0..@sizeOf(u64)]);
    source.lamports().* -= transfer_amount;
    destination.lamports().* += transfer_amount;
    return 0;
}
