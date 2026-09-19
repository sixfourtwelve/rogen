with Glfw.Input;
with Glfw.Input.Keys;

package body Keyboard is

   procedure Handle_Event
     (Window : not null access Glfw.Windows.Window'Class)
   is
      use type Glfw.Input.Button_State;
   begin
      if Window.Key_State (Glfw.Input.Keys.Escape) = Glfw.Input.Pressed then
         Window.Set_Should_Close (True);
      end if;

   end Handle_Event;
end Keyboard;
