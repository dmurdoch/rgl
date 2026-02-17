#include "BBoxDeco.h"
#include "TextSet.h"
#include "Device.h"
#include "DeviceManager.h"

#ifndef RGL_NO_OPENGL
#include "gl2ps.h"
#endif
#include "scene.h"
#include <cstdio>
#include <cmath>
#include "R.h"
#include "pretty.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   BBoxDeco
//

AxisInfo::AxisInfo()
: textArray()
{
  mode  = AXIS_LENGTH;
  nticks = 0;
  len   = 2;
  unit  = 0;
}

AxisInfo::AxisInfo(int in_nticks, double* in_ticks, char** in_texts, int in_len, float in_unit)
{
 
  int i;

  nticks = in_nticks;
  for (i = 0; i < nticks; i++)
  	textArray.push_back(in_texts[i]);
  len    = in_len;
  unit   = in_unit;
  ticks.clear();

  if (nticks > 0) {

    mode = AXIS_CUSTOM;

    ticks.resize(nticks);

    for(i=0;i<nticks;i++)
      ticks[i] = (float) in_ticks[i];

  } else {
    
    if (unit > 0)
      mode = AXIS_UNIT;
    else if (unit < 0 && len > 0)
      mode = AXIS_PRETTY;
    else if (len > 0)
      mode = AXIS_LENGTH;
    else
      mode = AXIS_NONE;

  }
}

AxisInfo::AxisInfo(AxisInfo& from) 
: textArray(from.textArray)
{
  mode = from.mode;
  nticks = from.nticks;
  len  = from.len;
  unit = from.unit;
  if (nticks > 0) {
    ticks.resize(nticks);
    memcpy (ticks.data(), from.ticks.data(), sizeof(float)*nticks);
  } else
    ticks.clear();
}

AxisInfo::~AxisInfo()
{
}

int AxisInfo::getNticks(float low, float high) {
  switch (mode) {

    case AXIS_CUSTOM: return nticks;

    case AXIS_LENGTH: return len;

    case AXIS_UNIT:   return static_cast<int>((high - low)/unit);

    case AXIS_PRETTY: {
      double lo=low, up=high, shrink_sml=0.75, high_u_fact[2];
      int ndiv=len, min_n=3, eps_correction=0;
      int count=0;

      high_u_fact[0] = 1.5;
      high_u_fact[1] = 2.75;
      unit = static_cast<float>(R_pretty0(&lo, &up, &ndiv, min_n, shrink_sml, high_u_fact, 
			     eps_correction, 0));
      
      for (int i=(int)lo; i<=up; i++) {
	float value = i*unit;
	if (value >= low && value <= high) 
	  count++;
      }
      return count;
    }
  }
  return 0;
}

double AxisInfo::getTick(float low, float high, int index) {
  switch (mode) {

    case AXIS_CUSTOM: return ticks[index];

    case AXIS_LENGTH: {
      float delta = (len>1) ? (high-low)/(len-1) : 0;
      return low + delta*(float)index;
    }
    case AXIS_UNIT: {
      float value =  ( (float) ( (int) ( ( low+(unit-1) ) / (unit) ) ) ) * (unit);
      return value + index*unit;
    }
    case AXIS_PRETTY: {
      double lo=low, up=high, shrink_sml=0.75, high_u_fact[2];
      int ndiv=len, min_n=3, eps_correction=0;
      int count=0;

      high_u_fact[0] = 1.5;
      high_u_fact[1] = 2.75;
      unit = static_cast<float>(R_pretty0(&lo, &up, &ndiv, min_n, shrink_sml, high_u_fact, 
			     eps_correction, 0));
      
      for (int i=(int)lo; i<=up; i++) {
	float value = i*unit;
	if (value >= low && value <= high) {
	  if (count == index) return value;
	  count++;
	}
      }
    }
  }
  return NA_REAL;
}
    
struct Side {
  int vidx[4];
  Vertex4 normal;

