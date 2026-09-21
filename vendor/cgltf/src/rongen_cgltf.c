#define CGLTF_IMPLEMENTATION
#include "../upstream/cgltf.h"

#include "../include/rongen_cgltf.h"

#include <limits.h>
#include <stdlib.h>

struct rongen_gltf_model {
    cgltf_data *data;
};

static const cgltf_primitive *rongen_gltf_primitive(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index)
{
    const cgltf_mesh *mesh;

    if (model == NULL || model->data == NULL ||
        mesh_index >= model->data->meshes_count) {
        return NULL;
    }

    mesh = &model->data->meshes[mesh_index];
    if (primitive_index >= mesh->primitives_count) {
        return NULL;
    }

    return &mesh->primitives[primitive_index];
}

static const cgltf_accessor *rongen_gltf_attribute(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index,
    cgltf_attribute_type type,
    cgltf_int attribute_index)
{
    const cgltf_primitive *primitive =
        rongen_gltf_primitive(model, mesh_index, primitive_index);

    if (primitive == NULL) {
        return NULL;
    }

    return cgltf_find_accessor(primitive, type, attribute_index);
}

static int rongen_gltf_read_float_attribute(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index,
    cgltf_attribute_type type,
    cgltf_int attribute_index,
    size_t components,
    float *values,
    size_t value_capacity)
{
    const cgltf_accessor *accessor = rongen_gltf_attribute(
        model,
        mesh_index,
        primitive_index,
        type,
        attribute_index);
    size_t required;
    size_t unpacked;

    if (accessor == NULL) {
        return rongen_gltf_primitive(model, mesh_index, primitive_index) == NULL
            ? RONGEN_GLTF_INDEX_OUT_OF_RANGE
            : RONGEN_GLTF_MISSING_ATTRIBUTE;
    }

    if (accessor->count > SIZE_MAX / components) {
        return RONGEN_GLTF_UNSUPPORTED_DATA;
    }

    required = accessor->count * components;
    if (values == NULL || value_capacity < required) {
        return RONGEN_GLTF_BUFFER_TOO_SMALL;
    }

    unpacked = cgltf_accessor_unpack_floats(accessor, values, required);
    if (unpacked != required) {
        return RONGEN_GLTF_UNSUPPORTED_DATA;
    }

    return RONGEN_GLTF_SUCCESS;
}

int rongen_gltf_model_load(
    const char *path,
    rongen_gltf_model **out_model)
{
    cgltf_options options = {0};
    cgltf_data *data = NULL;
    rongen_gltf_model *model;
    cgltf_result result;

    if (path == NULL || out_model == NULL) {
        return RONGEN_GLTF_INVALID_ARGUMENTS;
    }

    *out_model = NULL;

    result = cgltf_parse_file(&options, path, &data);
    if (result != cgltf_result_success) {
        return (int)result;
    }

    result = cgltf_load_buffers(&options, data, path);
    if (result != cgltf_result_success) {
        cgltf_free(data);
        return (int)result;
    }

    result = cgltf_validate(data);
    if (result != cgltf_result_success) {
        cgltf_free(data);
        return (int)result;
    }

    model = (rongen_gltf_model *)calloc(1, sizeof(*model));
    if (model == NULL) {
        cgltf_free(data);
        return (int)cgltf_result_out_of_memory;
    }

    model->data = data;
    *out_model = model;
    return RONGEN_GLTF_SUCCESS;
}

void rongen_gltf_model_destroy(rongen_gltf_model *model)
{
    if (model == NULL) {
        return;
    }

    cgltf_free(model->data);
    free(model);
}

size_t rongen_gltf_mesh_count(const rongen_gltf_model *model)
{
    return model == NULL || model->data == NULL
        ? 0
        : model->data->meshes_count;
}

size_t rongen_gltf_primitive_count(
    const rongen_gltf_model *model,
    size_t mesh_index)
{
    if (model == NULL || model->data == NULL ||
        mesh_index >= model->data->meshes_count) {
        return 0;
    }

    return model->data->meshes[mesh_index].primitives_count;
}

size_t rongen_gltf_vertex_count(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index)
{
    const cgltf_accessor *positions = rongen_gltf_attribute(
        model,
        mesh_index,
        primitive_index,
        cgltf_attribute_type_position,
        0);

    return positions == NULL ? 0 : positions->count;
}

size_t rongen_gltf_index_count(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index)
{
    const cgltf_primitive *primitive =
        rongen_gltf_primitive(model, mesh_index, primitive_index);

    if (primitive == NULL) {
        return 0;
    }

    return primitive->indices == NULL
        ? rongen_gltf_vertex_count(model, mesh_index, primitive_index)
        : primitive->indices->count;
}

int rongen_gltf_primitive_topology(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index)
{
    const cgltf_primitive *primitive =
        rongen_gltf_primitive(model, mesh_index, primitive_index);

    return primitive == NULL
        ? (int)cgltf_primitive_type_invalid
        : (int)primitive->type;
}

int rongen_gltf_has_normals(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index)
{
    return rongen_gltf_attribute(
        model,
        mesh_index,
        primitive_index,
        cgltf_attribute_type_normal,
        0) != NULL;
}

int rongen_gltf_has_texture_coordinates(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index)
{
    return rongen_gltf_attribute(
        model,
        mesh_index,
        primitive_index,
        cgltf_attribute_type_texcoord,
        0) != NULL;
}

