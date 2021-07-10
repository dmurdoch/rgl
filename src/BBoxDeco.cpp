#include "BBoxDeco.h"

#ifndef RGL_NO_OPENGL
#include "gl2ps.h"
#endif
#include "glgui.h"
#include "scene.h"
#include <cstdio>
#include <cmath>
#include "R.h"
#include "pretty.h"

#if 0
// This is debugging code to track down font problems.

#include "R.h"

static GLenum flags[] = {
GL_ALPHA_TEST ,
GL_AUTO_NORMAL ,
GL_MAP2_VERTEX_4,
GL_BLEND,

GL_CLIP_PLANE0,
GL_CLIP_PLANE1,
GL_CLIP_PLANE2,
GL_COLOR_LOGIC_OP,

GL_COLOR_MATERIAL,
GL_COLOR_TABLE,
GL_CONVOLUTION_1D,
GL_CONVOLUTION_2D,

GL_CULL_FACE,
GL_DEPTH_TEST,
GL_DITHER,
GL_FOG,

GL_HISTOGRAM,
GL_INDEX_LOGIC_OP,
GL_LIGHT0,
GL_LIGHT1,

GL_LIGHT2,
GL_LIGHTING,
GL_LINE_SMOOTH,
GL_LINE_STIPPLE,

GL_MAP1_COLOR_4,
GL_MAP1_INDEX,
GL_MAP1_NORMAL,
GL_MAP1_TEXTURE_COORD_1,

GL_MAP1_TEXTURE_COORD_2,
GL_MAP1_TEXTURE_COORD_3,
GL_MAP1_TEXTURE_COORD_4,
GL_MAP1_VERTEX_3,

GL_MAP1_VERTEX_4,
GL_MAP2_COLOR_4,
GL_MAP2_INDEX,
GL_MAP2_NORMAL,

GL_MAP2_TEXTURE_COORD_1,
GL_MAP2_TEXTURE_COORD_2,
GL_MAP2_TEXTURE_COORD_3,
GL_MAP2_TEXTURE_COORD_4,

GL_MAP2_VERTEX_3,
GL_MAP2_VERTEX_4,
GL_MINMAX,
GL_NORMALIZE,

GL_POINT_SMOOTH,
GL_POLYGON_OFFSET_FILL,
GL_POLYGON_OFFSET_LINE,
GL_POLYGON_OFFSET_POINT,

GL_POINT,
GL_POLYGON_SMOOTH,
GL_POLYGON_STIPPLE,
GL_POST_COLOR_MATRIX_COLOR_TABLE,

GL_POST_CONVOLUTION_COLOR_TABLE,
GL_RESCALE_NORMAL,
GL_SEPARABLE_2D,
GL_SCISSOR_TEST,

GL_STENCIL_TEST,
GL_TEXTURE_1D,
GL_TEXTURE_2D,
GL_TEXTURE_3D,

GL_TEXTURE_GEN_Q,
GL_TEXTURE_GEN_R,
GL_TEXTURE_GEN_S,
GL_TEXTURE_GEN_T};

void Rpf(const char * msg)
{
  int flag1=0, flag2 = 0;
  for (int i=0; i< 32; i++) {
    GLboolean f;
    glGetBooleanv( flags[i], &f);
    if (f) flag1 += (1 << i);
    glGetBooleanv( flags[i+32], &f);
    if (f) flag2 += (1 << i);
    }
  
  Rprintf("%s: Flags 0 to 31: %x 32 to 63: %x\n", msg, flag1, flag2);
  GLint modes[2];
  glGetIntegerv( GL_POLYGON_MODE, modes);
  Rprintf("    Polygon modes: %X %X\n", modes[0], modes[1]);
 }  
#endif 

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
  ticks = NULL;
  len   = 2;
  unit  = 0;
}

AxisInfo::AxisInfo(int in_nticks, double* in_ticks, char** in_texts, int in_len, float in_unit)
: textArray(in_nticks, in_texts)
{
 
  int i;

  nticks = in_nticks;
  len    = in_len;
  unit   = in_unit;
  ticks  = NULL;

  if (nticks > 0) {

    mode = AXIS_CUSTOM;

    ticks = new float [nticks];

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
    ticks = new float [nticks];
    memcpy (ticks, from.ticks, sizeof(float)*nticks);
  } else
    ticks = NULL;
}