  Side( int i0, int i1, int i2, int i3, Vertex4 v )
   : normal(v)
  {
    vidx[0] = i0;
    vidx[1] = i1;
    vidx[2] = i2;
    vidx[3] = i3;
  }

};

static Side side[6] = {
  // BACK
  Side(0, 2, 3, 1, Vertex4( 0.0f, 0.0f,-1.0f, 0.0f) ),

  // FRONT
  Side(4, 5, 7, 6, Vertex4( 0.0f, 0.0f, 1.0f, 0.0f) ),

  // LEFT
  Side(4, 6, 2, 0, Vertex4(-1.0f, 0.0f, 0.0f, 0.0f) ),

  // RIGHT
  Side(5, 1, 3, 7, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f) ),

  // BOTTOM
  Side(0, 1, 5, 4, Vertex4( 0.0f,-1.0f, 0.0f, 0.0f) ),

  // TOP
  Side(6, 7, 3, 2, Vertex4( 0.0f, 1.0f, 0.0f, 0.0f) )
};

struct Edge{
  Edge(int in_from, int in_to, Vertex4 in_dir, Vertex3 in_code, int in_coord) : from(in_from), to(in_to), coord(in_coord), dir(in_dir), code(in_code){ }
  int from, to, coord;
  Vertex4 dir;
  Vertex3 code;
};

static Edge axisedges[12] = { 
  Edge( 5,4, Vertex4( 0.0f, 0.0f, 1.0f, 0.0f), Vertex3( 0.0f, -1.0f,  1.0f), 0 ), 
  Edge( 0,1, Vertex4( 0.0f, 0.0f,-1.0f, 0.0f), Vertex3( 0.0f, -1.0f, -1.0f), 0 ),
  Edge( 6,7, Vertex4( 0.0f, 0.0f, 1.0f, 0.0f), Vertex3( 0.0f,  1.0f,  1.0f), 0 ),
  Edge( 3,2, Vertex4( 0.0f, 0.0f,-1.0f, 0.0f), Vertex3( 0.0f,  1.0f, -1.0f), 0 ),

  Edge( 5,7, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f), Vertex3( 1.0f, 0.0f, 1.0f), 1 ),
  Edge( 6,4, Vertex4(-1.0f, 0.0f, 0.0f, 0.0f), Vertex3(-1.0f, 0.0f, 1.0f), 1 ), 
  Edge( 2,0, Vertex4( 0.0f, 0.0f,-1.0f, 0.0f), Vertex3(-1.0f, 0.0f, -1.0f), 1  ), 
  Edge( 3,1, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f), Vertex3( 1.0f, 0.0f, -1.0f), 1  ),

  Edge( 1,5, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f), Vertex3( 1.0f,-1.0f, 0.0f), 2  ), 
  Edge( 4,0, Vertex4(-1.0f, 0.0f, 0.0f, 0.0f), Vertex3(-1.0f,-1.0f, 0.0f), 2  ), 
  Edge( 7,3, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f), Vertex3( 1.0f, 1.0f, 0.0f), 2  ), 
  Edge( 2,6, Vertex4(-1.0f, 0.0f, 0.0f, 0.0f), Vertex3(-1.0f, 1.0f, 0.0f), 2  ) 
};


AxisInfo BBoxDeco::defaultAxis(0,NULL,NULL,0,5);
Material BBoxDeco::defaultMaterial( Color(0.6f,0.6f,0.6f,0.5f), Color(1.0f,1.0f,1.0f) );

struct BBoxVertex {
  int index;
  float x, y;
  bool onhull;
  BBoxVertex(int i, Vertex4 v) {
    index = i;
    x = v.x/v.w;
    y = v.y/v.w;
    onhull = false;
  }
  bool operator<(const BBoxVertex& other) const {
    return x < other.x || (x == other.x && y < other.y );
  }
};

struct BBoxDeco::BBoxDecoImpl {
  static float crossprod(BBoxVertex a, BBoxVertex b, BBoxVertex c) {
    return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
  }
  
