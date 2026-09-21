with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Text_IO;
with Generic_ImGui;
with GL.Attributes;
with GL.Buffers;
with GL.Context;
with GL.Images;
with GL.Objects.Textures;
with GL.Objects.Textures.Targets;
with GL.Pixels;
with GL.Types;
with GL.Uniforms;
with Interfaces.C;
with Interfaces.C.Strings; use Interfaces.C.Strings;
with Shaders;              use Shaders;
with System;

package body GPU is
   use Ada.Text_IO;

   package ImGui is new Generic_ImGui (Float);
   package Elementary_Functions is new
     Ada.Numerics.Generic_Elementary_Functions (GL.Types.Single);

   Elapsed_Time : GL.Types.Single := 0.0;
   Texture      : GL.Objects.Textures.Texture;

   procedure Load_Data is
      use GL.Objects.Buffers;
      use GL.Types;

      procedure Load_Vertices is new
        GL.Objects.Buffers.Load_To_Buffer (Single_Pointers);

      Component_Size : constant GL.Types.Size :=
        Single'Size / System.Storage_Unit;
      Vertex_Stride  : constant GL.Types.Size := 5 * Component_Size;

      Triangle : constant Single_Array :=
        [-0.5,
         -0.5,
         0.0,
         0.0,
         0.0,
         0.5,
         -0.5,
         0.0,
         1.0,
         0.0,
         0.0,
         0.5,
         0.0,
         0.5,
         1.0];
   begin
      VAO.Bind;
      Array_Buffer.Bind (VBO);
      Load_Vertices (Array_Buffer, Triangle, Static_Draw);

      GL.Attributes.Set_Vertex_Attrib_Pointer
        (Index      => 0,
         Count      => 3,
         Kind       => Single_Type,
         Normalized => False,
         Stride     => Vertex_Stride,
         Offset     => 0);
      GL.Attributes.Enable_Vertex_Attrib_Array (0);

      GL.Attributes.Set_Vertex_Attrib_Pointer
        (Index      => 1,
         Count      => 2,
         Kind       => Single_Type,
         Normalized => False,
         Stride     => Vertex_Stride,
         Offset     => 3 * Component_Size);
      GL.Attributes.Enable_Vertex_Attrib_Array (1);

      GL.Objects.Textures.Set_Active_Unit (0);
      GL.Images.Load_File_To_Texture
        ("assets/textures/orange/texture_01.png", Texture, GL.Pixels.RGB);
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

      Shader.Use_Program;
      GL.Uniforms.Set_Int (Shader.Uniform_Location ("color_texture"), 0);
   end Initialize;

   -- GPU SHIT
   procedure BeginGPU (DeltaTime : Glfw.Seconds) is
      use GL.Types;
      use Interfaces.C;
      use ImGui.API;

      Offset_Location : GL.Uniforms.Uniform;

      Speed : constant Single := 1.0;

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

      GL.Objects.Textures.Set_Active_Unit (0);
      GL.Objects.Textures.Targets.Texture_2D.Bind (Texture);

      Shader.Use_Program;

      Offset_Location := Shader.Uniform_Location ("u_Offset");

      X := 0.5 * Elementary_Functions.Cos (Elapsed_Time * Speed);
      Y := 0.5 * Elementary_Functions.Sin (Elapsed_Time * Speed);

      GL.Uniforms.Set_Single
        (Location => Offset_Location, V1 => X, V2 => Y, V3 => 0.0, V4 => 0.0);

      if igBegin
           (New_String ("Debug Window"), null, flags => Debug_Window_Flags)
      then
         igText (New_String ("Testing"));
      end if;
      igEnd;
   end BeginGPU;

   procedure EndGPU is
   begin
      Vertex_Arrays.Draw_Arrays
        (Mode => GL.Types.Triangles, First => 0, Count => 3);
   end EndGPU;

   -- Cleanup

   procedure Shutdown is
      Null_Buffer  : Buffers.Buffer;
      Null_Program : Programs.Program;
      Null_Texture : GL.Objects.Textures.Texture;
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

      if Texture.Initialized then
         Null_Texture.Set_Raw_Id (0, Owned => False);
         GL.Objects.Textures.Targets.Texture_2D.Bind (Null_Texture);
         Texture.Clear;
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
