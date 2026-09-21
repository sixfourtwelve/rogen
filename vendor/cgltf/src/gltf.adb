with Interfaces.C.Strings;

package body GLTF is
   use type Interfaces.C.int;
   use type Interfaces.C.Strings.chars_ptr;
   use type System.Address;

   Success : constant Interfaces.C.int := 0;

   function C_Model_Load
     (Path   : Interfaces.C.Strings.chars_ptr;
      Handle : access System.Address) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_model_load";

   procedure C_Model_Destroy (Handle : System.Address)
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_model_destroy";

   function C_Mesh_Count
     (Handle : System.Address) return Interfaces.C.size_t
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_mesh_count";

   function C_Primitive_Count
     (Handle : System.Address;
      Mesh   : Interfaces.C.size_t) return Interfaces.C.size_t
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_primitive_count";

   function C_Vertex_Count
     (Handle    : System.Address;
      Mesh      : Interfaces.C.size_t;
      Primitive : Interfaces.C.size_t) return Interfaces.C.size_t
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_vertex_count";

   function C_Index_Count
     (Handle    : System.Address;
      Mesh      : Interfaces.C.size_t;
      Primitive : Interfaces.C.size_t) return Interfaces.C.size_t
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_index_count";

   function C_Primitive_Topology
     (Handle    : System.Address;
      Mesh      : Interfaces.C.size_t;
      Primitive : Interfaces.C.size_t) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_primitive_topology";

   function C_Has_Normals
     (Handle    : System.Address;
      Mesh      : Interfaces.C.size_t;
      Primitive : Interfaces.C.size_t) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_has_normals";

   function C_Has_Texture_Coordinates
     (Handle    : System.Address;
      Mesh      : Interfaces.C.size_t;
      Primitive : Interfaces.C.size_t) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_has_texture_coordinates";

   function C_Read_Positions
     (Handle    : System.Address;
      Mesh      : Interfaces.C.size_t;
      Primitive : Interfaces.C.size_t;
      Values    : System.Address;
      Capacity  : Interfaces.C.size_t) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_read_positions";

   function C_Read_Normals
     (Handle    : System.Address;
      Mesh      : Interfaces.C.size_t;
      Primitive : Interfaces.C.size_t;
      Values    : System.Address;
      Capacity  : Interfaces.C.size_t) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_read_normals";

   function C_Read_Texture_Coordinates
     (Handle    : System.Address;
      Mesh      : Interfaces.C.size_t;
      Primitive : Interfaces.C.size_t;
      Values    : System.Address;
      Capacity  : Interfaces.C.size_t) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_read_texture_coordinates";

   function C_Read_Indices
     (Handle    : System.Address;
      Mesh      : Interfaces.C.size_t;
      Primitive : Interfaces.C.size_t;
      Values    : System.Address;
      Capacity  : Interfaces.C.size_t) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_read_indices";

   function C_Node_Count
     (Handle : System.Address) return Interfaces.C.size_t
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_node_count";

   function C_Node_Has_Mesh
     (Handle : System.Address;
      Node   : Interfaces.C.size_t) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_node_has_mesh";

   function C_Node_Mesh_Index
     (Handle : System.Address;
      Node   : Interfaces.C.size_t;
      Mesh   : access Interfaces.C.size_t) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_node_mesh_index";

   function C_Node_World_Transform
     (Handle   : System.Address;
      Node     : Interfaces.C.size_t;
      Matrix   : System.Address;
      Capacity : Interfaces.C.size_t) return Interfaces.C.int
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_node_world_transform";

   function C_Result_Description
     (Result : Interfaces.C.int) return Interfaces.C.Strings.chars_ptr
   with Import,
        Convention    => C,
        External_Name => "rongen_gltf_result_description";

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
         raise Model_Error with
           Operation & " failed with result" & Interfaces.C.int'Image (Result);
      end if;

      raise Model_Error with
        Operation & " failed: " & Interfaces.C.Strings.Value (Description);
   end Check;

   procedure Require_Loaded (Self : Model) is
   begin
      if not Loaded (Self) then
         raise Program_Error with "glTF model is not loaded";
      end if;
   end Require_Loaded;

   procedure Require_Mesh (Self : Model; Mesh : Natural) is
   begin
      Require_Loaded (Self);
      if Mesh >= Mesh_Count (Self) then
         raise Constraint_Error with "glTF mesh index is out of range";
      end if;
   end Require_Mesh;

   procedure Require_Primitive
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural)
   is
   begin
      Require_Mesh (Self, Mesh);
      if Primitive >= Primitive_Count (Self, Mesh) then
         raise Constraint_Error with "glTF primitive index is out of range";
      end if;
   end Require_Primitive;

   procedure Require_Node (Self : Model; Node : Natural) is
   begin
      Require_Loaded (Self);
      if Node >= Node_Count (Self) then
         raise Constraint_Error with "glTF node index is out of range";
      end if;
   end Require_Node;

   procedure Load (Self : in out Model; Path : String) is
      C_Path     : Interfaces.C.Strings.chars_ptr :=
        Interfaces.C.Strings.Null_Ptr;
      New_Handle : aliased System.Address := System.Null_Address;
      Result     : Interfaces.C.int;
   begin
      if Self.Loaded then
         raise Program_Error with "glTF model is already loaded";
      end if;

      C_Path := Interfaces.C.Strings.New_String (Path);
      Result := C_Model_Load (C_Path, New_Handle'Access);
      Interfaces.C.Strings.Free (C_Path);
      Check (Result, "loading glTF model '" & Path & "'");
      Self.Handle := New_Handle;
   exception
      when others =>
         Interfaces.C.Strings.Free (C_Path);
         if New_Handle /= System.Null_Address then
            C_Model_Destroy (New_Handle);
         end if;
         raise;
   end Load;

   procedure Unload (Self : in out Model) is
   begin
      if Self.Handle /= System.Null_Address then
         C_Model_Destroy (Self.Handle);
         Self.Handle := System.Null_Address;
      end if;
   end Unload;

   function Loaded (Self : Model) return Boolean is
     (Self.Handle /= System.Null_Address);

   function Mesh_Count (Self : Model) return Natural is
   begin
      Require_Loaded (Self);
      return Natural (C_Mesh_Count (Self.Handle));
   end Mesh_Count;

   function Primitive_Count
     (Self : Model; Mesh : Natural) return Natural
   is
   begin
      Require_Mesh (Self, Mesh);
      return Natural
        (C_Primitive_Count (Self.Handle, Interfaces.C.size_t (Mesh)));
   end Primitive_Count;

   function Vertex_Count
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Natural
   is
   begin
      Require_Primitive (Self, Mesh, Primitive);
      return Natural
        (C_Vertex_Count
           (Self.Handle,
            Interfaces.C.size_t (Mesh),
            Interfaces.C.size_t (Primitive)));
   end Vertex_Count;

   function Index_Count
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Natural
   is
   begin
      Require_Primitive (Self, Mesh, Primitive);
      return Natural
        (C_Index_Count
           (Self.Handle,
            Interfaces.C.size_t (Mesh),
            Interfaces.C.size_t (Primitive)));
   end Index_Count;

   function Primitive_Topology
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Topology
   is
      Value : Interfaces.C.int;
   begin
      Require_Primitive (Self, Mesh, Primitive);
      Value :=
        C_Primitive_Topology
          (Self.Handle,
           Interfaces.C.size_t (Mesh),
           Interfaces.C.size_t (Primitive));

      case Value is
         when 1 =>
            return Points;
         when 2 =>
            return Lines;
         when 3 =>
            return Line_Loop;
         when 4 =>
            return Line_Strip;
         when 5 =>
            return Triangles;
         when 6 =>
            return Triangle_Strip;
         when 7 =>
            return Triangle_Fan;
         when others =>
            raise Model_Error with "glTF primitive topology is invalid";
      end case;
   end Primitive_Topology;

   function Has_Normals
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Boolean
   is
   begin
      Require_Primitive (Self, Mesh, Primitive);
      return
        C_Has_Normals
          (Self.Handle,
           Interfaces.C.size_t (Mesh),
           Interfaces.C.size_t (Primitive)) /= 0;
   end Has_Normals;

   function Has_Texture_Coordinates
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Boolean
   is
   begin
      Require_Primitive (Self, Mesh, Primitive);
      return
        C_Has_Texture_Coordinates
          (Self.Handle,
           Interfaces.C.size_t (Mesh),
           Interfaces.C.size_t (Primitive)) /= 0;
   end Has_Texture_Coordinates;

   function Positions
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Scalar_Array
   is
      Count : constant Natural := Vertex_Count (Self, Mesh, Primitive);
   begin
      if Count = 0 then
         raise Model_Error with "glTF primitive has no position data";
      end if;

      return Values : Scalar_Array (0 .. Count * 3 - 1) do
         Check
           (C_Read_Positions
              (Self.Handle,
               Interfaces.C.size_t (Mesh),
               Interfaces.C.size_t (Primitive),
               Values (Values'First)'Address,
               Interfaces.C.size_t (Values'Length)),
            "reading glTF positions");
      end return;
   end Positions;

   function Normals
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Scalar_Array
   is
      Count : constant Natural := Vertex_Count (Self, Mesh, Primitive);
   begin
      if not Has_Normals (Self, Mesh, Primitive) then
         raise Model_Error with "glTF primitive has no normal data";
      end if;

      return Values : Scalar_Array (0 .. Count * 3 - 1) do
         Check
           (C_Read_Normals
              (Self.Handle,
               Interfaces.C.size_t (Mesh),
               Interfaces.C.size_t (Primitive),
               Values (Values'First)'Address,
               Interfaces.C.size_t (Values'Length)),
            "reading glTF normals");
      end return;
   end Normals;

   function Texture_Coordinates
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Scalar_Array
   is
      Count : constant Natural := Vertex_Count (Self, Mesh, Primitive);
   begin
      if not Has_Texture_Coordinates (Self, Mesh, Primitive) then
         raise Model_Error with
           "glTF primitive has no texture coordinate data";
      end if;

      return Values : Scalar_Array (0 .. Count * 2 - 1) do
         Check
           (C_Read_Texture_Coordinates
              (Self.Handle,
               Interfaces.C.size_t (Mesh),
               Interfaces.C.size_t (Primitive),
               Values (Values'First)'Address,
               Interfaces.C.size_t (Values'Length)),
            "reading glTF texture coordinates");
      end return;
   end Texture_Coordinates;

   function Indices
     (Self      : Model;
      Mesh      : Natural;
      Primitive : Natural) return Index_Array
   is
      Count : constant Natural := Index_Count (Self, Mesh, Primitive);
   begin
      if Count = 0 then
         raise Model_Error with "glTF primitive has no indexable vertices";
      end if;

      return Values : Index_Array (0 .. Count - 1) do
         Check
           (C_Read_Indices
              (Self.Handle,
               Interfaces.C.size_t (Mesh),
               Interfaces.C.size_t (Primitive),
               Values (Values'First)'Address,
               Interfaces.C.size_t (Values'Length)),
            "reading glTF indices");
      end return;
   end Indices;

   function Node_Count (Self : Model) return Natural is
   begin
      Require_Loaded (Self);
      return Natural (C_Node_Count (Self.Handle));
   end Node_Count;

   function Node_Has_Mesh
     (Self : Model; Node : Natural) return Boolean
   is
   begin
      Require_Node (Self, Node);
      return
        C_Node_Has_Mesh (Self.Handle, Interfaces.C.size_t (Node)) /= 0;
   end Node_Has_Mesh;

   function Node_Mesh
     (Self : Model; Node : Natural) return Natural
   is
      Mesh : aliased Interfaces.C.size_t;
   begin
      Require_Node (Self, Node);
      Check
        (C_Node_Mesh_Index
           (Self.Handle, Interfaces.C.size_t (Node), Mesh'Access),
         "reading glTF node mesh");
      return Natural (Mesh);
   end Node_Mesh;

   function Node_World_Transform
     (Self : Model; Node : Natural) return Matrix_4
   is
   begin
      Require_Node (Self, Node);
      return Value : Matrix_4 do
         Check
           (C_Node_World_Transform
              (Self.Handle,
               Interfaces.C.size_t (Node),
               Value (Value'First)'Address,
               Interfaces.C.size_t (Value'Length)),
            "reading glTF node transform");
      end return;
   end Node_World_Transform;

   overriding
   procedure Finalize (Self : in out Model) is
   begin
      Self.Unload;
   end Finalize;

end GLTF;
