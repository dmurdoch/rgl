#ifndef VIEWPOINT_HPP
#define VIEWPOINT_HPP

#include "SceneNode.hpp"

#include "render.h"
#include "geom.hpp"

class Viewpoint : public SceneNode
{

#define VIEWPOINT_MAX_ZOOM  10

public:

  Viewpoint(PolarCoord position=PolarCoord(0.0f,15.0f), float fov=90.0f, float zoom=0.0f, bool interactive=true);
  
  PolarCoord& getPosition();
  void        setPosition(const PolarCoord& position);
  float       getZoom(void) const; 
  void        setZoom(const float zoom);
  float       getFOV(void) const;
  void        setFOV(const float in_fov);
  void        setupFrustum(RenderContext* rctx, const Sphere& viewvolumeSphere);
  void        setupTransformation(RenderContext* rctx, const Sphere& viewvolumeSphere);
  void        setupOrientation(RenderContext* rctx) const;
  bool        isInteractive() const;
  Frustum     frustum;
  Vertex      getCOP(const Sphere& viewvolumeSphere) const;

private:
  PolarCoord  position;
  float       fov;
  float       zoom;
  bool        interactive;

};

#endif // VIEWPOINT_HPP
