with Ada.Finalization;
with System;

package Miniaudio is

   Audio_Error : exception;

   subtype Volume_Level is Float range 0.0 .. 1.0;

   type Engine is tagged limited private;

   procedure Create (Self : in out Engine);
   function Created (Self : Engine) return Boolean;
   procedure Set_Volume
     (Self : in out Engine; Volume : Volume_Level);

   type Sound is tagged limited private;

   procedure Load
     (Self   : in out Sound;
      Engine : Miniaudio.Engine'Class;
      Path   : String);

   procedure Unload (Self : in out Sound);
   function Loaded (Self : Sound) return Boolean;

   procedure Play
     (Self : in out Sound; Restart : Boolean := False);
   procedure Stop (Self : in out Sound);
   procedure Rewind (Self : in out Sound);

   procedure Set_Volume
     (Self : in out Sound; Volume : Volume_Level);
   procedure Set_Looping
     (Self : in out Sound; Enabled : Boolean);

   function Is_Playing (Self : Sound) return Boolean;

private

   type Engine is new Ada.Finalization.Limited_Controlled with record
      Handle : System.Address := System.Null_Address;
   end record;

   overriding
   procedure Finalize (Self : in out Engine);

   type Sound is new Ada.Finalization.Limited_Controlled with record
      Handle : System.Address := System.Null_Address;
   end record;

   overriding
   procedure Finalize (Self : in out Sound);

end Miniaudio;
