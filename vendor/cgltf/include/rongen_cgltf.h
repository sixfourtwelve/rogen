#ifndef RONGEN_CGLTF_H
#define RONGEN_CGLTF_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct rongen_gltf_model rongen_gltf_model;

enum rongen_gltf_result {
    RONGEN_GLTF_SUCCESS = 0,
    RONGEN_GLTF_INVALID_ARGUMENTS = 100,
    RONGEN_GLTF_INDEX_OUT_OF_RANGE = 101,
    RONGEN_GLTF_MISSING_ATTRIBUTE = 102,
    RONGEN_GLTF_BUFFER_TOO_SMALL = 103,
    RONGEN_GLTF_UNSUPPORTED_DATA = 104
};

int rongen_gltf_model_load(
    const char *path,
    rongen_gltf_model **out_model);

void rongen_gltf_model_destroy(rongen_gltf_model *model);

size_t rongen_gltf_mesh_count(const rongen_gltf_model *model);
size_t rongen_gltf_primitive_count(
    const rongen_gltf_model *model,
    size_t mesh_index);

size_t rongen_gltf_vertex_count(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index);

size_t rongen_gltf_index_count(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index);

int rongen_gltf_primitive_topology(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index);

int rongen_gltf_has_normals(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index);

int rongen_gltf_has_texture_coordinates(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index);

int rongen_gltf_read_positions(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index,
    float *values,
    size_t value_capacity);

int rongen_gltf_read_normals(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index,
    float *values,
    size_t value_capacity);

int rongen_gltf_read_texture_coordinates(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index,
    float *values,
    size_t value_capacity);

int rongen_gltf_read_indices(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index,
    uint32_t *values,
    size_t value_capacity);

size_t rongen_gltf_node_count(const rongen_gltf_model *model);

int rongen_gltf_node_has_mesh(
    const rongen_gltf_model *model,
    size_t node_index);

int rongen_gltf_node_mesh_index(
    const rongen_gltf_model *model,
    size_t node_index,
    size_t *mesh_index);

int rongen_gltf_node_world_transform(
    const rongen_gltf_model *model,
    size_t node_index,
    float *matrix,
    size_t value_capacity);

const char *rongen_gltf_result_description(int result);

#ifdef __cplusplus
}
#endif

#endif
