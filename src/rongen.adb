with Generic_ImGui;
with Glfw;
with Glfw.Input;
with Glfw.Windows;
with Glfw.Windows.Context;
with GPU;
with ImGui_Layer;
with Window;
with Keyboard;

procedure Rongen is
   use type Glfw.Seconds;

   package ImGui is new Generic_ImGui (Float);

   Time_Previous : Glfw.Seconds;
   Time_Current  : Glfw.Seconds;
   Elapsed       : Glfw.Seconds;

   Frame_Count : Natural := 0;
   Frame_Rate  : Natural;
begin
   Window.Initialize;
   GPU.Initialize;
   ImGui_Layer.Initialize (Window.Game_Window);
   Time_Previous := Glfw.Time;

   while not Window.Game_Window.Should_Close loop
      Glfw.Input.Poll_Events;

      Keyboard.Handle_Event (Window.Game_Window'Access);

      exit when Window.Game_Window.Should_Close;

      GPU.BeginGPU;
      GPU.EndGPU;

      ImGui_Layer.BeginLayer;
      ImGui.API.igShowDemoWindow (null);
      ImGui_Layer.EndLayer;
      Glfw.Windows.Context.Swap_Buffers (Window.Game_Window'Access);

      Frame_Count := Frame_Count + 1;
      Time_Current := Glfw.Time;
      Elapsed := Time_Current - Time_Previous;
      if Elapsed >= 1.0 then
         Frame_Rate := Natural (Glfw.Seconds (Frame_Count) / Elapsed);
         Window.Game_Window.Set_Title ("Rongen -" & Frame_Rate'Image & " FPS");
         Time_Previous := Time_Current;
         Frame_Count := 0;
      end if;
   end loop;

   Window.Destroy;
exception
   when others =>
      begin
         Window.Destroy;
      exception
         when others =>
            null;
      end;
      raise;
end Rongen;
