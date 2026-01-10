const std = @import("std");
const surface = @import("surface/glfw.zig");

pub fn main() !void {
	try surface.init();
	defer surface.deinit();

	const window = try surface.createWindow("Zig Smogline Tech Demo", 1280, 720);
	defer surface.destroyWindow(window);
	
	surface.makeContextCurrent(window);

	while (!surface.shouldClose(window)) {
		surface.pollEvents();

		// TODO: update()
		// TODO: render()

		window.swapBuffers();
	}
}