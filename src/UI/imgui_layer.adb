with Generic_ImGui;

package body ImGui_Layer is
   package ImGui is new Generic_ImGui (Float);

   Context_Initialized        : Boolean := False;
   Glfw_Backend_Initialized   : Boolean := False;
   OpenGL_Backend_Initialized : Boolean := False;

   procedure Initialize (Window : Glfw.Windows.Window'Class) is
   begin
      ImGui.Contexts.Initialise;
      Context_Initialized := True;

      ImGui.API.igStyleColorsDark;

      ImGui.Backend_Glfw.Init_For_OpenGL
        (Window => Window, install_callbacks => True);
      Glfw_Backend_Initialized := True;

      ImGui.Backend_OpenGL3.Init ("#version 410 core");
      OpenGL_Backend_Initialized := True;
   end Initialize;

   procedure BeginLayer is
   begin
      if not OpenGL_Backend_Initialized then
         raise Program_Error with "user interface is not initialized";
      end if;

      ImGui.Backend_OpenGL3.Begin_Frame;
      ImGui.Backend_Glfw.Begin_Frame;
      ImGui.Drawing.Begin_Frame;

   end BeginLayer;

   procedure EndLayer is
   begin
      ImGui.Drawing.Render;
      ImGui.Backend_OpenGL3.Render_Draw_Data (ImGui.Drawing.Get_Draw_Data);
   end EndLayer;

   procedure Shutdown is
   begin
      if OpenGL_Backend_Initialized then
         ImGui.Backend_OpenGL3.Shutdown;
         OpenGL_Backend_Initialized := False;
      end if;

      if Glfw_Backend_Initialized then
         ImGui.Backend_Glfw.Shutdown;
         Glfw_Backend_Initialized := False;
      end if;

      if Context_Initialized then
         ImGui.Contexts.Destroy;
         Context_Initialized := False;
      end if;
   end Shutdown;
end ImGui_Layer;
