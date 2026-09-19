with GL.Objects.Buffers;
with GL.Objects.Programs;
with GL.Objects.Shaders;
with GL.Objects.Vertex_Arrays;

package GPU is

   package Buffers renames GL.Objects.Buffers;
   package Programs renames GL.Objects.Programs;
   package Shaders renames GL.Objects.Shaders;
   package Vertex_Arrays renames GL.Objects.Vertex_Arrays;

   procedure Initialize;
   procedure BeginGPU;
   procedure EndGPU;
   procedure Shutdown;

private
   procedure Clear_Screen;

   procedure Load_Data;

   VAO : Vertex_Arrays.Vertex_Array_Object;
   VBO : Buffers.Buffer;

end GPU;
