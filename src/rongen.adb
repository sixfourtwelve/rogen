with Audio;
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

   Game_Window : aliased Window.Instance;
   Renderer    : GPU.Renderer;
   UI          : ImGui_Layer.UI;
   Music       : Audio.Music;

begin
   Game_Window.Open;
   Renderer.Create;
   UI.Create (Game_Window.Handle.all);

   Music.Create ("assets/audio/music.mp3");

   Current_Time := Glfw.Time;
   Previous_Frame_Time := Current_Time;
   Fps_Window_Start := Current_Time;

   while not Game_Window.Handle.Should_Close loop
      Glfw.Input.Poll_Events;

      Current_Time := Glfw.Time;
      Delta_Time := Current_Time - Previous_Frame_Time;
      Previous_Frame_Time := Current_Time;
      Fps_Window_Elapsed := Current_Time - Fps_Window_Start;
      Frame_Count := Frame_Count + 1;

      Keyboard.Handle_Event (Game_Window.Handle);

      exit when Game_Window.Handle.Should_Close;

      UI.Begin_Layer;
      Renderer.Begin_Frame (Delta_Time);
      Renderer.End_Frame;
      UI.End_Layer;

      Glfw.Windows.Context.Swap_Buffers (Game_Window.Handle);

      if Fps_Window_Elapsed >= 1.0 then
         Frame_Rate :=
           Natural (Glfw.Seconds (Frame_Count) / Fps_Window_Elapsed);
         Game_Window.Handle.Set_Title ("Rongen -" & Frame_Rate'Image & " FPS");
         Fps_Window_Start := Current_Time;
         Frame_Count := 0;
      end if;
   end loop;
end Rongen;
