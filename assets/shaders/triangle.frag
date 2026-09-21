#version 410 core

uniform sampler2D color_texture;
in vec2 vertex_texture_coordinate;

out vec4 fragment_color;

void main()
{
    fragment_color = texture(color_texture, vertex_texture_coordinate);
}
