with Ada.Finalization;
with Miniaudio;

package Audio is

   type Music is tagged limited private;

   procedure Create (Self : in out Music; Path : String);

private

   type Music is new Ada.Finalization.Limited_Controlled with record
      Engine : Miniaudio.Engine;
      Sound  : Miniaudio.Sound;
   end record;

   overriding
   procedure Finalize (Self : in out Music);

end Audio;
