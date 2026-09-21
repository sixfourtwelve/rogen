#ifndef RONGEN_MINIAUDIO_H
#define RONGEN_MINIAUDIO_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct rongen_audio_engine rongen_audio_engine;
typedef struct rongen_audio_sound rongen_audio_sound;

/*
 * Creates the process audio engine. The caller owns the returned handle.
 * Associated sounds retain the underlying engine until they are destroyed.
 *
 * Returns zero on success or a miniaudio result code on failure.
 */
int rongen_audio_engine_create(rongen_audio_engine **out_engine);
void rongen_audio_engine_destroy(rongen_audio_engine *engine);

int rongen_audio_engine_set_volume(
    rongen_audio_engine *engine,
    float volume);

/*
 * Loads a sound from disk. The sound retains the underlying engine while
 * preserving separate ownership of both public handles.
 */
int rongen_audio_sound_create(
    rongen_audio_engine *engine,
    const char *path,
    rongen_audio_sound **out_sound);

void rongen_audio_sound_destroy(rongen_audio_sound *sound);

int rongen_audio_sound_start(rongen_audio_sound *sound);
int rongen_audio_sound_stop(rongen_audio_sound *sound);
int rongen_audio_sound_seek_to_start(rongen_audio_sound *sound);

int rongen_audio_sound_set_volume(
    rongen_audio_sound *sound,
    float volume);

int rongen_audio_sound_set_looping(
    rongen_audio_sound *sound,
    int enabled);

int rongen_audio_sound_is_playing(const rongen_audio_sound *sound);

/* The returned description is static storage and must not be freed. */
const char *rongen_audio_result_description(int result);

#ifdef __cplusplus
}
#endif

#endif
