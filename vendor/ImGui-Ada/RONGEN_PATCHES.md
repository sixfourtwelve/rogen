# Local ImGui-Ada patches

This directory vendors ImGui-Ada at commit
`0864e5314aef605f7edc6f841dec1a23ef7b43a6`. The root project pins it because
it is not published in the Alire index.

GNAT 16 compatibility changes:

- `src/binding/dear_imgui-contexts.ads`: use named generic associations when
  leaving the `P_Types` formal unspecified. GNAT 16 rejects a positional box
  after a supplied positional actual.
- `src/binding/dear_imgui.adb`: convert each static string buffer's address to
  `Interfaces.C.Strings.char_array_access` explicitly. GNAT 16 requires the
  aliased object's constrained subtype to statically match the access type's
  unconstrained designated subtype when using `Unchecked_Access` directly.

Remove these patches if the vendored binding is upgraded to a revision that
supports the active GNAT toolchain without them.
