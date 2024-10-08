const std = @import("std");
const solana = @import("solana-program-sdk");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(solana.sbf_target);
    const optimize = .ReleaseFast;

    const dep_opts = .{ .target = target, .optimize = optimize };

    const solana_lib_dep = b.dependency("solana-program-library", dep_opts);
    const solana_lib_mod = solana_lib_dep.module("solana-program-library");

    const program = b.addSharedLibrary(.{
        .name = "solana_program_rosetta_cpi",
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });

    program.root_module.addImport("solana-program-library", solana_lib_mod);

    _ = solana.buildProgram(b, program, target, optimize);

    b.installArtifact(program);
}
