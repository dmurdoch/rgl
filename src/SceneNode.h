#ifndef SCENENODE_H
#define SCENENODE_H

//
// ABSTRACT BASE CLASS
//   SceneNode
//

#include "types.h"
#include "String.h"
#include "geom.h"

namespace rgl {

/*
enum TypeID { 
  SHAPE=1, 
  LIGHT, 
  BBOXDECO, 
  USERVIEWPOINT, 
  BACKGROUND,
  SUBSCENE,
  MODELVIEWPOINT
};
*/

#define SHAPE 1
#define LIGHT 2
#define BBOXDECO 3
#define USERVIEWPOINT 4
#define BACKGROUND 6  // 5 was used for the material
#define SUBSCENE 7
#define MODELVIEWPOINT 8
#define MAX_TYPE 8

typedef unsigned int TypeID;
typedef int ObjID;

/* Possible attributes to request */

#define VERTICES 1
#define NORMALS 2
#define COLORS 3
#define TEXCOORDS 4
#define SURFACEDIM 5
#define TEXTS 6
#define CEX 7
#define ADJ 8
#define RADII 9
#define CENTERS 10
#define IDS 11
#define USERMATRIX 12
#define TYPES 13
#define FLAGS 14
#define OFFSETS 15
#define FAMILY 16
#define FONT 17
#define POS 18
#define FOGSCALE 19
#define AXES 20
#define INDICES 21

typedef unsigned int AttribID;

class SceneNode
{
public:
  inline const TypeID getTypeID() const { return typeID; }
  inline const ObjID getObjID() const { return objID; }
  virtual ~SceneNode() { };
  static ObjID nextID;
  SceneNode *owner;  /* don't delete this node while the owner is non-NULL */

  /* Some nodes depend on the bbox, so we pass it to all */
  virtual int getAttributeCount(SceneNode* subscene, AttribID attrib) { return 0; }
  virtual void getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result) { return; }
  virtual String  getTextAttribute(SceneNode* subscene, AttribID attrib, int index) { return String(0, NULL); }
  virtual void getTypeName(char* buffer, int buflen) = 0;

protected:
  SceneNode(const TypeID in_typeID) : typeID(in_typeID)
  {  objID = nextID++; 
     owner = NULL;
  };
private:
  const TypeID typeID;
  ObjID objID;
};

/**
 * used in find_if searches, so can't be a method
 */
 
bool sameID(SceneNode* node, int id);

} // namespace rgl

#endif // SCENENODE_H
 