AxisInfo::~AxisInfo()
{
  if (ticks) {
    delete [] ticks;
  }
}

void AxisInfo::draw(RenderContext* renderContext, Vertex4& v, Vertex4& dir, Matrix4x4& modelview, 
                    Vertex& marklen, String& string) {
#ifndef RGL_NO_OPENGL
  Vertex4 p;
  GLboolean valid;
    
  // draw mark ( 1 time ml away )

  p.x = v.x + dir.x * marklen.x;
  p.y = v.y + dir.y * marklen.y;
  p.z = v.z + dir.z * marklen.z;  
  
  glBegin(GL_LINES);
  glVertex3f(v.x,v.y,v.z);
  glVertex3f(p.x,p.y,p.z);
  glEnd();
  
  // draw text ( 2 times ml away )

  p.x = v.x + 2 * dir.x * marklen.x;
  p.y = v.y + 2 * dir.y * marklen.y;
  p.z = v.z + 2 * dir.z * marklen.z; 

  glRasterPos3f( p.x, p.y, p.z );
  
  glGetBooleanv(GL_CURRENT_RASTER_POSITION_VALID, &valid);
  if (valid) {  
    // Work out the text adjustment 
  
    float adj = 0.5;  
    Vertex4 eyedir = modelview * dir;
    bool  xlarge = fabs(eyedir.x) > fabs(eyedir.y);
  
    if (xlarge) {
      adj = fabs(eyedir.y)/fabs(eyedir.x)/2.0f;
      if (eyedir.x < 0) adj = 1.0f - adj;
    }
  
    if (renderContext->font)
      renderContext->font->draw(string.text, string.length, adj, 0.5, 0, 
                                *renderContext);
  }      
#endif
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
  Edge(int in_from, int in_to, Vertex4 in_dir, Vertex3 in_code) : from(in_from), to(in_to), dir(in_dir), code(in_code) { }
  int from, to;
  Vertex4 dir;
  Vertex3 code;
};

static Edge xaxisedge[4] = { 
  Edge( 5,4, Vertex4( 0.0f, 0.0f, 1.0f, 0.0f), Vertex3( 0.0f, -1.0f,  1.0f) ), 
  Edge( 0,1, Vertex4( 0.0f, 0.0f,-1.0f, 0.0f), Vertex3( 0.0f, -1.0f, -1.0f) ),
  Edge( 6,7, Vertex4( 0.0f, 0.0f, 1.0f, 0.0f), Vertex3( 0.0f,  1.0f,  1.0f) ),
  Edge( 3,2, Vertex4( 0.0f, 0.0f,-1.0f, 0.0f), Vertex3( 0.0f,  1.0f, -1.0f) )
};

static Edge yaxisedge[8] = { 
  Edge( 5,7, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f), Vertex3( 1.0f, 0.0f, 1.0f) ),
  Edge( 7,5, Vertex4( 0.0f, 0.0f, 1.0f, 0.0f), Vertex3( 1.0f, 0.0f, 1.0f) ), 
  Edge( 6,4, Vertex4(-1.0f, 0.0f, 0.0f, 0.0f), Vertex3(-1.0f, 0.0f, 1.0f) ), 
  Edge( 4,6, Vertex4( 0.0f, 0.0f, 1.0f, 0.0f), Vertex3(-1.0f, 0.0f, 1.0f) ), 
  Edge( 2,0, Vertex4( 0.0f, 0.0f,-1.0f, 0.0f), Vertex3(-1.0f, 0.0f, -1.0f)  ), 
  Edge( 0,2, Vertex4(-1.0f, 0.0f, 0.0f, 0.0f), Vertex3(-1.0f, 0.0f, -1.0f)  ),
  Edge( 3,1, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f), Vertex3( 1.0f, 0.0f, -1.0f)  ), 
  Edge( 1,3, Vertex4( 0.0f, 0.0f,-1.0f, 0.0f), Vertex3( 1.0f, 0.0f, -1.0f)  )
};
static Edge zaxisedge[4] = { 
  Edge( 1,5, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f), Vertex3( 1.0f,-1.0f, 0.0f)  ), 
  Edge( 4,0, Vertex4(-1.0f, 0.0f, 0.0f, 0.0f), Vertex3(-1.0f,-1.0f, 0.0f)  ), 
  Edge( 7,3, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f), Vertex3( 1.0f, 1.0f, 0.0f)  ), 
  Edge( 2,6, Vertex4(-1.0f, 0.0f, 0.0f, 0.0f), Vertex3(-1.0f, 1.0f, 0.0f)  ) 
};


