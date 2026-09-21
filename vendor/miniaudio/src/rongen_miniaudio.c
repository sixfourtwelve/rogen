#define MINIAUDIO_IMPLEMENTATION
#include "../upstream/miniaudio.h"

#include "../include/rongen_miniaudio.h"

#include <stdlib.h>

struct rongen_audio_engine {
    ma_engine value;
    size_t reference_count;
};

struct rongen_audio_sound {
    ma_sound value;
    rongen_audio_engine *engine;
};

static void rongen_audio_engine_retain(rongen_audio_engine *engine)
{
    engine->reference_count += 1;
}

static void rongen_audio_engine_release(rongen_audio_engine *engine)
{
    engine->reference_count -= 1;
    if (engine->reference_count == 0) {
        ma_engine_uninit(&engine->value);
        free(engine);
    }
}

int rongen_audio_engine_create(rongen_audio_engine **out_engine)
{
    rongen_audio_engine *engine;
    ma_result result;

    if (out_engine == NULL) {
        return MA_INVALID_ARGS;
    }

    *out_engine = NULL;
    engine = (rongen_audio_engine *)calloc(1, sizeof(*engine));
    if (engine == NULL) {
        return MA_OUT_OF_MEMORY;
    }

    result = ma_engine_init(NULL, &engine->value);
    if (result != MA_SUCCESS) {
        free(engine);
        return result;
    }

    engine->reference_count = 1;
    *out_engine = engine;
    return MA_SUCCESS;
}

void rongen_audio_engine_destroy(rongen_audio_engine *engine)
{
    if (engine == NULL) {
        return;
    }

    rongen_audio_engine_release(engine);
}

int rongen_audio_engine_set_volume(
    rongen_audio_engine *engine,
    float volume)
{
    if (engine == NULL) {
        return MA_INVALID_ARGS;
    }

    return ma_engine_set_volume(&engine->value, volume);
}

int rongen_audio_sound_create(
    rongen_audio_engine *engine,
    const char *path,
    rongen_audio_sound **out_sound)
{
    rongen_audio_sound *sound;
    ma_result result;

    if (engine == NULL || path == NULL || out_sound == NULL) {
        return MA_INVALID_ARGS;
    }

    *out_sound = NULL;
    sound = (rongen_audio_sound *)calloc(1, sizeof(*sound));
    if (sound == NULL) {
        return MA_OUT_OF_MEMORY;
    }

    result = ma_sound_init_from_file(
        &engine->value,
        path,
        0,
        NULL,
        NULL,
        &sound->value);
    if (result != MA_SUCCESS) {
        free(sound);
        return result;
    }

    rongen_audio_engine_retain(engine);
    sound->engine = engine;
    *out_sound = sound;
    return MA_SUCCESS;
}

void rongen_audio_sound_destroy(rongen_audio_sound *sound)
{
    rongen_audio_engine *engine;

    if (sound == NULL) {
        return;
    }

    engine = sound->engine;
    ma_sound_uninit(&sound->value);
    free(sound);
    rongen_audio_engine_release(engine);
}

int rongen_audio_sound_start(rongen_audio_sound *sound)
{
    if (sound == NULL) {
        return MA_INVALID_ARGS;
    }

    return ma_sound_start(&sound->value);
}

int rongen_audio_sound_stop(rongen_audio_sound *sound)
{
    if (sound == NULL) {
        return MA_INVALID_ARGS;
    }

    return ma_sound_stop(&sound->value);
}

int rongen_audio_sound_seek_to_start(rongen_audio_sound *sound)
{
    if (sound == NULL) {
        return MA_INVALID_ARGS;
    }

    return ma_sound_seek_to_pcm_frame(&sound->value, 0);
}

int rongen_audio_sound_set_volume(
    rongen_audio_sound *sound,
    float volume)
{
    if (sound == NULL) {
        return MA_INVALID_ARGS;
    }

    ma_sound_set_volume(&sound->value, volume);
    return MA_SUCCESS;
}

int rongen_audio_sound_set_looping(
    rongen_audio_sound *sound,
    int enabled)
{
    if (sound == NULL) {
        return MA_INVALID_ARGS;
    }

    ma_sound_set_looping(&sound->value, enabled != 0 ? MA_TRUE : MA_FALSE);
    return MA_SUCCESS;
}

int rongen_audio_sound_is_playing(const rongen_audio_sound *sound)
{
    if (sound == NULL) {
        return 0;
    }

    return ma_sound_is_playing(&sound->value) == MA_TRUE ? 1 : 0;
}

const char *rongen_audio_result_description(int result)
{
    return ma_result_description((ma_result)result);
}
