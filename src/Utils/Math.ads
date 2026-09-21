with Ada.Numerics.Generic_Elementary_Functions;
with GL.Types; use GL.Types;

package Math is
   package Singles is new
     Ada.Numerics.Generic_Elementary_Functions (GL.Types.Single);

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