  static std::vector<BBoxVertex> chull(std::vector<BBoxVertex> points) {
    
    int n = points.size();
    if (n <= 2) return points;
    
    std::sort(points.begin(), points.end());
    std::vector<BBoxVertex> hull;
    // 1. Build Lower Hull
    for (int i = 0; i < n; ++i) {
      while (hull.size() >= 2 && crossprod(hull[hull.size() - 2], hull.back(), points[i]) <= 0) {
        hull.pop_back();
      }
      hull.push_back(points[i]);
    }
    
    // 2. Build Upper Hull
    int lower_hull_size = hull.size();
    for (int i = n - 2; i >= 0; --i) {
      while (hull.size() > lower_hull_size && crossprod(hull[hull.size() - 2], hull.back(), points[i]) <= 0) {
        hull.pop_back();
      }
      hull.push_back(points[i]);
    }
    hull.pop_back(); // The last point is duplicated
    return hull;
  }
  
  static Edge* getTickEdges(RenderContext* renderContext, BBoxDeco& bboxdeco, int coord) 
  {
    /* First we find which vertices are on the
     * convex hull after transforming */

    // vertex array:
    
    std::vector<Vertex4> boxv = {
      Vertex4( bboxdeco.bbox.vmin.x, bboxdeco.bbox.vmin.y, bboxdeco.bbox.vmin.z ),
      Vertex4( bboxdeco.bbox.vmax.x, bboxdeco.bbox.vmin.y, bboxdeco.bbox.vmin.z ),
      Vertex4( bboxdeco.bbox.vmin.x, bboxdeco.bbox.vmax.y, bboxdeco.bbox.vmin.z ),
      Vertex4( bboxdeco.bbox.vmax.x, bboxdeco.bbox.vmax.y, bboxdeco.bbox.vmin.z ),
      Vertex4( bboxdeco.bbox.vmin.x, bboxdeco.bbox.vmin.y, bboxdeco.bbox.vmax.z ),
      Vertex4( bboxdeco.bbox.vmax.x, bboxdeco.bbox.vmin.y, bboxdeco.bbox.vmax.z ),
      Vertex4( bboxdeco.bbox.vmin.x, bboxdeco.bbox.vmax.y, bboxdeco.bbox.vmax.z ),
      Vertex4( bboxdeco.bbox.vmax.x, bboxdeco.bbox.vmax.y, bboxdeco.bbox.vmax.z )
    };
    
    Matrix4x4 PMV = renderContext->subscene->projMatrix * renderContext->subscene->modelMatrix;
    
    std::vector<BBoxVertex> boxvertex, hull;
    for (int i = 0; i < boxv.size(); i++) {
      boxvertex.push_back(BBoxVertex(i, PMV * boxv[i]));
    }
    hull = chull(boxvertex);
    for (int i = 0; i < hull.size(); i++) {
      boxvertex[hull[i].index].onhull = true;
    }
      /* Indices of possible edges. Start with them all for this coordinate */
      int best = -1;
      float dist = INFINITY;
      bool foundonhull = false;
      for (int i = 4*coord; i < 4*coord+4; i++) {
        Edge* e = &axisedges[i];
        /* only consider edges on the convex hull */
        bool onhull =
          boxvertex[e->from].onhull &&
          boxvertex[e->to].onhull;
        if (onhull && !foundonhull) {
          foundonhull = true;
          dist = INFINITY;
        }
        if (onhull || !foundonhull) {
          /* find the one with a point 
           * closest to the bottom left 
           * corner */
          float newdist = std::min(boxvertex[e->from].x + boxvertex[e->from].y,
                             boxvertex[e->to].x + boxvertex[e->to].y);
          if (newdist < dist) {
            dist = newdist;
            best = i;
          }
        }
      }

    return &axisedges[best];
  }
  