int rongen_gltf_read_positions(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index,
    float *values,
    size_t value_capacity)
{
    return rongen_gltf_read_float_attribute(
        model,
        mesh_index,
        primitive_index,
        cgltf_attribute_type_position,
        0,
        3,
        values,
        value_capacity);
}

int rongen_gltf_read_normals(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index,
    float *values,
    size_t value_capacity)
{
    return rongen_gltf_read_float_attribute(
        model,
        mesh_index,
        primitive_index,
        cgltf_attribute_type_normal,
        0,
        3,
        values,
        value_capacity);
}

int rongen_gltf_read_texture_coordinates(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index,
    float *values,
    size_t value_capacity)
{
    return rongen_gltf_read_float_attribute(
        model,
        mesh_index,
        primitive_index,
        cgltf_attribute_type_texcoord,
        0,
        2,
        values,
        value_capacity);
}

int rongen_gltf_read_indices(
    const rongen_gltf_model *model,
    size_t mesh_index,
    size_t primitive_index,
    uint32_t *values,
    size_t value_capacity)
{
    const cgltf_primitive *primitive =
        rongen_gltf_primitive(model, mesh_index, primitive_index);
    size_t count;
    size_t unpacked;
    size_t index;

    if (primitive == NULL) {
        return RONGEN_GLTF_INDEX_OUT_OF_RANGE;
    }

    count = rongen_gltf_index_count(model, mesh_index, primitive_index);
    if (values == NULL || value_capacity < count) {
        return RONGEN_GLTF_BUFFER_TOO_SMALL;
    }

    if (primitive->indices != NULL) {
        unpacked = cgltf_accessor_unpack_indices(
            primitive->indices,
            values,
            sizeof(*values),
            count);
        return unpacked == count
            ? RONGEN_GLTF_SUCCESS
            : RONGEN_GLTF_UNSUPPORTED_DATA;
    }

    if (count > UINT32_MAX) {
        return RONGEN_GLTF_UNSUPPORTED_DATA;
    }

    for (index = 0; index < count; ++index) {
        values[index] = (uint32_t)index;
    }

    return RONGEN_GLTF_SUCCESS;
}

size_t rongen_gltf_node_count(const rongen_gltf_model *model)
{
    return model == NULL || model->data == NULL
        ? 0
        : model->data->nodes_count;
}

int rongen_gltf_node_has_mesh(
    const rongen_gltf_model *model,
    size_t node_index)
{
    if (model == NULL || model->data == NULL ||
        node_index >= model->data->nodes_count) {
        return 0;
    }

    return model->data->nodes[node_index].mesh != NULL;
}

int rongen_gltf_node_mesh_index(
    const rongen_gltf_model *model,
    size_t node_index,
    size_t *mesh_index)
{
    const cgltf_node *node;

    if (model == NULL || model->data == NULL || mesh_index == NULL) {
        return RONGEN_GLTF_INVALID_ARGUMENTS;
    }

    if (node_index >= model->data->nodes_count) {
        return RONGEN_GLTF_INDEX_OUT_OF_RANGE;
    }

    node = &model->data->nodes[node_index];
    if (node->mesh == NULL) {
        return RONGEN_GLTF_MISSING_ATTRIBUTE;
    }

    *mesh_index = (size_t)(node->mesh - model->data->meshes);
    return RONGEN_GLTF_SUCCESS;
}

int rongen_gltf_node_world_transform(
    const rongen_gltf_model *model,
    size_t node_index,
    float *matrix,
    size_t value_capacity)
{
    if (model == NULL || model->data == NULL || matrix == NULL) {
        return RONGEN_GLTF_INVALID_ARGUMENTS;
    }

    if (node_index >= model->data->nodes_count) {
        return RONGEN_GLTF_INDEX_OUT_OF_RANGE;
    }

    if (value_capacity < 16) {
        return RONGEN_GLTF_BUFFER_TOO_SMALL;
    }

    cgltf_node_transform_world(&model->data->nodes[node_index], matrix);
    return RONGEN_GLTF_SUCCESS;
}

const char *rongen_gltf_result_description(int result)
{
    switch (result) {
        case cgltf_result_success:
            return "success";
        case cgltf_result_data_too_short:
            return "glTF data is too short";
        case cgltf_result_unknown_format:
            return "unknown glTF format";
        case cgltf_result_invalid_json:
            return "invalid glTF JSON";
        case cgltf_result_invalid_gltf:
            return "invalid glTF data";
        case cgltf_result_invalid_options:
            return "invalid cgltf options";
        case cgltf_result_file_not_found:
            return "glTF file was not found";
        case cgltf_result_io_error:
            return "I/O error while reading glTF data";
        case cgltf_result_out_of_memory:
            return "out of memory while reading glTF data";
        case cgltf_result_legacy_gltf:
            return "legacy glTF is not supported";
        case RONGEN_GLTF_INVALID_ARGUMENTS:
            return "invalid arguments";
        case RONGEN_GLTF_INDEX_OUT_OF_RANGE:
            return "mesh, primitive, or node index is out of range";
        case RONGEN_GLTF_MISSING_ATTRIBUTE:
            return "required glTF attribute is missing";
        case RONGEN_GLTF_BUFFER_TOO_SMALL:
            return "destination buffer is too small";
        case RONGEN_GLTF_UNSUPPORTED_DATA:
            return "glTF data is unsupported";
        default:
            return "unknown glTF error";
    }
}
