with Ada.Numerics;
with GL;

package body Math is

   use type GL.Types.Single;
   use type GL.Types.Singles.Vector3;

   function Dot (Left, Right : Vec3) return Scalar is
   begin
      return
        Left (GL.X) * Right (GL.X) + Left (GL.Y) * Right (GL.Y)
        + Left (GL.Z) * Right (GL.Z);
   end Dot;

   function Cross (Left, Right : Vec3) return Vec3 is
   begin
      return GL.Types.Singles.Cross_Product (Left, Right);
   end Cross;

   function Length_Squared (Value : Vec3) return Scalar is
   begin
      return Dot (Value, Value);
   end Length_Squared;

   function Length (Value : Vec3) return Scalar is
   begin
      return Singles.Sqrt (Length_Squared (Value));
   end Length;

   function Normalize (Value : Vec3) return Vec3 is
      Magnitude : constant Scalar := Length (Value);
   begin
      if Magnitude = 0.0 then
         return Value;
      end if;

      return Value / Magnitude;
   end Normalize;

   function Distance_Squared (Left, Right : Vec3) return Scalar is
   begin
      return Length_Squared (Right - Left);
   end Distance_Squared;

   function Distance (Left, Right : Vec3) return Scalar is
   begin
      return Singles.Sqrt (Distance_Squared (Left, Right));
   end Distance;

   function Lerp (From, To : Vec3; Amount : Scalar) return Vec3 is
   begin
      return From + (To - From) * Amount;
   end Lerp;

   function Min (Left, Right : Vec3) return Vec3 is
   begin
      return
        [GL.X => Scalar'Min (Left (GL.X), Right (GL.X)),
         GL.Y => Scalar'Min (Left (GL.Y), Right (GL.Y)),
         GL.Z => Scalar'Min (Left (GL.Z), Right (GL.Z))];
   end Min;

   function Max (Left, Right : Vec3) return Vec3 is
   begin
      return
        [GL.X => Scalar'Max (Left (GL.X), Right (GL.X)),
         GL.Y => Scalar'Max (Left (GL.Y), Right (GL.Y)),
         GL.Z => Scalar'Max (Left (GL.Z), Right (GL.Z))];
   end Max;

   function Clamp (Value, Minimum, Maximum : Scalar) return Scalar is
   begin
      if Value < Minimum then
         return Minimum;
      elsif Value > Maximum then
         return Maximum;
      else
         return Value;
      end if;
   end Clamp;

   function Saturate (Value : Scalar) return Scalar is
   begin
      return Clamp (Value, 0.0, 1.0);
   end Saturate;

   function To_Radians (Degrees : Scalar) return Scalar
   is (Degrees * Scalar (Ada.Numerics.Pi) / 180.0);

   function To_Degrees (Radians : Scalar) return Scalar
   is (Radians * 180.0 / Scalar (Ada.Numerics.Pi));

   function Translation (Value : Vec3) return Mat4 is
      Result : Mat4 := Identity_4;
   begin
      Result (GL.W, GL.X) := Value (GL.X);
      Result (GL.W, GL.Y) := Value (GL.Y);
      Result (GL.W, GL.Z) := Value (GL.Z);

      return Result;
   end Translation;

   function Scaling (Value : Vec3) return Mat4 is
      Result : Mat4 := Identity_4;
   begin
      Result (GL.X, GL.X) := Value (GL.X);
      Result (GL.Y, GL.Y) := Value (GL.Y);
      Result (GL.Z, GL.Z) := Value (GL.Z);

      return Result;
   end Scaling;

   function Rotation_X (Angle : Scalar) return Mat4 is
      Result : Mat4 := Identity_4;

      C : constant Scalar := Singles.Cos (Angle);
      S : constant Scalar := Singles.Sin (Angle);
   begin
      Result (GL.Y, GL.Y) := C;
      Result (GL.Z, GL.Y) := -S;

      Result (GL.Y, GL.Z) := S;
      Result (GL.Z, GL.Z) := C;

      return Result;
   end Rotation_X;

   function Rotation_Y (Angle : Scalar) return Mat4 is
      Result : Mat4 := Identity_4;

      C : constant Scalar := Singles.Cos (Angle);
      S : constant Scalar := Singles.Sin (Angle);
   begin
      Result (GL.X, GL.X) := C;
      Result (GL.Z, GL.X) := S;

      Result (GL.X, GL.Z) := -S;
      Result (GL.Z, GL.Z) := C;

      return Result;
   end Rotation_Y;

   function Rotation_Z (Angle : Scalar) return Mat4 is
      Result : Mat4 := Identity_4;

      C : constant Scalar := Singles.Cos (Angle);
      S : constant Scalar := Singles.Sin (Angle);
   begin
      Result (GL.X, GL.X) := C;
      Result (GL.Y, GL.X) := -S;

      Result (GL.X, GL.Y) := S;
      Result (GL.Y, GL.Y) := C;

      return Result;
   end Rotation_Z;

   function Perspective
     (Field_Of_View : Scalar;
      Aspect_Ratio  : Scalar;
      Near_Plane    : Scalar;
      Far_Plane     : Scalar) return Mat4
   is
      Result : Mat4 := (others => (others => 0.0));

      F : constant Scalar := 1.0 / Singles.Tan (Field_Of_View / 2.0);
   begin
      Result (GL.X, GL.X) := F / Aspect_Ratio;
      Result (GL.Y, GL.Y) := F;

      Result (GL.Z, GL.Z) :=
        (Far_Plane + Near_Plane) / (Near_Plane - Far_Plane);

      Result (GL.Z, GL.W) := -1.0;

      Result (GL.W, GL.Z) :=
        (2.0 * Far_Plane * Near_Plane) / (Near_Plane - Far_Plane);

      return Result;
   end Perspective;

   function Orthographic
     (Left, Right : Scalar;
      Bottom, Top : Scalar;
      Near_Plane  : Scalar;
      Far_Plane   : Scalar) return Mat4
   is
      Result : Mat4 := Identity_4;
   begin
      Result (GL.X, GL.X) := 2.0 / (Right - Left);

      Result (GL.Y, GL.Y) := 2.0 / (Top - Bottom);

      Result (GL.Z, GL.Z) := -2.0 / (Far_Plane - Near_Plane);

      Result (GL.W, GL.X) := -(Right + Left) / (Right - Left);

      Result (GL.W, GL.Y) := -(Top + Bottom) / (Top - Bottom);

      Result (GL.W, GL.Z) :=
        -(Far_Plane + Near_Plane) / (Far_Plane - Near_Plane);

      return Result;
   end Orthographic;

   function Look_At (Eye : Vec3; Target : Vec3; Up : Vec3) return Mat4 is
      Forward : constant Vec3 := Normalize (Target - Eye);

      Right : constant Vec3 := Normalize (Cross (Forward, Up));

      Camera_Up : constant Vec3 := Cross (Right, Forward);

      Result : Mat4 := Identity_4;
   begin
      Result (GL.X, GL.X) := Right (GL.X);
      Result (GL.Y, GL.X) := Right (GL.Y);
      Result (GL.Z, GL.X) := Right (GL.Z);

      Result (GL.X, GL.Y) := Camera_Up (GL.X);
      Result (GL.Y, GL.Y) := Camera_Up (GL.Y);
      Result (GL.Z, GL.Y) := Camera_Up (GL.Z);

      Result (GL.X, GL.Z) := -Forward (GL.X);
      Result (GL.Y, GL.Z) := -Forward (GL.Y);
      Result (GL.Z, GL.Z) := -Forward (GL.Z);

      Result (GL.W, GL.X) := -Dot (Right, Eye);
      Result (GL.W, GL.Y) := -Dot (Camera_Up, Eye);
      Result (GL.W, GL.Z) := Dot (Forward, Eye);

      return Result;
   end Look_At;

end Math;
