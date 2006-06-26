#ifndef VIEWPOINT_HPP
#define VIEWPOINT_HPP

#include "opengl.hpp"
#include "SceneNode.hpp"

#include "render.h"
#include "geom.hpp"

class Viewpoint : public SceneNode
{

#define VIEWPOINT_MAX_ZOOM  10

public:

  Viewpoint(PolarCoord position=PolarCoord(0.0f,15.0f), float fov=90.0f, float zoom=0.0f, bool interactive=true);
  Viewpoint(double* userMatrix, float fov=90.0f, float zoom=0.0f, bool interactive=true);
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
  Frustum     frustum;
  Vertex      getCOP(const Sphere& viewvolumeSphere) const;

private:
  PolarCoord  position;
  float       fov;
  float       zoom;
  bool        interactive;
  GLdouble    userMatrix[16], mouseMatrix[16];

};

#endif // VIEWPOINT_HPP
