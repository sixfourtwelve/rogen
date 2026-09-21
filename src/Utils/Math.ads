with Ada.Numerics.Generic_Elementary_Functions;
with GL.Types;

package Math is
   package Singles is new
     Ada.Numerics.Generic_Elementary_Functions (GL.Types.Single);
end Math;
