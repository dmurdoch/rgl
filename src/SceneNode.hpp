#ifndef SCENENODE_HPP
#define SCENENODE_HPP

//
// ABSTRACT BASE CLASS
//   SceneNode
//

#include "types.h"
#include "String.hpp"

/*
enum TypeID { 
  SHAPE=1, 
  LIGHT, 
  BBOXDECO, 
  VIEWPOINT, 
  BACKGROUND 
};
*/

#define SHAPE 1
#define LIGHT 2
#define BBOXDECO 3
#define VIEWPOINT 4
#define BACKGROUND 6  // 5 was used for the material

typedef unsigned int TypeID;
typedef int ObjID;

#define BBOXID 1

/* Possible attributes to request */

#define VERTICES 1
#define NORMALS 2
#define COLORS 3
#define TEXCOORDS 4
#define SURFACEDIM 5
#define TEXTS 6
#define CEX 7
#define ADJ 8

typedef unsigned int AttribID;

class SceneNode
{
public:
  inline const TypeID getTypeID() const { return typeID; }
  inline const ObjID getObjID() const { return objID; }
  virtual ~SceneNode() { };
  static ObjID nextID;
  virtual int getAttributeCount(AttribID attrib) { return 0; }
  virtual void getAttribute(AttribID attrib, int first, int count, double* result) { return; }
  virtual String  getTextAttribute(AttribID attrib, int index) { return String(0, NULL); }
  
protected:
  SceneNode(const TypeID in_typeID) : typeID(in_typeID)
  {  objID = nextID++; };
private:
  const TypeID typeID;
  ObjID objID;
};

#endif // SCENENODE_HPP
 
