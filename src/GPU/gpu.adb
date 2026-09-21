with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Text_IO;
with Generic_ImGui;
with GL.Attributes;
with GL.Buffers;
with GL.Context;
with Interfaces.C;
with Interfaces.C.Strings;  use Interfaces.C.Strings;
with Shaders;
with System;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package body GPU is
   use Ada.Text_IO;

   package ImGui is new Generic_ImGui (Float);
   package Elementary_Functions is new
     Ada.Numerics.Generic_Elementary_Functions (GL.Types.Single);

   procedure Clear_Screen is
      Flags : constant GL.Buffers.Buffer_Bits :=
        (Depth => True, Accum => False, Stencil => False, Color => True);
   begin
      GL.Buffers.Clear (Flags);
   end Clear_Screen;

   procedure Create (Self : in out Renderer) is
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
      if Self.Program.Initialized then
         raise Program_Error with "renderer is already initialized";
      end if;

      Put_Line ("Renderer initialized.");
      Put_Line (GL.Context.Version_String);
      GL.Buffers.Set_Color_Clear_Value ([0.19, 0.19, 0.19, 1.0]);

      Self.Program :=
        Shaders.Make_Shader_Program
          ("assets/shaders/triangle.vert", "assets/shaders/triangle.frag");

      Self.VAO.Initialize_Id;
      Self.VBO.Initialize_Id;

      Self.VAO.Bind;
      Array_Buffer.Bind (Self.VBO);
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

      Self.Texture.Create
        (To_Unbounded_String ("assets/textures/orange/texture_01.png"));

      Self.Program.Use_Program;
      GL.Uniforms.Set_Int (Self.Program.Uniform_Location ("color_texture"), 0);
      Self.Uniforms.Offset := Self.Program.Uniform_Location ("u_Offset");
   end Create;

   procedure Begin_Frame (Self : in out Renderer; Delta_Time : Glfw.Seconds) is
      use GL.Types;
      use Interfaces.C;
      use ImGui.API;

      Speed : constant Single := 1.0;

      X                  : Single;
      Y                  : Single;
      Debug_Window_Flags : constant ImGuiWindowFlags :=
        ImGuiWindowFlags_AlwaysAutoResize
        or ImGuiWindowFlags_NoMove
        or ImGuiWindowFlags_NoResize;
   begin
      if not Self.Program.Initialized then
         raise Program_Error with "renderer is not initialized";
      end if;

      Self.Elapsed_Time := Self.Elapsed_Time + Single (Delta_Time);

      Clear_Screen;
      Self.VAO.Bind;

      Self.Texture.Bind;
      Self.Program.Use_Program;

      X := 0.5 * Elementary_Functions.Cos (Self.Elapsed_Time * Speed);
      Y := 0.5 * Elementary_Functions.Sin (Self.Elapsed_Time * Speed);

      GL.Uniforms.Set_Single
        (Location => Self.Uniforms.Offset,
         V1       => X,
         V2       => Y,
         V3       => 0.0,
         V4       => 0.0);

      if igBegin
           (New_String ("Debug Window"), null, flags => Debug_Window_Flags)
      then
         igText (New_String ("Testing"));
      end if;
      igEnd;
   end Begin_Frame;

   procedure End_Frame (Self : in out Renderer) is
   begin
      if not Self.VAO.Initialized then
         raise Program_Error with "renderer is not initialized";
      end if;

      Self.VAO.Bind;
      GL.Objects.Vertex_Arrays.Draw_Arrays
        (Mode => GL.Types.Triangles, First => 0, Count => 3);
   end End_Frame;

   overriding
   procedure Finalize (Self : in out Renderer) is
      Null_Buffer  : GL.Objects.Buffers.Buffer;
      Null_Program : GL.Objects.Programs.Program;
   begin
      if Self.VAO.Initialized then
         GL.Objects.Vertex_Arrays.Null_Array_Object.Bind;
         Self.VAO.Clear;
      end if;

      if Self.VBO.Initialized then
         Null_Buffer.Set_Raw_Id (0, Owned => False);
         GL.Objects.Buffers.Array_Buffer.Bind (Null_Buffer);
         Self.VBO.Clear;
      end if;

      if Self.Program.Initialized then
         Null_Program.Set_Raw_Id (0, Owned => False);
         Null_Program.Use_Program;
         Self.Program.Clear;
      end if;
   end Finalize;

end GPU;
