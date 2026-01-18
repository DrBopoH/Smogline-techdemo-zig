#version 450

layout(location = 0) in vec3 pos;
layout(location = 1) in vec3 color;

layout(location = 0) uniform mat4 model;

layout(location = 0) out vec3 frag_color;

void main() {
    gl_Position = model * vec4(pos, 1.0);
    frag_color = color;
}
