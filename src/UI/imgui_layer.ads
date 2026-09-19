with Glfw.Windows;

package ImGui_Layer is
   procedure Initialize (Window : Glfw.Windows.Window'Class);

   procedure BeginLayer;
   procedure EndLayer;

   procedure Shutdown;
end ImGui_Layer;
