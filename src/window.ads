with Glfw.Windows;

package Window is
   type Application_Window is new Glfw.Windows.Window with null record;

   Game_Window : aliased Application_Window;

   procedure Initialize;
   procedure Destroy;
end Window;
