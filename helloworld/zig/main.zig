const sol = @import("solana-program-sdk");

export fn entrypoint(_: [*]u8) u64 {
    sol.log("Hello world!");
    return 0;
}
