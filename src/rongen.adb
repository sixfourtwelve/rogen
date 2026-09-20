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

   Previous_Frame_Time : Glfw.Seconds;
   Current_Time        : Glfw.Seconds;
   Delta_Time          : Glfw.Seconds;
   Fps_Window_Start    : Glfw.Seconds;
   Fps_Window_Elapsed  : Glfw.Seconds;

   Frame_Count : Natural := 0;
   Frame_Rate  : Natural;
begin
   Window.Initialize;
   GPU.Initialize;
   ImGui_Layer.Initialize (Window.Game_Window);

   Current_Time := Glfw.Time;
   Previous_Frame_Time := Current_Time;
   Fps_Window_Start := Current_Time;

   while not Window.Game_Window.Should_Close loop
      Glfw.Input.Poll_Events;

      Current_Time := Glfw.Time;
      Delta_Time := Current_Time - Previous_Frame_Time;
      Previous_Frame_Time := Current_Time;
      Fps_Window_Elapsed := Current_Time - Fps_Window_Start;
      Frame_Count := Frame_Count + 1;

      Keyboard.Handle_Event (Window.Game_Window'Access);

      exit when Window.Game_Window.Should_Close;

      ImGui_Layer.BeginLayer;
      GPU.BeginGPU (DeltaTime => Delta_Time);
      GPU.EndGPU;
      ImGui_Layer.EndLayer;

      Glfw.Windows.Context.Swap_Buffers (Window.Game_Window'Access);

      if Fps_Window_Elapsed >= 1.0 then
         Frame_Rate :=
           Natural (Glfw.Seconds (Frame_Count) / Fps_Window_Elapsed);
         Window.Game_Window.Set_Title ("Rongen -" & Frame_Rate'Image & " FPS");
         Fps_Window_Start := Current_Time;
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
