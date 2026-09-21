package body Audio is

   procedure Create (Self : in out Music; Path : String) is
   begin

      Self.Engine.Create;
      Self.Engine.Set_Volume (0.50);

      Self.Sound.Load (Self.Engine, Path);

      Self.Sound.Set_Looping (True);
      Self.Sound.Play (True);

   end Create;

   overriding
   procedure Finalize (Self : in out Music) is
   begin
      null;
   end Finalize;

end Audio;
