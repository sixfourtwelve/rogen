with GL.Images;
with GL.Objects.Textures.Targets;
with GL.Pixels;

package body Textures is
   procedure Create (Self : in out Texture; Path : Unbounded_String) is
   begin

      GL.Objects.Textures.Set_Active_Unit (0);
      GL.Images.Load_File_To_Texture
        (To_String (Path), Self.Texture, GL.Pixels.RGB);
   end Create;

   procedure Bind (Self : in out Texture) is
   begin
      GL.Objects.Textures.Set_Active_Unit (0);
      GL.Objects.Textures.Targets.Texture_2D.Bind (Self.Texture);
   end Bind;

   overriding
   procedure Finalize (Self : in out Texture) is
      Null_Texture : GL.Objects.Textures.Texture;
   begin
      if Self.Texture.Initialized then
         Null_Texture.Set_Raw_Id (0, Owned => False);
         GL.Objects.Textures.Targets.Texture_2D.Bind (Null_Texture);
         Self.Texture.Clear;
      end if;

   end Finalize;
end Textures;
