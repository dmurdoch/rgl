// C++ source
// This file is part of RGL.
//
// $Id: scene.cpp,v 1.2 2003/05/14 10:58:36 dadler Exp $

#include "scene.h"
#include "math.h"

#include "lib.h"
#include "opengl.h"
#include <stdio.h>
#include <stdlib.h>

#include "pixmap.h"

template<>
void copy(double* from, Vertex* to, int size)
{
  copy(from, (float*) to, size*3);
}

//////////////////////////////////////////////////////////////////////////////
//
// SECTION: Strings
//

//
// CLASS
//   StringArrayImpl
//

class StringArrayImpl : public AutoDestroy
{
public:
  StringArrayImpl(int in_ntexts, char** in_texts) 
  {
    int i;

    ntexts = in_ntexts;

    lengths = new unsigned int [ntexts];

    int buflen = 0;

    for(i=0;i<ntexts;i++)
      buflen += lengths[i] = strlen(in_texts[i]);

    char* tptr = textbuffer = new char [buflen];

    for(i=0;i<ntexts;i++) {
      int len = lengths[i];
      memcpy(tptr, in_texts[i], len);
      tptr += len;
    }
  }

  ~StringArrayImpl()
  {
    delete [] lengths;
    delete [] textbuffer;
  }
  int   ntexts;
  char* textbuffer;
  unsigned int*  lengths;
};

//
// CLASS
//   StringArray
//

StringArray::StringArray()
{
  impl = NULL;
}

StringArray::StringArray(int in_ntexts, char** in_texts)
{
  if (in_ntexts > 0)
    impl = new StringArrayImpl(in_ntexts, in_texts);
  else
    impl = NULL;
}

StringArray::StringArray(StringArray& from)
{
  impl = from.impl;

  if (impl)
    impl->ref();
}

StringArray::~StringArray()
{
  if (impl)
    impl->unref();
}

//
// CLASS
//   StringArrayIterator
//

StringArrayIterator::StringArrayIterator(StringArray* in_array)
{
  array = in_array;
}

void StringArrayIterator::first()
{
  cnt = 0;
  if (array->impl)
    textptr = array->impl->textbuffer;
  else
    textptr = NULL;
}

void StringArrayIterator::next()
{
  if ( (textptr) && (cnt < array->impl->ntexts) )
    textptr += array->impl->lengths[cnt++];
}

String StringArrayIterator::getCurrent()
{
  return String(array->impl->lengths[cnt], textptr );
}

bool StringArrayIterator::isDone() const 
{
  if (array->impl)
    return (cnt == array->impl->ntexts) ? true : false;
  else
    return true;
}

//////////////////////////////////////////////////////////////////////////////
//
//  SECTION: MATERIAL
//
//////////////////////////////////////////////////////////////////////////////

//
// COLOR UTILS
//

//
// FUNCTION
//   HexCharToNibble
//

u8 HexCharToNibble(char c) {
  u8 nibble = 0;

  if ((c >= '0') && (c <= '9'))
    nibble = c - '0';
  else if (( c >= 'A') && (c <= 'F'))
    nibble = (c - 'A') + 10;
  else if (( c >= 'a') && (c <= 'f'))
    nibble = (c - 'a') + 10;

  return nibble;
}

//
// FUNCTION
//   StringToRGB8
//

