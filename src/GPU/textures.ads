with Ada.Finalization;
with GL.Objects.Textures;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Textures is
   type Texture is tagged limited private;

   procedure Create (Self : in out Texture; Path : Unbounded_String);
   procedure Bind (Self : in out Texture);

private
   type Texture is new Ada.Finalization.Limited_Controlled with record
      Path    : Unbounded_String;
      Texture : GL.Objects.Textures.Texture;
   end record;

   overriding
   procedure Finalize (Self : in out Texture);
end Textures;
