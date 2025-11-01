const std = @import("std");
const solana = @import("solana_program_sdk");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(solana.sbf_target);
    const optimize = .ReleaseFast;
    const program = b.addLibrary(.{
        .name = "solana_program_rosetta_pubkey",
        .linkage = .dynamic,
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .optimize = optimize,
            .target = target,
        })
    });
    _ = solana.buildProgram(b, program, target, optimize);
    b.installArtifact(program);
}