static void StringToRGB8(const char* string, u8* colorptr) {

  char* strptr = (char*) string;
  int cnt = 0;

  if (( *strptr++ == '#') && (cnt < 3)) {
    char c;

    while( (c = *strptr++) != '\0' ) {
  
      u8 component;

      component = (HexCharToNibble(c) << 4);
      
      if ( (c = *strptr++) == '\0')
        break;

      component |= HexCharToNibble(c);

      *colorptr++ = component; cnt++;
    }
  }

  for(int i=cnt;i<3;i++)
    *colorptr++ = 0x00;
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Color
//

Color::Color()
{
  data[0] = 1.0f;
  data[1] = 1.0f;
  data[2] = 1.0f;
  data[3] = 1.0f;
}

Color::Color(float red, float green, float blue, float alpha)
{
  data[0] = red;
  data[1] = green;
  data[2] = blue;
  data[3] = alpha;
}

Color::Color(u8 red, u8 green, u8 blue, u8 alpha)
{
  data[0] = ((float)red)/255.0f;
  data[1] = ((float)green)/255.0f;
  data[2] = ((float)blue)/255.0f;
  data[3] = ((float)alpha)/255.0f;
}

Color::Color(const char* string)
{
  u8 tmp[4];

  tmp[3] = 255;

  StringToRGB8(string, tmp);
  for (int i=0;i<4;i++)
    data[i] = ((float)tmp[i])/255.0f;
}

void Color::set3iv(int* color)
{
  data[0] = ((float)color[0])/255.0f;
  data[1] = ((float)color[1])/255.0f;
  data[2] = ((float)color[2])/255.0f;
  data[3] = 1.0f;
}

void Color::useClearColor() const
{
  glClearColor(data[0],data[1],data[2], data[3]);
}

void Color::useColor() const
{
  glColor4fv(data);
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   ColorArray
//

ColorArray::ColorArray() 
{
  arrayptr = NULL;
  ncolor   = 0;
  nalpha   = 0;
}

ColorArray::ColorArray( Color& bg, Color &fg )
{
  ncolor   = 2;
  nalpha   = 2;
  arrayptr = (u8*) realloc( NULL, sizeof(u8) * 4 * ncolor);
  arrayptr[0] = bg.getRedub();
  arrayptr[1] = bg.getBlueub();
  arrayptr[2] = bg.getGreenub();
  arrayptr[3] = bg.getAlphaub();
  arrayptr[4] = fg.getRedub();
  arrayptr[5] = fg.getBlueub();
  arrayptr[6] = fg.getGreenub();
  arrayptr[7] = fg.getAlphaub();
  hint_alphablend = ( (bg.getAlphaub() < 255) || (fg.getAlphaub() < 255) ) ? true : false;
}

ColorArray::ColorArray( ColorArray& src ) {
  ncolor = src.ncolor;
  nalpha = src.nalpha;
  hint_alphablend = src.hint_alphablend;
  if (ncolor > 0) {
    arrayptr = (u8*) realloc( NULL, sizeof(u8) * 4 * ncolor);
    memcpy( arrayptr, src.arrayptr, sizeof(u8) * 4 * ncolor);
  } else {
    arrayptr = NULL;
  }
}

ColorArray::~ColorArray() {
  if (arrayptr)
    free(arrayptr);
}

void ColorArray::set( int in_ncolor, char** in_color, int in_nalpha, double* in_alpha)
{
  ncolor  = getMax(in_ncolor, in_nalpha);
  nalpha  = in_nalpha;
  u8* ptr = arrayptr = (u8*) realloc( arrayptr, sizeof(u8) * 4 * ncolor);

  hint_alphablend = false;

  for (unsigned int i=0;i<ncolor;i++) {
    StringToRGB8(in_color[i%in_ncolor], ptr);
    if (in_nalpha > 0) {
      u8 alpha = (u8) ( clamp( (float) in_alpha[i%in_nalpha], 0.0f, 1.0f) * 255.0f );
      if (alpha < 255)
        hint_alphablend = true;
      ptr[3] = alpha;
    } else
      ptr[3] = 0xFF;
    ptr += 4;
  }
}

void ColorArray::set( int in_ncolor, int* in_color, int in_nalpha, double* in_alpha)
{
  ncolor  = getMax(in_ncolor, in_nalpha);
  nalpha  = in_nalpha;
  u8* ptr = arrayptr = (u8*) realloc( arrayptr, sizeof(u8) * 4 * ncolor);

  hint_alphablend = false;

  for (unsigned int i=0;i<ncolor;i++) {
    int base = (i%in_ncolor) * 3;
    ptr[0] = (u8) in_color[base];
    ptr[1] = (u8) in_color[base+1];
    ptr[2] = (u8) in_color[base+2];
    if (in_nalpha > 0) {
      u8 alpha = (u8) ( clamp( (float) in_alpha[i%in_nalpha], 0.0f, 1.0f) * 255.0f );
      if (alpha < 255)
        hint_alphablend = true;
      ptr[3] = alpha;
    } else
      ptr[3] = 0xFF;
    ptr += 4;    
  }
}

unsigned int ColorArray::getLength() const
{
  return ncolor;
}

bool ColorArray::hasAlpha() const
{
  return hint_alphablend;
}

void ColorArray::useArray() const
{
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, (const GLvoid*) arrayptr );
}

void ColorArray::useColor(int index) const
{
  glColor4ubv( (const GLubyte*) &arrayptr[ index * 4] );
}

Color ColorArray::getColor(int index) const
{
  return Color( arrayptr[index*4], arrayptr[index*4+1], arrayptr[index*4+2], arrayptr[index*4+3] );
}

void ColorArray::recycle(unsigned int newsize)
{
  if (ncolor != newsize) {
    if (ncolor > 1) {

      if (newsize > 0) {
        arrayptr = (u8*) realloc(arrayptr, sizeof(u8)*4*newsize);

        for(unsigned int i=ncolor;i<newsize;i++) {
          int m = (i % ncolor)*4;
          arrayptr[i*4+0] = arrayptr[ m + 0];
          arrayptr[i*4+1] = arrayptr[ m + 1];
          arrayptr[i*4+2] = arrayptr[ m + 2];
          arrayptr[i*4+3] = arrayptr[ m + 3];
        }
      } else 
        arrayptr = NULL;

      ncolor = newsize;
    }
  }
}


//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   VertexArray
//

VertexArray::VertexArray()
{
  arrayptr = NULL;
}

VertexArray::~VertexArray()
{
  if (arrayptr)
    delete[] arrayptr;
}

void VertexArray::alloc(int nvertex)
{
  if (arrayptr)
    delete[] arrayptr;

  arrayptr = new float [nvertex*3];
}

void VertexArray::copy(int nvertex, double* vertices)
{
  for(int i=0;i<nvertex;i++) {
    arrayptr[i*3+0] = (float) vertices[i*3+0];
    arrayptr[i*3+1] = (float) vertices[i*3+1];
    arrayptr[i*3+2] = (float) vertices[i*3+2];
  }
}

inline Vertex& VertexArray::operator[](int index) {
  return (Vertex&) arrayptr[index*3];
}

void VertexArray::beginUse() {
  glEnableClientState(GL_VERTEX_ARRAY);
  glVertexPointer(3, GL_FLOAT, 0, (const GLvoid*) arrayptr );
}

void VertexArray::endUse() {
  glDisableClientState(GL_VERTEX_ARRAY);
}

Vertex VertexArray::getNormal(int iv1, int iv2, int iv3)
{
  Vertex normal;

  Vertex& v1 = (*this)[iv1];
  Vertex& v2 = (*this)[iv2];
  Vertex& v3 = (*this)[iv3];

  Vertex a(v3-v2), b(v1-v2);

  normal = a.cross(b);

  normal.normalize();

  return normal;
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   NormalArray
//

void NormalArray::beginUse() {
  glEnableClientState(GL_NORMAL_ARRAY);
  glNormalPointer(GL_FLOAT, 0, (const GLvoid*) arrayptr );
}

void NormalArray::endUse() {
  glDisableClientState(GL_NORMAL_ARRAY);
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   TexCoordArray
//

TexCoordArray::TexCoordArray()
{
  arrayptr = NULL;
}

TexCoordArray::~TexCoordArray()
{
  if (arrayptr)
    delete[] arrayptr;
}

void TexCoordArray::alloc(int nvertex)
{
  if (arrayptr) {
    delete[] arrayptr;
    arrayptr = NULL;
  }
  arrayptr = new float[2*nvertex];
}

TexCoord& TexCoordArray::operator [] (int index) {
  return (TexCoord&) arrayptr[index*2];
}

void TexCoordArray::beginUse() {
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  glTexCoordPointer(2, GL_FLOAT, 0, (const GLvoid*) arrayptr );
}

void TexCoordArray::endUse() {
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Scene
//

static int gl_light_ids[8] = { GL_LIGHT0, GL_LIGHT1, GL_LIGHT2, GL_LIGHT3, GL_LIGHT4, GL_LIGHT5, GL_LIGHT6, GL_LIGHT7 };

Scene::Scene()
{
  background = NULL;
  viewpoint  = NULL;
  nlights    = 0;
  bboxDeco   = NULL;
 
  add( new BBoxDeco );
  add( new Background );
  add( new Viewpoint );
  add( new Light ); 
}

Scene::~Scene()
{
  clear(SHAPE);
  clear(LIGHT);
  clear(BBOXDECO);

  if (background)
    delete background;
  if (viewpoint)
    delete viewpoint;
}

Viewpoint* Scene::getViewpoint() 
{
  return viewpoint;
}

bool Scene::clear(TypeID typeID)
{
  bool success = false;

  switch(typeID) {
    case SHAPE:
      shapes.deleteItems();
      data_bbox.invalidate();
      success = true;
      break;
    case LIGHT:
      lights.deleteItems();
      nlights = 0;
      success = true;
      break;
    case BBOXDECO:
      delete bboxDeco;
      bboxDeco = NULL;
      success = true;
      break;
    default:
      break;
  }
  return success;
}

bool Scene::add(SceneNode* node)
{
  bool success = false;
  switch( node->getTypeID() )
  {
    case LIGHT:
      if (nlights < 8) {

        Light* light = (Light*) node;

        light->id = gl_light_ids[ nlights++ ];

        lights.addTail( light );

        success = true;
      }
      break;
    case SHAPE:
      {
        Shape* shape = (Shape*) node;

        data_bbox += shape->getBoundingBox();

        shapes.addTail( shape );
        success = true;
      }
      break;
    case VIEWPOINT:
      {
        if (viewpoint)
          delete viewpoint;
        viewpoint = (Viewpoint*) node;
        success = true;
      }
      break;
    case BACKGROUND:
      {
        if (background)
          delete background;
        background = (Background*) node;
        success = true;
      }
      break;
    case BBOXDECO:
      {
        if (bboxDeco)
          delete bboxDeco;
        bboxDeco = (BBoxDeco*) node;
        success = true;
      }
      break;
    default:
      break;
  }
  return success;
}


bool Scene::pop(TypeID type)
{
  bool success = false;

  switch(type) {
  case SHAPE:
    {
      Node* tail = shapes.getTail();
      if (tail) {
        delete shapes.remove(tail);

        calcDataBBox();

        success = true;
      }
    }
    break;
  case LIGHT:
    {
      Node* tail = lights.getTail();
      if (tail) {
        delete lights.remove(tail);
        nlights--;
        success = true;
      }
    }
    break;
  case BBOXDECO:
    {
      if (bboxDeco) {
        delete bboxDeco;
        bboxDeco = NULL;
        success = true;
      }
    }
    break;
  default: // VIEWPOINT,BACKGROUND ignored
    break;
  }

  return success;
}

void Scene::render(RenderContext* renderContext)
{
  renderContext->scene     = this;
  renderContext->viewpoint = viewpoint;


  //
  // CLEAR BUFFERS
  //

  GLbitfield clearFlags = 0;

  // Depth Buffer

  glClearDepth(1.0);
  glDepthFunc(GL_LESS);

  clearFlags  |= GL_DEPTH_BUFFER_BIT;

  // Color Buffer (optional - depends on background node)
  
  clearFlags |= background->setupClear(renderContext);

  // clear

  glClear(clearFlags);


  //
  // SETUP LIGHTING MODEL
  //

  setupLightModel(renderContext);


  Sphere total_bsphere;

  if (data_bbox.isValid()) {
    
    // 
    // GET DATA VOLUME SPHERE
    //

    total_bsphere = Sphere( (bboxDeco) ? bboxDeco->getBoundingBox(data_bbox) : data_bbox );

  } else {
    total_bsphere = Sphere( Vertex(0,0,0), 1 );
  }


  //
  // SETUP VIEWPORT TRANSFORMATION
  //

  glViewport(0,0,renderContext->size.width, renderContext->size.height);


  //
  //
  //

  viewpoint->setupFrustum( renderContext, total_bsphere );

  //
  // RENDER BACKGROUND
  //

  background->render(renderContext);

  
  //
  // RENDER MODEL
  //

  if (data_bbox.isValid() ) {

    //
    // SETUP CAMERA
    //

    viewpoint->setupTransformation( renderContext, total_bsphere);

    //
    // RENDER BBOX DECO
    //

    if (bboxDeco)
      bboxDeco->render(renderContext);

    //
    // RENDER SOLID SHAPES
    //

    glEnable(GL_DEPTH_TEST);

    ListIterator iter(&shapes);

    for(iter.first(); !iter.isDone(); iter.next() ) {
      Shape* shape = (Shape*) iter.getCurrent();

      if (!shape->getMaterial().alphablend)
        shape->render(renderContext);
    }
    
    //
    // RENDER ALPHA SHADED
    //

    for(iter.first(); !iter.isDone(); iter.next() ) {
      Shape* shape = (Shape*) iter.getCurrent();

      if (shape->getMaterial().alphablend)
        shape->render(renderContext);
    }

  }
}


void Scene::setupLightModel(RenderContext* rctx)
{
  Color global_ambient(0.0f,0.0f,0.0f,1.0f);

  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, global_ambient.data );
  glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER, GL_TRUE );
  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE );

#ifdef GL_VERSION_1_2
//  glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL, GL_SINGLE_COLOR );
#endif

  //
  // global lights
  //

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  rctx->viewpoint->setupOrientation(rctx);

  ListIterator iter(&lights);

  for(iter.first(); !iter.isDone() ; iter.next() ) {

    Light* light = (Light*) iter.getCurrent();

    if (!light->viewpoint)
      light->setup(rctx);
  }

  //
  // viewpoint lights
  //

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  for(iter.first(); !iter.isDone() ; iter.next() ) {

    Light* light = (Light*) iter.getCurrent();

    if (light->viewpoint)
      light->setup(rctx);

  }

  //
  // disable unused lights
  //

  for (int i=nlights;i<8;i++)
    glDisable(gl_light_ids[i]);

}

void Scene::calcDataBBox()
{
  data_bbox.invalidate();

  ListIterator iter(&shapes);

  for(iter.first(); !iter.isDone(); iter.next() ) {
    Shape* shape = (Shape*) iter.getCurrent();

    data_bbox += shape->getBoundingBox();
  }
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Viewpoint
//

Viewpoint::Viewpoint(PolarCoord in_position, float in_fov, float in_zoom, bool in_interactive) :
    SceneNode(VIEWPOINT),
    position( in_position ),
    fov(in_fov),
    zoom(in_zoom),
    interactive(in_interactive)
{
};


PolarCoord& Viewpoint::getPosition()
{
  return position;
}

void Viewpoint::setPosition(const PolarCoord& in_position)
{
  position = in_position;
}

float Viewpoint::getZoom() const
{
  return zoom;
}

void Viewpoint::setZoom(const float in_zoom)
{
  zoom = in_zoom;
}

bool Viewpoint::isInteractive() const
{
  return interactive;
}

void Viewpoint::setFOV(const float in_fov)
{
  fov = clamp(in_fov, 1.0, 179.0 );
}

float Viewpoint::getFOV() const
{
  return fov;
}

void Viewpoint::setupFrustum(RenderContext* rctx, const Sphere& viewSphere)
{
  frustum.enclose(viewSphere.radius, fov, rctx->size);

  // zoom

  float factor = 1.0f/(1.0f+zoom* ((float)(VIEWPOINT_MAX_ZOOM-1)) );

  frustum.left *= factor;
  frustum.right *= factor;
  frustum.bottom *= factor;
  frustum.top *= factor;
}

void Viewpoint::setupOrientation(RenderContext* rctx) const
{
  glRotatef( position.phi,   1.0f, 0.0f, 0.0f);
  glRotatef(-position.theta, 0.0f, 1.0f, 0.0f);
}

void Viewpoint::setupTransformation(RenderContext* rctx, const Sphere& viewSphere)
{     
  // projection

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glFrustum(frustum.left, frustum.right, frustum.bottom, frustum.top, frustum.znear, frustum.zfar);  

  // modelview

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glTranslatef( 0.0f, 0.0f, -frustum.distance );

  setupOrientation(rctx);

  glTranslatef( -viewSphere.center.x, -viewSphere.center.y, -viewSphere.center.z );
}


//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Light
//

Light::Light( PolarCoord in_position, bool in_viewpoint, Color in_ambient, Color in_diffuse, Color in_specular )
: SceneNode(LIGHT), 
  ambient(in_ambient),
  diffuse(in_diffuse),
  specular(in_specular),
  id(GL_FALSE),
  viewpoint(in_viewpoint)
{
  Vertex v(0.0f, 0.0f, 1.0f);

  v.rotateX( -in_position.phi );
  v.rotateY(  in_position.theta );

  position[0] = v.x;
  position[1] = v.y;
  position[2] = v.z;

  position[3] = 0.0f;
}

void Light::setup(RenderContext* renderContext) 
{
  glLightfv(id, GL_AMBIENT,   ambient.data  );
  glLightfv(id, GL_DIFFUSE,   diffuse.data  );
  glLightfv(id, GL_SPECULAR,  specular.data );
  glLightfv(id, GL_POSITION,  position );

  glLightf(id, GL_SPOT_EXPONENT, 0.0f);
  glLightf(id, GL_SPOT_CUTOFF, 180.0f);

  glLightf(id, GL_CONSTANT_ATTENUATION, 1.0f);
  glLightf(id, GL_LINEAR_ATTENUATION, 0.0f);
  glLightf(id, GL_QUADRATIC_ATTENUATION, 0.0f);


  glEnable(id);
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   SphereMesh
//


SphereMesh::SphereMesh()
: center( Vertex(0.0f,0.0f,0.0f) ), 
  radius( 1.0f ),
  philow(-90.0f ),
  phihigh( 90.0f ),
  segments( 16 ),
  sections( 16 ),
  type( GLOBE ),
  genNormal(false),
  genTexCoord(false)
{
}

void SphereMesh::setGlobe(int in_segments, int in_sections)
{
  type     = GLOBE;
  segments = in_segments;
  sections = in_sections;
  setupMesh();
}

void SphereMesh::setTesselation(int level)
{
  type     = TESSELATION;
}

void SphereMesh::setupMesh()
{
  // setup arrays

  int nvertex = (sections+1) * (segments+1);

  vertexArray.alloc(nvertex);

  if (genNormal)
    normalArray.alloc(nvertex);

  if (genTexCoord)
    texCoordArray.alloc(nvertex);  
}

void SphereMesh::setCenter(const Vertex& in_center)
{
  center = in_center;
}

void SphereMesh::setRadius(float in_radius)
{
  radius = in_radius;
}

void SphereMesh::update()
{
  int i = 0;

  for(int iy=0;iy<=sections;iy++) {

    Vertex p(0.0f,0.0f,radius);

    float fy = ((float)iy)/((float)sections);

    float phi = philow + fy * (phihigh - philow);

    p.rotateX( -phi );

    for (int ix=0;ix<=segments;ix++,i++) {

      float fx  = ((float)ix)/((float)segments);
      float theta = fx * 360.0f;

      Vertex q(p);

      q.rotateY( theta );

      vertexArray[i] = center + q;

      if (genNormal) {
        normalArray[i] = q;
        normalArray[i].normalize();
      }

      if (genTexCoord) {
        texCoordArray[i].s = fx;
        texCoordArray[i].t = fy;
      }

    }
  }
}

void SphereMesh::draw(RenderContext* renderContext)
{
  vertexArray.beginUse();

  if (genNormal)
    normalArray.beginUse();

  if (genTexCoord)
    texCoordArray.beginUse();

  for(int i=0; i<sections; i++ ) {

    int curr = i * (segments+1);
    int next = curr + (segments+1);

    glBegin(GL_QUAD_STRIP);
    for(int i=0;i<=segments;i++) {
      glArrayElement( next + i );
      glArrayElement( curr + i );
    }
    glEnd();
  }

  vertexArray.endUse();

  if (genNormal)
    normalArray.endUse();

  if (genTexCoord)
    texCoordArray.endUse();
}


//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Shape
//

Shape::Shape(Material& in_material, TypeID in_typeID)
: SceneNode(in_typeID), material(in_material), displayList(0), doUpdate(true)
{
}

void Shape::update(RenderContext* renderContext)
{
  doUpdate = false;
}

void Shape::render(RenderContext* renderContext)
{
  if (displayList == 0)
    displayList = glGenLists(1);

  if (doUpdate) {
    update(renderContext);
    glNewList(displayList, GL_COMPILE_AND_EXECUTE);
    draw(renderContext);
    glEndList();
  } else 
    glCallList(displayList);
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Material
//

Material::Material(Color bg, Color fg)
: 
  ambient(0.0f,0.0f,0.0f,1.0f),
  specular(1.0f,1.0f,1.0f,1.0f),
  emission(0.0f,0.0f,0.0f,0.0f),
  shininess(50.0f),
  size(1.0f),
  colors(bg,fg),
  texture(NULL),
  front(FILL_FACE),
  back(FILL_FACE),
  smooth(true),
  lit(true), 
  fog(true),
  useColorArray(false)
{
  alphablend = ( ( bg.getAlphaf() < 1.0f ) || ( fg.getAlphaf() < 1.0f ) ) ? true : false;
}

Material::~Material()
{
/*
  if (texture)
    delete texture;
*/
}

void Material::setup()
{
}


void Material::beginUse(RenderContext* renderContext)
{
  int ncolor = colors.getLength();

  glPushAttrib(GL_DEPTH_BUFFER_BIT | GL_ENABLE_BIT | GL_POLYGON_BIT );

  if (alphablend) {
    glDepthMask(GL_FALSE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE );
  } else {
    glDepthMask(GL_TRUE);
  }

  glDisable(GL_CULL_FACE);

  for (int i=0;i<2;i++) {
    
    PolygonMode mode = (i==0) ? front : back;
    
    GLenum face = (i==0) ? GL_FRONT : GL_BACK;

    switch (mode) {
      case FILL_FACE:
        glPolygonMode( face, GL_FILL);
        break;
      case LINE_FACE:
        glPolygonMode( face, GL_LINE);
        break;
      case POINT_FACE:
        glPolygonMode( face, GL_POINT);
        break;
      case CULL_FACE:
        glEnable(GL_CULL_FACE);
        glCullFace(face);
        break;
    }
  }

  glShadeModel( (smooth) ? GL_SMOOTH : GL_FLAT );

  if (lit) {
    glEnable(GL_LIGHTING);

#ifdef GL_VERSION_1_2
//    glLightModeli(GL_LIGHT_MODEL_COLOUR_CONTROL, (texture) ? GL_SEPARATE_SPECULAR_COLOR : GL_SINGLE_COLOR );
#endif

    glColorMaterial(GL_FRONT_AND_BACK, GL_DIFFUSE);
    glEnable(GL_COLOR_MATERIAL);
    glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT, ambient.data);
    glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR, specular.data);
    glMaterialf (GL_FRONT_AND_BACK,GL_SHININESS, shininess);
    glMaterialfv(GL_FRONT_AND_BACK,GL_EMISSION, emission.data);
  }

  if ( (useColorArray) && ( ncolor > 1 ) ) {
    glEnableClientState(GL_COLOR_ARRAY);
    colors.useArray();
  } else
    colors.useColor(0);

  glPointSize( size );
  glLineWidth( size );

  if (texture)
    texture->beginUse(renderContext);

  if (!fog)
    glDisable(GL_FOG);
}

void Material::useColor(int index)
{
  if (colors.getLength() > 0)
    colors.useColor( index % colors.getLength() );
}

void Material::endUse(RenderContext* renderContext)
{
  int ncolor = colors.getLength();

  if ( (useColorArray) && ( ncolor > 1 ) ) {
    glDisableClientState(GL_COLOR_ARRAY);
  }

  if (texture)
    texture->endUse(renderContext);

  glPopAttrib();
}

void Material::colorPerVertex(bool enable, int numVertices)
{
  useColorArray = enable;
  if (enable)
    colors.recycle(numVertices);
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Surface
//

Surface::Surface(Material& in_material, int in_nx, int in_nz, double* in_x, double* in_z, double* in_y)
: Shape(in_material)
{
  nx = in_nx;
  nz = in_nz;

  int nvertex = nx*nz;

  material.colorPerVertex(true, nvertex);

  vertexArray.alloc(nvertex);

  if (material.texture)
    texCoordArray.alloc(nvertex);

  Vertex v;

  int iy  = 0;
  for(int iz=0;iz<nz;iz++) {
    v.z = (float) in_z[iz];
    for(int ix=0;ix<nx;ix++,iy++) {
      v.x = (float) in_x[ix];
      v.y = (float) in_y[iy];

      vertexArray[iy] = v;

      if (material.texture) {
        texCoordArray[iy].s = ((float)ix)/((float)(nx-1));
        texCoordArray[iy].t = 1.0f - ((float)iz)/((float)(nx-1));
      }

      boundingBox += v;
    }
  }
}

void Surface::setNormal(int ix, int iz)
{
  Vertex n[4];

  int i = iz*nx + ix;
  int num = 0;

  if (ix < nx-1) {
    if (iz > 0)     // right/top
      n[num++] = vertexArray.getNormal(i, i+1, i-nx );
    if (iz < nz-1)  // right/bottom
      n[num++] = vertexArray.getNormal(i, i+nx, i+1 );
  }
  if (ix > 0) { 
    if (iz > 0)     // left/top
      n[num++] = vertexArray.getNormal(i, i-nx, i-1 );
    if (iz < nz-1)  // left/bottom
      n[num++] = vertexArray.getNormal(i, i-1, i+nx );
  }

  Vertex total(0.0f,0.0f,0.0f);

  for(i=0;i<num;i++)
    total += n[i];

  total.normalize();

  glNormal3f(total.x,total.y,total.z);
}

void Surface::draw(RenderContext* renderContext)
{
  material.beginUse(renderContext);
  vertexArray.beginUse();

  if (material.texture)
    texCoordArray.beginUse();

  for(int iz=0;iz<nz-1;iz++) {
    glBegin(GL_QUAD_STRIP);
    for(int ix=0;ix<nx;ix++) {

      int i;

      i = (iz)  *nx+ix;
      if (material.lit)
        setNormal(ix, iz);
      glArrayElement( i );

      i = (iz+1)*nx+ix;
      if (material.lit)
        setNormal(ix, iz+1);
      glArrayElement( i );

    }
    glEnd();
  }

  if (material.texture)
    texCoordArray.endUse();

  vertexArray.endUse();

  material.endUse(renderContext);
}


//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   SphereSet
//

SphereSet::SphereSet(Material& in_material, int in_ncenter, double* in_center, int in_nradius, double* in_radius)
 : Shape(in_material), 
   center(in_ncenter, in_center), 
   radius(in_nradius, in_radius)
{
  material.colorPerVertex(false);

  if (material.lit)
    sphereMesh.setGenNormal(true);
  if (material.texture)
    sphereMesh.setGenTexCoord(true);

  sphereMesh.setGlobe(16,16);
  
  for (int i=0;i<center.size();i++)
    boundingBox += Sphere( center.get(i), radius.getRecycled(i) );
}

SphereSet::~SphereSet()
{
}

void SphereSet::draw(RenderContext* renderContext)
{
  material.beginUse(renderContext);

  for(int i=0;i<center.size();i++) {
  
    material.useColor(i);

    sphereMesh.setCenter( center.get(i) );
    sphereMesh.setRadius( radius.getRecycled(i) );

    sphereMesh.update();

    sphereMesh.draw(renderContext);
  }

  material.endUse(renderContext);
}


//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   SpriteSet
//

SpriteSet::SpriteSet(Material& in_material, int in_nvertex, double* in_vertex, int in_nsize, double* in_size)
 : Shape(in_material), 
  vertex(in_nvertex, in_vertex),
   size(in_nsize, in_size)
{ 
  material.colorPerVertex(false);

  for(int i=0;i<vertex.size();i++)
    boundingBox += Sphere( vertex.get(i), size.getRecycled(i) );
}

SpriteSet::~SpriteSet()
{ }

void SpriteSet::render(RenderContext* renderContext)
{ 
  double mdata[16] = { 0 };

  glGetDoublev(GL_MODELVIEW_MATRIX, mdata);

  Matrix4x4 m(mdata);

  material.beginUse(renderContext);
  
  glPushMatrix();

  glLoadIdentity();
  
  bool doTex = (material.texture) ? true : false;

  glNormal3f(0.0f,0.0f,1.0f);

  glBegin(GL_QUADS);
  for(int i=0;i<vertex.size();i++) {

    Vertex& o = vertex.get(i);
    float   s = size.getRecycled(i) * 0.5f;
    Vertex  v;

    v = m * o;

    material.useColor(i);

    if (doTex)
      glTexCoord2f(0.0f,0.0f);
    glVertex3f(v.x - s, v.y - s, v.z);

    if (doTex)
      glTexCoord2f(1.0f,0.0f);
    glVertex3f(v.x + s, v.y - s, v.z);

    if (doTex)
      glTexCoord2f(1.0f,1.0f);
    glVertex3f(v.x + s, v.y + s, v.z);

    if (doTex)
      glTexCoord2f(0.0f,1.0f);
    glVertex3f(v.x - s, v.y + s, v.z);

  }
  glEnd();

  glPopMatrix();

  material.endUse(renderContext);
}

void SpriteSet::draw(RenderContext* renderContext)
{ 
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   PrimitveSet
//

PrimitiveSet::PrimitiveSet(Material &in_material, GLenum in_type, int in_nelements, double* vertex)
: Shape(in_material)
{
  type = in_type;

  nelements = in_nelements;

  material.colorPerVertex(true, nelements);

  vertexArray.alloc(nelements);
  for(int i=0;i<nelements;i++) {
    vertexArray[i].x = (float) vertex[i*3+0];
    vertexArray[i].y = (float) vertex[i*3+1];
    vertexArray[i].z = (float) vertex[i*3+2];
    boundingBox += vertexArray[i];
  }
}

void PrimitiveSet::draw(RenderContext* renderContext) {
  material.beginUse(renderContext);
  vertexArray.beginUse();

  glDrawArrays( type, 0, nelements );

  vertexArray.endUse();
  material.endUse(renderContext);
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   PointSet
//

PointSet::PointSet(Material& in_material, int in_nelements, double* in_vertex) 
  : PrimitiveSet(in_material, GL_POINTS, in_nelements, in_vertex) 
{
  material.lit = false;
}; 

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   LineSet
//

LineSet::LineSet(Material& in_material, int in_nelements, double* in_vertex) 
  : PrimitiveSet(in_material, GL_LINES, in_nelements, in_vertex) 
{
  material.lit = false;
}; 

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   FaceSet
//

FaceSet::FaceSet(Material& in_material, GLenum in_type, int in_nelements, double* in_vertex)  
: PrimitiveSet(in_material, in_type, in_nelements, in_vertex)
{
}

void FaceSet::draw(RenderContext* renderContext) {
  if (material.lit)
    normalArray.beginUse();

  PrimitiveSet::draw(renderContext);

  if (material.lit)
    normalArray.endUse();
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   TriangleSet
//

TriangleSet::TriangleSet(Material& in_material, int in_nelements, double* in_vertex) 
  : FaceSet(in_material, GL_TRIANGLES,     in_nelements, in_vertex) 
{
  if (material.lit) {
    normalArray.alloc(nelements);
    for (int i=0;i<nelements-2;i+=3) {
      normalArray[i+2] = normalArray[i+1] = normalArray[i] = vertexArray.getNormal(i,i+1,i+2);
    }
  }
}; 

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   QuadSet
//

QuadSet::QuadSet(Material& in_material, int in_nelements, double* in_vertex) 
  : FaceSet(in_material, GL_QUADS,     in_nelements, in_vertex) 
{
  if (material.lit) {
    normalArray.alloc(nelements);
    for (int i=0;i<nelements-3;i+=4) {
      normalArray[i+3] = normalArray[i+2] = normalArray[i+1] = normalArray[i] = vertexArray.getNormal(i,i+1,i+2);
    }
  }
}; 

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   TextSet
//
// INTERNAL TEXTS STORAGE
//   texts are copied to a buffer without null byte
//   a separate length buffer holds string lengths in order
//

TextSet::TextSet(Material& in_material, int in_ntexts, char** in_texts, double *in_center, int in_justify)
 : Shape(in_material), textArray(in_ntexts, in_texts)
{
  int i;

  material.lit = false;
  material.colorPerVertex(false);

  justify = in_justify;

  // init vertex array

  vertexArray.alloc(in_ntexts);

  for (i=0;i<in_ntexts;i++) {

    vertexArray[i].x = (float) in_center[i*3+0];
    vertexArray[i].y = (float) in_center[i*3+1];
    vertexArray[i].z = (float) in_center[i*3+2];

    boundingBox += vertexArray[i];
  }

}

TextSet::~TextSet()
{
}

void TextSet::draw(RenderContext* renderContext) {

  int cnt;

  material.beginUse(renderContext);

  renderContext->font->enable();

  StringArrayIterator iter(&textArray);

  for( cnt = 0, iter.first(); !iter.isDone(); iter.next(), cnt++ ) {
    material.useColor(cnt);
    glRasterPos3f( vertexArray[cnt].x, vertexArray[cnt].y, vertexArray[cnt].z );
    String text = iter.getCurrent();
    renderContext->font->draw( text.text, text.length, justify );
  }

  material.endUse(renderContext);
}



//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Background
//

Material Background::defaultMaterial( Color(0.3f,0.3f,0.3f), Color(1.0f,0.0f,0.0f) );

Background::Background(Material& in_material, bool in_sphere, int in_fogtype)
: Shape(in_material, BACKGROUND), sphere(in_sphere), fogtype(in_fogtype)
{
  clearColorBuffer = true;

  if (sphere) {
    material.colors.recycle(2);
    material.front = Material::CULL_FACE;

    material.colorPerVertex(false);

    if (material.back == Material::FILL_FACE)
      clearColorBuffer = false;

    if (material.lit)
      sphereMesh.setGenNormal(true);
    if (material.texture)
      sphereMesh.setGenTexCoord(true);

    sphereMesh.setGlobe (16,16);

    sphereMesh.setCenter( Vertex(0.0f,0.0f,0.0f) );
    sphereMesh.setRadius( 1.0f );
    sphereMesh.update();
  }
  else
    material.colors.recycle(1);
}

GLbitfield Background::setupClear(RenderContext* renderContext)
{
  if (clearColorBuffer) {
    material.colors.getColor(0).useClearColor();
    return GL_COLOR_BUFFER_BIT;
  } else
    return 0;
}

void Background::render(RenderContext* renderContext)
{
  const AABox& boundingBox = renderContext->scene->getBoundingBox();

  // setup fog
  
  if ((fogtype != FOG_NONE) && (boundingBox.isValid() )) {
    // Sphere bsphere(boundingBox);

    glFogfv(GL_FOG_COLOR, material.colors.getColor(0).getFloatPtr() );

    switch(fogtype) {
    case FOG_LINEAR:
      glFogi(GL_FOG_MODE, GL_LINEAR);
      glFogf(GL_FOG_START, renderContext->viewpoint->frustum.znear /*bsphere.radius*2*/);
      glFogf(GL_FOG_END,   renderContext->viewpoint->frustum.zfar /*bsphere.radius*3*/ );
      break;
    case FOG_EXP:
      glFogi(GL_FOG_MODE, GL_EXP);
      glFogf(GL_FOG_DENSITY, 1.0f/renderContext->viewpoint->frustum.zfar /*(bsphere.radius*3)*/ );
      break;
    case FOG_EXP2:
      glFogi(GL_FOG_MODE, GL_EXP2);
      glFogf(GL_FOG_DENSITY, 1.0f/renderContext->viewpoint->frustum.zfar /*(bsphere.radius*3)*/ );
      break;
    }

    glEnable(GL_FOG);
  } else {
    glDisable(GL_FOG);
  }

  // render bg sphere 
  
  if (sphere) {

    float fov = renderContext->viewpoint->getFOV();

    float rad = deg2radf(fov/2.0f);

    float hlen  = sinf(rad) * cosf(deg2radf(45.0));
    float znear = hlen / tanf(rad);
    float zfar  = znear + 1.0f;
    float hwidth, hheight;

    float winwidth  = (float) renderContext->size.width;
    float winheight = (float) renderContext->size.height;

    // aspect ratio

    if (winwidth >= winheight) {
      hwidth  = hlen;
      hheight = hlen * (winheight / winwidth);
    } else {
      hwidth  = hlen * (winwidth  / winheight);
      hheight = hlen;
    }

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustum(-hwidth, hwidth, -hheight, hheight, znear, zfar );

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glTranslatef(0.0f,0.0f,-znear);

    renderContext->viewpoint->setupOrientation(renderContext);
    

    Shape::render(renderContext);

  } 
}

void Background::draw(RenderContext* renderContext)
{
  glPushAttrib(GL_ENABLE_BIT);

  material.beginUse(renderContext);
  
  material.useColor(1);
 
  glDisable(GL_DEPTH_TEST);
  glDepthMask(GL_FALSE);

  sphereMesh.draw(renderContext);

  material.endUse(renderContext);

  glPopAttrib();
}


//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Texture
//

Texture::Texture(const char* filename, Type in_type)
{
  texName = 0;
  pixmap = new Pixmap();
  type   = in_type;

  if ( !pixmap->load(filename) ) {
    delete pixmap;
    pixmap = NULL;
  }
}

Texture::~Texture()
{
  if (texName) {
    glDeleteTextures(1, &texName);
  }
  if (pixmap)
    delete pixmap;
}


bool Texture::isValid() const 
{
  return (pixmap) ? true : false;
}

void Texture::beginUse(RenderContext* renderContext)
{
  if (!texName) {
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);


    GLint gltexfmt;
    GLenum glpixfmt;
    GLint ualign;

    switch(type)
    {
    case ALPHA:
      gltexfmt = GL_ALPHA;
      break;
    case LUMINANCE:
      gltexfmt = GL_LUMINANCE;
      break;
    case LUMINANCE_ALPHA:
      gltexfmt = GL_LUMINANCE_ALPHA;
      break;
    case RGB:
      gltexfmt = GL_RGB;
      break;
    case RGBA:
      gltexfmt = GL_RGBA;
      break;
    }

    switch(pixmap->typeID)
    {
    case GRAY8:
      ualign = 1;
      switch(gltexfmt)
      {
      case GL_LUMINANCE:
        glpixfmt = GL_LUMINANCE;
        break;
      case GL_ALPHA:
        glpixfmt = GL_ALPHA;
        break;
      case GL_LUMINANCE_ALPHA:
        glpixfmt = GL_LUMINANCE;
        break;
      }
      break;
    case RGB24:
      ualign = 1;
      glpixfmt = GL_RGB;
      break;
    case RGB32:
      ualign = 2;
      glpixfmt = GL_RGB;
      break;
    case RGBA32:
      ualign = 2;
      glpixfmt = GL_RGBA;
      break;
    default: // INVALID
      return;
    }

    glPixelStorei(GL_UNPACK_ALIGNMENT, ualign);
    glTexImage2D(GL_TEXTURE_2D, 0, gltexfmt, pixmap->width, pixmap->height, 0, glpixfmt, GL_UNSIGNED_BYTE, pixmap->data);
  }

  glPushAttrib(GL_TEXTURE_BIT|GL_ENABLE_BIT|GL_CURRENT_BIT);

  glEnable(GL_TEXTURE_2D);
  glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  glBindTexture(GL_TEXTURE_2D, texName);

  if (type == GL_ALPHA) {
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
  }
}

void Texture::endUse(RenderContext* renderContext)
{
  glPopAttrib();
}

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

void AxisInfo::draw(RenderContext* renderContext, Vertex4& v, Vertex4& dir, float marklen, String& string) {

  Vertex4 p;

  // draw mark ( 1 time ml away )

  p = v + dir * marklen;
  glBegin(GL_LINES);
  glVertex3f(v.x,v.y,v.z);
  glVertex3f(p.x,p.y,p.z);
  glEnd();

  // draw text ( 2 times ml away )

  p = v + dir * marklen * 2;

  glRasterPos3f( p.x, p.y, p.z );
  renderContext->font->draw(string.text, string.length, 0);

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

BBoxDeco::BBoxDeco(Material& in_material, AxisInfo& in_xaxis, AxisInfo& in_yaxis, AxisInfo& in_zaxis, float in_marklen_value, bool in_marklen_fract)
: SceneNode(BBOXDECO), material(in_material), xaxis(in_xaxis), yaxis(in_yaxis), zaxis(in_zaxis), marklen_value(in_marklen_value), marklen_fract(in_marklen_fract)
{
  material.colors.recycle(2);
}

float BBoxDeco::getMarkLength(const AABox& boundingBox) const
{
  return (marklen_fract) ? Sphere(boundingBox).radius / marklen_value : marklen_value;
}

AABox BBoxDeco::getBoundingBox(const AABox& in_bbox) const
{
  AABox bbox(in_bbox);

  float marklen = getMarkLength(bbox);

  Vertex v = Vertex(1,1,1) * 2 * marklen;

  bbox += bbox.vmin - v;
  bbox += bbox.vmax + v;

  return bbox;
}

void BBoxDeco::render(RenderContext* renderContext)
{
  const AABox& bbox = renderContext->scene->getBoundingBox();

  if (bbox.isValid()) {

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

    // transform vertices: used for edge distance criterion

    double mdata[16] = { 0 };

    glGetDoublev(GL_MODELVIEW_MATRIX, mdata);

    Matrix4x4 modelview(mdata);

    for(i=0;i<8;i++)
      eyev[i] = modelview * boxv[i];
 
    // setup material

    material.beginUse(renderContext);
    renderContext->font->enable();

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

    float marklen = getMarkLength(bbox);


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
                  axis->draw(renderContext, v, edge->dir, marklen, string);
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

                axis->draw(renderContext, v, edge->dir, marklen, string);
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

                axis->draw(renderContext, v, edge->dir, marklen, s );

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