  static Edge* fixedEdge(Material* material)
  {
    int i,j, lim = 4, coord = material->marginCoord, first;
    bool match;
    switch(coord) {
    case 0:
      first = 0;
      break;
    case 1:
      first = 4;
      break;
    case 2:
      first = 8;
      break;
    }
    for (j = 0; j < lim; j++) {
      match = true;
      for (i = 0; i < 3; i++)
        if (coord != i && axisedges[j + first].code[i] != material->edge[i]) {
          match = false;
          break;
        }
        if (match)
          return &axisedges[j+first];
    }
    Rf_error("fixedEdge: material->floating=%d marginCoord=%d edge=%d %d %d\n", material->floating,
             material->marginCoord, material->edge[0], material->edge[1], material->edge[2]);
    return axisedges;
  }
  
  static void setMarginParameters(RenderContext* renderContext, BBoxDeco& bboxdeco, Material* material,
                                  int *at, int* line, int* level,
                                  Vec3* trans, Vec3* scale) {
    Edge* edge;
    int j;
    *at = material->marginCoord;
    if (material->floating)
      edge = BBoxDecoImpl::getTickEdges(renderContext, bboxdeco, *at);
    else
      edge = BBoxDecoImpl::fixedEdge(material);
    if (!edge) {
      *at = NA_INTEGER;
      return;
    }
    for (j = 0; j < 3; j++) {
      if (edge->dir[j] != 0) {
        *line = j;
        break;
      }
    }
    *level = 2;
    for (j = 0; j < 2; j++) {
      if (*at != j && *line != j) {
        *level = j;
        break;
      }
    }
    /* Set up translation and scaling */
    AABox bbox = bboxdeco.bbox;
    Vertex marklen = bboxdeco.getMarkLength(bbox);
    for (j = 0; j < 3; j++) {
      if (j != *at) {
        int e = 1;
        if (material->floating && edge->code[j] < 0)
          e = -1;
        e = e*material->edge[j];
        (*trans)[j] = e == 1 ? bbox.vmax[j] : bbox.vmin[j];
        (*scale)[j] = marklen[j]*e;
      } else {
        (*trans)[j] = 0.0;
        (*scale)[j] = 1.0;
      }
    }
  };
  QuadSet* cube;
  LineSet* ticks[3];
  TextSet* labels[3];
};

BBoxDeco::BBoxDeco(Material& in_material, AxisInfo& in_xaxis, AxisInfo& in_yaxis, AxisInfo& in_zaxis, float in_marklen_value, bool in_marklen_fract,
                   float in_expand, bool in_front)
: SceneNode(BBOXDECO), 
  impl(std::make_unique<BBoxDecoImpl>()),
  material(in_material), xaxis(in_xaxis), yaxis(in_yaxis), zaxis(in_zaxis), marklen_value(in_marklen_value), marklen_fract(in_marklen_fract),
  expand(in_expand), draw_front(in_front)
{
  material.colors.recycle(2);
  impl->cube = new QuadSet(material,
                           0, NULL, NULL, 
                           NULL, /* in_texcoords */
                           true, /* ignoreExtent */
                           0, NULL, /* indices */
                           true, false);
  impl->cube->owner = this;
  for (int i=0; i<3; i++) {
    impl->ticks[i] = nullptr;
    impl->labels[i] = nullptr;
  }

}

Vertex BBoxDeco::getMarkLength(const AABox& boundingBox) const
{
  return (marklen_fract) ? (boundingBox.vmax - boundingBox.vmin) * (1 / marklen_value) : Vertex(1,1,1) * marklen_value;
}

AABox BBoxDeco::getBoundingBox(const AABox& in_bbox) const
{
  AABox bbox2(in_bbox);

  Vertex marklen = getMarkLength(bbox2);

  Vertex v = marklen * 2;

  bbox2 += bbox2.vmin - v;
  bbox2 += bbox2.vmax + v;

  return bbox2;
}

