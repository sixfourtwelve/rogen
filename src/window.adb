with GL.Types;
with GL.Window;
with Glfw.Windows.Context;
with Glfw.Windows.Hints;
with Constants;

package body Window is

   procedure Open (Self : in out Instance) is
      Framebuffer_Width  : Glfw.Size;
      Framebuffer_Height : Glfw.Size;

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
      Self.Glfw_Initialized := True;

      Glfw.Windows.Hints.Set_Minimum_OpenGL_Version (Major => 4, Minor => 1);
      Glfw.Windows.Hints.Set_Forward_Compat (True);
      Glfw.Windows.Hints.Set_Profile (Glfw.Windows.Context.Core_Profile);
      Glfw.Windows.Hints.Set_Maximized (True);

      Self.Native_Window.Init
        (Width  => Glfw.Size (Constants.Width),
         Height => Glfw.Size (Constants.Height),
         Title  => "Rongen");
      Self.Window_Opened := True;

      Glfw.Windows.Context.Make_Current (Self.Native_Window'Access);
      Glfw.Windows.Context.Set_Swap_Interval (0);

      Self.Native_Window.Get_Framebuffer_Size
        (Framebuffer_Width, Framebuffer_Height);
      Framebuffer_Size_Changed
        (Self.Native_Window'Access,
         Natural (Framebuffer_Width),
         Natural (Framebuffer_Height));
      Self.Native_Window.Enable_Callback
        (Glfw.Windows.Callbacks.Framebuffer_Size);
   end Open;

   function Handle
     (Self : aliased in out Instance)
      return not null access Glfw.Windows.Window'Class is
   begin
      if not Self.Window_Opened then
         raise Program_Error with "window is not open";
      end if;

      return Self.Native_Window'Access;
   end Handle;

   overriding
   procedure Finalize (Self : in out Instance) is
   begin
      if Self.Window_Opened then
         Self.Native_Window.Destroy;
         Self.Window_Opened := False;
      end if;

      if Self.Glfw_Initialized then
         Glfw.Shutdown;
         Self.Glfw_Initialized := False;
      end if;
   end Finalize;

end Window;
