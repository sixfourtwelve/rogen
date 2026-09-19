with GL.Types;
with GL.Window;
with Glfw.Windows.Context;
with Glfw.Windows.Hints;
with Constants;

package body Window is
   Glfw_Initialized   : Boolean := False;
   Framebuffer_Width  : Glfw.Size;
   Framebuffer_Height : Glfw.Size;

   procedure Initialize is
      procedure Framebuffer_Size_Changed
        (Object : not null access Application_Window; Width, Height : Natural);

      procedure Framebuffer_Size_Changed
        (Object : not null access Application_Window; Width, Height : Natural)
      is
         pragma Unreferenced (Object);
      begin
         GL.Window.Set_Viewport
           (X      => 0,
            Y      => 0,
            Width  => GL.Types.Size (Width),
            Height => GL.Types.Size (Height));
      end Framebuffer_Size_Changed;

   begin
      Glfw.Init;
      Glfw_Initialized := True;

      Glfw.Windows.Hints.Set_Minimum_OpenGL_Version (Major => 4, Minor => 1);
      Glfw.Windows.Hints.Set_Forward_Compat (True);
      Glfw.Windows.Hints.Set_Profile (Glfw.Windows.Context.Core_Profile);
      Glfw.Windows.Hints.Set_Maximized (True);

      Game_Window.Init
        (Width  => Glfw.Size (Constants.Width),
         Height => Glfw.Size (Constants.Height),
         Title  => "Rongen");
      Glfw.Windows.Context.Make_Current (Game_Window'Access);
      Glfw.Windows.Context.Set_Swap_Interval (0);

      Game_Window.Get_Framebuffer_Size (Framebuffer_Width, Framebuffer_Height);
      Framebuffer_Size_Changed
        (Game_Window'Access,
         Natural (Framebuffer_Width),
         Natural (Framebuffer_Height));
      Game_Window.Enable_Callback (Glfw.Windows.Callbacks.Framebuffer_Size);

   end Initialize;

   procedure Destroy is
   begin
      if Glfw_Initialized then
         Glfw.Shutdown;
         Glfw_Initialized := False;
      end if;
   end Destroy;

end Window;
