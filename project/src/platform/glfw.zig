const std = @import("std");
const glfw = @import("zglfw");  // ← импорт zglfw (не меняй)

pub const Window = *glfw.Window;  // ← теперь pointer to opaque!

fn errorCallback(error_code: glfw.ErrorCode, description: ?[*:0]const u8) callconv(.c) void {
	std.log.err("GLFW error {d}: {?s}", .{error_code, description});
}

pub fn init() !void {
	// Устанавливаем callback (игнорируем старый return)
	_ = glfw.setErrorCallback(errorCallback);

	// Инициализация
	try glfw.init();

	// Опционально: форс X11 для NVIDIA/Wayland фикса
	// glfw.windowHint(.platform, .x11);
}

pub fn deinit() void {
	glfw.terminate();
}

pub fn createWindow(
	width: i32,
	height: i32,
	title: [:0]const u8,
) !Window {  // ← !*Window (pointer!)
	// Hint для NO_API
	//glfw.windowHint(.client_api, .no_api);

	glfw.windowHint(.client_api, .opengl_api);
	glfw.windowHint(.context_version_major, 3);
	glfw.windowHint(.context_version_minor, 3);
	glfw.windowHint(.opengl_profile, .opengl_core_profile);
	// glfw.windowHint(.opengl_forward_compat, true); // если macOS

	return try glfw.createWindow(
		@as(c_int, @intCast(width)),   // каст i32 → c_int
		@as(c_int, @intCast(height)),
		title,
		null,  // monitor
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