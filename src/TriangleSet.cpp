#include "PrimitiveSet.hpp"

#if 0

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   TriangleSet
//

TriangleSet::TriangleSet(Material& in_material, int in_nelements, double* in_vertex) 
  : FaceSet<GL_TRIANGLES,3>(in_material, in_nelements, in_vertex) 
{
  if (material.lit) {
    normalArray.alloc(nvertices);
    for (int i=0;i<nvertices-2;i+=3) {
      normalArray[i+2] = normalArray[i+1] = normalArray[i] = vertexArray.getNormal(i,i+1,i+2);
    }
  }
}

void TriangleSet::renderBegin()
{
}

void TriangleSet::drawElement(int index)
{

}

void TriangleSet::renderEnd()
{
}


void TriangleSet::renderZSort(RenderContext* renderContext)
{
  Vertex cop = renderContext->cop;
  
  std::multimap<float,int> distanceMap;
  for (int index = 0 ; i < nelements ; ++index ) {
    float distance = getCenter(index) - cop;
    insert( std::pair<float,int>(distance,index)
  }

  drawBegin();
  for ( std::multimap<float,int>::iterator iter = distanceMap.begin(); iter != distanceMap.end() ; ++ iter ) {
    drawElement( iter->second );
  }  
  drawEnd();
}

#endif
