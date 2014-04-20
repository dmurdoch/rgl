#ifndef VIEWPOINT_HPP
#define VIEWPOINT_HPP

#include "SceneNode.hpp"

#include "render.h"
#include "geom.hpp"

namespace rgl {

class Viewpoint : public SceneNode
{

#define VIEWPOINT_MAX_ZOOM  10

public:

  Viewpoint(PolarCoord position=PolarCoord(0.0f,15.0f), float fov=90.0f, float zoom=1.0f, Vec3 in_scale=Vec3(1.0f, 1.0f, 1.0f), bool interactive=true);
  Viewpoint(double* userMatrix, float fov=90.0f, float zoom=1.0f, Vec3 in_scale=Vec3(1.0f, 1.0f, 1.0f), bool interactive=true);
  PolarCoord& getPosition();
  void        setPosition(const PolarCoord& position);
  void	      clearMouseMatrix();
  float       getZoom(void) const; 
  void        setZoom(const float zoom);
  float       getFOV(void) const;
  void        setFOV(const float in_fov);
  void        setupFrustum(RenderContext* rctx, const Sphere& viewvolumeSphere);
  void        setupTransformation(RenderContext* rctx, const Sphere& viewvolumeSphere);
  void        setupOrientation(RenderContext* rctx) const;
  bool        isInteractive() const;
  void        updateMouseMatrix(Vertex dragStart,Vertex dragCurrent);
  void	      updateMouseMatrix(PolarCoord newpos);
  void	      mouseOneAxis(Vertex dragStart,Vertex dragCurrent,Vertex axis);
  void 	      mergeMouseMatrix();
  void        getUserMatrix(double* dest);
  void	      setUserMatrix(double* src);
  void	      getScale(double* dest);
  void	      setScale(double* src);
  void 	      getPosition(double* dest);
  void        setPosition(double* src);
  Frustum     frustum;
  Vertex      getCOP(const Sphere& viewvolumeSphere) const;
  Vertex      scale;
  bool        scaleChanged;
private:
  PolarCoord  position;
  float       fov;
  float       zoom;
  bool        interactive;
public:
  GLdouble    userMatrix[16], mouseMatrix[16];
};

} // namespace rgl 

#endif // VIEWPOINT_HPP
