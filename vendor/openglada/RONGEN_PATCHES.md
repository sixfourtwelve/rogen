# Local OpenGLAda patches

This directory vendors OpenGLAda 0.9.0 from upstream tag `v0.9.0`
(commit `058254a300be53afb1bf6ae9e55d0235f7f4ab52`). It is pinned from the
root `alire.toml` because the published crate does not compile with GNAT 16.

Local changes:

- `src/implementation/gl-debug.adb`: explicitly convert the anonymous access
  parameter to `Conv.Object_Pointer` before calling `Conv.To_Address`.
- `src/interface/gl-raster.ads`: remove a redundant `use GL.Types` clause.
  OpenGLAda promotes warnings to errors, so GNAT 16 otherwise rejects it.

OpenGLAda is no longer maintained upstream, so this vendored source is the
project's maintained copy. Preserve the pin and these patches unless the
renderer is deliberately migrated to another OpenGL binding.
