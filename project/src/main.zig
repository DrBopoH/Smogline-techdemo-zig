const std = @import("std");

const sokol = @import("sokol");
const sapp = sokol.app;
const sg = sokol.gfx;

fn init() callconv(.c) void {
    sg.setup(.{
        .logger = .{ .func = sokol.log.func },
    });
}

fn frame() callconv(.c) void {
    const app_sc = sapp.getSwapchain();

    const gfx_sc = sg.Swapchain{
        .width = app_sc.width,
        .height = app_sc.height,
        .sample_count = app_sc.sample_count,
        .color_format = sg.PixelFormat.DEFAULT,
        .depth_format = sg.PixelFormat.DEFAULT,
        .gl = sg.GlSwapchain{},
        .vulkan = sg.VulkanSwapchain{},
        .metal = sg.MetalSwapchain{},
        .d3d11 = sg.D3d11Swapchain{},
        .wgpu = sg.WgpuSwapchain{},
    };

    sg.beginPass(.{
        .swapchain = gfx_sc,
        .action = .{
            .colors = [_]sg.ColorAttachmentAction{
                .{
                    .load_action = .CLEAR,
                    .clear_value = .{ .r = 0.1, .g = 0.12, .b = 0.15, .a = 1.0 },
                },
                .{}, 
                .{}, 
                .{}, 
                .{}, 
                .{}, 
                .{}, 
                .{},
            },
        },
    });
    sg.endPass();
    sg.commit();
}

fn cleanup() callconv(.c) void {
    sg.shutdown();
}

fn event(ev: [*c]const sapp.Event) callconv(.c) void {
    _ = ev;
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = event,

        .width = 1280,
        .height = 720,
        .window_title = "Zig Smogline Tech Demo",
        .logger = .{ .func = sokol.log.func },
    });
}
