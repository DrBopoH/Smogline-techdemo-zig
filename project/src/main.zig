const std = @import("std");
const sokol = @import("sokol");
const sapp = sokol.app;
const sg = sokol.gfx;



const Vertex = struct {
	pos: [3]f32,
	color: [3]f32,
};

const Uniforms = struct {
	model: [16]f32 align(16),
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

var rotation: f32 = 0.0;

var u: Uniforms = .{ .model = [_]f32{0} ** 16 };





var vertex_buffer: sg.Buffer = sg.Buffer{};
var index_buffer: sg.Buffer = sg.Buffer{};
var pipeline: sg.Pipeline = sg.Pipeline{};
var gfx_sc: sg.Swapchain = sg.Swapchain{};



var Page_Allocator: std.mem.Allocator = std.heap.page_allocator;

const env: std.process.Environ = .{
	.block = &.{},
};

fn readFileAll(allocator: *std.mem.Allocator, io: std.Io, file: std.Io.File) ![]u8 {
	var buffer: [4096]u8 = undefined;
	var content = try allocator.alloc(u8, 0);
	var offset: u64 = 0;

	while (true) {
		const size = try std.Io.File.readPositionalAll(file, io, &buffer, offset);
		if (size == 0) break;
		const old_len = content.len;
		content = try allocator.realloc(content, old_len + size);
		
		var i: usize = 0;
		while (i < size) : (i += 1) {
			content[old_len + i] = buffer[i];
		}
		
		offset += size;
	}

	return content;
}


pub fn readFileAlloc(allocator: *std.mem.Allocator, path: []const u8,) ![]u8 {
	var t = std.Io.Threaded.init(allocator.*, .{ .environ = env });
	const io = std.Io.Threaded.io(&t);
	const dir = std.Io.Dir.cwd();

	const file = try dir.openFile(io, path, .{ .mode = .read_only });
	defer file.close(io);

	return try readFileAll(allocator, io, file);
}

fn readFileAllocOrPanic(allocator: *std.mem.Allocator, path: []const u8) []u8 {
	return readFileAlloc(allocator, path) catch |err| {
		std.debug.print("Failed to read file {s}: {s}\n", .{path, @typeName(@TypeOf(err))});
		@panic("Failed to read file");
	};
}

fn makeShader() sg.Shader {
    const vert_src = readFileAllocOrPanic(&Page_Allocator, "vertex.glsl");
    const frag_src = readFileAllocOrPanic(&Page_Allocator, "fragment.glsl");

    return sg.makeShader(.{
        .vertex_func = .{
            .source = vert_src.ptr,
        },
        .fragment_func = .{
            .source = frag_src.ptr,
        },

        .attrs = blk: {
            var attrs = [_]sg.ShaderVertexAttr{.{}} ** 16;
            attrs[0] = .{ .glsl_name = "pos",   .base_type = .FLOAT };
            attrs[1] = .{ .glsl_name = "color", .base_type = .FLOAT };
            break :blk attrs;
        },

        .uniform_blocks = blk: {
            var blocks = [_]sg.ShaderUniformBlock{.{}} ** 8;
            blocks[0] = .{
                .stage = .VERTEX, 
                .size = @sizeOf(Uniforms),
                .glsl_uniforms = blk_u: {
                    var un = [_]sg.GlslShaderUniform{.{}} ** 16;
                    un[0] = .{ 
                        .glsl_name = "model",
                        .type = .MAT4 
                    };
                    break :blk_u un;
                },
            };
            break :blk blocks;
        },
    });
}

fn init() callconv(.c) void {
	sg.setup(.{
		.logger = .{ .func = sokol.log.func },
	});

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


	const shader = makeShader();

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



fn mat4RotationXYZ(rx: f32, ry: f32, rz: f32) [16]f32 {
	const cx = @cos(rx);
	const sx = @sin(rx);
	const cy = @cos(ry);
	const sy = @sin(ry);
	const cz = @cos(rz);
	const sz = @sin(rz);

	return [_]f32{
		 cy*cz,            -cy*sz,             sy,    0.0,
		
		 sx*sy*cz + cx*sz, -sx*sy*sz + cx*cz, -sx*cy, 0.0,
		
		-cx*sy*cz + sx*sz,  cx*sy*sz + sx*cz,  cx*cy, 0.0,

		 0.0,               0.0,               0.0,   1.0,
	};
}


fn frame() callconv(.c) void {
	const CLEAR_COLOR: sg.ColorAttachmentAction = .{
		.load_action = .CLEAR,
		.clear_value = .{ .r=0.1, .g=0.12, .b=0.15, .a=1.0 },
	};

	rotation += 0.01;
	u.model = mat4RotationXYZ(rotation, rotation * 0.7, rotation * 1.3);

	sg.beginPass(.{
		.swapchain = gfx_sc,
		.action = .{
			.colors = [_]sg.ColorAttachmentAction{CLEAR_COLOR} ** 8,
		},
	});


	sg.applyPipeline(pipeline);

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
	sg.applyBindings(bind);	
	
	sg.applyUniforms(0, .{ .ptr = &u, .size = @sizeOf(Uniforms), });
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
