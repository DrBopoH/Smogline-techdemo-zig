const std = @import("std");
const glfw = @import("zglfw");


pub const Window = *glfw.Window;


fn errorCallback(error_code: glfw.ErrorCode, description: ?[*:0]const u8) callconv(.c) void {
	std.log.err("GLFW error {d}: {?s}", .{error_code, description});
}

pub fn init() !void {
	_ = glfw.setErrorCallback(errorCallback);

	try glfw.init();
	// Опционально: форс X11 для NVIDIA/Wayland фикса
	// glfw.windowHint(.platform, .x11);
}

pub fn deinit() void { 
	glfw.terminate(); 
}


pub fn createWindow(title: [:0]const u8, width: i32, height: i32) !Window {
	// Hint для NO_API
	//glfw.windowHint(.client_api, .no_api);

	glfw.windowHint(.client_api, .opengl_api);
	glfw.windowHint(.context_version_major, 3);
	glfw.windowHint(.context_version_minor, 3);
	glfw.windowHint(.opengl_profile, .opengl_core_profile);
	// glfw.windowHint(.opengl_forward_compat, true); // если macOS

	return try glfw.createWindow(
		@as(c_int, @intCast(width)),
		@as(c_int, @intCast(height)),
		title,
		null,
	);
}

pub fn destroyWindow(window: Window) void { 
	window.destroy(); 
}

pub fn pollEvents() void { 
	glfw.pollEvents(); 
}

pub fn shouldClose(window: Window) bool { 
	return window.shouldClose(); 
}


pub fn makeContextCurrent(window: Window) void {
	glfw.makeContextCurrent(window);
}