#include "Background.h"
#include "Viewpoint.h"
#include "scene.h"
#include "rglmath.h"
#include "R.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Background
//

Material Background::defaultMaterial( Color(0.3f,0.3f,0.3f), Color(1.0f,0.0f,0.0f) );

Background::Background(Material& in_material, bool in_sphere, int in_fogtype,
                       float in_fogScale)
: Shape(in_material, true, BACKGROUND), sphere(in_sphere), fogtype(in_fogtype),
  fogScale(in_fogScale), quad(NULL)
{
  clearColorBuffer = true;

  if (sphere) {
    material.colors.recycle(2);

    material.colorPerVertex(false);

    if (material.back == Material::FILL_FACE)
      clearColorBuffer = false;

    if ( (material.lit) || ( (material.texture) && (material.texture->is_envmap() ) ) )
      sphereMesh.setGenNormal(true);
    if ( (material.texture) && (!material.texture->is_envmap() ) )
      sphereMesh.setGenTexCoord(true);

    sphereMesh.setGlobe (16,16);

    sphereMesh.setCenter( Vertex(0.0f,0.0f,0.0f) );
    sphereMesh.setRadius( 1.0f );
    sphereMesh.update();
  }
  else if (material.texture) {
    double vertices[12] = { -1, -1, 1,
                             1, -1, 1,
                             1,  1, 1,
                            -1,  1, 1 };
    double texcoords[8] = { 0, 0, 
                            1, 0,
                            1, 1,
                            0, 1 };
    material.colorPerVertex(false);
    material.colors.recycle(1);
    material.depth_test = 7;
    material.back = Material::FILL_FACE;
    quad = new QuadSet(material, 4, vertices, NULL, texcoords, true, 0, NULL, 0, 1);
    quad->owner = this;
  } else
    material.colors.recycle(1);    
}

Background::~Background()
{
  if (quad) {
    quad->owner = NULL;
    quad = NULL;
  }
}	

GLbitfield Background::getClearFlags(RenderContext* renderContext)
{
  if (clearColorBuffer) {
    return GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT;
  } else
    return GL_DEPTH_BUFFER_BIT;
}

void Background::draw(RenderContext* renderContext)
{
  // Scene::render clears to the 
  // background color first.
  
  // NB:  spheres and quads are different!
  // quads are a Shape, but spheres let
  // the background handle some stuff.
  
#ifndef RGL_NO_OPENGL

  // render bg sphere 
  Matrix4x4 savedModelMatrix,
            savedProjMatrix; 
  if (sphere) { 
    Subscene* subscene = renderContext->subscene;
    savedModelMatrix = subscene->modelMatrix;
    /* The way we draw a background sphere is to start by rotating
     * the sphere so the pole is at (0, 1, 0) instead of (0, 0, 1),
     * then scale it to 4 times the radius of the bounding box,
     * then translate it to the center of the bbox and apply
     * the model-view transformation to it.  After that, 
     * flatten it to zero thickness in the z direction.
     */
    
    AABox bbox = subscene->getBoundingBox();
    Vec3 center = bbox.getCenter();
    Vec3 scale = subscene->getModelViewpoint()->scale;
    double zoom = subscene->getUserViewpoint()->getZoom();
    
    Matrix4x4 m;
    m.setRotate(0, 90);
    /* This calculation gets the aspect ratio
     * from the scale and range, by undoing aspect3d()
     */
    Vec3 ranges = bbox.vmax - bbox.vmin;
    float avgscale = ranges.getLength()/sqrtf(3.0f);
    Vec3 aspect(ranges.x*scale.x/avgscale, ranges.y*scale.y/avgscale, ranges.z*scale.z/avgscale);
    float maxaspect = std::max(aspect.x, std::max(aspect.y, aspect.z));
    m.multLeft(Matrix4x4::scaleMatrix(zoom*2.0*maxaspect*ranges.x/aspect.x,
                                      zoom*2.0*maxaspect*ranges.y/aspect.y,
                                      zoom*2.0*maxaspect*ranges.z/aspect.z));
    m.multLeft(Matrix4x4::translationMatrix(center.x, center.y, center.z));
    
    m.multLeft(savedModelMatrix);
    
    center = savedModelMatrix * center;
    m.multLeft(Matrix4x4::translationMatrix(-center.x, -center.y, -center.z));
    m.multLeft(Matrix4x4::scaleMatrix(1.0, 1.0, 0.25/zoom));
    m.multLeft(Matrix4x4::translationMatrix(center.x, center.y, center.z));
    subscene->modelMatrix.loadData(m);
  
    drawBegin(renderContext);
    drawPrimitive(renderContext);
    drawEnd(renderContext);
 
    subscene->modelMatrix.loadData(savedModelMatrix);
  } else if (quad) {
    Subscene* subscene = renderContext->subscene;
    savedModelMatrix = subscene->modelMatrix;
    subscene->modelMatrix.setIdentity();
    savedProjMatrix = subscene->projMatrix;
    subscene->projMatrix.setIdentity();
    
    quad->draw(renderContext);
    
    subscene->projMatrix.loadData(savedProjMatrix);
    subscene->modelMatrix.loadData(savedModelMatrix);
  }
    
#endif    
}

