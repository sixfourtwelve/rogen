with GL.Objects.Programs;
with GL.Objects.Shaders;

package Shaders is

   package Programs renames GL.Objects.Programs;
   package Shaders renames GL.Objects.Shaders;

   function Make_Shader_Module
     (Filename : String; Module_Type : Shaders.Shader_Type)
      return Shaders.Shader;

   function Make_Shader_Program
     (Vertex_Filename, Fragment_Filename : String) return Programs.Program;

   Shader : Programs.Program;

end Shaders;
