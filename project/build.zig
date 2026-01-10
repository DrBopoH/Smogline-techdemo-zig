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
		}),
	});


	const zglfw = b.dependency("zglfw", .{.target = target,	.optimize = optimize,});
	//exe.root_module.addCFlags(&[_][]const u8{"-DGLFW_INCLUDE_VULKAN"});

	exe.root_module.addImport("zglfw", zglfw.module("root"));
	exe.root_module.linkLibrary(zglfw.artifact("glfw"));
	exe.root_module.linkSystemLibrary("vulkan", .{});
	
	const sokol = b.dependency("sokol", .{ .target = target, .optimize = optimize });
	const cgltf = b.dependency("cgltf", .{ .target = target, .optimize = optimize });
	const cimgui = b.dependency("cimgui", .{ .target = target, .optimize = optimize });

	exe.root_module.addIncludePath(sokol.path(""));
	exe.root_module.addIncludePath(cgltf.path(""));
	exe.root_module.addIncludePath(cimgui.path("cimgui"));

	//exe.root_module.addCFlags(&[_][]const u8{"-DSOKOL_VULKAN", "-DSOKOL_NO_ENTRY",});
	//exe.root_module.addCxxFlags(&[_][]const u8{"-DSOKOL_VULKAN", "-DSOKOL_NO_ENTRY",});

	b.installArtifact(exe);



	const run_cmd = b.addRunArtifact(exe);
	run_cmd.step.dependOn(b.getInstallStep());

	if (b.args) |args| {
		run_cmd.addArgs(args);
	}

	const run_step = b.step("run", "Run the app");
	run_step.dependOn(&run_cmd.step);
}