void Background::drawBegin(RenderContext* renderContext) {
#ifndef RGL_NO_OPENGL
  if (sphere) {
    Shape::drawBegin(renderContext);
    Shape::beginShader(renderContext);
    material.beginUse(renderContext);
    material.colors.setAttribLocation(glLocs.at("aCol"));
  }
#endif
}
 
void Background::drawPrimitive(RenderContext* renderContext, int index)
{
#ifndef RGL_NO_OPENGL

  material.useColor(1);
  
  if (sphere) 
    sphereMesh.draw(renderContext);

#endif
}

void Background::drawEnd(RenderContext* renderContext) {
#ifndef RGL_NO_OPENGL
  if (sphere) {
    Shape::endShader();
    material.endUse(renderContext);
    Shape::drawEnd(renderContext);
  }
#endif
}


void Background::initialize()
{
  Shape::initialize();
#ifndef RGL_NO_OPENGL
  
  initShader();
  glVertexAttrib3f(glLocs["aPos"], 0.0, 0.0, 0.0);
  
  material.colors.setAttribLocation(glLocs["aCol"]);
  
  if (material.texture && glLocs_has_key("uSampler"))
    material.texture->setSamplerLocation(glLocs["uSampler"]);
  
  if (sphere)
    sphereMesh.initialize(glLocs, vertexbuffer);
  
  SAVEGLERROR;
#endif
}

int Background::getAttributeCount(SceneNode* subscene, AttribID attrib) 
{
  switch (attrib) {    
  case FLAGS: return 4;
  case FOGSCALE: return 1;
  case TYPES:
  case IDS: if (quad) return 1;
            else return 0;
         
  }
  return Shape::getAttributeCount(subscene, attrib);
}

void Background::getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(subscene, attrib);
  if (first + count < n) n = first + count;
  
  if (first < n) {
    switch(attrib) {
    case FLAGS:
      for (int i = first; i < first+count; i++) {
        if (i == 0)  
          result[i-first] = (double) sphere;
        if (i == 1)
	        result[i-first] = (double) (fogtype == FOG_LINEAR);
        if (i == 2)
	        result[i-first] = (double) (fogtype == FOG_EXP);
        if (i == 3)
	        result[i-first] = (double) (fogtype == FOG_EXP2);
      }
      return;
    case FOGSCALE:
      if (first <= 0)
        *result++ = fogScale;
      return;
    case IDS:
      if (quad)
      	*result++ = quad->getObjID();
      return;
    }
    Shape::getAttribute(subscene, attrib, first, count, result);
  }
}

std::string Background::getTextAttribute(SceneNode* subscene, AttribID attrib, int index)
{
  int n = getAttributeCount(subscene, attrib);
  if (index < n && attrib == TYPES)
    return quad->getTypeName();
  else
    return Shape::getTextAttribute(subscene, attrib, index);
}