bool BBoxDeco::hasNewBBox(RenderContext* renderContext)
{
  AABox data_bbox = renderContext->subscene->getBoundingBox();
  bool result = data_bbox.vmin.x != bbox0.vmin.x ||
                data_bbox.vmin.y != bbox0.vmin.y ||
                data_bbox.vmin.z != bbox0.vmin.z ||
                data_bbox.vmax.x != bbox0.vmax.x ||
                data_bbox.vmax.y != bbox0.vmax.y ||
                data_bbox.vmax.z != bbox0.vmax.z
                ;
  if (result) {
    bbox = bbox0 = data_bbox;
    Vertex center = bbox.getCenter();
    bbox += center + (bbox0.vmin - center)*expand;
    bbox += center + (bbox0.vmax - center)*expand;
  }
    
  return result;
}

void BBoxDeco::setCube()
{
  if (bbox.isValid()) {

    // vertex array:
    
    Vertex4 boxv[8] = {
      Vertex4( bbox.vmin.x, bbox.vmin.y, bbox.vmin.z ),
      Vertex4( bbox.vmax.x, bbox.vmin.y, bbox.vmin.z ),
      Vertex4( bbox.vmin.x, bbox.vmax.y, bbox.vmin.z ),
      Vertex4( bbox.vmax.x, bbox.vmax.y, bbox.vmin.z ),
      Vertex4( bbox.vmin.x, bbox.vmin.y, bbox.vmax.z ),
      Vertex4( bbox.vmax.x, bbox.vmin.y, bbox.vmax.z ),
      Vertex4( bbox.vmin.x, bbox.vmax.y, bbox.vmax.z ),
      Vertex4( bbox.vmax.x, bbox.vmax.y, bbox.vmax.z )
    };
    int nverts = 6*4;
    double *vertices = new double[nverts*3], *normals = new double[nverts*3];
    for (int i = 0; i < 6; i++) {
      Vertex4 n = side[i].normal;
      for (int j = 0; j < 4; j++) {
        Vertex4 v = boxv[side[i].vidx[j]];
        int k = 12*i + 3*j;
        vertices[k] = v.x;
        vertices[k + 1] = v.y;
        vertices[k + 2] = v.z;
        normals[k] = n.x;
        normals[k + 1] = n.y;
        normals[k + 2] = n.z;
      }
    }
    impl->cube = new QuadSet(material,
                             nverts, vertices, normals,
                             NULL, /* in_texcoords */
                             true, /* ignoreExtent */
                             0, NULL, /* indices */
                             true, false);
    delete[] vertices;
    delete[] normals;
  }
  impl->cube->material.colors.recycle(1);
  if (!draw_front)
    impl->cube->material.front = Material::CULL_FACE;
}

