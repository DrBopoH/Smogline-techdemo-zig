const std = @import("std");

pub fn build(b: *std.Build) void {
	const target = b.standardTargetOptions(.{});
	const optimize = b.standardOptimizeOption(.{});

	const exe = b.addExecutable(.{
		.name = "Smogline_techdemo_zig",
		.root_module = b.createModule(.{
			.root_source_file = b.path("src/main.zig"),
			.target = target,
			.optimize = optimize,
			//.link_libc = true,
		}),
	});
	
	const sokol_dep = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
        // .gl = true,              // ← форсировать GL на всех платформах (если нужно)
        // .vulkan = true,          // ← экспериментально, только Linux
        // .with_sokol_imgui = true, // ← если хочешь ImGui (см. ниже)
    });
	exe.root_module.addImport("sokol", sokol_dep.module("sokol"));
	// Если нужен ImGui через sokol (опционально)
    // exe.root_module.addImport("sokol_imgui", sokol_dep.module("imgui"));


	const cgltf = b.dependency("cgltf", .{ .target = target, .optimize = optimize });
	exe.root_module.addIncludePath(cgltf.path(""));

	b.installArtifact(exe);



	const run_cmd = b.addRunArtifact(exe);
	run_cmd.step.dependOn(b.getInstallStep());

	if (b.args) |args| {
		run_cmd.addArgs(args);
	}

	const run_step = b.step("run", "Run the app");
	run_step.dependOn(&run_cmd.step);
}