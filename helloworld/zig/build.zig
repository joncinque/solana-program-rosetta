const std = @import("std");
const solana = @import("solana-program-sdk");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(solana.sbf_target);
    const optimize = .ReleaseFast;
    const program = b.addSharedLibrary(.{
        .name = "solana_program_rosetta_helloworld",
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });
    _ = solana.buildProgram(b, program, target, optimize);
    b.installArtifact(program);
}
