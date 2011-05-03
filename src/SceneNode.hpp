#ifndef SCENENODE_HPP
#define SCENENODE_HPP

//
// ABSTRACT BASE CLASS
//   SceneNode
//

#include "types.h"

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
#define BACKGROUND 5

typedef unsigned int TypeID;
typedef int ObjID;

#define BBOXID 1


class SceneNode
{
public:
  inline const TypeID getTypeID() const { return typeID; }
  inline const ObjID getObjID() const { return objID; }
  virtual ~SceneNode() { };
  static ObjID nextID;
protected:
  SceneNode(const TypeID in_typeID) : typeID(in_typeID)
  {  objID = nextID++; };
private:
  const TypeID typeID;
  ObjID objID;
};

#endif // SCENENODE_HPP
 
