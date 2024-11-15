const std = @import("std");
const PublicKey = @import("solana-program-sdk").PublicKey;

pub const Mint = packed struct {
    pub const len = 82;

    mint_authority: COption(PublicKey),
    supply: u64,
    decimals: u8,
    is_initialized: u8,
    freeze_authority: COption(PublicKey),
};

pub const Account = packed struct {
    pub const len = 165;

    pub const State = enum(u8) {
        uninitialized,
        initialized,
        frozen,
    };

    mint: PublicKey,
    owner: PublicKey,
    amount: u64,
    delegate: COption(PublicKey),
    state: Account.State,
    is_native: COption(u64),
    delegated_amount: u64,
    close_authority: COption(PublicKey),

    pub fn isNative(self: Account) bool {
        return self.is_native.is_some != 0;
    }
};

pub fn COption(T: type) type {
    return packed struct {
        is_some: u32,
        value: T,
        const Self = @This();
        pub fn fromOptional(v: ?T) Self {
            if (v) |value| {
                return Self.fromValue(value);
            } else {
                return Self.asNull();
            }
        }
        pub fn fromValue(value: T) Self {
            return Self{
                .is_some = 1,
                .value = value,
            };
        }
        pub fn asNull() Self {
            return Self{
                .is_some = 0,
                .value = std.mem.zeroes(T),
            };
        }
        pub fn asOptional(self: *const Self) ?T {
            if (self.is_some == 0) {
                return null;
            } else {
                return self.value;
            }
        }
    };
}

pub const Multisig = packed struct {
    pub const len = 355;
};

test "Mint: bitCast" {
    const mint = Mint{
        .authority = COption(PublicKey).fromOptional(std.mem.bytesToValue(PublicKey, &[_]u8{1} ** 32)),
        .supply = 42,
        .decimals = 7,
        .is_initialized = 1,
        .freeze_authority = COption(PublicKey).fromOptional(std.mem.bytesToValue(PublicKey, &[_]u8{2} ** 32)),
    };
    const mint_buffer = [_]u8{
        1, 0, 0, 0, 1, 1, 1,  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 42, 0, 0, 0, 0, 0, 0, 0, 7, 1, 1, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2,  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    };
    try std.testing.expectEqualSlices(u8, &mint_buffer, std.mem.asBytes(&mint)[0..82]);
    const cast_mint: Mint = @bitCast(mint_buffer);
    try std.testing.expectEqual(cast_mint, mint);
}

test "Mint: cast with padding" {
    const mint = Mint{
        .authority = COption(PublicKey).new(std.mem.bytesToValue(PublicKey, &[_]u8{1} ** 32)),
        .supply = 42,
        .decimals = 7,
        .is_initialized = 1,
        .freeze_authority = COption(PublicKey).new(std.mem.bytesToValue(PublicKey, &[_]u8{2} ** 32)),
    };
    const mint_buffer = [_]u8{
        0, 1, 0, 0, 0, 1, 1,  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 42, 0, 0, 0, 0, 0, 0, 0, 7, 1, 1, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2,  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    };
    try std.testing.expectEqualSlices(u8, mint_buffer[1..], std.mem.asBytes(&mint)[0..82]);
    const cast_mint: *const Mint = @alignCast(@ptrCast(mint_buffer[1..]));
    // can't test the whole thing because of post padding in struct
    try std.testing.expectEqual(cast_mint.authority, mint.authority);
}

test "COption: pubkey" {
    const COptionKey = COption(PublicKey);
    const none_key = COptionKey.new(null);
    try std.testing.expectEqual(none_key.asOptional(), null);
    const some_key = COptionKey.new(1);
    try std.testing.expectEqual(some_key.asOptional(), 1);
}
