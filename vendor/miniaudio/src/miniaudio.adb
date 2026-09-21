with Interfaces.C;
with Interfaces.C.Strings;

package body Miniaudio is
   use type Interfaces.C.int;
   use type Interfaces.C.Strings.chars_ptr;
   use type System.Address;

   Success : constant Interfaces.C.int := 0;

   function C_Engine_Create
     (Handle : access System.Address) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_audio_engine_create";

   procedure C_Engine_Destroy (Handle : System.Address)
   with Import,
        Convention    => C,
        External_Name => "rongen_audio_engine_destroy";

   function C_Engine_Set_Volume
     (Handle : System.Address;
      Volume : Interfaces.C.C_float) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_audio_engine_set_volume";

   function C_Sound_Create
     (Engine : System.Address;
      Path   : Interfaces.C.Strings.chars_ptr;
      Handle : access System.Address) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_audio_sound_create";

   procedure C_Sound_Destroy (Handle : System.Address)
   with Import,
        Convention    => C,
        External_Name => "rongen_audio_sound_destroy";

   function C_Sound_Start
     (Handle : System.Address) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_audio_sound_start";

   function C_Sound_Stop
     (Handle : System.Address) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_audio_sound_stop";

   function C_Sound_Seek_To_Start
     (Handle : System.Address) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_audio_sound_seek_to_start";

   function C_Sound_Set_Volume
     (Handle : System.Address;
      Volume : Interfaces.C.C_float) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_audio_sound_set_volume";

   function C_Sound_Set_Looping
     (Handle  : System.Address;
      Enabled : Interfaces.C.int) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_audio_sound_set_looping";

   function C_Sound_Is_Playing
     (Handle : System.Address) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_audio_sound_is_playing";

   function C_Result_Description
     (Result : Interfaces.C.int) return Interfaces.C.Strings.chars_ptr
   with Import,
        Convention    => C,
        External_Name => "rongen_audio_result_description";

   procedure Check
     (Result : Interfaces.C.int; Operation : String)
   is
      Description : constant Interfaces.C.Strings.chars_ptr :=
        C_Result_Description (Result);
   begin
      if Result = Success then
         return;
      end if;

      if Description = Interfaces.C.Strings.Null_Ptr then
         raise Audio_Error with
           Operation & " failed with result" & Interfaces.C.int'Image (Result);
      end if;

      raise Audio_Error with
        Operation & " failed: " & Interfaces.C.Strings.Value (Description);
   end Check;

   procedure Require_Created (Self : Engine) is
   begin
      if not Self.Created then
         raise Program_Error with "audio engine is not created";
      end if;
   end Require_Created;

   procedure Require_Loaded (Self : Sound) is
   begin
      if not Self.Loaded then
         raise Program_Error with "sound is not loaded";
      end if;
   end Require_Loaded;

   procedure Create (Self : in out Engine) is
      New_Handle : aliased System.Address := System.Null_Address;
   begin
      if Self.Created then
         raise Program_Error with "audio engine is already created";
      end if;

      Check (C_Engine_Create (New_Handle'Access), "creating audio engine");
      Self.Handle := New_Handle;
   end Create;

   function Created (Self : Engine) return Boolean is
     (Self.Handle /= System.Null_Address);

   procedure Set_Volume
     (Self : in out Engine; Volume : Volume_Level)
   is
   begin
      Self.Require_Created;
      Check
        (C_Engine_Set_Volume
           (Self.Handle, Interfaces.C.C_float (Volume)),
         "setting audio engine volume");
   end Set_Volume;

   procedure Load
     (Self   : in out Sound;
      Engine : Miniaudio.Engine'Class;
      Path   : String)
   is
      C_Path     : Interfaces.C.Strings.chars_ptr :=
        Interfaces.C.Strings.Null_Ptr;
      New_Handle : aliased System.Address := System.Null_Address;
      Result     : Interfaces.C.int;
   begin
      if Self.Loaded then
         raise Program_Error with "sound is already loaded";
      end if;

      Require_Created (Miniaudio.Engine (Engine));
      C_Path := Interfaces.C.Strings.New_String (Path);
      Result :=
        C_Sound_Create
          (Miniaudio.Engine (Engine).Handle, C_Path, New_Handle'Access);
      Interfaces.C.Strings.Free (C_Path);
      Check (Result, "loading sound '" & Path & "'");
      Self.Handle := New_Handle;
   exception
      when others =>
         Interfaces.C.Strings.Free (C_Path);
         if New_Handle /= System.Null_Address then
            C_Sound_Destroy (New_Handle);
         end if;
         raise;
   end Load;

   procedure Unload (Self : in out Sound) is
   begin
      if Self.Handle /= System.Null_Address then
         C_Sound_Destroy (Self.Handle);
         Self.Handle := System.Null_Address;
      end if;
   end Unload;

   function Loaded (Self : Sound) return Boolean is
     (Self.Handle /= System.Null_Address);

   procedure Play
     (Self : in out Sound; Restart : Boolean := False)
   is
   begin
      Self.Require_Loaded;

      if Restart then
         Check
           (C_Sound_Seek_To_Start (Self.Handle), "rewinding sound");
      end if;

      Check (C_Sound_Start (Self.Handle), "starting sound");
   end Play;

   procedure Stop (Self : in out Sound) is
   begin
      Self.Require_Loaded;
      Check (C_Sound_Stop (Self.Handle), "stopping sound");
   end Stop;

   procedure Rewind (Self : in out Sound) is
   begin
      Self.Require_Loaded;
      Check (C_Sound_Seek_To_Start (Self.Handle), "rewinding sound");
   end Rewind;

   procedure Set_Volume
     (Self : in out Sound; Volume : Volume_Level)
   is
   begin
      Self.Require_Loaded;
      Check
        (C_Sound_Set_Volume
           (Self.Handle, Interfaces.C.C_float (Volume)),
         "setting sound volume");
   end Set_Volume;

   procedure Set_Looping
     (Self : in out Sound; Enabled : Boolean)
   is
      C_Enabled : constant Interfaces.C.int :=
        Interfaces.C.int (Boolean'Pos (Enabled));
   begin
      Self.Require_Loaded;
      Check
        (C_Sound_Set_Looping (Self.Handle, C_Enabled),
         "setting sound looping");
   end Set_Looping;

   function Is_Playing (Self : Sound) return Boolean is
   begin
      if not Self.Loaded then
         return False;
      end if;

      return C_Sound_Is_Playing (Self.Handle) /= 0;
   end Is_Playing;

   overriding
   procedure Finalize (Self : in out Engine) is
   begin
      if Self.Handle /= System.Null_Address then
         C_Engine_Destroy (Self.Handle);
         Self.Handle := System.Null_Address;
      end if;
   end Finalize;

   overriding
   procedure Finalize (Self : in out Sound) is
   begin
      Self.Unload;
   end Finalize;

end Miniaudio;
