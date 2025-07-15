const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const spice_dep = b.dependency("spice", .{});
    const spice_mod = spice_dep.module("spice");

    // Server
    const server = b.addExecutable("grpc-server", "src/server.zig");
    server.setTarget(target);
    server.setBuildMode(optimize);
    server.root_module.addImport("spice", spice_mod);
    b.installArtifact(server);

    // Client
    const client = b.addExecutable("grpc-client", "src/client.zig");
    client.setTarget(target);
    client.setBuildMode(optimize);
    client.root_module.addImport("spice", spice_mod);
    b.installArtifact(client);

    // Tests
    const tests = b.addTest("src/tests.zig");
    tests.setTarget(target);
    tests.setBuildMode(optimize);
    tests.root_module.addImport("spice", spice_mod);

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}