AxisInfo BBoxDeco::defaultAxis(0,NULL,NULL,0,5);
Material BBoxDeco::defaultMaterial( Color(0.6f,0.6f,0.6f,0.5f), Color(1.0f,1.0f,1.0f) );

BBoxDeco::BBoxDeco(Material& in_material, AxisInfo& in_xaxis, AxisInfo& in_yaxis, AxisInfo& in_zaxis, float in_marklen_value, bool in_marklen_fract,
                   float in_expand, bool in_front)
: SceneNode(BBOXDECO), material(in_material), xaxis(in_xaxis), yaxis(in_yaxis), zaxis(in_zaxis), marklen_value(in_marklen_value), marklen_fract(in_marklen_fract),
  expand(in_expand), draw_front(in_front)
#ifndef RGL_NO_OPENGL  
  , axisBusy(false)
#endif
{
  material.colors.recycle(2);
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

struct BBoxDeco::BBoxDecoImpl {
  
  static Edge* chooseEdge(RenderContext* renderContext, BBoxDeco& bboxdeco, int coord) 
  {
    
    AABox bbox = renderContext->subscene->getBoundingBox();
    
    if (!bbox.isValid())
      return NULL;
    
    Vertex center = bbox.getCenter();
    bbox += center + (bbox.vmin - center)*bboxdeco.expand;
    bbox += center + (bbox.vmax - center)*bboxdeco.expand;
    
    // edge adjacent matrix
    
    int adjacent[8][8] = { { 0 } };
    
    int i,j;
    
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
    
    Vertex4 eyev[8];
    
    // transform vertices: used for edge distance criterion and text justification
    
    Matrix4x4 modelview(renderContext->subscene->modelMatrix);
    
    for(i=0;i<8;i++)
      eyev[i] = modelview * boxv[i];
    
    for(i=0;i<6;i++) {
      
      const Vertex4 q = modelview * side[i].normal;
      const Vertex4 view(0.0f,0.0f,1.0f,0.0f);
      
      float cos_a = view * q;
      
      const bool front = (cos_a >= 0.0f) ? true : false;
      
      if (bboxdeco.draw_front || !front) {
        
        for(j=0;j<4;j++) {
          
          if (!front) {
            // modify adjacent matrix
            
            int from = side[i].vidx[j];
            int to   = side[i].vidx[(j+1)%4];
            
            adjacent[from][to] = 1;
          }          
          
        }
        
      }
    }
    
    AxisInfo*  axis;
    Edge*  axisedge;
    int    nedges;
    
    switch(coord)
    {
      case 0:
        axis     = &(bboxdeco.xaxis);       
        axisedge = xaxisedge;
        nedges   = 4;
        break;
      case 1:
        axis     = &(bboxdeco.yaxis);
        axisedge = yaxisedge;
        nedges   = 8;
        break;
      case 2:
      default:
        axis     = &(bboxdeco.zaxis);
        axisedge = zaxisedge;
        nedges   = 4;
        break;
    }
    
    if (axis->mode == AXIS_NONE)
      return NULL;
    
    // search z-nearest contours
    
    float d = FLT_MAX;
    Edge* edge = NULL;
    
    for(j=0;j<nedges;j++) {
      
      int from = axisedge[j].from;
      int to   = axisedge[j].to;
      
      if ((adjacent[from][to] == 1) && (adjacent[to][from] == 0)) {
        
        // found contour
        
        float dtmp = -(eyev[from].z + eyev[to].z)/2.0f;
        
        if (dtmp < d) {
          
          // found near contour
          
          d = dtmp;
          edge = &axisedge[j];
          
        }
        
      } 
      
    }
    return edge;
  }
  
  static void setMarginParameters(RenderContext* renderContext, BBoxDeco& bboxdeco, Material* material,
                                  int *at, int* line, int* level,
                                  Vec3* trans, Vec3* scale) {
    *at = material->marginCoord;
    Edge* edge = BBoxDecoImpl::chooseEdge(renderContext, bboxdeco, *at);
    int j;
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
    AABox bbox = renderContext->subscene->getBoundingBox();
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
};

void BBoxDeco::render(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL  
  AABox bbox = renderContext->subscene->getBoundingBox();
  
  if (bbox.isValid()) {
    
    glPushAttrib(GL_ENABLE_BIT);
    
    int i,j;
    
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
    
    // 
    // // transform vertices: used for edge distance criterion and text justification
    // 
    Matrix4x4 modelview(renderContext->subscene->modelMatrix);
    
    // setup material
    
    material.beginUse(renderContext);
    
    if (material.line_antialias || material.isTransparent()) {
      // SETUP BLENDING
      if (renderContext->gl2psActive == GL2PS_NONE) 
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
      else
        gl2psBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
      // ENABLE BLENDING
      glEnable(GL_BLEND);
      
    }
    
    // draw back faces
    
    glBegin(GL_QUADS);
    
    for(i=0;i<6;i++) {
      
      const Vertex4 q = modelview * side[i].normal;
      const Vertex4 view(0.0f,0.0f,1.0f,0.0f);
      
      float cos_a = view * q;
      
      const bool front = (cos_a >= 0.0f) ? true : false;
      
      if (draw_front || !front) {
        
        // draw face
        
        glNormal3f(side[i].normal.x, side[i].normal.y, side[i].normal.z);
        
        for(j=0;j<4;j++) {
          
          // feed vertex
          
          Vertex4& v = boxv[ side[i].vidx[j] ];
          glVertex3f(v.x, v.y, v.z);
          
        }
        
      }
    }
    
    glEnd();
    
    // setup mark length
    
    Vertex marklen = getMarkLength(bbox);
    
    
    // draw axis and tickmarks
    // find contours
    
    glDisable(GL_LIGHTING);
    
    material.useColor(1);
    
    for(i=0;i<3;i++) {
      Vertex4 v;
      AxisInfo*  axis;
      float* valueptr;
      float  low, high;
      switch(i)
      {
        case 0:
          axis     = &xaxis;       
          valueptr = &v.x;
          low      = bbox.vmin.x;
          high     = bbox.vmax.x;
          break;
        case 1:
          axis     = &yaxis;
          valueptr = &v.y;
          low      = bbox.vmin.y;
          high     = bbox.vmax.y;
          break;
        case 2:
        default:
          axis     = &zaxis;
          valueptr = &v.z;
          low      = bbox.vmin.z;
          high     = bbox.vmax.z;
          break;
      }
      if (axis->mode == AXIS_NONE)
        continue;
      
      Edge* edge = BBoxDecoImpl::chooseEdge(renderContext, *this, i); 
      
      if (axis->mode == AXIS_USER) {
        
        if (!axisBusy) {
          axisBusy = true;
          if (axisCallback[i]) {
            int e[3];
            if (edge) {
              e[0] = edge->code[0];
              e[1] = edge->code[1];
              e[2] = edge->code[2];
            } else{
              e[0] = 0;
              e[1] = 0;
              e[2] = 0;
            }
            axisCallback[i](axisData[i], i, e);
            axisBusy = false;
          }
        }
      } else if (edge) {
        
        v = boxv[edge->from];
        
        switch (axis->mode) {
        case AXIS_CUSTOM:
        {
          // draw axis and tickmarks
          
          StringArrayIterator iter(&axis->textArray);
          
          
          for (iter.first(), j=0; (j<axis->nticks) && (!iter.isDone());j++, iter.next()) {
            
            float value = axis->ticks[j];
            
            // clip marks
            
            if ((value >= low) && (value <= high)) {
              
              String string = iter.getCurrent();
              *valueptr = value;
              axis->draw(renderContext, v, edge->dir, modelview, marklen, string);
            }
            
          }
        }
        break;
        case AXIS_LENGTH:
        {
          float delta = (axis->len>1) ? (high-low)/((axis->len)-1) : 0;
  
          for(int k=0;k<axis->len;k++)
          {
            float value = low + delta * (float)k;
  
            *valueptr = value;
  
            char text[32];
            sprintf(text, "%.4g", value);
              
            String string(static_cast<int>(strlen(text)),text);
              
            axis->draw(renderContext, v, edge->dir, modelview, marklen, string);
          }
        }
        break;
        case AXIS_UNIT:
        {
          float value =  ( (float) ( (int) ( ( low+(axis->unit-1) ) / (axis->unit) ) ) ) * (axis->unit);
          while(value < high) {
                
            *valueptr = value;
                
            char text[32];
            sprintf(text, "%.4g", value);
                
            String s (static_cast<int>(strlen(text)),text);
                
            axis->draw(renderContext, v, edge->dir, modelview, marklen, s );
                
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
                
          for (int i=(int)lo; i<=up; i++) {
            float value = i*axis->unit;
            if (value >= low && value <= high) {
              *valueptr = value;
                    
              char text[32];
              sprintf(text, "%.4g", value);
                    
              String s (static_cast<int>(strlen(text)),text);
                    
              axis->draw(renderContext, v, edge->dir, modelview, marklen, s );
            }
          }
        }
        break;
        }
        
       }
    }
    material.endUse(renderContext);
    glPopAttrib();
  }
#endif  
}

Vec3 BBoxDeco::marginVecToDataVec(Vec3 marginvec, RenderContext* renderContext, Material* material) {
  /* Create permutation to map at, line, pos to x, y, z */
  int at = 0, line = 0, level = 0; /* initialize to suppress warning */
  Vec3 trans, scale;
  BBoxDecoImpl::setMarginParameters(renderContext, *this, material,
        &at, &line, &level,
        &trans, &scale); 
  /* It might make more sense to do this by
   * modifying the MODELVIEW matrix, but 
   * I couldn't get that right for some reason...
   */
  Vertex result;
  AABox bbox = renderContext->subscene->getBoundingBox();
  if (marginvec.missing())
    result[at] = (bbox.vmin[at] + bbox.vmax[at])/2.0;
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
}

void BBoxDeco::getAxisCallback(userAxisPtr *fn, void** user, int axis)
{
  *fn = axisCallback[axis];
  *user = axisData[axis];
}

int BBoxDeco::getAttributeCount(AABox& bbox, AttribID attrib) 
{
  switch (attrib) {    
    case TEXTS: {
      int count = ((xaxis.mode == AXIS_CUSTOM) ? xaxis.nticks : 0)
           + ((yaxis.mode == AXIS_CUSTOM) ? yaxis.nticks : 0)
           + ((zaxis.mode == AXIS_CUSTOM) ? zaxis.nticks : 0);
      if (count == 0) return 0; 
    }
    /* if non-zero, we want labels for every vertex, so fall through. */
    case VERTICES:
      return xaxis.getNticks(bbox.vmin.x, bbox.vmax.x)
           + yaxis.getNticks(bbox.vmin.y, bbox.vmax.y)
           + zaxis.getNticks(bbox.vmin.z, bbox.vmax.z);
    case COLORS:
      return material.colors.getLength();
    case FLAGS:
      return 2;
    case AXES:
      return 5;
  }
  return SceneNode::getAttributeCount(bbox, attrib);
}

void BBoxDeco::getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(bbox, attrib);

  if (first + count < n) n = first + count;
  if (first < n) {
    switch(attrib) {
    case VERTICES:  
    
      float low, high;
      int i, thisn;
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
    SceneNode::getAttribute(bbox, attrib, first, count, result);
  }
}

String BBoxDeco::getTextAttribute(AABox& bbox, AttribID attrib, int index)
{
  int n = getAttributeCount(bbox, attrib);
  
  if (index < n) {
    int count;
    switch(attrib) {
    case TEXTS: 
      count = xaxis.getNticks(bbox.vmin.x, bbox.vmax.x);
      if (index < count) {
        if (xaxis.mode == AXIS_CUSTOM)
          return xaxis.textArray[index];
        else
          return String(0, NULL);
      }  
      index -= count;
      count = yaxis.getNticks(bbox.vmin.y, bbox.vmax.y);
      if (index < count) {
        if (yaxis.mode == AXIS_CUSTOM)
          return yaxis.textArray[index];
        else
          return String(0, NULL);
      }  
      index -= count;
      count = zaxis.getNticks(bbox.vmin.z, bbox.vmax.z);
      if (index < count) {
        if (zaxis.mode == AXIS_CUSTOM)
          return zaxis.textArray[index];
        else
          return String(0, NULL);
      }
      break;
    }
  }
  return String(0, NULL);
}
