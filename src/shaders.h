#ifndef SHADERS_H
#define SHADERS_H

#include <string>

namespace rgl {

enum ShaderType {
	VERTEX_SHADER = 0,
	FRAGMENT_SHADER,
	NUM_SHADERS
};

struct ShaderFlags {
	/* these ones are used in shader defines */
	bool fat_lines;
	bool fixed_quads;
	bool fixed_size;
	bool has_fog;
	bool has_normals;
	bool has_texture;
	bool is_brush;
	bool is_lines;
	bool is_lit;
	bool is_points;
	bool is_transparent;
	bool is_twosided;
	bool needs_vnormal;
	bool rotating;
	bool round_points;
	/* these ones are used elsewhere */
	bool sprites_3d;
	bool is_smooth;
	bool depth_sort;
	bool is_subscene;
	bool is_clipplanes;
};

std::string defaultShader(ShaderType type);

} // namespace rgl

#endif // SHADERS_H
