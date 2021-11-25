#ifndef VIEWPOINT_H
#define VIEWPOINT_H

#include "SceneNode.h"

#include "render.h"
#include "geom.h"

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
  void        setupTransformation(RenderContext* rctx);
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
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "modelviewpoint", buflen); };

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
  void        setupProjMatrix(RenderContext* rctx, const Sphere& viewvolumeSphere);
  Vertex      getObserver();
  void	      setObserver(bool automatic, Vertex in_eye);
  void	      setupViewer(RenderContext* rctx);
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "userviewpoint", buflen); };
  Frustum     frustum;
  void        getUserProjection(double* dest);
  void        setUserProjection(double* src);
  void        clearUserProjection();
private:
  float       fov;
  float       zoom;
  bool        viewerInScene;
  Vertex      eye;
  Matrix4x4   userProjection;
};


} // namespace rgl 

#endif // VIEWPOINT_H
