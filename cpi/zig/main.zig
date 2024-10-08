const sol = @import("solana-program-sdk");
const sol_lib = @import("solana-program-library");

const system_ix = sol_lib.system;
const SIZE = 42;

export fn entrypoint(input: [*]u8) u64 {
    const context = sol.Context.load(input) catch return 1;
    const accounts = context.loadRawAccounts(sol.allocator) catch return 1;
    defer accounts.deinit();

    const allocated = accounts.items[0];

    const expected_allocated_key = sol.PublicKey.createProgramAddress(
        &.{ "You pass butter", &.{context.data[0]} },
        context.program_id.*,
    ) catch return 1;

    // allocated key does not match the derived address
    if (!allocated.id().equals(expected_allocated_key)) return 1;

    // Invoke the system program to allocate account data
    system_ix.allocate(
        sol.allocator,
        allocated.info(),
        SIZE,
        .{ .seeds = &.{&.{ "You pass butter", &.{context.data[0]} }} },
    ) catch return 1;

    return 0;
}
