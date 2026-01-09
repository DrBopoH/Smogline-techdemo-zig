const std = @import("std");
const glfw = @import("zglfw");

const platform = @import("platform/glfw.zig");

pub fn main() !void {
	try platform.init();
	defer platform.deinit();

	const window = try platform.createWindow(
		1280,
		720,
		"Zig Smogline Tech Demo",
	);
	defer platform.destroyWindow(window);

	glfw.makeContextCurrent(window);

	while (!platform.shouldClose(window)) {
		platform.pollEvents();

		// TODO: update()
		// TODO: render()
		window.swapBuffers();
	}
}