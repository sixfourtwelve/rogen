with Ada.Finalization;
with Interfaces;
with Interfaces.C;
with System;

package GLTF is

   Model_Error : exception;

   subtype Scalar is Interfaces.C.C_float;
   subtype Index_Value is Interfaces.Unsigned_32;

   type Scalar_Array is array (Natural range <>) of aliased Scalar
   with Convention => C;

   type Index_Array is array (Natural range <>) of aliased Index_Value
   with Convention => C;

   subtype Matrix_4 is Scalar_Array (0 .. 15);

   type Topology is
     (Points,
      Lines,
      Line_Loop,
      Line_Strip,
      Triangles,
      Triangle_Strip,
      Triangle_Fan);

   type Model is tagged limited private;

   procedure Load (Self : in out Model; Path : String);
   procedure Unload (Self : in out Model);
   function Loaded (Self : Model) return Boolean;

   function Mesh_Count (Self : Model) return Natural;
   function Primitive_Count
     (Self : Model; Mesh : Natural) return Natural;

   function Vertex_Count
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Natural;

   function Index_Count
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Natural;

   function Primitive_Topology
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Topology;

   function Has_Normals
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Boolean;

   function Has_Texture_Coordinates
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Boolean;

   function Positions
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Scalar_Array;

   function Normals
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Scalar_Array;

   function Texture_Coordinates
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Scalar_Array;

   function Indices
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Index_Array;

   function Node_Count (Self : Model) return Natural;
   function Node_Has_Mesh
     (Self : Model; Node : Natural) return Boolean;
   function Node_Mesh
     (Self : Model; Node : Natural) return Natural;
   function Node_World_Transform
     (Self : Model; Node : Natural) return Matrix_4;

private

   type Model is new Ada.Finalization.Limited_Controlled with record
      Handle : System.Address := System.Null_Address;
   end record;

   overriding
   procedure Finalize (Self : in out Model);

end GLTF;
