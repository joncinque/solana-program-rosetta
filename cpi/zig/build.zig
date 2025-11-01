const std = @import("std");
const solana = @import("solana_program_sdk");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(solana.sbf_target);
    const optimize = .ReleaseFast;
    const dep_opts = .{ .target = target, .optimize = optimize };

    const solana_lib_dep = b.dependency("solana_program_library", dep_opts);
    const solana_lib_mod = solana_lib_dep.module("solana_program_library");

    const program = b.addLibrary(.{
        .name = "solana_program_rosetta_cpi",
        .linkage = .dynamic,
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .optimize = optimize,
            .target = target,
        })
    });

    program.root_module.addImport("solana_program_library", solana_lib_mod);

    _ = solana.buildProgram(b, program, target, optimize);

    b.installArtifact(program);
}