void BBoxDeco::setAxes()
{
  if (bbox.isValid()) {
    
    for(int i=0;i<3;i++) {
      if (impl->ticks[i]) {
        delete impl->ticks[i];
        impl->ticks[i] = nullptr;
        delete impl->labels[i];
        impl->labels[i] = nullptr;
      }
        
      AxisInfo*  axis;
      float  low, high;
      switch(i)
      {
      case 0:
        axis     = &xaxis;       
        low      = bbox.vmin.x;
        high     = bbox.vmax.x;
        break;
      case 1:
        axis     = &yaxis;
        low      = bbox.vmin.y;
        high     = bbox.vmax.y;
        break;
      case 2:
      default:
        axis     = &zaxis;
        low      = bbox.vmin.z;
        high     = bbox.vmax.z;
        break;
      }
      if (axis->mode == AXIS_NONE)
        continue;
      
      switch (axis->mode) {
      case AXIS_CUSTOM:
        break;
        
      case AXIS_LENGTH:
      {
        float delta = (axis->len>1) ? (high-low)/((axis->len)-1) : 0;
        axis->ticks.clear();
        axis->textArray.clear();
        for(int k=0;k<axis->len;k++)
        {
          float value = low + delta * (float)k;
          
          axis->ticks.push_back(value);
          
          char text[32];
          snprintf(text, 32, "%.4g", value);
          
          axis->textArray.push_back(text);
          
        }
      }
        break;
      case AXIS_UNIT:
      {
        float value =  ( (float) ( (int) ( ( low+(axis->unit-1) ) / (axis->unit) ) ) ) * (axis->unit);
        axis->ticks.clear();
        axis->textArray.clear();
        while(value < high) {
          
          axis->ticks.push_back(value);
          
          char text[32];
          snprintf(text, 32, "%.4g", value);
          
          axis->textArray.push_back(text);
          
          value += axis->unit;
        }
      }
        break;
      case AXIS_PRETTY:
      {
        /* These are the defaults from the R pretty() function, except min_n is 3 */
        double lo=low, up=high, shrink_sml=0.75, high_u_fact[2];
        int ndiv=axis->len, min_n=3, eps_correction=0;
        
        high_u_fact[0] = 1.5;
        high_u_fact[1] = 2.75;
        axis->unit = static_cast<float>(R_pretty0(&lo, &up, &ndiv, min_n, shrink_sml, high_u_fact, 
                                                  eps_correction, 0));
        
        axis->ticks.clear();
        axis->textArray.clear();
        for (int i=(int)lo; i<=up; i++) {
          float value = i*axis->unit;
          if (value >= low && value <= high) {
            axis->ticks.push_back(value);
            
            char text[32];
            snprintf(text, 32, "%.4g", value);
            axis->textArray.push_back(text);
          }
        }
      }
        break;
      }
      axis->nticks = axis->ticks.size();
      if (axis->mode == AXIS_NONE || axis->nticks == 0)
        continue;
      
      double values[6*axis->nticks];
      for (int j = 0; j < axis->nticks; j++) {
        values[6*j]   = axis->ticks[j];
        values[6*j+1] = 0.0;
        values[6*j+2] = 0.0;
        
        values[6*j+3] = axis->ticks[j];
        values[6*j+4] = 1.0;
        values[6*j+5] = 0.0;
      }
      
      impl->ticks[i] = new LineSet(material, 2*axis->nticks, values, 
                                   true /* in_ignoreExtent */, 0, nullptr);
      
      char* label_ptrs[axis->nticks]; 
      for (int j = 0; j < axis->nticks; j++)
      {
        values[3*j] = axis->ticks[j];
        values[3*j+1] = 2.0;
        values[3*j+2] = 0.0;
        
        label_ptrs[j] = (char*)axis->textArray[j].c_str();
      }      
      const char * family[] = { "sans" };
      int style[] = { 1 };
      double cex[] = { 1.0 };
      const char * fontfile[] = { "" };

      impl->labels[i] = new TextSet(material, axis->nticks, label_ptrs, values, 
                                    nullptr /*in_adj*/,
                                    true  /*in_ignoreExtent*/, 
                                    1, family, style,
                                    cex,
                                    fontfile,
                                    0, nullptr /*in_pos*/);
      impl->ticks[i]->material.marginCoord = i;
      impl->labels[i]->material.marginCoord = i;
      for (int j = 0; j < 3; j++) {
        impl->labels[i]->material.edge[j] =
          impl->ticks[i]->material.edge[j] = (i == j) ? 0 : 1;
      }
      impl->labels[i]->material.floating =
        impl->ticks[i]->material.floating = true;
      impl->labels[i]->material.front = Material::FILL_FACE;
      impl->labels[i]->material.back = Material::FILL_FACE;
      impl->ticks[i]->material.colors.setColor(0, material.colors.getColor(1));
      impl->ticks[i]->material.colors.recycle(1);
      impl->labels[i]->material.colors.setColor(0, material.colors.getColor(1));
      impl->labels[i]->material.colors.recycle(1);
      impl->labels[i]->owner =
        impl->ticks[i]->owner = this;
    }
  }
}

