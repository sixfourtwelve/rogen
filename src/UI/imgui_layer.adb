with Generic_ImGui;

package body ImGui_Layer is
   package ImGui is new Generic_ImGui (Float);

   procedure Create (Self : in out UI; Window : Glfw.Windows.Window'Class) is
   begin
      ImGui.Contexts.Initialise;
      Self.Context_Initialized := True;

      ImGui.API.igStyleColorsDark;

      ImGui.Backend_Glfw.Init_For_OpenGL
        (Window => Window, install_callbacks => True);
      Self.Glfw_Backend_Initialized := True;

      ImGui.Backend_OpenGL3.Init ("#version 410 core");
      Self.OpenGL_Backend_Initialized := True;
   end Create;

   procedure Begin_Layer (Self : in out UI) is
   begin
      if not Self.OpenGL_Backend_Initialized then
         raise Program_Error with "user interface is not initialized";
      end if;

      ImGui.Backend_OpenGL3.Begin_Frame;
      ImGui.Backend_Glfw.Begin_Frame;
      ImGui.Drawing.Begin_Frame;

   end Begin_Layer;

   procedure End_Layer (Self : in out UI) is
   begin
      ImGui.Drawing.Render;
      ImGui.Backend_OpenGL3.Render_Draw_Data (ImGui.Drawing.Get_Draw_Data);
   end End_Layer;

   overriding
   procedure Finalize (Self : in out UI) is
   begin
      if Self.OpenGL_Backend_Initialized then
         ImGui.Backend_OpenGL3.Shutdown;
         Self.OpenGL_Backend_Initialized := False;
      end if;

      if Self.Glfw_Backend_Initialized then
         ImGui.Backend_Glfw.Shutdown;
         Self.Glfw_Backend_Initialized := False;
      end if;

      if Self.Context_Initialized then
         ImGui.Contexts.Destroy;
         Self.Context_Initialized := False;
      end if;
   end Finalize;
end ImGui_Layer;
