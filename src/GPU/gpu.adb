with GL.Attributes;
with GL.Buffers;
with GL.Context;
with Ada.Text_IO;
with GL.Types;
with GL.Uniforms;
with Shaders;              use Shaders;
with Generic_ImGui;
with Interfaces.C.Strings; use Interfaces.C.Strings;
with Interfaces.C;

with Ada.Numerics.Generic_Elementary_Functions;

package body GPU is
   use Ada.Text_IO;

   package ImGui is new Generic_ImGui (Float);
   package Elementary_Functions is new
     Ada.Numerics.Generic_Elementary_Functions (GL.Types.Single);

   Elapsed_Time : GL.Types.Single := 0.0;

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

   procedure BeginGPU (DeltaTime : Glfw.Seconds) is
      use GL.Types;
      use Interfaces.C;
      use ImGui.API;

      Color_Location  : GL.Uniforms.Uniform;
      Offset_Location : GL.Uniforms.Uniform;

      Speed : constant Single := 1.0;

      R : Single;
      G : Single;
      B : Single;

      X                  : Single;
      Y                  : Single;
      Debug_Window_Flags : constant ImGuiWindowFlags :=
        ImGuiWindowFlags_AlwaysAutoResize
        or ImGuiWindowFlags_NoMove
        or ImGuiWindowFlags_NoResize;
   begin
      Elapsed_Time := Elapsed_Time + Single (DeltaTime);

      Clear_Screen;
      VAO.Bind;
      Shader.Use_Program;

      R := 0.5 + 0.5 * Elementary_Functions.Sin (Elapsed_Time * Speed);

      G := 0.5 + 0.5 * Elementary_Functions.Sin (Elapsed_Time * Speed + 2.094);

      B := 0.5 + 0.5 * Elementary_Functions.Sin (Elapsed_Time * Speed + 4.189);

      Color_Location := Shader.Uniform_Location ("u_Color");

      GL.Uniforms.Set_Single
        (Location => Color_Location, V1 => R, V2 => G, V3 => B, V4 => 1.0);

      Offset_Location := Shader.Uniform_Location ("u_Offset");

      X := 0.5 * Elementary_Functions.Sin (Elapsed_Time * Speed);
      Y := 0.5 * Elementary_Functions.Cos (Elapsed_Time * Speed);

      GL.Uniforms.Set_Single
        (Location => Offset_Location, V1 => X, V2 => Y, V3 => 0.0, V4 => 0.0);

      if igBegin
           (New_String ("Debug Window"), null, flags => Debug_Window_Flags)
      then
         igText (New_String ("Testing"));
         igSliderFloat (New_String ("Colour"), v => Float (R), 0.0, 1.0);
      end if;
      igEnd;
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
          (Depth => True, Accum => False, Stencil => False, Color => True);
   begin
      GL.Buffers.Clear (Flags);
   end Clear_Screen;
end GPU;