void BBoxDeco::render(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  // The cube only changes when the bbox changes.  
  // Some aspects of the ticks and labels change then,
  // but others may change in every rendering, and the
  // labels move to a different edge of the cube.
  
  if (hasNewBBox(renderContext)) {
    setCube();
    setAxes();
  }
  impl->cube->render(renderContext);
  for (int i=0; i < 3; i++)
    if (impl->ticks[i])
      impl->ticks[i]->render(renderContext);
    
  glEnable(GL_BLEND);  
  for (int i=0; i < 3; i++)
    if (impl->labels[i])
      impl->labels[i]->render(renderContext);
  glDisable(GL_BLEND);
#endif  
}

Vec3 BBoxDeco::marginVecToDataVec(Vec3 marginvec, RenderContext* renderContext, Material* material) {
  /* Create permutation to map at, line, pos to x, y, z */
  int at = 0, line = 0, level = 0; /* initialize to suppress warning */
  Vec3 trans, scale;
  BBoxDecoImpl::setMarginParameters(renderContext, *this, material,
        &at, &line, &level,
        &trans, &scale); 
  if (at == NA_INTEGER) return Vertex(NA_FLOAT, NA_FLOAT, NA_FLOAT);
  /* It might make more sense to do this by
   * modifying the MODELVIEW matrix, but 
   * I couldn't get that right for some reason...
   */
  Vertex result;
  if (marginvec.missing())
    result[at] = (bbox.vmin[at] + bbox.vmax[at])/2.0f;
  else if (marginvec.x == -INFINITY)
    result[at] = bbox.vmin[at];
  else if (marginvec.x == INFINITY)
    result[at] = bbox.vmax[at];
  else
    result[at] = marginvec.x*scale[at] + trans[at];
  result[line] = marginvec.y*scale[line] + trans[line];
  result[level] = marginvec.z*scale[level] + trans[level];

  return result;
}

Vec3 BBoxDeco::marginNormalToDataNormal(Vec3 marginvec, RenderContext* renderContext, Material* material) {
  int at=0, line=0, level=0; /* initialize to suppress warning */
  Vec3 trans, scale;
  BBoxDecoImpl::setMarginParameters(renderContext, *this, material,
                                    &at, &line, &level,
                                    &trans, &scale); 
  if (at == NA_INTEGER)
    return Vertex(NA_FLOAT, NA_FLOAT, NA_FLOAT);
  Vertex result;
  result[at] = marginvec.x/scale[at];
  result[line] = marginvec.y/scale[line];
  result[level] = marginvec.z/scale[level];
  return result;
}

void BBoxDeco::setAxisCallback(userAxisPtr fn, void* user, int axis)
{
  axisCallback[axis] = fn;
  axisData[axis] = user;
  switch(axis) {
    case 0: xaxis.mode = AXIS_USER;
            break;
    case 1: yaxis.mode = AXIS_USER;
            break;
    case 2: zaxis.mode = AXIS_USER;
            break;
  }
  if (impl->ticks[axis])
    delete impl->ticks[axis];
  impl->ticks[axis] = nullptr;
  if (impl->labels[axis])
    delete impl->labels[axis];
  impl->labels[axis] = nullptr;
}

void BBoxDeco::getAxisCallback(userAxisPtr *fn, void** user, int axis)
{
  *fn = axisCallback[axis];
  *user = axisData[axis];
}

int BBoxDeco::getAttributeCount(SceneNode* subscene, AttribID attrib) 
{
  switch (attrib) {    
    case TEXTS: {
      int count = ((xaxis.mode == AXIS_CUSTOM) ? xaxis.nticks : 0)
           + ((yaxis.mode == AXIS_CUSTOM) ? yaxis.nticks : 0)
           + ((zaxis.mode == AXIS_CUSTOM) ? zaxis.nticks : 0);
      if (count == 0) return 0; 
    }
    /* if non-zero, we want labels for every vertex, so fall through. */
    case VERTICES: {
      AABox bbox = ((Subscene*)subscene)->getBoundingBox();
      return xaxis.getNticks(bbox.vmin.x, bbox.vmax.x)
           + yaxis.getNticks(bbox.vmin.y, bbox.vmax.y)
           + zaxis.getNticks(bbox.vmin.z, bbox.vmax.z);
    }
    case COLORS:
      return material.colors.getLength();
    case FLAGS:
      return 2;
    case AXES:
      return 5;
  }
  return SceneNode::getAttributeCount(subscene, attrib);
}

