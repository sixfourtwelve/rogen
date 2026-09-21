#version 410 core

uniform vec4 u_Offset;

layout (location = 0) in vec3 position;
layout(location = 1) in vec2 texture_coordinate;

out vec2 vertex_texture_coordinate;

void main()
{
  gl_Position = u_Offset + vec4(position, 1.0);
  vertex_texture_coordinate = texture_coordinate;
}
