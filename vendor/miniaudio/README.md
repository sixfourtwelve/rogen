# Rongen miniaudio shim

This directory contains Rongen's narrow C interface to
[miniaudio](https://github.com/mackron/miniaudio).

## Upstream version

- Version: `0.11.25`
- Release date: 2026-03-04
- Header SHA-256: `ac7af4de748b7e26b777f37e01cee313a308a7296a3eb080e2906b320cc55c89`
- License SHA-256: `457f1b500e0adf6bc059edddfa78a2f62012e7c3bb43476c20e0bd23b25ba0eb`
- License: public domain or MIT No Attribution, at the user's choice

The upstream files are intentionally kept unchanged in `upstream/`.

## Layout

- `upstream/miniaudio.h`: pinned upstream single-header library.
- `upstream/LICENSE`: upstream license text.
- `include/rongen_miniaudio.h`: stable API consumed by Ada bindings.
- `src/rongen_miniaudio.c`: implementation and ownership boundary.
- `src/miniaudio.ads`: public Ada API.
- `src/miniaudio.adb`: Ada/C binding and controlled cleanup.
- `rongen_miniaudio.gpr`: static-library project imported by `rongen.gpr`.

## Ownership

The shim allocates opaque engine and sound handles in C. Sounds retain the
underlying engine, so controlled finalization remains safe even if an engine's
Ada handle is finalized before one of its sounds. Declaring the engine before
its sounds is still recommended because Ada then finalizes the sounds first.

Destroy functions accept null pointers. Other C functions return a miniaudio
result code, where zero means success. The Ada layer translates failures into
`Miniaudio.Audio_Error` with the diagnostic returned by
`rongen_audio_result_description()`.

No callback crosses the C/Ada boundary. This is intentional: miniaudio may invoke
callbacks from its audio threads, and Ada exceptions must never cross a C ABI
boundary.

## Ada usage

```ada
with Miniaudio;

procedure Example is
   Engine : Miniaudio.Engine;
   Music  : Miniaudio.Sound;
begin
   Engine.Create;
   Engine.Set_Volume (0.8);

   Music.Load (Engine, "assets/audio/music.wav");
   Music.Set_Looping (True);
   Music.Play;
end Example;
```

`Engine` is declared before `Music`, so normal reverse-order finalization unloads
the sound before releasing the engine. The C ownership layer also retains the
underlying engine until its final sound is destroyed.

## Updating

When updating miniaudio:

1. Replace only `upstream/miniaudio.h` and `upstream/LICENSE`.
2. Update the pinned version and hashes above.
3. Build the static library and run the engine smoke test.
4. Review miniaudio's changelog for API, ABI, backend, and decoder changes.