void BBoxDeco::getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(subscene, attrib);

  if (first + count < n) n = first + count;
  if (first < n) {
    switch(attrib) {
    case VERTICES:  {
    
      float low, high;
      int i, thisn;
      AABox bbox = ((Subscene*)subscene)->getBoundingBox();
      i = 0;
     
      low = bbox.vmin.x;
      high = bbox.vmax.x;
      thisn = xaxis.getNticks(low, high);
      for (int j=0; j<thisn; j++) {
        if (first <= i && i < n) {
          *result++ = xaxis.getTick(low, high, j);
          *result++ = NA_REAL;
          *result++ = NA_REAL;
        }
        i++;  
      }
      
      low = bbox.vmin.y;
      high = bbox.vmax.y;
      thisn = yaxis.getNticks(low, high);
      for (int j=0; j<thisn; j++) {
        if (first <= i && i < n) {
          *result++ = NA_REAL;
          *result++ = yaxis.getTick(low, high, j);
          *result++ = NA_REAL;
        }
        i++;  
      }
      
      low = bbox.vmin.z;
      high = bbox.vmax.z;
      thisn = zaxis.getNticks(low, high);
      for (int j=0; j<thisn; j++) {
        if (first <= i && i < n) {
          *result++ = NA_REAL;
          *result++ = NA_REAL;
          *result++ = zaxis.getTick(low, high, j);
        }
        i++;  
      }
      return;
    }
    case COLORS:
      while (first < n) {
	Color color = material.colors.getColor(first);
	*result++ = color.data[0];
	*result++ = color.data[1];
	*result++ = color.data[2];
	*result++ = color.data[3];
	first++;
      }
      return;
    case FLAGS:
      *result++ = (double) draw_front;
      *result++ = (double) marklen_fract;
      break;  // there could be more flags, so fall through...
    case AXES:
      *result++ = xaxis.mode;
      *result++ = yaxis.mode;
      *result++ = zaxis.mode;
      *result++ = xaxis.unit;
      *result++ = yaxis.unit;
      *result++ = zaxis.unit;
      *result++ = xaxis.len;
      *result++ = yaxis.len;
      *result++ = zaxis.len;
      *result++ = marklen_value;
      *result++ = marklen_value;
      *result++ = marklen_value;
      *result++ = expand;
      *result++ = expand;
      *result++ = expand;
      return;
    }
    SceneNode::getAttribute(subscene, attrib, first, count, result);
  }
}

std::string BBoxDeco::getTextAttribute(SceneNode* subscene, AttribID attrib, int index)
{
  int n = getAttributeCount(subscene, attrib);
  
  if (index < n) {
    int count;
    switch(attrib) {
    case TEXTS: {
      AABox bbox = ((Subscene*)subscene)->getBoundingBox();
      count = xaxis.getNticks(bbox.vmin.x, bbox.vmax.x);
      if (index < count) {
        if (xaxis.mode == AXIS_CUSTOM)
          return xaxis.textArray[index];
        else
          return "";
      }  
      index -= count;
      count = yaxis.getNticks(bbox.vmin.y, bbox.vmax.y);
      if (index < count) {
        if (yaxis.mode == AXIS_CUSTOM)
          return yaxis.textArray[index];
        else
          return "";
      }  
      index -= count;
      count = zaxis.getNticks(bbox.vmin.z, bbox.vmax.z);
      if (index < count) {
        if (zaxis.mode == AXIS_CUSTOM)
          return zaxis.textArray[index];
        else
          return "";
      }
      break;
    }
    }
  }
  return "";
}
