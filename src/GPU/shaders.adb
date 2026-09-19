with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;

package body Shaders is
   use Ada.Text_IO;

   function Make_Shader_Module
     (Filename : String; Module_Type : Shaders.Shader_Type)
      return Shaders.Shader
   is
      Module      : Shaders.Shader (Module_Type);
      Source_File : File_Type;
      Source_Code : Unbounded_String;
   begin

      Open (Source_File, In_File, Filename);
      while not End_Of_File (Source_File) loop
         Ada.Strings.Unbounded.Append
           (Source_Code, Get_Line (Source_File) & Character'Val (10));
      end loop;
      Close (Source_File);

      Module.Initialize_Id;
      Module.Set_Source (To_String (Source_Code));
      Module.Compile;

      if not Module.Compile_Status then
         Put_Line (Filename & " compilation failed.");
         Put_Line (Shaders.Info_Log (Module));
      end if;

      return Module;
   end Make_Shader_Module;

   function Make_Shader_Program
     (Vertex_Filename, Fragment_Filename : String) return Programs.Program
   is
      Program : Programs.Program;
   begin
      Program.Initialize_Id;
      Program.Attach
        (Make_Shader_Module (Vertex_Filename, Shaders.Vertex_Shader));
      Program.Attach
        (Make_Shader_Module (Fragment_Filename, Shaders.Fragment_Shader));
      Program.Link;
      if not Program.Link_Status then
         Put_Line ("Module Linking failed.");
         Put_Line (Programs.Info_Log (Program));
      end if;

      Shaders.Release_Shader_Compiler;
      return Program;
   end Make_Shader_Program;

end Shaders;
