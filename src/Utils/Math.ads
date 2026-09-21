with Ada.Numerics.Generic_Elementary_Functions;
with GL.Types; use GL.Types;
with GL.Types.Colors;

package Math is

   subtype Scalar is GL.Types.Single;

   subtype Vec2 is GL.Types.Singles.Vector2;
   subtype Vec3 is GL.Types.Singles.Vector3;
   subtype Vec4 is GL.Types.Singles.Vector4;

   subtype Mat2 is GL.Types.Singles.Matrix2;
   subtype Mat3 is GL.Types.Singles.Matrix3;
   subtype Mat4 is GL.Types.Singles.Matrix4;

   subtype Color is GL.Types.Colors.Color;

   package Singles is new Ada.Numerics.Generic_Elementary_Functions (Scalar);

   Identity_2 : constant Mat2 := GL.Types.Singles.Identity2;
   Identity_3 : constant Mat3 := GL.Types.Singles.Identity3;
   Identity_4 : constant Mat4 := GL.Types.Singles.Identity4;

   Zero : constant Vec3 := [0.0, 0.0, 0.0];
   One  : constant Vec3 := [1.0, 1.0, 1.0];

   Right   : constant Vec3 := [1.0, 0.0, 0.0];
   Left    : constant Vec3 := [-1.0, 0.0, 0.0];
   Up      : constant Vec3 := [0.0, 1.0, 0.0];
   Down    : constant Vec3 := [0.0, -1.0, 0.0];
   Forward : constant Vec3 := [0.0, 0.0, -1.0];
   Back    : constant Vec3 := [0.0, 0.0, 1.0];

   function Length (Value : Vec3) return Scalar;

   function Length_Squared (Value : Vec3) return Scalar;

   function Normalize (Value : Vec3) return Vec3;

   function Distance (Left, Right : Vec3) return Scalar;

   function Distance_Squared (Left, Right : Vec3) return Scalar;

   function Dot (Left, Right : Vec3) return Scalar;

   function Cross (Left, Right : Vec3) return Vec3;

   function Lerp (From, To : Vec3; Amount : Scalar) return Vec3;

   function Min (Left, Right : Vec3) return Vec3;

   function Max (Left, Right : Vec3) return Vec3;

   function Clamp (Value, Minimum, Maximum : Scalar) return Scalar
   with Pre => Minimum <= Maximum;

   function Saturate (Value : Scalar) return Scalar;

   function To_Radians (Degrees : Scalar) return Scalar;

   function To_Degrees (Radians : Scalar) return Scalar;

   function Translation (Value : Vec3) return Mat4;

   function Scaling (Value : Vec3) return Mat4;

   function Rotation_X (Angle : Scalar) return Mat4;

   function Rotation_Y (Angle : Scalar) return Mat4;

   function Rotation_Z (Angle : Scalar) return Mat4;

   function Perspective
     (Field_Of_View : Scalar;
      Aspect_Ratio  : Scalar;
      Near_Plane    : Scalar;
      Far_Plane     : Scalar) return Mat4
   with
     Pre => Aspect_Ratio > 0.0 and Near_Plane > 0.0 and Far_Plane > Near_Plane;

   function Orthographic
     (Left, Right : Scalar;
      Bottom, Top : Scalar;
      Near_Plane  : Scalar;
      Far_Plane   : Scalar) return Mat4
   with Pre => Left /= Right and Bottom /= Top and Near_Plane /= Far_Plane;

   function Look_At (Eye : Vec3; Target : Vec3; Up : Vec3) return Mat4;

   --  Vertices for basic use. Will probably be removed at some point.
   Triangle_Vertices : constant GL.Types.Single_Array :=
     [-0.5,
      -0.5,
      0.0,
      0.0,
      0.0,

      0.5,
      -0.5,
      0.0,
      1.0,
      0.0,

      0.0,
      0.5,
      0.0,
      0.5,
      1.0];

end Math;
