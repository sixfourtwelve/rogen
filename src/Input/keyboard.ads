with Glfw.Windows;

package Keyboard is
   procedure Handle_Event
     (Window : not null access Glfw.Windows.Window'Class);
end Keyboard;
