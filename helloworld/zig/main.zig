const sol = @import("solana_program_sdk");

export fn entrypoint(_: [*]u8) u64 {
    sol.log("Hello world!");
    return 0;
}
