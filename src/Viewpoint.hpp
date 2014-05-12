#ifndef VIEWPOINT_HPP
#define VIEWPOINT_HPP

#include "SceneNode.hpp"

#include "render.h"
#include "geom.hpp"

namespace rgl {

class ModelViewpoint : public SceneNode
{

#define VIEWPOINT_MAX_ZOOM  10

public:

  ModelViewpoint(PolarCoord position=PolarCoord(0.0f,15.0f), Vec3 in_scale=Vec3(1.0f, 1.0f, 1.0f), bool interactive=true);
  ModelViewpoint(double* userMatrix, Vec3 in_scale=Vec3(1.0f, 1.0f, 1.0f), bool interactive=true);
  PolarCoord& getPosition();
  void        setPosition(const PolarCoord& position);
  void	      clearMouseMatrix();
  void        setupTransformation(Vertex center);
  void        setupOrientation() const;
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
  Vertex      scale;
  bool        scaleChanged;
private:
  PolarCoord  position;
  bool        interactive;
public:
  GLdouble    userMatrix[16], mouseMatrix[16];
};

class UserViewpoint : public SceneNode
{

#define VIEWPOINT_MAX_ZOOM  10

public:

  UserViewpoint(float fov=90.0f, float zoom=1.0f);
  float       getZoom(void) const; 
  void        setZoom(const float zoom);
  float       getFOV(void) const;
  void        setFOV(const float in_fov);
  void        setupFrustum(RenderContext* rctx, const Sphere& viewvolumeSphere);
  Vertex      setObserver(bool automatic, Vertex eye); /* applied after model; returns previous setting */
  void	      setupViewer();
  Frustum     frustum;
private:
  float       fov;
  float       zoom;
  bool        viewerInScene;
  Vertex      eye;
};


} // namespace rgl 

#endif // VIEWPOINT_HPP
