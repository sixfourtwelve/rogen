#version 410 core

uniform vec4 u_Offset;

layout (location = 0) in vec3 position;

void main()
{
  gl_Position = u_Offset + vec4(position, 1.0);
}
