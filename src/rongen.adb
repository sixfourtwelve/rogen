with Constants;
with GL.Types;
with Generic_ImGui;
with GL.Window;
with Glfw;
with Glfw.Input;
with Glfw.Input.Keys;
with Glfw.Windows;
with Glfw.Windows.Context;
with Glfw.Windows.Hints;
with GPU;
with ImGui_Layer;

procedure Rongen is
   use Constants;
   use type Glfw.Input.Button_State;
   use type Glfw.Seconds;

   package ImGui is new Generic_ImGui (Float);

   type Application_Window is new Glfw.Windows.Window with null record;

   overriding
   procedure Framebuffer_Size_Changed
     (Object : not null access Application_Window; Width, Height : Natural);

   overriding
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

   Window : aliased Application_Window;

   Time_Previous : Glfw.Seconds;
   Time_Current  : Glfw.Seconds;
   Elapsed       : Glfw.Seconds;

   Frame_Count : Natural := 0;
   Frame_Rate  : Natural;

   Framebuffer_Width  : Glfw.Size;
   Framebuffer_Height : Glfw.Size;
   Glfw_Initialized   : Boolean := False;

   procedure Cleanup is
   begin
      if Window.Initialized then
         ImGui_Layer.Shutdown;
         GPU.Shutdown;
         Window.Destroy;
      end if;

      if Glfw_Initialized then
         Glfw.Shutdown;
         Glfw_Initialized := False;
      end if;
   end Cleanup;

begin
   Glfw.Init;
   Glfw_Initialized := True;

   Glfw.Windows.Hints.Set_Minimum_OpenGL_Version (Major => 4, Minor => 1);
   Glfw.Windows.Hints.Set_Forward_Compat (True);
   Glfw.Windows.Hints.Set_Profile (Glfw.Windows.Context.Core_Profile);
   Glfw.Windows.Hints.Set_Maximized (True);

   Window.Init
     (Width  => Glfw.Size (Width),
      Height => Glfw.Size (Height),
      Title  => "Rongen");
   Glfw.Windows.Context.Make_Current (Window'Access);
   Glfw.Windows.Context.Set_Swap_Interval (0);

   Window.Get_Framebuffer_Size (Framebuffer_Width, Framebuffer_Height);
   Framebuffer_Size_Changed
     (Window'Access,
      Natural (Framebuffer_Width),
      Natural (Framebuffer_Height));
   Window.Enable_Callback (Glfw.Windows.Callbacks.Framebuffer_Size);

   GPU.Initialize;
   ImGui_Layer.Initialize (Window);
   Time_Previous := Glfw.Time;

   while not Window.Should_Close loop
      Glfw.Input.Poll_Events;

      if Window.Key_State (Glfw.Input.Keys.Escape) = Glfw.Input.Pressed then
         Window.Set_Should_Close (True);
      end if;

      exit when Window.Should_Close;

      -- GPU rendering
      GPU.BeginGPU;
      GPU.EndGPU;

      -- UI shit
      ImGui_Layer.BeginLayer;
      ImGui.API.igShowDemoWindow (null);
      ImGui_Layer.EndLayer;
      Glfw.Windows.Context.Swap_Buffers (Window'Access);

      Frame_Count := Frame_Count + 1;
      Time_Current := Glfw.Time;
      Elapsed := Time_Current - Time_Previous;

      if Elapsed >= 1.0 then
         Frame_Rate := Natural (Glfw.Seconds (Frame_Count) / Elapsed);
         Window.Set_Title ("Rongen -" & Frame_Rate'Image & " FPS");
         Time_Previous := Time_Current;
         Frame_Count := 0;
      end if;
   end loop;

   Cleanup;
exception
   when others =>
      begin
         Cleanup;
      exception
         when others =>
            null;
      end;
      raise;
end Rongen;
