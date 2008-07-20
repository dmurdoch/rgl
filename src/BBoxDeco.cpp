#include "BBoxDeco.hpp"

#include "glgui.hpp"
#include "scene.h"
#include <cstdio>
#include <cmath>

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

  Vertex4 p;
    
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
  
  // Work out the text adjustment 
  
  float adj = 0.5;  
  Vertex4 eyedir = modelview * dir;
  bool  xlarge = fabs(eyedir.x) > fabs(eyedir.y);
  
  if (xlarge) {
    adj = fabs(eyedir.y)/fabs(eyedir.x)/2.0;
    if (eyedir.x < 0) adj = 1.0 - adj;
  }
  
  if (renderContext->font)
    renderContext->font->draw(string.text, string.length, adj, 0.5, *renderContext);

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
  Edge(int in_from, int in_to, Vertex4 in_dir) : from(in_from), to(in_to), dir(in_dir) { }
  int from, to;
  Vertex4 dir;
};

static Edge xaxisedge[4] = { 
  Edge( 5,4, Vertex4( 0.0f, 0.0f, 1.0f, 0.0f) ), 
  Edge( 0,1, Vertex4( 0.0f, 0.0f,-1.0f, 0.0f) ),
  Edge( 6,7, Vertex4( 0.0f, 0.0f, 1.0f, 0.0f) ),
  Edge( 3,2, Vertex4( 0.0f, 0.0f,-1.0f, 0.0f) )
};
static Edge yaxisedge[8] = { 
  Edge( 5,7, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f) ),
  Edge( 7,5, Vertex4( 0.0f, 0.0f, 1.0f, 0.0f) ), 
  Edge( 6,4, Vertex4(-1.0f, 0.0f, 0.0f, 0.0f) ), 
  Edge( 4,6, Vertex4( 0.0f, 0.0f, 1.0f, 0.0f) ), 
  Edge( 2,0, Vertex4( 0.0f, 0.0f,-1.0f, 0.0f) ), 
  Edge( 0,2, Vertex4(-1.0f, 0.0f, 0.0f, 0.0f) ),
  Edge( 3,1, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f) ), 
  Edge( 1,3, Vertex4( 0.0f, 0.0f,-1.0f, 0.0f) )
};
static Edge zaxisedge[4] = { 
  Edge( 1,5, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f) ), 
  Edge( 4,0, Vertex4(-1.0f, 0.0f, 0.0f, 0.0f) ), 
  Edge( 7,3, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f) ), 
  Edge( 2,6, Vertex4(-1.0f, 0.0f, 0.0f, 0.0f) ) 
};


AxisInfo BBoxDeco::defaultAxis(0,NULL,NULL,0,5);
Material BBoxDeco::defaultMaterial( Color(0.6f,0.6f,0.6f,0.5f), Color(1.0f,1.0f,1.0f) );

BBoxDeco::BBoxDeco(Material& in_material, AxisInfo& in_xaxis, AxisInfo& in_yaxis, AxisInfo& in_zaxis, float in_marklen_value, bool in_marklen_fract,
                   float in_expand)
: SceneNode(BBOXDECO), material(in_material), xaxis(in_xaxis), yaxis(in_yaxis), zaxis(in_zaxis), marklen_value(in_marklen_value), marklen_fract(in_marklen_fract),
  expand(in_expand)
{
  material.colors.recycle(2);
}

Vertex BBoxDeco::getMarkLength(const AABox& boundingBox) const
{
  return (marklen_fract) ? (boundingBox.vmax - boundingBox.vmin) * (1 / marklen_value) : Vertex(1,1,1) * marklen_value;
}

AABox BBoxDeco::getBoundingBox(const AABox& in_bbox) const
{
  AABox bbox(in_bbox);

  Vertex marklen = getMarkLength(bbox);

  Vertex v = marklen * 2;

  bbox += bbox.vmin - v;
  bbox += bbox.vmax + v;

  return bbox;
}

void BBoxDeco::render(RenderContext* renderContext)
{
  AABox bbox = renderContext->scene->getBoundingBox();

  if (bbox.isValid()) {
  
    Vertex center = bbox.getCenter();
    bbox += center + (bbox.vmin - center)*expand;
    bbox += center + (bbox.vmax - center)*expand;

    // Sphere bsphere(bbox);

    glPushAttrib(GL_ENABLE_BIT);

    glDisable(GL_DEPTH_TEST);

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

    Matrix4x4 modelview(renderContext->modelview);

    for(i=0;i<8;i++)
      eyev[i] = modelview * boxv[i];
 
    // setup material
    
    material.beginUse(renderContext);

    // edge adjacent matrix

    int adjacent[8][8] = { { 0 } };

    // draw back faces
    // construct adjacent matrix

    glBegin(GL_QUADS);

    for(i=0;i<6;i++) {

      const Vertex4 q = modelview * side[i].normal;
      const Vertex4 view(0.0f,0.0f,1.0f,0.0f);
      
      float cos_a = view * q;

      const bool front = (cos_a >= 0.0f) ? true : false;

      if (!front) {

        // draw back face

        glNormal3f(side[i].normal.x, side[i].normal.y, side[i].normal.z);

        for(j=0;j<4;j++) {

          // modify adjacent matrix

          int from = side[i].vidx[j];
          int to   = side[i].vidx[(j+1)%4];

          adjacent[from][to] = 1;
          
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
      Edge*  axisedge;
      int    nedges;
      float* valueptr;
      float  low, high;

      switch(i)
      {
        case 0:
          axis     = &xaxis;       
          axisedge = xaxisedge;
          nedges   = 4;
          valueptr = &v.x;
          low      = bbox.vmin.x;
          high     = bbox.vmax.x;
          break;
        case 1:
          axis     = &yaxis;
          axisedge = yaxisedge;
          nedges   = 8;
          valueptr = &v.y;
          low      = bbox.vmin.y;
          high     = bbox.vmax.y;
          break;
        case 2:
	default:
          axis     = &zaxis;
          axisedge = zaxisedge;
          nedges   = 4;
          valueptr = &v.z;
          low      = bbox.vmin.z;
          high     = bbox.vmax.z;
          break;
      }

      if (axis->mode == AXIS_NONE)
        continue;

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

      if (edge) {

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

                String string(strlen(text),text);

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

                String s (strlen(text),text);

                axis->draw(renderContext, v, edge->dir, modelview, marklen, s );

                value += axis->unit;
              }
            }
            break;
        }
      }
    }

    material.endUse(renderContext);

    glPopAttrib();

  }

}
