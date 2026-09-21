with Ada.Finalization;
with GL.Objects.Buffers;
with GL.Objects.Programs;
with GL.Objects.Vertex_Arrays;
with GL.Types;
with GL.Uniforms;
with Glfw;
with Textures;

package GPU is

   type Renderer is tagged limited private;

   procedure Create (Self : in out Renderer);
   procedure Begin_Frame (Self : in out Renderer; Delta_Time : Glfw.Seconds);
   procedure End_Frame (Self : in out Renderer);

private

   type Uniform_Locations is record
      Offset : GL.Uniforms.Uniform;
   end record;

   type Renderer is new Ada.Finalization.Limited_Controlled with record
      Elapsed_Time : GL.Types.Single := 0.0;
      Texture      : Textures.Texture;
      Uniforms     : Uniform_Locations;
      VAO          : GL.Objects.Vertex_Arrays.Vertex_Array_Object;
      VBO          : GL.Objects.Buffers.Buffer;
      Program      : GL.Objects.Programs.Program;
   end record;

   overriding
   procedure Finalize (Self : in out Renderer);

end GPU;
