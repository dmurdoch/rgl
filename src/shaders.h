#ifndef SHADERS_H
#define SHADERS_H

#include "opengl.h"
#include <vector>
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

class UserData {
public:
  UserData(int in_size, int in_dim, double* values);
  int getSize() { return size;}
  int getDim()  { return dim; }
  float* getData() { return floats.data(); }
  void recycle( unsigned int newsize );
#ifndef RGL_NO_OPENGL
  void setLocation(GLint loc) { location = loc; };
  /* These are used for attributes */
  void beginUse();
  void endUse();
  void appendToBuffer(std::vector<GLubyte>& buffer);
  /* These are used for uniforms */
  void uploadUniform();
#endif  
  
private:
  int size, dim, offset;
  std::vector<float> floats;
  GLint location;
};

std::string defaultShader(ShaderType type);

} // namespace rgl

#endif // SHADERS_H
