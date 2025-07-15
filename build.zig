const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const spice_dep = b.dependency("spice", .{});
    const spice_mod = spice_dep.module("spice"); // Or another path like "src" if needed

    // Server executable
    const server = b.addExecutable(.{
        .name = "grpc-server",
        .root_source_file = b.path("src/server.zig"), // ✅ use root_module_file
        .target = target,
        .optimize = optimize,
    });
    server.root_module.addImport("spice", spice_mod); // ✅ use root_module.addImport()
    b.installArtifact(server);

    // Client executable
    const client = b.addExecutable(.{
        .name = "grpc-client",
        .root_module_file = b.path("src/client.zig"),
        .target = target,
        .optimize = optimize,
    });
    client.root_module.addImport("spice", spice_mod);
    b.installArtifact(client);

    // Tests
    const tests = b.addTest(.{
        .root_module_file = b.path("src/tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    tests.root_module.addImport("spice", spice_mod);

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}
