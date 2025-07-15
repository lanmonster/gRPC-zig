const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const spice_dep = b.dependency("spice", .{});
    const spice_mod = spice_dep.module("spice");

    const server = b.addExecutable(.{
        .name = "grpc-server",
        .root_src = b.path("src/server.zig"), // ✅ works for your Zig version
        .target = target,
        .optimize = optimize,
    });
    server.root_module.addImport("spice", spice_mod);
    b.installArtifact(server);

    const client = b.addExecutable(.{
        .name = "grpc-client",
        .root_src = b.path("src/client.zig"),
        .target = target,
        .optimize = optimize,
    });
    client.root_module.addImport("spice", spice_mod);
    b.installArtifact(client);

    const tests = b.addTest(.{
        .root_src = b.path("src/tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    tests.root_module.addImport("spice", spice_mod);

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}
