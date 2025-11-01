const std = @import("std");
const PublicKey = @import("solana_program_sdk").public_key.PublicKey;

export fn entrypoint(input: [*]u8) u64 {
    const id: *align(1) PublicKey = @ptrCast(input + 16);
    const owner_id: *align(1) PublicKey = @ptrCast(input + 16 + 32);
    if (id.equals(owner_id.*)) {
        return 0;
    } else {
        return 1;
    }
}
