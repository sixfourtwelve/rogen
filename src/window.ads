with Ada.Finalization;
with Glfw.Windows;

package Window is

   type Instance is tagged limited private;

   procedure Open (Self : in out Instance);

   function Handle
     (Self : aliased in out Instance)
      return not null access Glfw.Windows.Window'Class;

private
   type Application_Window is new Glfw.Windows.Window with null record;

   type Instance is new Ada.Finalization.Limited_Controlled with record
      Native_Window    : aliased Application_Window;
      Glfw_Initialized : Boolean := False;
      Window_Opened    : Boolean := False;
   end record;

   overriding
   procedure Finalize (Self : in out Instance);
end Window;
