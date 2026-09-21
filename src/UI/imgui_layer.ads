with Ada.Finalization;
with Glfw.Windows;

package ImGui_Layer is

   type UI is tagged limited private;

   procedure Create (Self : in out UI; Window : Glfw.Windows.Window'Class);
   procedure Begin_Layer (Self : in out UI);
   procedure End_Layer (Self : in out UI);

private

   type UI is new Ada.Finalization.Limited_Controlled with record
      Context_Initialized        : Boolean := False;
      Glfw_Backend_Initialized   : Boolean := False;
      OpenGL_Backend_Initialized : Boolean := False;
   end record;

   overriding
   procedure Finalize (Self : in out UI);

end ImGui_Layer;
