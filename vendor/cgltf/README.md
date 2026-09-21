# Rongen cgltf wrapper

This directory contains Rongen's Ada-facing wrapper around
[cgltf](https://github.com/jkuhlmann/cgltf), a C99 glTF 2.0 loader.

## Upstream version

- Version: `1.15`
- Header SHA-256: `e378a21c084bf1f288bb799de827bb26906efb024255f1ecf1705ea13f11c6ec`
- License SHA-256: `f619925f80ef862497aaf8e8155ef218fa6a2190055129523ca3df9119a9ba95`
- License: MIT

The upstream files are intentionally kept unchanged in `upstream/`.

## Layout

- `upstream/cgltf.h`: pinned upstream single-header library.
- `upstream/LICENSE`: upstream license text.
- `include/rongen_cgltf.h`: stable C ABI consumed by Ada.
- `src/rongen_cgltf.c`: narrow C implementation.
- `src/gltf.ads`: public Ada API.
- `src/gltf.adb`: Ada/C binding and controlled cleanup.
- `rongen_cgltf.gpr`: static-library project imported by `rongen.gpr`.

## Current scope

The wrapper loads `.gltf` and `.glb` files and exposes:

- Mesh and primitive counts.
- Primitive topology.
- Positions, normals, and the first texture-coordinate set.
- Explicit or generated 32-bit indices.
- Node-to-mesh associations.
- Node world transforms.

The wrapper intentionally does not yet expose materials, embedded images,
animation, skinning, morph targets, or compressed mesh extensions. cgltf parses
these features, so the wrapper can be extended without replacing the backend.

## Ada usage

```ada
with GLTF;

procedure Example is
   Model : GLTF.Model;
begin
   Model.Load ("assets/models/scene.glb");

   if Model.Mesh_Count > 0 then
      for Mesh in 0 .. Model.Mesh_Count - 1 loop
         if Model.Primitive_Count (Mesh) > 0 then
            for Primitive in 0 .. Model.Primitive_Count (Mesh) - 1 loop
               declare
                  Positions : constant GLTF.Scalar_Array :=
                    Model.Positions (Mesh, Primitive);
                  Indices : constant GLTF.Index_Array :=
                    Model.Indices (Mesh, Primitive);
               begin
                  --  Upload Positions and Indices to GPU buffers.
                  null;
               end;
            end loop;
         end if;
      end loop;
   end if;
end Example;
```

Empty glTF models are valid, so check counts before loops whose upper bound
subtracts one.

## Updating

When updating cgltf:

1. Replace only `upstream/cgltf.h` and `upstream/LICENSE`.
2. Update the pinned version and hashes above.
3. Build the static library and run geometry extraction tests.
4. Review cgltf's changelog for parser or accessor changes.
