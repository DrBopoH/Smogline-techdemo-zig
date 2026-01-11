const std = @import("std");
const sokol = @import("sokol");
const sapp = sokol.app;
const sg = sokol.gfx;

// ---------------- Vertex ----------------
const Vertex = struct {
	pos: [3]f32,
	color: [3]f32,
};

const vertices: [8]Vertex = .{
	.{ .pos = .{-0.5, -0.5, -0.5}, .color = [3]f32{1,0,0} },
	.{ .pos = .{ 0.5, -0.5, -0.5}, .color = [3]f32{0,1,0} },
	.{ .pos = .{ 0.5,  0.5, -0.5}, .color = [3]f32{0,0,1} },
	.{ .pos = .{-0.5,  0.5, -0.5}, .color = [3]f32{1,1,0} },
	.{ .pos = .{-0.5, -0.5,  0.5}, .color = [3]f32{1,0,1} },
	.{ .pos = .{ 0.5, -0.5,  0.5}, .color = [3]f32{0,1,1} },
	.{ .pos = .{ 0.5,  0.5,  0.5}, .color = [3]f32{1,1,1} },
	.{ .pos = .{-0.5,  0.5,  0.5}, .color = [3]f32{0,0,0} },
};

const indices: [36]u16 = .{
	0,1,2,  2,3,0, // back
	4,5,6,  6,7,4, // front
	0,4,7,  7,3,0, // left
	1,5,6,  6,2,1, // right
	3,2,6,  6,7,3, // top
	0,1,5,  5,4,0, // bottom
};

// ---------------- Globals ----------------
var vertex_buffer: sg.Buffer = sg.Buffer{};
var index_buffer: sg.Buffer = sg.Buffer{};
var pipeline: sg.Pipeline = sg.Pipeline{};
var gfx_sc: sg.Swapchain = sg.Swapchain{};

// ---------------- Init ----------------
fn init() callconv(.c) void {
	sg.setup(.{
		.logger = .{ .func = sokol.log.func },
	});

	// Buffers
	vertex_buffer = sg.makeBuffer(.{
		.size = @sizeOf(@TypeOf(vertices)),
		.usage = .{ 
			.vertex_buffer = true 
		},
		.data = sg.Range{
			.ptr = &vertices,
			.size = @sizeOf(@TypeOf(vertices)),
		},
	});

	index_buffer = sg.makeBuffer(.{
		.size = @sizeOf(@TypeOf(indices)),
		.usage = .{ 
			.index_buffer = true 
		},
		.data = sg.Range{
			.ptr = &indices,
			.size = @sizeOf(@TypeOf(indices)),
		},
	});


	// Shader
	const shader = sg.makeShader(.{ 
		.vertex_func = sg.ShaderFunction{ 
			.source = "#version 450\nlayout(location=0) in vec3 pos;\nlayout(location=1) in vec3 color;\nlayout(location=0) out vec3 frag_color;\nvoid main() {\n\tgl_Position = vec4(pos,1.0);\n\tfrag_color = color;\n}",	
		}, 
		.fragment_func = sg.ShaderFunction{ 
			.source = "#version 450\nlayout(location=0) in vec3 frag_color;\nlayout(location=0) out vec4 out_color;\nvoid main() {\n\tout_color = vec4(frag_color,1.0);\n}",
		}, 
		.attrs = [_]sg.ShaderVertexAttr{
			.{ .glsl_name = "pos", .base_type = .FLOAT },
			.{ .glsl_name = "color", .base_type = .FLOAT },
			.{}, 
			.{}, 
			.{}, 
			.{}, 
			.{}, 
			.{}, 
			.{}, 
			.{}, 
			.{}, 
			.{}, 
			.{}, 
			.{}, 
			.{}, 
			.{}, 
		},
	});

	pipeline = sg.makePipeline(.{
		.shader = shader,
		.layout = sg.VertexLayoutState{
			.buffers = [_]sg.VertexBufferLayoutState{
				.{ .stride = @sizeOf(Vertex) },
				.{}, 
				.{}, 
				.{}, 
				.{}, 
				.{}, 
				.{}, 
				.{},
			},
			.attrs = [_]sg.VertexAttrState{
				.{ .buffer_index = 0, .offset = 0, .format = .FLOAT3 },
				.{ .buffer_index = 0, .offset = @sizeOf([3]f32), .format = .FLOAT3 },
				.{}, 
				.{}, 
				.{}, 
				.{}, 
				.{},
				.{}, 
				.{}, 
				.{}, 
				.{}, 
				.{}, 
				.{}, 
				.{}, 
				.{}, 
				.{},
			},
		},
		.index_type = .UINT16,
	});

	const app_sc = sapp.getSwapchain();
	gfx_sc = sg.Swapchain{
		.width = app_sc.width,
		.height = app_sc.height,
		.sample_count = app_sc.sample_count,
		.color_format = sg.PixelFormat.DEFAULT,
		.depth_format = sg.PixelFormat.DEFAULT,
		.vulkan = sg.VulkanSwapchain{},
	};
}

fn frame() callconv(.c) void {
	const CLEAR_COLOR: sg.ColorAttachmentAction = .{
		.load_action = .CLEAR,
		.clear_value = .{ .r=0.1, .g=0.12, .b=0.15, .a=1.0 },
	};

	sg.beginPass(.{
		.swapchain = gfx_sc,
		.action = .{
			.colors = [_]sg.ColorAttachmentAction{CLEAR_COLOR} ** 8,
		},
	});


	const bind = sg.Bindings{
		.vertex_buffers = [_]sg.Buffer{
			vertex_buffer,
			sg.Buffer{}, 
			sg.Buffer{}, 
			sg.Buffer{},
			sg.Buffer{}, 
			sg.Buffer{}, 
			sg.Buffer{},
			sg.Buffer{},
		},
		.index_buffer = index_buffer,
	};

	sg.applyPipeline(pipeline);
	sg.applyBindings(bind);	
	sg.draw(0, 36, 1);


	sg.endPass();
	sg.commit();
}

fn cleanup() callconv(.c) void {
	sg.shutdown();
}

fn event(ev: [*c]const sapp.Event) callconv(.c) void {
	if (ev.*.type == sapp.EventType.QUIT_REQUESTED) {
		sapp.quit();
	}
}

pub fn main() void {
	sapp.run(.{
		.init_cb = init,
		.frame_cb = frame,
		.cleanup_cb = cleanup,
		.event_cb = event,
		.width = 1280,
		.height = 720,
		.window_title = "sokol + zig 0.16 (Vulkan Cube)",
		.logger = .{ .func = sokol.log.func },
	});
}
