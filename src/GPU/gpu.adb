with GL.Attributes;
with GL.Buffers;
with GL.Context;
with Ada.Text_IO;
with GL.Types;
with GL.Uniforms;
with Shaders; use Shaders;

package body GPU is

   use Ada.Text_IO;

   procedure Load_Data is
      use GL.Types;
      use GL.Objects.Buffers;
      procedure Load_Vectors is new
        GL.Objects.Buffers.Load_To_Buffer (Singles.Vector3_Pointers);

      Triangle : constant Singles.Vector3_Array :=
        [[-0.5, -0.5, 0.0], [0.5, -0.5, 0.0], [0.0, 0.5, 0.0]];
   begin
      VAO.Bind;
      Array_Buffer.Bind (VBO);
      Load_Vectors (Array_Buffer, Triangle, Static_Draw);
      GL.Attributes.Set_Vertex_Attrib_Pointer (0, 3, Single_Type, False, 0, 0);
      GL.Attributes.Enable_Vertex_Attrib_Array (0);
   end Load_Data;

   procedure Initialize is
   begin
      Put_Line ("Renderer initialized.");
      Put_Line (GL.Context.Version_String);
      GL.Buffers.Set_Color_Clear_Value ([0.19, 0.19, 0.19, 1.0]);

      Shader :=
        Make_Shader_Program
          ("assets/shaders/triangle.vert", "assets/shaders/triangle.frag");

      VAO.Initialize_Id;
      VBO.Initialize_Id;
      Load_Data;
   end Initialize;

   procedure BeginGPU is
      Color_Location  : GL.Uniforms.Uniform;
      Offset_Location : GL.Uniforms.Uniform;
   begin
      Clear_Screen;
      VAO.Bind;
      Shader.Use_Program;

      Color_Location := Shader.Uniform_Location ("u_Color");
      GL.Uniforms.Set_Single
        (Location => Color_Location,
         V1       => 1.0,
         V2       => 1.0,
         V3       => 1.0,
         V4       => 1.0);

      Offset_Location := Shader.Uniform_Location ("u_Offset");
      GL.Uniforms.Set_Single
        (Location => Offset_Location,
         V1       => 0.0,
         V2       => 0.0,
         V3       => 0.0,
         V4       => 0.0);

   end BeginGPU;

   procedure EndGPU is
   begin
      Vertex_Arrays.Draw_Arrays
        (Mode => GL.Types.Triangles, First => 0, Count => 3);
   end EndGPU;

   procedure Shutdown is
      Null_Buffer  : Buffers.Buffer;
      Null_Program : Programs.Program;
   begin
      if Shader.Initialized then
         Null_Program.Set_Raw_Id (0, Owned => False);
         Null_Program.Use_Program;
         Shader.Clear;
      end if;

      if VAO.Initialized then
         Vertex_Arrays.Null_Array_Object.Bind;
         VAO.Clear;
      end if;

      if VBO.Initialized then
         Null_Buffer.Set_Raw_Id (0, Owned => False);
         Buffers.Array_Buffer.Bind (Null_Buffer);
         VBO.Clear;
      end if;
   end Shutdown;

   procedure Clear_Screen is
      Flags : constant GL.Buffers.Buffer_Bits :=
        GL.Buffers.Buffer_Bits'
          (Depth => False, Accum => False, Stencil => False, Color => True);
   begin
      GL.Buffers.Clear (Flags);
   end Clear_Screen;
end GPU;
