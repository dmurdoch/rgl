#include "R.h"
#ifdef PI
#undef PI
#endif
#include "scene.h"
#include "rglmath.h"
#include "render.h"
#include "geom.h"
#include "pretty.h"

#include <hpdf.h>
#include <hpdf_conf.h>
#include <hpdf_u3d.h>
#include <hpdf_annotation.h>

#include <unistd.h>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <cstdio>
#include <string>

#include "PRCbitStream.cc"
#include "PRCdouble.cc"
#include "writePRC.cc"
#include "oPRCFile.cc"
#include "prc.h"

prcout::prcout(const char *filename, const RenderContext* rendercontext) : file(NULL),rc(rendercontext),scale(1,1,1),transform(new double[16])
{
  file = new oPRCFile(filename);
}
prcout::~prcout()
{
  delete file;
  delete transform;
}

//-----------------------------------------------------------------------------
#define EQFLD(fld) fld==o.fld
#define COMPFLD(fld) \
if(fld != o.fld) \
return (fld < o.fld);

struct prctriangle {
	uint32_t si;
	uint32_t pi[3];
	uint32_t ni[3];
	uint32_t ti[3];
	uint32_t ci[3];
};
struct prcquad {
	uint32_t si;
	uint32_t pi[4];
	uint32_t ni[4];
	uint32_t ti[4];
	uint32_t ci[4];
};
struct prclinesegment {
	uint32_t pi[2];
	uint32_t ci;
};
struct prclinetriangle {
	uint32_t pi[3];
	uint32_t ci[3];
};
struct prclinequad {
	uint32_t pi[4];
	uint32_t ci[4];
};
struct prcdot {
	PRCVector3d p;
	RGBAColour c;
  bool operator==(const prcdot &o) const
  {
    return (EQFLD(p) && EQFLD(c));
  }
  bool operator!=(const prcdot &o) const
  {
    return !(EQFLD(p) && EQFLD(c));
  }
  bool operator<(const prcdot &o) const
  {
    COMPFLD(p)
    COMPFLD(c)
    return false;
  }

};
#undef EQFLD
#undef COMPFLD
//-----------------------------------------------------------------------------
struct prcgroup {
	std::map<PRCVector3d,uint32_t> points;
	std::map<PRCVector3d,uint32_t> normals;
	std::map<PRCVector2d,uint32_t> texturecoords;
	std::map<RGBAColour,uint32_t> colours;
	std::vector<prctriangle> triangles;
	std::vector<prcquad> quads;
	std::vector<prclinesegment> linesegments;
	std::vector<prclinetriangle> linetriangles;
	std::vector<prclinequad> linequads;
	std::set<prcdot> dots;

	uint32_t addVertex(float x, float y, float z)
	{
		const PRCVector3d point(x,y,z);

		std::map<PRCVector3d,uint32_t>::iterator pPoint = points.find(point);
		if(pPoint!=points.end())
			return pPoint->second;
		else
		{
			const uint32_t point_index = (uint32_t)points.size();
			points.insert(std::make_pair(point,point_index));
			return point_index;
		}
	}

	uint32_t addVertex(const Vertex& v)
	{
          return addVertex(v.x, v.y, v.z);
        }

	uint32_t addNormal(float x, float y, float z)
	{
		const PRCVector3d normal(x,y,z);

		std::map<PRCVector3d,uint32_t>::iterator pNormal = normals.find(normal);
		if(pNormal!=normals.end())
			return pNormal->second;
		else
		{
			const uint32_t normal_index = (uint32_t)normals.size();
			normals.insert(std::make_pair(normal,normal_index));
			return normal_index;
		}
	}

	uint32_t addNormal(const Vertex& n)
	{
          return addNormal(n.x, n.y, n.z);
        }

	uint32_t addTextureCoords(float u, float v)
	{
		const PRCVector2d tc(u,v);

		std::map<PRCVector2d,uint32_t>::iterator pTc = texturecoords.find(tc);
		if(pTc!=texturecoords.end())
			return pTc->second;
		else
		{
			const uint32_t tc_index = (uint32_t)texturecoords.size();
			texturecoords.insert(std::make_pair(tc,tc_index));
			return tc_index;
		}
	}

	uint32_t addTexCoord(const TexCoord& tc)
	{
          return addTextureCoords(tc.s, tc.t);
	}

	uint32_t addColour(const RGBAColour& colour)
	{
		std::map<RGBAColour,uint32_t>::iterator pColour = colours.find(colour);
		if(pColour!=colours.end())
			return pColour->second;
		else
		{
			const uint32_t colour_index = (uint32_t)colours.size();
			colours.insert(std::make_pair(colour,colour_index));
			return colour_index;
		}
	}

	uint32_t addColour(float r, float g, float b, float a)
	{
		const RGBAColour colour(r,g,b,a);
                return addColour(colour);
	}

	uint32_t addColor(const Color& c)
	{
		const RGBAColour colour(c.getRedf(), c.getGreenf(), c.getBluef(), c.getAlphaf());
                return addColour(colour);
	}

	void writePoints(double (*P)[3])
	{
		for(std::map<PRCVector3d,uint32_t>::const_iterator pPoint = points.begin(); pPoint != points.end(); pPoint++)
		{
			P[pPoint->second][0] = pPoint->first.x;
			P[pPoint->second][1] = pPoint->first.y;
			P[pPoint->second][2] = pPoint->first.z;
		}
	}

	void writeNormals(double (*P)[3])
	{
		for(std::map<PRCVector3d,uint32_t>::const_iterator pNormal = normals.begin(); pNormal != normals.end(); pNormal++)
		{
			P[pNormal->second][0] = pNormal->first.x;
			P[pNormal->second][1] = pNormal->first.y;
			P[pNormal->second][2] = pNormal->first.z;
		}
	}

	void writeTextureCoords(double (*T)[2])
	{
		for(std::map<PRCVector2d,uint32_t>::const_iterator pPoint = texturecoords.begin(); pPoint != texturecoords.end(); pPoint++)
		{
			T[pPoint->second][0] = pPoint->first.x;
			T[pPoint->second][1] = pPoint->first.y;
		}
	}

	void writeColours(RGBAColour *C)
	{
		for(std::map<RGBAColour,uint32_t>::const_iterator pColour = colours.begin(); pColour != colours.end(); pColour++)
		{
			C[pColour->second] = pColour->first;
		}
	}

	void addDot(const PRCVector3d& p, const RGBAColour& c) 
        {
               prcdot dot;
               dot.p = p;
               dot.c = c;
               dots.insert(dot);
        }

	void addDot(const Vertex& v, const Color& c) 
        {
               addDot(PRCVector3d(v.x, v.y, v.z), RGBAColour(c.getRedf(), c.getGreenf(), c.getBluef(), c.getAlphaf()));
        }

	void addTriangle(uint32_t si,
			uint32_t pi1, uint32_t ni1, uint32_t ti1, uint32_t ci1,
			uint32_t pi2, uint32_t ni2, uint32_t ti2, uint32_t ci2,
			uint32_t pi3, uint32_t ni3, uint32_t ti3, uint32_t ci3
                        )
	{
		prctriangle triangle;
		triangle.si = si;
		triangle.pi[0] = pi1;
		triangle.pi[1] = pi2;
		triangle.pi[2] = pi3;
		triangle.ni[0] = ni1;
		triangle.ni[1] = ni2;
		triangle.ni[2] = ni3;
		triangle.ti[0] = ti1;
		triangle.ti[1] = ti2;
		triangle.ti[2] = ti3;
		triangle.ci[0] = ci1;
		triangle.ci[1] = ci2;
		triangle.ci[2] = ci3;
		triangles.push_back(triangle);
	}

	void addQuad(uint32_t si,
			uint32_t pi1, uint32_t ni1, uint32_t ti1, uint32_t ci1,
			uint32_t pi2, uint32_t ni2, uint32_t ti2, uint32_t ci2,
			uint32_t pi3, uint32_t ni3, uint32_t ti3, uint32_t ci3,
			uint32_t pi4, uint32_t ni4, uint32_t ti4, uint32_t ci4
                        )
	{
		prcquad quad;
		quad.si = si;
		quad.pi[0] = pi1;
		quad.pi[1] = pi2;
		quad.pi[2] = pi3;
		quad.pi[3] = pi4;
		quad.ni[0] = ni1;
		quad.ni[1] = ni2;
		quad.ni[2] = ni3;
		quad.ni[3] = ni4;
		quad.ti[0] = ti1;
		quad.ti[1] = ti2;
		quad.ti[2] = ti3;
		quad.ti[3] = ti4;
		quad.ci[0] = ci1;
		quad.ci[1] = ci2;
		quad.ci[2] = ci3;
		quad.ci[3] = ci4;
		quads.push_back(quad);
	}

	void addLineSegment(
			uint32_t pi1, uint32_t pi2, uint32_t ci
                        )
	{
		prclinesegment linesegment;
		linesegment.pi[0] = pi1;
		linesegment.pi[1] = pi2;
		linesegment.ci = ci;
		linesegments.push_back(linesegment);
	}

	void addLineTriangle(
			uint32_t pi1, uint32_t ci1,
			uint32_t pi2, uint32_t ci2,
			uint32_t pi3, uint32_t ci3
                        )
	{
		prclinetriangle linetriangle;
		linetriangle.pi[0] = pi1;
		linetriangle.pi[1] = pi2;
		linetriangle.pi[2] = pi3;
		linetriangle.ci[0] = ci1;
		linetriangle.ci[1] = ci2;
		linetriangle.ci[2] = ci3;
		linetriangles.push_back(linetriangle);
	}

	void addLineQuad(
			uint32_t pi1, uint32_t ci1,
			uint32_t pi2, uint32_t ci2,
			uint32_t pi3, uint32_t ci3,
			uint32_t pi4, uint32_t ci4
                        )
	{
		prclinequad linequad;
		linequad.pi[0] = pi1;
		linequad.pi[1] = pi2;
		linequad.pi[2] = pi3;
		linequad.pi[3] = pi4;
		linequad.ci[0] = ci1;
		linequad.ci[1] = ci2;
		linequad.ci[2] = ci3;
		linequad.ci[3] = ci4;
		linequads.push_back(linequad);
	}

};

static const char script[] = 
"\
function fulltransform(mesh) \n\
{ \n\
  var t=new Matrix4x4(mesh.transform); \n\
  if(mesh.parent.name != \"\") { \n\
    var parentTransform=fulltransform(mesh.parent); \n\
    t.multiplyInPlace(parentTransform); \n\
    return t; \n\
  } else \n\
    return t; \n\
} \n\
 \n\
// arrays of specially-named sections of the model tree  \n\
var bbnodes = new Array(); // stores the billboard meshes \n\
var bbtrans = new Array(); // stores the billboard transforms \n\
  \n\
var zero=new Vector3(0,0,0); \n\
 \n\
var nodes=scene.nodes; \n\
var nodescount=nodes.count; \n\
var rootnode = null; \n\
for(var i=0; i < nodescount; i++) { \n\
  var node=nodes.getByIndex(i);  \n\
  if ( node.name.indexOf(\"root\") == 0 || (node.name != \"\" && node.parent.name == \"\") ) {  \n\
    rootnode = node; \n\
  }  \n\
} \n\
 \n\
function searchbb(node) \n\
{ \n\
  if ( node.name.indexOf(\"sprite_rot\") == 0 ) {  \n\
    bbnodes.push(node); \n\
    var nodeMatrix = fulltransform(node.parent); \n\
    var c=nodeMatrix.translation; // position \n\
    var d=Math.pow(Math.abs(nodeMatrix.determinant),1.0/3.0); // scale \n\
    bbtrans.push(Matrix4x4().scale(d,d,d).translate(c).multiply(nodeMatrix.inverse)); \n\
  } \n\
  for (var child = node.firstChild; child != null; child = child.nextSibling ) { \n\
    searchbb(child); \n\
  } \n\
} \n\
 \n\
if (rootnode != null) \n\
  searchbb(rootnode); \n\
 \n\
var camera=scene.cameras.getByIndex(0); \n\
 \n\
var bbcount=bbnodes.length; \n\
 \n\
billboardHandler=new RenderEventHandler(); \n\
billboardHandler.onEvent=function(event) \n\
{ \n\
  var T=new Matrix4x4(); \n\
  T.setView(zero,camera.position.subtract(camera.targetPosition), camera.up.subtract(camera.position)); \n\
 \n\
  for (var j = 0; j < bbcount; j++) { \n\
    var nodeMatrix = fulltransform(bbnodes[j].parent); \n\
    var c = nodeMatrix.translation; // position \n\
    var d = Math.pow(Math.abs(nodeMatrix.determinant),1.0/3.0); // scale \n\
    var bbt = Matrix4x4().scale(d,d,d).translate(c).multiply(nodeMatrix.inverse); \n\
 // bbnodes[j].transform.set(T.multiply(bbtrans[j])); \n\
    bbnodes[j].transform.set(T.multiply(bbt)); \n\
  } \n\
 \n\
  runtime.refresh();  \n\
} \n\
  \n\
runtime.addEventHandler(billboardHandler);  \n\
 \n\
";

vector<string> Scene::writePRC(const char* const basename, const RenderContext* const renderContext,
 const bool writepdf, const bool writeprc, const bool writevws, const bool writejs)
{
  vector<string> ret;

  if (writejs) {
    string jsname = string(basename).append(".js");
    std::FILE *fp = fopen(jsname.c_str(), "w");
    if (fp != NULL)
    {
      fputs(script, fp);
      fclose(fp);
      fp = NULL;
      ret.push_back(jsname);
    }
    else
    {
      error("rgl2pdf3d: failed to open JS file for writing.\n");
      return ret;
    }
    if (!writepdf && !writeprc && !writevws) { // nothing more to do
     return ret;
    }
  }

  // camera placement
  Sphere total_bsphere;
  
  if (data_bbox.isValid()) {
    
    // 
    // GET DATA VOLUME SPHERE
    //
  
    total_bsphere = Sphere( (bboxDeco) ? bboxDeco->getBoundingBox(data_bbox) : data_bbox, viewpoint->scale );
    if (total_bsphere.radius <= 0.0)
      total_bsphere.radius = 1.0;
  
  } else {
    total_bsphere = Sphere( Vertex(0,0,0), 1 );
  }
  Matrix4x4 centering; centering.setTranslate(total_bsphere.center.scale(viewpoint->scale)*-1.0f);
  Matrix4x4 viewingdistance; viewingdistance.setTranslate(Vertex(0,0,-viewpoint->frustum.distance));
  double userMatrix[16];
  viewpoint->getUserMatrix(userMatrix);
  Matrix4x4 orientation(userMatrix);
  Matrix4x4 m = viewingdistance*orientation*centering;
  double tmp[16];
  m.inverse().getData(tmp);

  const Color bgc = background->getMaterial()->colors.getColor(0);
  const double fov = atan(tan(viewpoint->getFOV()*M_PI/360)*viewpoint->getZoom())*360/M_PI;

  if (writevws) {
    string vwsname = string(basename).append(".vws");
    std::FILE *fp = fopen(vwsname.c_str(), "w");
    if (fp != NULL)
    {
      fprintf(fp,
        "VIEW=DefaultView\n"
        "LIGHTS=CAD\n"
        "BGCOLOR=%.9f %.9f %.9f,\n" 
        "C2W=%.9f %.9f %.9f %.9f %.9f %.9f %.9f %.9f %.9f %.9f %.9f %.9f ,\n"
        "ROO=%.9f,\n"
        "AAC=%.9f,\n"
        "END\n",
        bgc.getRedf(), bgc.getGreenf(), bgc.getBluef(),
        -tmp[ 0], -tmp[ 1], -tmp[ 2], tmp[ 4], tmp[ 5], tmp[ 6], -tmp[ 8], -tmp[ 9], -tmp[10], tmp[12], tmp[13], tmp[14],
        viewpoint->frustum.distance,
        fov
      );
      fclose(fp);
      fp = NULL;
      ret.push_back(vwsname);
    }
    else
    {
      error("rgl2pdf3d: failed to open VWS file for writing.\n");
      return ret;
    }
    if (!writepdf && !writeprc) { // nothing more to do
     return ret;
    }
  }

  if (writeprc || writepdf) {

    string prcname;
    if (writeprc)
      prcname = string(basename).append(".prc");
    else
    {
      char basename[32];
      strncpy(basename,"rgl2pdf3d_tmp_XXXXXXXXXXXX",32);
      mktemp(basename);
      prcname = string(basename).append(".prc");
      // prcname = string(tmpnam(NULL)).append(".prc");
    }
   
    if(!fstream(prcname.c_str(),std::ios::out|std::ios::binary|std::ios::trunc)) {
        error("rgl2pdf3d: unable to open PRC file for writing.\n");
        return ret;
    }

    prcout prc(prcname.c_str(), renderContext);
   
    {
      PRCFontKeysSameFont font;
      font.font_name = "Courier Std Medium";
      font.char_set = 0x40000000;
      PRCFontKey fontKey;
      fontKey.font_size = 10;
      fontKey.attributes = 1;
      font.font_keys.push_back(fontKey);
      prc.file->fileStructures[0]->font_keys_of_font.push_back(font);
    }
   
    prc.scale = viewpoint->scale;
    for(size_t i=0;i<16;i++)
      prc.transform[i] = 0.0f;
    prc.transform[ 0] = viewpoint->scale.x;
    prc.transform[ 5] = viewpoint->scale.y;
    prc.transform[10] = viewpoint->scale.z;
    prc.transform[15] = 1.0f;
   
    orientation.inverse().getData(prc.invorientation);
   
    if (bboxDeco)
      bboxDeco->writePRC(prc, renderContext);
   
    for (std::vector<Shape*>::const_iterator iter = shapes.begin() ; iter != shapes.end() ; ++iter ) {
      Shape * shape = *iter;
      shape->writePRC(prc);
    }
   
    prc.file->finish();
     
    if (writeprc)
      ret.push_back(prcname);

    if (writepdf) {
      string pdfname = string(basename).append(".pdf");
   
      HPDF_REAL right = renderContext->viewport[2] - renderContext->viewport[0];
      HPDF_REAL top   = renderContext->viewport[3] - renderContext->viewport[1];
      HPDF_Rect rect = {0, 0, right, top};
     
      HPDF_Doc  pdf;
      HPDF_Page page;
      HPDF_Annotation annot;
      HPDF_U3D u3d;
     
      pdf = HPDF_New (NULL, NULL);
     
      pdf->pdf_version = HPDF_VER_17;
     
      page = HPDF_AddPage (pdf);
     
      HPDF_Page_SetWidth  (page, right);
      HPDF_Page_SetHeight (page, top);
     
      u3d = HPDF_LoadU3DFromFile (pdf, prcname.c_str());
     
      HPDF_Dict view;
      //      Default view                                  
      view = HPDF_Create3DView (u3d->mmgr, "DefaultView");  
     
      //      Position camera
      HPDF_3DMatrix mat;
      mat.a  =-tmp[ 0];
      mat.b  =-tmp[ 1];
      mat.c  =-tmp[ 2];
      mat.d  = tmp[ 4];
      mat.e  = tmp[ 5];
      mat.f  = tmp[ 6];
      mat.g  =-tmp[ 8];
      mat.h  =-tmp[ 9];
      mat.i  =-tmp[10];
      mat.tx = tmp[12];
      mat.ty = tmp[13];
      mat.tz = tmp[14];
      HPDF_3DView_SetCameraByMatrix (view, mat, viewpoint->frustum.distance);
     
      //      Set projection
      HPDF_3DView_SetPerspectiveProjection (view, fov);
     
      //      Background color
      HPDF_3DView_SetBackgroundColor (view, bgc.getRedf(), bgc.getGreenf(), bgc.getBluef());
     
      //      Lighting
      HPDF_3DView_SetLighting (view, "CAD");
     
      //      Add views
      HPDF_U3D_Add3DView (u3d, view);
      HPDF_U3D_SetDefault3DView(u3d, "DefaultView");
     
      // Set js
      HPDF_JavaScript js = HPDF_CreateJavaScript (pdf, script);
      HPDF_U3D_AddOnInstanciate(u3d, js);
     
      //  Create annotation
      annot = HPDF_Page_Create3DAnnot (page, rect, HPDF_TRUE, HPDF_FALSE, u3d, NULL);
     
      //  Enable toolbar
      HPDF_Dict action = (HPDF_Dict)HPDF_Dict_GetItem (annot, "3DA", HPDF_OCLASS_DICT);
      HPDF_Dict_AddBoolean (action, "TB", HPDF_TRUE);
     
      /* save the document to a file */
      if(HPDF_SaveToFile (pdf, pdfname.c_str())!=HPDF_OK) {
        HPDF_Free (pdf);
        error("rgl2pdf3d: failed to write PDF file.\n");
        return ret;
      }
     
      /* clean up */
      HPDF_Free (pdf);
   
      if (!writeprc)
        remove(prcname.c_str());

      ret.push_back(pdfname);
      return ret;
    }
    else
     return ret;
  }

  error("rgl2pdf3d: nothing to do.\n");
  return ret;
}

void TextSet::writePRC(prcout& prc)
{
// prc.file->begingroup("text");
  Matrix4x4 mt;
  if (prc.transform)
    mt = Matrix4x4(prc.transform);
  else
    mt.setIdentity();
  for (int index=0; index < textArray.size(); index++) {
    const double cex = fonts[index % fonts.size()];
    if (cex == 0.0)
      continue;
    const String text = textArray[index];
    Vertex const& o = vertexArray[index];
    if (o.missing())
      continue;

    Vertex  v;
    v = mt * o;
 
    Color color = material.colors.getColor(index % material.colors.getLength());
    const uint32_t col = prc.file->addRgbColor(PRCRgbColor( color.getRedf(), color.getGreenf(), color.getBluef()));

    PRCMarkupTess *tess = new PRCMarkupTess();
    tess->coordinates.push_back(v.x);
    tess->coordinates.push_back(v.y);
    tess->coordinates.push_back(v.z);
    
    tess->coordinates.push_back(1);
    tess->coordinates.push_back(0);
    tess->coordinates.push_back(0);
    tess->coordinates.push_back(0); // -
    tess->coordinates.push_back(0);
    tess->coordinates.push_back(1);
    tess->coordinates.push_back(0);
    tess->coordinates.push_back(0); // -
    tess->coordinates.push_back(0);
    tess->coordinates.push_back(0);
    tess->coordinates.push_back(0);
    tess->coordinates.push_back(0); // -
    tess->coordinates.push_back(-adjx*cex*0.5*60*text.length);
    tess->coordinates.push_back(-adjy*cex*0.5*60);
    tess->coordinates.push_back(0);
    tess->coordinates.push_back(1); // -

    tess->coordinates.push_back(cex*0.5*60*text.length); // width
    tess->coordinates.push_back(cex*0.5*60); // height
    
    tess->codes.push_back(PRC_MARKUP_ExtraDataType_FrameDrawMode|15); //  frame draw mode start
    tess->codes.push_back(21); // 21 doubles total, 3 doubles - frame origin is (1,0,0)
    tess->codes.push_back(PRC_MARKUP_ExtraDataType_Color|1); // set color
    tess->codes.push_back(0x0); // no doubles
    tess->codes.push_back(col); // third color
    tess->codes.push_back(PRC_MARKUP_ExtraDataType_Font|1); // font - does work
    tess->codes.push_back(0x0); // no doubles
    tess->codes.push_back(0x1); // first font
    tess->codes.push_back(PRC_MARKUP_IsMatrix|5); // matrix mode start
    tess->codes.push_back(0x12); // 18 doubles total, 16 doubles - matrix
    //          1       0       0   -adjx*width
    //          0       1       0   -adjy*hight
    //          0       0       0   0
    //          0       0       0   1
    tess->codes.push_back(PRC_MARKUP_ExtraDataType_Text|1); // text - does work
    tess->codes.push_back(0x2); // width heigth
    tess->codes.push_back(0x0); // first of texts
    tess->codes.push_back(PRC_MARKUP_IsMatrix); // matrix mode end
    tess->codes.push_back(0x0);
    tess->codes.push_back(PRC_MARKUP_ExtraDataType_FrameDrawMode); // frame draw mode end
    tess->codes.push_back(0x0);
    
    tess->texts.push_back(text.text);
    tess->label = text.text;
    PRCMarkup *markup = new PRCMarkup(text.text);
    markup->index_tessellation = prc.file->addMarkupTess(tess);
    markup->type = KEPRCMarkupType_Other;
    //    markup->type = KEPRCMarkupType_Text;
    const uint32_t markup_unique_identifier = markup->getPRCID();
    prc.file->findGroup().part_definition->addMarkup(markup);
    PRCAnnotationItem *item = new PRCAnnotationItem(text.text);
    item->markup.type = PRC_TYPE_MKP_Markup;
    item->markup.unique_identifier = markup_unique_identifier;
    prc.file->findGroup().part_definition->addAnnotationItem(item);
  }
//  prc.file->endgroup();
}

static void AxisInfowritePRC(const RenderContext* renderContext, const Vertex4& v, const Vertex4& dir, const Matrix4x4& modelview, 
                    const Vertex& marklen, const String& string, prcgroup& group, uint32_t col, prcout& prc) {

  Vertex4 p;
    
  // draw mark ( 1 time ml away )

  p.x = v.x + dir.x * marklen.x;
  p.y = v.y + dir.y * marklen.y;
  p.z = v.z + dir.z * marklen.z;  
  
  const uint32_t pv = group.addVertex(v.x,v.y,v.z);
  const uint32_t pp = group.addVertex(p.x,p.y,p.z);
  group.addLineSegment(pv, pp, m1);

  // draw text ( 2 times ml away )

  p.x = v.x + 2 * dir.x * marklen.x;
  p.y = v.y + 2 * dir.y * marklen.y;
  p.z = v.z + 2 * dir.z * marklen.z; 

  // Work out the text adjustment 
  
  float adj = 0.5;  
  Vertex4 eyedir = modelview * dir;
  bool  xlarge = fabs(eyedir.x) > fabs(eyedir.y);
  
  if (xlarge) {
    adj = fabs(eyedir.y)/fabs(eyedir.x)/2.0;
    if (eyedir.x < 0) adj = 1.0 - adj;
  }
  
  const double cex = renderContext->font;

  PRCMarkupTess *tess = new PRCMarkupTess();
  tess->coordinates.push_back(p.x);
  tess->coordinates.push_back(p.y);
  tess->coordinates.push_back(p.z);
  
  tess->coordinates.push_back(1);
  tess->coordinates.push_back(0);
  tess->coordinates.push_back(0);
  tess->coordinates.push_back(0); // -
  tess->coordinates.push_back(0);
  tess->coordinates.push_back(1);
  tess->coordinates.push_back(0);
  tess->coordinates.push_back(0); // -
  tess->coordinates.push_back(0);
  tess->coordinates.push_back(0);
  tess->coordinates.push_back(0);
  tess->coordinates.push_back(0); // -
  tess->coordinates.push_back(-adj*cex*0.5*60*string.length);
  tess->coordinates.push_back(-0.5*cex*0.5*60);
  tess->coordinates.push_back(0);
  tess->coordinates.push_back(1); // -

  tess->coordinates.push_back(cex*0.5*60*string.length); // width
  tess->coordinates.push_back(cex*0.5*60); // height
  
  tess->codes.push_back(PRC_MARKUP_ExtraDataType_FrameDrawMode|15); //  frame draw mode start
  tess->codes.push_back(21); // 21 doubles total, 3 doubles - frame origin is (1,0,0)
  tess->codes.push_back(PRC_MARKUP_ExtraDataType_Color|1); // set color
  tess->codes.push_back(0x0); // no doubles
  tess->codes.push_back(col); // color
  tess->codes.push_back(PRC_MARKUP_ExtraDataType_Font|1); // font - does work
  tess->codes.push_back(0x0); // no doubles
  tess->codes.push_back(0x1); // first font
  tess->codes.push_back(PRC_MARKUP_IsMatrix|5); // matrix mode start
  tess->codes.push_back(0x12); // 18 doubles total, 16 doubles - matrix
  //          1       0       0   -adj*width
  //          0       1       0   -0.5*hight
  //          0       0       0   0
  //          0       0       0   1
  tess->codes.push_back(PRC_MARKUP_ExtraDataType_Text|1); // text - does work
  tess->codes.push_back(0x2); // width heigth
  tess->codes.push_back(0x0); // first of texts
  tess->codes.push_back(PRC_MARKUP_IsMatrix); // matrix mode end
  tess->codes.push_back(0x0);
  tess->codes.push_back(PRC_MARKUP_ExtraDataType_FrameDrawMode); // frame draw mode end
  tess->codes.push_back(0x0);
  
  tess->texts.push_back(string.text);
  tess->label = string.text;
  PRCMarkup *markup = new PRCMarkup(string.text);
  markup->index_tessellation = prc.file->addMarkupTess(tess);
  markup->type = KEPRCMarkupType_Other;
  //    markup->type = KEPRCMarkupType_Text;
  const uint32_t markup_unique_identifier = markup->getPRCID();
  prc.file->findGroup().part_definition->addMarkup(markup);
  PRCAnnotationItem *item = new PRCAnnotationItem(string.text);
  item->markup.type = PRC_TYPE_MKP_Markup;
  item->markup.unique_identifier = markup_unique_identifier;
  prc.file->findGroup().part_definition->addAnnotationItem(item);
       
}

void BBoxDeco::writePRC(prcout& prc, const RenderContext* const renderContext)
{
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

const static Edge xaxisedge[4] = {
  Edge( 5,4, Vertex4( 0.0f, 0.0f, 1.0f, 0.0f) ),
  Edge( 0,1, Vertex4( 0.0f, 0.0f,-1.0f, 0.0f) ),
  Edge( 6,7, Vertex4( 0.0f, 0.0f, 1.0f, 0.0f) ),
  Edge( 3,2, Vertex4( 0.0f, 0.0f,-1.0f, 0.0f) )
};
const static Edge yaxisedge[8] = {
  Edge( 5,7, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f) ),
  Edge( 7,5, Vertex4( 0.0f, 0.0f, 1.0f, 0.0f) ),
  Edge( 6,4, Vertex4(-1.0f, 0.0f, 0.0f, 0.0f) ),
  Edge( 4,6, Vertex4( 0.0f, 0.0f, 1.0f, 0.0f) ),
  Edge( 2,0, Vertex4( 0.0f, 0.0f,-1.0f, 0.0f) ),
  Edge( 0,2, Vertex4(-1.0f, 0.0f, 0.0f, 0.0f) ),
  Edge( 3,1, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f) ),
  Edge( 1,3, Vertex4( 0.0f, 0.0f,-1.0f, 0.0f) )
};
const static Edge zaxisedge[4] = {
  Edge( 1,5, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f) ),
  Edge( 4,0, Vertex4(-1.0f, 0.0f, 0.0f, 0.0f) ),
  Edge( 7,3, Vertex4( 1.0f, 0.0f, 0.0f, 0.0f) ),
  Edge( 2,6, Vertex4(-1.0f, 0.0f, 0.0f, 0.0f) )
};

  AABox bbox = renderContext->scene->getBoundingBox();

  if (!bbox.isValid())
    return;

  PRCoptions grpopt;
  grpopt.tess = true;
  grpopt.closed = true;
  prc.file->begingroup("bboxdeco",&grpopt,prc.transform);

  Vertex center = bbox.getCenter();
  bbox += center + (bbox.vmin - center)*expand;
  bbox += center + (bbox.vmax - center)*expand;

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

  const Color color = material.colors.getColor(0);
  const RGBAColour colour( color.getRedf(), color.getGreenf(), color.getBluef(), color.getAlphaf());
  const RGBAColour  ambient(  material.ambient.getRedf(),  material.ambient.getGreenf(),  material.ambient.getBluef(),  material.ambient.getAlphaf());
  const RGBAColour emission( material.emission.getRedf(), material.emission.getGreenf(), material.emission.getBluef(), material.emission.getAlphaf());
  const RGBAColour specular( material.specular.getRedf(), material.specular.getGreenf(), material.specular.getBluef(), material.specular.getAlphaf());
  const PRCmaterial mater(
    ambient,
    colour,
    emission,
    specular,
    colour.A,material.shininess,material.lwd
  );
  uint32_t mat = prc.file->addMaterial(mater);

  // edge adjacent matrix

  int adjacent[8][8] = { { 0 } };

  // draw back faces
  // construct adjacent matrix

  prcgroup boxgroup;

  for(i=0;i<6;i++) {
    const Vertex4 q = modelview * side[i].normal;
    const Vertex4 view(0.0f,0.0f,1.0f,0.0f);

    float cos_a = view * q;

    const bool front = (cos_a >= 0.0f) ? true : false;

    if (draw_front || !front) {

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

  if (material.front == material.FILL_FACE || material.back == material.FILL_FACE) {
    PRC3DTess *tess = new PRC3DTess();
    PRCTessFace *tessFace = new PRCTessFace();
    tessFace->used_entities_flag = PRC_FACETESSDATA_Triangle;

    uint32_t trianglecount = 0;
    for(i=0;i<6;i++) {

      const Vertex4 q = modelview * side[i].normal;
      const Vertex4 view(0.0f,0.0f,1.0f,0.0f);

      float cos_a = view * q;

      const bool front = (cos_a >= 0.0f) ? true : false;

      if (draw_front || !front) {
          uint32_t pi[4];
          for(j=0;j<4;j++) {
            // feed vertex
            Vertex4& v = boxv[ side[i].vidx[j] ];
            pi[j] = boxgroup.addVertex(v.x, v.y, v.z);
          }
          uint32_t ni = boxgroup.addNormal(-side[i].normal.x, -side[i].normal.y, -side[i].normal.z);
          tess->triangulated_index.push_back(3*ni);
          tess->triangulated_index.push_back(3*pi[0]);
          tess->triangulated_index.push_back(3*ni);
          tess->triangulated_index.push_back(3*pi[2]);
          tess->triangulated_index.push_back(3*ni);
          tess->triangulated_index.push_back(3*pi[1]);
          tess->triangulated_index.push_back(3*ni);
          tess->triangulated_index.push_back(3*pi[2]);
          tess->triangulated_index.push_back(3*ni);
          tess->triangulated_index.push_back(3*pi[0]);
          tess->triangulated_index.push_back(3*ni);
          tess->triangulated_index.push_back(3*pi[3]);
          trianglecount += 2;
      }
    }
    tess->coordinates.resize(3*boxgroup.points.size());
    for(std::map<PRCVector3d,uint32_t>::const_iterator pPoint = boxgroup.points.begin(); pPoint != boxgroup.points.end(); pPoint++)
    {
      tess->coordinates[3*pPoint->second+0] = pPoint->first.x;
      tess->coordinates[3*pPoint->second+1] = pPoint->first.y;
      tess->coordinates[3*pPoint->second+2] = pPoint->first.z;
    }
    tess->normal_coordinate.resize(3*boxgroup.normals.size());
    for(std::map<PRCVector3d,uint32_t>::const_iterator pNormal = boxgroup.normals.begin(); pNormal != boxgroup.normals.end(); pNormal++)
    {
      tess->normal_coordinate[3*pNormal->second+0] = pNormal->first.x;
      tess->normal_coordinate[3*pNormal->second+1] = pNormal->first.y;
      tess->normal_coordinate[3*pNormal->second+2] = pNormal->first.z;
    }
    
    if (trianglecount!=0) {
      tessFace->sizes_triangulated.push_back(trianglecount);
      tess->addTessFace(tessFace);
      const uint32_t tess_index = prc.file->add3DTess(tess);
      prc.file->useMesh(tess_index, mat);
    }
    else {
      delete tessFace;
      delete tess;
    }
  }
  else if (material.front == material.LINE_FACE || material.back == material.LINE_FACE) {
    PRC3DWireTess *tess = new PRC3DWireTess();
    for(i=0;i<6;i++) {

      const Vertex4 q = modelview * side[i].normal;
      const Vertex4 view(0.0f,0.0f,1.0f,0.0f);

      const float cos_a = view * q;

      const bool front = (cos_a >= 0.0f) ? true : false;

      if (draw_front || !front) {
          uint32_t pi[4];
          for(j=0;j<4;j++) {
            // feed vertex
            Vertex4& v = boxv[ side[i].vidx[j] ];
            pi[j] = boxgroup.addVertex(v.x, v.y, v.z);
          }
          tess->wire_indexes.push_back(4|PRC_3DWIRETESSDATA_IsClosing);
          tess->wire_indexes.push_back(3*pi[0]);
          tess->wire_indexes.push_back(3*pi[1]);
          tess->wire_indexes.push_back(3*pi[2]);
          tess->wire_indexes.push_back(3*pi[3]);
      }
    }
    tess->coordinates.resize(3*boxgroup.points.size());
    for(std::map<PRCVector3d,uint32_t>::const_iterator pPoint = boxgroup.points.begin(); pPoint != boxgroup.points.end(); pPoint++)
    {
      tess->coordinates[3*pPoint->second+0] = pPoint->first.x;
      tess->coordinates[3*pPoint->second+1] = pPoint->first.y;
      tess->coordinates[3*pPoint->second+2] = pPoint->first.z;
    }
    if (tess->wire_indexes.size()!=0) {
      const uint32_t tess_index = prc.file->add3DWireTess(tess);
      prc.file->useLines(tess_index, mat);
    }
    else {
      delete tess;
    }
  }
  else if (material.front == material.POINT_FACE || material.back == material.POINT_FACE) {
    for(i=0;i<6;i++) {

      const Vertex4 q = modelview * side[i].normal;
      const Vertex4 view(0.0f,0.0f,1.0f,0.0f);

      const float cos_a = view * q;

      const bool front = (cos_a >= 0.0f) ? true : false;

      if (draw_front || !front) {
          for(j=0;j<4;j++) {
            // feed vertex
            Vertex4& v = boxv[ side[i].vidx[j] ];
            boxgroup.addDot(PRCVector3d(v.x, v.y, v.z),colour);
          }
      }
    }
    if (!boxgroup.dots.empty()) {
      for(std::set<prcdot>::const_iterator pDot = boxgroup.dots.begin(); pDot != boxgroup.dots.end(); pDot++)
        prc.file->addPoint(pDot->p.x, pDot->p.y, pDot->p.z, pDot->c, material.size);
    }
  }

  prc.file->endgroup();

  prc.file->begingroup("axis",&grpopt,prc.transform);
  // setup mark length

  Vertex marklen = getMarkLength(bbox);


  // draw axis and tickmarks
  // find contours
  
  prcgroup group;

  const Color axiscolor = (material.colors.getLength() > 1) ? material.colors.getColor(1) : material.colors.getColor(0);
  const RGBAColour axiscolour(axiscolor.getRedf(), axiscolor.getGreenf(), axiscolor.getBluef());
  const uint32_t axiscol = prc.file->addRgbColorUnique(axiscolour.R, axiscolour.G, axiscolour.B);
  const uint32_t axismat = prc.file->addLineMaterial(axiscolour,material.lwd);

  for(i=0;i<3;i++) {

    Vertex4 v;
    AxisInfo*  axis;
    const Edge*  axisedge;
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
    const Edge* edge = NULL;

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
                AxisInfowritePRC(renderContext, v, edge->dir, modelview, marklen, string, group, axiscol, prc);
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

              AxisInfowritePRC(renderContext, v, edge->dir, modelview, marklen, string, group, axiscol, prc);
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

              AxisInfowritePRC(renderContext, v, edge->dir, modelview, marklen, s, group, axiscol, prc );

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
            axis->unit = R_pretty0(&lo, &up, &ndiv, min_n, shrink_sml, high_u_fact, 
                                   eps_correction, 0);
            
            for (int i=(int)lo; i<=up; i++) {
              float value = i*axis->unit;
      	if (value >= low && value <= high) {
                *valueptr = value;

                char text[32];
                sprintf(text, "%.4g", value);

                String s (strlen(text),text);

                AxisInfowritePRC(renderContext, v, edge->dir, modelview, marklen, s, group, axiscol, prc );
      	}
            }
          }
          break;
          
      }
    }
  }
  if (!group.linesegments.empty()) {
     const uint32_t nI = (uint32_t)group.linesegments.size();
     const uint32_t nP = (uint32_t)group.points.size();
     double (*P)[3] = new double[nP][3];
     group.writePoints(P);
     uint32_t (*PI)[2] = new uint32_t[nI][2];
     for(uint32_t k = 0; k<nI; k++)
     {
             PI[k][0] = group.linesegments[k].pi[0];
             PI[k][1] = group.linesegments[k].pi[1];
     }
     const uint32_t tess_index = prc.file->createLineSegments(nP, P, nI, PI, 0, NULL, NULL, NULL, false);
     prc.file->useLines(tess_index, axismat);
     delete [] PI;
     delete [] P;
   }

  prc.file->endgroup();

}

static PRCtexture* mktex(const Material& material)
{
  if (!material.texture)
    return NULL;
  Texture::Type type;
  bool mipmap, envmap;
  unsigned int minfilter, magfilter;
  char filename[1024];
  material.texture->getParameters(&type, &mipmap, &minfilter, &magfilter, &envmap, 1023, filename) ;

  uint8_t *buffer = NULL;
  int length = 0;
  {
    std::ifstream is;
    is.open (filename, std::ios::binary );
    if (!is.is_open())
    {
      error("PRC can not open texture file %s \n", filename);
    }
    // get length of file:
    is.seekg (0, std::ios::end);
    length = is.tellg();
    if(length==0 || length==1)
    {
      error("PRC can not read texture file %s \n", filename);
    }
    is.seekg (0, std::ios::beg);
 
    // allocate memory:                             
    buffer = new uint8_t [length];                  
 
    // read data as a block:                        
    is.read ((char *)buffer,length);
 
    is.close();
  }
 
  PRCtexture *tex = new PRCtexture();
  tex->format = KEPRCPicture_PNG;
  tex->data = buffer;
  tex->size = length;
  switch(type)
   {
   case Texture::ALPHA:
     tex->components = PRC_TEXTURE_MAPPING_COMPONENTS_ALPHA;
     tex->mapping = PRC_TEXTURE_MAPPING_OPACITY;
     break;
   case Texture::RGB:
     tex->components = PRC_TEXTURE_MAPPING_COMPONENTS_RGB;
     tex->mapping = PRC_TEXTURE_MAPPING_DIFFUSE;
     break;
   case Texture::RGBA:
     tex->components = PRC_TEXTURE_MAPPING_COMPONENTS_RGBA;
     tex->mapping = PRC_TEXTURE_MAPPING_DIFFUSE;
     break;
   default:
     tex->components = PRC_TEXTURE_MAPPING_COMPONENTS_RGBA;
     tex->mapping = PRC_TEXTURE_MAPPING_DIFFUSE;
     REprintf("PRC unsupported texture type\n");
   }

  tex->function = KEPRCTextureFunction_Modulate;
  tex->wrapping_mode_S = KEPRCTextureWrappingMode_Repeat;
  tex->wrapping_mode_T = KEPRCTextureWrappingMode_Repeat;
  
  return tex;
}

void Surface::writePRC(prcout& prc)
{
  const int nvertex = nx*nz;
  bool colorPerVertexHasAlpha = false;
  bool colorPerVertex = false;
  const Color color = material.colors.getColor(0);
  const RGBAColour colour(color.getRedf(), color.getGreenf(), color.getBluef(), color.getAlphaf());
  if ((material.useColorArray) && ( material.colors.getLength() == (unsigned)nvertex ))
    for(int i=0; i<nvertex; i++)
      if (!vertexArray[i].missing()) {
        colorPerVertexHasAlpha |= (material.colors.getColor(i).getAlphaf() < 1.0f);
        colorPerVertex |= (material.colors.getColor(i)!=color);
      }
  PRCoptions grpopt;
  grpopt.tess = true;
  prcgroup group;
  if (material.front == material.FILL_FACE || material.back == material.FILL_FACE ) {
    grpopt.closed = material.front == material.CULL_FACE || material.back == material.CULL_FACE; // set to true to make only front side visible
    const bool switchorientation = material.front == material.CULL_FACE;

    prc.file->begingroup("surface_fill",&grpopt,prc.transform);
    const RGBAColour  ambient(  material.ambient.getRedf(),  material.ambient.getGreenf(),  material.ambient.getBluef(),  material.ambient.getAlphaf());
    const RGBAColour emission( material.emission.getRedf(), material.emission.getGreenf(), material.emission.getBluef(), material.emission.getAlphaf());
    const RGBAColour specular( material.specular.getRedf(), material.specular.getGreenf(), material.specular.getBluef(), material.specular.getAlphaf());
    uint32_t mat = m1;
    PRCtexture* tex = NULL;
    const bool textc = colorPerVertex && !material.texture;
    const bool textured = textc || material.texture;
    const bool usenormals = material.lit;
    const bool usevc = colorPerVertex && !textc &&!(colorPerVertexHasAlpha || material.lit || (material.texture && material.texture->hasAlpha()));
    const bool averc = colorPerVertex && !textc && (colorPerVertexHasAlpha || material.lit || (material.texture && material.texture->hasAlpha()));
    if (textc) {  // vertex color converted to texture
      const int nc = colorPerVertexHasAlpha?4:3;
      uint8_t *pic = new uint8_t[nvertex*nc];
      int iy  = 0;
      for(int iz=0;iz<nz;iz++) {
        for(int ix=0;ix<nx;ix++,iy++) {    
          const Color color  = material.colors.getColor(iy);
          pic[iy*nc+0] = color.getRedub(); 
          pic[iy*nc+1] = color.getGreenub(); 
          pic[iy*nc+2] = color.getBlueub(); 
          if (colorPerVertexHasAlpha)
           pic[iy*4+3] = color.getAlphaub(); 
        }
      }
    
      PRCmaterial materialDiffuse(
        RGBAColour(0.1,0.1,0.1,1),
        RGBAColour(1.0,1.0,1.0,1),
        RGBAColour(0.1,0.1,0.1,1),
        RGBAColour(0.1,0.1,0.1,1),
        1.0,0.1);
      PRCmaterial materialEmissive(
        RGBAColour(0.0,0.0,0.0,1),
        RGBAColour(0.0,0.0,0.0,1),
        RGBAColour(1.0,1.0,1.0,1),
        RGBAColour(0.0,0.0,0.0,1),
        1.0,0.0);
      PRCtexture* tex = new PRCtexture();
      tex->mapping = material.lit ? PRC_TEXTURE_MAPPING_DIFFUSE : PRC_TEXTURE_MAPPING_EMISSION;
      tex->components = colorPerVertexHasAlpha ? PRC_TEXTURE_MAPPING_COMPONENTS_RGBA : PRC_TEXTURE_MAPPING_COMPONENTS_RGB;
      tex->function = KEPRCTextureFunction_Replace;
      tex->wrapping_mode_S = KEPRCTextureWrappingMode_ClampToEdge;
      tex->wrapping_mode_T = KEPRCTextureWrappingMode_ClampToEdge;
      tex->data = pic;
      tex->width = nx;
      tex->height = nz;
      tex->size	= nx*nz*nc;
      tex->format = colorPerVertexHasAlpha ? KEPRCPicture_BITMAP_RGBA_BYTE : KEPRCPicture_BITMAP_RGB_BYTE;
      mat = prc.file->addTexturedMaterial((material.lit ? materialDiffuse : materialEmissive),1,&tex);
      delete [] tex->data;
      tex->data = NULL;
      delete tex;
      tex = NULL;
    }
    else 
    {
      tex = mktex(material);

      if (usevc) {
        const RGBAColour black(0,0,0,1);
        const RGBAColour white(1,1,1,1);
        const PRCmaterial mater(
          black, // ambient
          white, // diffuse
          black, // emissive
          black, // specular
          1.0,0.0);
        if (material.texture) {
          tex->texture_applying_mode = PRC_TEXTURE_APPLYING_MODE_VERTEXCOLOR;
          mat = prc.file->addTexturedMaterial(mater,1,&tex);
          delete [] tex->data;
          tex->data = NULL;
          delete tex;
          tex = NULL;
        }
//      else
//        mat = prc.file->addMaterial(mater);
      }
      else {
        if (!averc) {
          if (material.lit) {
            const PRCmaterial mater(
              ambient,
              colour,
              emission,
              specular,
              colour.A,material.shininess
              );
            if (material.texture) {
              mat = prc.file->addTexturedMaterial(mater,1,&tex);
              delete [] tex->data;
              tex->data = NULL;
              delete tex;
              tex = NULL;
            }
            else
              mat = prc.file->addMaterial(mater);
          }
          else {
            const RGBAColour black(0,0,0,colour.A);
            const PRCmaterial mater(
              black,
              black,
              colour,
              black,
              colour.A,0.0
              );
            if (material.texture) {
              if (tex->mapping == PRC_TEXTURE_MAPPING_DIFFUSE)
                tex->mapping = PRC_TEXTURE_MAPPING_EMISSION;
              mat = prc.file->addTexturedMaterial(mater,1,&tex);
              delete [] tex->data;
              tex->data = NULL;
              delete tex;
              tex = NULL;
            }
            else
              mat = prc.file->addMaterial(mater);
          }
        }
      }
    }

    std::vector<uint32_t> pi(nvertex,m1); 
    for (int i=0; i<nvertex; i++) {
      if (!vertexArray[i].missing()) 
        pi[i] = group.addVertex(vertexArray[i]);
    }
    PRC3DTess *tess = new PRC3DTess();
    tess->coordinates.resize(3*group.points.size());
    for(std::map<PRCVector3d,uint32_t>::const_iterator pPoint = group.points.begin(); pPoint != group.points.end(); pPoint++)
    {
      tess->coordinates[3*pPoint->second+0] = pPoint->first.x;
      tess->coordinates[3*pPoint->second+1] = pPoint->first.y;
      tess->coordinates[3*pPoint->second+2] = pPoint->first.z;
    }

    std::vector<uint32_t> ni; 
    if (usenormals) {
      ni.resize(nvertex,m1); 
      for(int iz=0;iz<nz;iz++) {
        for(int ix=0;ix<nx;ix++) {    
          const int i = iz*nx + ix;
          Vertex total(0.0f,0.0f,0.0f);
          if (user_normals)
            total = normalArray[i];
          else
          {
            Vertex n[4];
           
            size_t num = 0;
            
            if (!vertexArray[i].missing()) {
              if (ix < nx-1 && !vertexArray[i+1].missing() ) {
                if (iz > 0 && !vertexArray[i-nx].missing() )     // right/top
                  n[num++] = vertexArray.getNormal(i, i+1, i-nx );
                if (iz < nz-1 && !vertexArray[i+nx].missing() )  // right/bottom
                  n[num++] = vertexArray.getNormal(i, i+nx, i+1 );
              }
              if (ix > 0 && !vertexArray[i-1].missing() ) { 
                if (iz > 0 && !vertexArray[i-nx].missing() )     // left/top
                  n[num++] = vertexArray.getNormal(i, i-nx, i-1 );
                if (iz < nz-1 && !vertexArray[i+nx].missing() )  // left/bottom
                  n[num++] = vertexArray.getNormal(i, i-1, i+nx );
              }
            }
           
            for(size_t i=0;i<num;i++)
              total += n[i];
           
            total.normalize();
           
            if (orientation!=switchorientation)
              total = total * -1.0f;
          }
          ni[i] = group.addNormal(total);
        }
      }
      tess->normal_coordinate.resize(3*group.normals.size());
      for(std::map<PRCVector3d,uint32_t>::const_iterator pNormal = group.normals.begin(); pNormal != group.normals.end(); pNormal++)
      {
        tess->normal_coordinate[3*pNormal->second+0] = pNormal->first.x;
        tess->normal_coordinate[3*pNormal->second+1] = pNormal->first.y;
        tess->normal_coordinate[3*pNormal->second+2] = pNormal->first.z;
      }
    }

    std::vector<uint32_t> ti; 
    if (textured) {
      ti.resize(nvertex,m1); 
      int iy  = 0;
      for(int iz=0;iz<nz;iz++) {
        for(int ix=0;ix<nx;ix++,iy++) {    
          if (!vertexArray[iy].missing()) { 
            if (textc)
              ti[iy] = group.addTextureCoords(((float)ix)/((float)nx)+(1/(2*(float)nx)), ((float)iz)/((float)nz)+(1/(2*(float)nz)));
            else
              ti[iy] = group.addTexCoord(texCoordArray[iy]);
		  }
        }
      }
      tess->texture_coordinate.resize(2*group.texturecoords.size());
      for(std::map<PRCVector2d,uint32_t>::const_iterator pTC = group.texturecoords.begin(); pTC != group.texturecoords.end(); pTC++)
      {
        tess->texture_coordinate[2*pTC->second+0] = pTC->first.x;
        tess->texture_coordinate[2*pTC->second+1] = pTC->first.y;
      }
    }

    PRCTessFace *tessFace = new PRCTessFace();
    if (averc)
      tessFace->used_entities_flag = textured ? PRC_FACETESSDATA_TriangleTextured : PRC_FACETESSDATA_Triangle;
    else 
      tessFace->used_entities_flag = textured ? PRC_FACETESSDATA_TriangleStripeTextured : PRC_FACETESSDATA_TriangleStripe;
    tessFace->number_of_texture_coordinate_indexes = textured ? 1 : 0;
    tessFace->is_rgba=colorPerVertexHasAlpha;

//  tess->triangulated_index.reserve((1+(material.lit?1:0)+(textured?1:0))*2*nprimitives); // 3 points, 3 normals, 3 texture coords per triangle
    std::vector<size_t> sizes_triangulated;
    std::vector<uint32_t> trianglestrip;
    uint32_t numtri = 0;
   
#define PRCEND \
      if (trianglestrip.size()>2) { \
        if (averc) { \
          for (size_t k=0; k<trianglestrip.size()-2; k++) { \
            numtri++; \
            Color color(0.0f,0.0f,0.0f,0.0f); \
            bool ke = (k%2)==0; \
            for (size_t l=0; l<3; l++) { \
              color = color + material.colors.getColor(trianglestrip[k+(ke?l:(2-l))]); \
              if (usenormals) \
                tess->triangulated_index.push_back(3*ni[trianglestrip[k+(ke?l:(2-l))]]); \
              if(textured) \
                tess->triangulated_index.push_back(2*ti[trianglestrip[k+(ke?l:(2-l))]]); \
                tess->triangulated_index.push_back(3*pi[trianglestrip[k+(ke?l:(2-l))]]); \
            } \
            color = (1.0f/3) * color; \
            const RGBAColour colour( color.getRedf(), color.getGreenf(), color.getBluef(), color.getAlphaf()); \
            if (material.lit) { \
              const PRCmaterial mater( \
                ambient, \
                colour, \
                emission, \
                specular, \
                colour.A,material.shininess \
                ); \
              if (material.texture) { \
                tessFace->line_attributes.push_back(prc.file->addTexturedMaterial(mater,1,&tex)); \
              } \
              else \
                tessFace->line_attributes.push_back(prc.file->addMaterial(mater)); \
            } \
            else { \
              const RGBAColour black(0,0,0,colour.A); \
              const PRCmaterial mater( \
                black, \
                black, \
                colour, \
                black, \
                colour.A,0.0 \
                ); \
              if (material.texture) { \
                if (tex->mapping == PRC_TEXTURE_MAPPING_DIFFUSE) \
                  tex->mapping = PRC_TEXTURE_MAPPING_EMISSION; \
                tessFace->line_attributes.push_back(prc.file->addTexturedMaterial(mater,1,&tex)); \
              } \
              else \
                tessFace->line_attributes.push_back(prc.file->addMaterial(mater)); \
            } \
          } \
        } \
        else { \
          for(std::vector<uint32_t>::const_iterator pP = trianglestrip.begin(); pP != trianglestrip.end(); pP++) { \
            if (usenormals) \
              tess->triangulated_index.push_back(3*ni[*pP]); \
            if(textured) \
              tess->triangulated_index.push_back(2*ti[*pP]); \
              tess->triangulated_index.push_back(3*pi[*pP]); \
            if (usevc) { \
              const Color color  = material.colors.getColor(*pP); \
              tessFace->rgba_vertices.push_back(color.getRedub()); \
              tessFace->rgba_vertices.push_back(color.getGreenub()); \
              tessFace->rgba_vertices.push_back(color.getBlueub()); \
              if (colorPerVertexHasAlpha) \
              tessFace->rgba_vertices.push_back(color.getAlphaub()); \
            } \
          } \
          sizes_triangulated.push_back(trianglestrip.size()); \
        } \
      } \
      trianglestrip.clear();

#define PRCBEGIN trianglestrip.clear();

    for(int ix=0;ix<nx-1;ix++) {
      for(int iz=0;iz<nz;iz++) {
        int i = iz*nx+ix;
        const bool bothmissing = (vertexArray[i].missing() && vertexArray[i+1].missing());
        const bool onemissing  = (vertexArray[i].missing() || vertexArray[i+1].missing());
        const bool nonemissing = !onemissing;

        if (bothmissing && !trianglestrip.empty())
          { PRCEND }
          
        if (onemissing && !bothmissing) {
          const int ii = vertexArray[i].missing() ? i+1 : i;
          if (trianglestrip.empty()) {
            PRCBEGIN
            trianglestrip.push_back(ii);
          }
          else {
            trianglestrip.push_back(ii);
            PRCEND
          }
        }
          
        if (nonemissing) {
          // If orientation == 1, we draw ix first, otherwise ix+1 first      
          i = iz*nx+ix+ (!orientation!=switchorientation);
          trianglestrip.push_back(i);
    
          i = iz*nx+ix+  (orientation!=switchorientation);
          trianglestrip.push_back(i);
        }
      }
      { PRCEND }
    }
#undef PRCBEGIN
#undef PRCEND   

    if (sizes_triangulated.empty() && numtri==0) {
      delete tessFace;
      delete tess;
    }
    else {
      if (!sizes_triangulated.empty()) {
        tessFace->sizes_triangulated.push_back(sizes_triangulated.size());
        tessFace->sizes_triangulated.insert(tessFace->sizes_triangulated.end(), sizes_triangulated.begin(), sizes_triangulated.end());
      }
      else {
        tessFace->sizes_triangulated.push_back(numtri);
      }

      tess->addTessFace(tessFace);
      const uint32_t tess_index = prc.file->add3DTess(tess);
      prc.file->useMesh(tess_index, mat);
    }

    if (tex) {
      delete [] tex->data;
      tex->data = NULL;
      delete tex;
      tex = NULL;
    }
  }
  else if (material.front == material.LINE_FACE) {
    prc.file->begingroup("surface_line",&grpopt,prc.transform);
    prcgroup group;
    uint32_t mat = m1;
    if (colorPerVertex ) {
        const RGBAColour colour(0,0,0,1);
        mat = prc.file->addLineMaterial(colour,material.lwd);
    }
    else {
        mat = prc.file->addLineMaterial(colour,material.lwd);
    }
    uint32_t *pi = new uint32_t[nvertex]; 
    for (int i=0; i<nvertex; i++) {
      if (vertexArray[i].missing()) 
        pi[i] = m1;
      else
        pi[i] = group.addVertex(vertexArray[i]);
    }
    const uint32_t nP = (uint32_t)group.points.size();
    double (*P)[3] = new double[nP][3];
    group.writePoints(P);
    PRC3DWireTess *tess = new PRC3DWireTess();
    tess->coordinates.reserve(3*nP);
    for(uint32_t i=0; i<nP; i++)
    {
      tess->coordinates.push_back(P[i][0]);
      tess->coordinates.push_back(P[i][1]);
      tess->coordinates.push_back(P[i][2]);                 
    }
    tess->wire_indexes.reserve(nz+nz*nx+nx+nx*nz);
    if (colorPerVertex) {
      tess->is_segment_color = true;
      tess->is_rgba = colorPerVertexHasAlpha;
      tess->rgba_vertices.reserve((tess->is_rgba?4:3)*(nz*(nx-1)+nx*(nz-1)));
    }
    int iy  = 0;
    std::vector<int> pnts;
    pnts.reserve(nx);
    for(int iz=0;iz<nz;iz++) {
      for(int ix=0;ix<nx;ix++) {    
        iy = iz*nx+ix;
        if (pi[iy] != m1) // add point to line
          pnts.push_back(iy);
        if ((pi[iy] != m1 && ix<nx-1) || pnts.empty()) // no need to output line
          continue;
        if (pnts.size()==1) { // line of one point is a point
          const PRCVector3d p(P[pi[pnts.front()]][0],P[pi[pnts.front()]][1],P[pi[pnts.front()]][2]);
          if (colorPerVertex) {
            const Color color  = material.colors.getColor(pnts.front());
            const RGBAColour colour( color.getRedf(), color.getGreenf(), color.getBluef(), color.getAlphaf());
            group.addDot(p,colour);
          }
          else
            group.addDot(p,colour);
        }
        else {
          tess->wire_indexes.push_back(pnts.size());
          for(size_t i=0;i<pnts.size();i++) {
            tess->wire_indexes.push_back(3*pi[pnts[i]]);
            if (colorPerVertex && i!=0) {
              const Color c  = 0.5 * (material.colors.getColor(pnts[i-1]) + material.colors.getColor(pnts[i]));
              tess->rgba_vertices.push_back(c.getRedub());
              tess->rgba_vertices.push_back(c.getGreenub());
              tess->rgba_vertices.push_back(c.getBlueub());
              if(tess->is_rgba)
              tess->rgba_vertices.push_back(c.getAlphaub());
            }
          }
        }
        pnts.clear();
      }
    }
    for(int ix=0;ix<nx;ix++) {
      for(int iz=0;iz<nz;iz++) {    
        iy = iz*nx+ix;
        if (pi[iy] != m1) // add point to line
          pnts.push_back(iy);
        if ((pi[iy] != m1 && iz<nz-1) || pnts.empty()) // no need to output line
          continue;
        if (pnts.size()==1) { // line of one point is a point
          const PRCVector3d p(P[pi[pnts.front()]][0],P[pi[pnts.front()]][1],P[pi[pnts.front()]][2]);
          if (colorPerVertex) {
            const Color color  = material.colors.getColor(pnts.front());
            const RGBAColour colour( color.getRedf(), color.getGreenf(), color.getBluef(), color.getAlphaf());
            group.addDot(p,colour);
          }
          else
            group.addDot(p,colour);
        }
        else {
          tess->wire_indexes.push_back(pnts.size());
          for(size_t i=0;i<pnts.size();i++) {
            tess->wire_indexes.push_back(3*pi[pnts[i]]);
            if (colorPerVertex && i!=0) {
              const Color c  = 0.5 * (material.colors.getColor(pnts[i-1]) + material.colors.getColor(pnts[i]));
              tess->rgba_vertices.push_back(c.getRedub());
              tess->rgba_vertices.push_back(c.getGreenub());
              tess->rgba_vertices.push_back(c.getBlueub());
              if(tess->is_rgba)
              tess->rgba_vertices.push_back(c.getAlphaub());
            }
          }
        }
        pnts.clear();
      }
    }
    if (tess->wire_indexes.empty())
      delete tess;
    else {
      const uint32_t tess_index = prc.file->add3DWireTess(tess);
      prc.file->useLines(tess_index, mat);
    }
    delete [] P;
    delete [] pi;
    if (!group.dots.empty()) {
      for(std::set<prcdot>::const_iterator pDot = group.dots.begin(); pDot != group.dots.end(); pDot++)
        prc.file->addPoint(pDot->p.x, pDot->p.y, pDot->p.z, pDot->c, material.lwd);
    }
  }
  else if (material.front == material.POINT_FACE) {
    prc.file->begingroup("surface_point",&grpopt,prc.transform);
    prcgroup group;
    for(int i=0;i<nvertex;i++) {
      if (vertexArray[i].missing())
        continue;
      if (colorPerVertex)
        group.addDot(vertexArray[i],material.colors.getColor(i));
      else
        group.addDot(vertexArray[i],color);
    }
    if (!group.dots.empty()) {
      for(std::set<prcdot>::const_iterator pDot = group.dots.begin(); pDot != group.dots.end(); pDot++)
        prc.file->addPoint(pDot->p.x, pDot->p.y, pDot->p.z, pDot->c, material.size);
    }
  }
  prc.file->endgroup();
}

void SpriteSet::writePRC(prcout& prc)
{
  PRCoptions grpopt;
  grpopt.tess = true;
  prc.file->begingroup("sprites");
  double *oldtransform = prc.transform;
  Matrix4x4 mt;
  if (prc.transform)
    mt = Matrix4x4(prc.transform);
  else
    mt.setIdentity();
  prc.transform = NULL;
  if (shapes.size()) {
    for (int index=0; index < vertex.size(); index++) {
      Vertex const& o = vertex.get(index);
      float s = size.getRecycled(index);
      if (o.missing() || ISNAN(s)) continue;

      Vertex  v;
      s = s * 0.5f;
      v = mt * o;

//    glLoadIdentity();
      double t[16] = { 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
//    glTranslatef(v.x, v.y, v.z);
      t[12] = v.x;
      t[13] = v.y;
      t[14] = v.z;

    
      prc.file->begingroup("sprite_pos",NULL,t);

      prcgroup group;
      prc.file->begingroup("sprite_rot",NULL,prc.invorientation);
     
//    glMultMatrixd(userMatrix);
//    glScalef(s,s,s);
      double sr[16];
      for(size_t i=0;i<12;i++)
        sr[i] = s*userMatrix[i];
      for(size_t i=12;i<16;i++)
        sr[i] = userMatrix[i];
    
      prc.transform = sr;

      for (std::vector<Shape*>::const_iterator i = shapes.begin(); i != shapes.end() ; ++ i ) 
        (*i)->writePRC(prc);  
      
      prc.file->endgroup();
      prc.file->endgroup();
    }
  }
  else {
//    material.useColor(index);
//  
//    glBegin(GL_QUADS);
//  
//    if (doTex)
//      glTexCoord2f(0.0f,0.0f);
//    glVertex3f(-s, -s, 0.0f);
// 
//    if (doTex)
//      glTexCoord2f(1.0f,0.0f);
//    glVertex3f(s, -s, 0.0f);
// 
//    if (doTex)
//      glTexCoord2f(1.0f,1.0f);
//    glVertex3f(s, s, 0.0);
// 
//    if (doTex)
//      glTexCoord2f(0.0f,1.0f);
//    glVertex3f(-s, s, 0.0f);  
//  
//    glEnd();

    if (material.front == material.FILL_FACE) {
      grpopt.closed = true; // set to true to make only front side visible

      const RGBAColour  ambient(  material.ambient.getRedf(),  material.ambient.getGreenf(),  material.ambient.getBluef(),  material.ambient.getAlphaf());
      const RGBAColour emission( material.emission.getRedf(), material.emission.getGreenf(), material.emission.getBluef(), material.emission.getAlphaf());
      const RGBAColour specular( material.specular.getRedf(), material.specular.getGreenf(), material.specular.getBluef(), material.specular.getAlphaf());
      uint32_t mat = m1;
      PRCtexture* tex = NULL;

      tex = mktex(material);

      for (int index=0; index < vertex.size(); index++) {
        const Color color = material.colors.getColor(index % material.colors.getLength());
        const RGBAColour colour( color.getRedf(), color.getGreenf(), color.getBluef(), color.getAlphaf());
        if (material.lit) {
          const PRCmaterial mater(
            ambient,
            colour,
            emission,
            specular,
            colour.A,material.shininess
            );
          if (material.texture) {
            mat = prc.file->addTexturedMaterial(mater,1,&tex);
          }
          else
            mat = prc.file->addMaterial(mater);
        }
        else {
          const RGBAColour black(0,0,0,colour.A);
          const PRCmaterial mater(
            black,
            black,
            colour,
            black,
            colour.A,0.0
            );
          if (material.texture) {
            if (tex->mapping == PRC_TEXTURE_MAPPING_DIFFUSE)
              tex->mapping = PRC_TEXTURE_MAPPING_EMISSION;
            mat = prc.file->addTexturedMaterial(mater,1,&tex);
          }
          else
            mat = prc.file->addMaterial(mater);
        }

        Vertex const& o = vertex.get(index);
        float   s = size.getRecycled(index);
        if (o.missing() || ISNAN(s)) continue;

        Vertex  v;
        s = s * 0.5f;
        v = mt * o;

//      glLoadIdentity();
        double t[16] = { 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
//      glTranslatef(v.x, v.y, v.z);
        t[12] = v.x;
        t[13] = v.y;
        t[14] = v.z;

      
        prc.file->begingroup("sprite_pos",NULL,t);

        prc.file->begingroup("sprite_rot",NULL,prc.invorientation);
       
        PRC3DTess *tess = new PRC3DTess();
        PRCTessFace *tessFace = new PRCTessFace();
        tessFace->used_entities_flag = material.texture ? PRC_FACETESSDATA_TriangleTextured : PRC_FACETESSDATA_Triangle;
        tessFace->number_of_texture_coordinate_indexes = material.texture ? 1 : 0;

        tess->coordinates.resize(12);
        tess->coordinates[3*0+0] = -s;
        tess->coordinates[3*0+1] = -s;
        tess->coordinates[3*0+2] =  0;
        tess->coordinates[3*1+0] =  s;
        tess->coordinates[3*1+1] = -s;
        tess->coordinates[3*1+2] =  0;
        tess->coordinates[3*2+0] =  s;
        tess->coordinates[3*2+1] =  s;
        tess->coordinates[3*2+2] =  0;
        tess->coordinates[3*3+0] = -s;
        tess->coordinates[3*3+1] =  s;
        tess->coordinates[3*3+2] =  0;

        if (material.texture) {
          tess->texture_coordinate.resize(8);
          tess->texture_coordinate[2*0+0] = 0;
          tess->texture_coordinate[2*0+1] = 0;
          tess->texture_coordinate[2*1+0] = 1;
          tess->texture_coordinate[2*1+1] = 0;
          tess->texture_coordinate[2*2+0] = 1;
          tess->texture_coordinate[2*2+1] = 1;
          tess->texture_coordinate[2*3+0] = 0;
          tess->texture_coordinate[2*3+1] = 1;
        }

        tessFace->sizes_triangulated.push_back(2);

        size_t jj[2][3] ={ {0,1,2}, {2,3,0} };
        for (size_t k=0; k<2; k++) {
          for (size_t l=0; l<3; l++) {
            if (material.texture)
              tess->triangulated_index.push_back(2*jj[k][l]);
            tess->triangulated_index.push_back(3*jj[k][l]);
          }
        }

        tess->addTessFace(tessFace);
        const uint32_t tess_index = prc.file->add3DTess(tess);
        prc.file->useMesh(tess_index, mat);

        prc.file->endgroup();
        prc.file->endgroup();
      }
      if (tex) {
        delete [] tex->data;
        tex->data = NULL;
        delete tex;
        tex = NULL;
      }
    }
    if (material.front == material.LINE_FACE) {
      for (int index=0; index < vertex.size(); index++) {
        Vertex const& o = vertex.get(index);
        float s = size.getRecycled(index);
        if (o.missing() || ISNAN(s)) continue;

        const Color color = material.colors.getColor(index % material.colors.getLength());
        const RGBAColour colour( color.getRedf(), color.getGreenf(), color.getBluef(), color.getAlphaf());
        const uint32_t lmat = prc.file->addLineMaterial(colour,material.lwd);

        Vertex  v;
        s = s * 0.5f;
        v = mt * o;

        double t[16] = { 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
        t[12] = v.x;
        t[13] = v.y;
        t[14] = v.z;

      
        prc.file->begingroup("sprite_pos",NULL,t);

        prc.file->begingroup("sprite_rot",NULL,prc.invorientation);
       
        const uint32_t nP = 4;
        const double P[4][3] = { {-s,-s,0}, {s,-s,0}, {s,s,0}, {-s,s,0} };
        const uint32_t nI = 1;
        const uint32_t PI[1][4] = { {0,1,2,3} };
        const uint32_t tess_index = prc.file->createLineQuads(nP, P, nI, PI, true, 0, NULL, NULL, true);
        prc.file->useLines(tess_index, lmat);

        prc.file->endgroup();
        prc.file->endgroup();
      }
    }
    if (material.front == material.POINT_FACE) {
      for (int index=0; index < vertex.size(); index++) {
        Vertex const& o = vertex.get(index);
        float s = size.getRecycled(index);
        if (o.missing() || ISNAN(s)) continue;

        const Color color = material.colors.getColor(index % material.colors.getLength());
        const RGBAColour colour( color.getRedf(), color.getGreenf(), color.getBluef(), color.getAlphaf());

        Vertex  v;
        s = s * 0.5f;
        v = mt * o;

        double t[16] = { 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
        t[12] = v.x;
        t[13] = v.y;
        t[14] = v.z;
      
        prc.file->begingroup("sprite_pos",NULL,t);

        prc.file->begingroup("sprite_rot",NULL,prc.invorientation);
       
        prc.file->addPoint(-s, -s, 0, colour, material.size);
        prc.file->addPoint( s, -s, 0, colour, material.size);
        prc.file->addPoint( s,  s, 0, colour, material.size);
        prc.file->addPoint(-s,  s, 0, colour, material.size);

        prc.file->endgroup();
        prc.file->endgroup();
      }
    }
  }
  prc.file->endgroup();
  prc.transform = oldtransform;
}

void SphereSet::writePRC(prcout& prc)
{
  PRCoptions grpopt;
  grpopt.tess = true;
  grpopt.granularity = 4.0;
  prcgroup group;
  grpopt.closed = material.back == material.CULL_FACE; // set to true to make only front side visible
  prc.file->begingroup("spheres",&grpopt,prc.transform);
  const RGBAColour  ambient(  material.ambient.getRedf(),  material.ambient.getGreenf(),  material.ambient.getBluef(),  material.ambient.getAlphaf());
  const RGBAColour emission( material.emission.getRedf(), material.emission.getGreenf(), material.emission.getBluef(), material.emission.getAlphaf());
  const RGBAColour specular( material.specular.getRedf(), material.specular.getGreenf(), material.specular.getBluef(), material.specular.getAlphaf());
  for ( int index=0; index < center.size(); index++) {
    if ( center.get(index).missing() || ISNAN(radius.getRecycled(index)) ) continue;
    const Color color = material.colors.getColor(index % material.colors.getLength());
    const RGBAColour colour(color.getRedf(), color.getGreenf(), color.getBluef(), color.getAlphaf());
    PRCmaterial mat;
    if (material.lit) {
      mat = PRCmaterial(
        ambient,
        colour,
        emission,
        specular,
        colour.A,material.shininess
        );
    }
    else {
      const RGBAColour black(0,0,0,colour.A);
      mat = PRCmaterial(
        black,
        black,
        colour,
        black,
        colour.A,0.0
        );
    }
    const Vertex c = center.get(index);
    double t[16];
    for(size_t i=0;i<16;i++)
      t[i] = 0.0f;
    t[ 0] = 1/prc.scale.x;
    t[ 5] = 1/prc.scale.y;
    t[10] = 1/prc.scale.z;
    t[12] = c.x;
    t[13] = c.y;
    t[14] = c.z;
    t[15] = 1.0;

//  double origin[3];
//  const Vertex c = Matrix4x4(prc.transform)*center.get(index);
//  origin[0] = c.x;
//  origin[1] = c.y;
//  origin[2] = c.z;
//  prc.file->addSphere(radius.getRecycled(index), mat, origin);
    prc.file->addSphere(radius.getRecycled(index), mat, NULL, NULL, NULL, 1, t);
  }
  prc.file->endgroup();
}

void PointSet::writePRC(prcout& prc)
{
  if (type!=GL_POINTS || nverticesperelement!=1)
    return;
  const bool colorPerVertex = (material.useColorArray) && ( material.colors.getLength() > 1 );
  PRCoptions grpopt;

  prc.file->begingroup("points",&grpopt,prc.transform);
  prcgroup group;
  const Color color  = material.colors.getColor(0);
  const RGBAColour colour( color.getRedf(), color.getGreenf(), color.getBluef(), color.getAlphaf());
  for (int i=0; i<nprimitives; i++) {
    if (!vertexArray[i].missing()) {
      const double P[3] = {vertexArray[i].x, vertexArray[i].y, vertexArray[i].z};
      if (colorPerVertex) {
        const Color color  = material.colors.getColor(i);
        const RGBAColour colour( color.getRedf(), color.getGreenf(), color.getBluef(), color.getAlphaf());
        prc.file->addPoint(P, colour, material.size);
      }
      else
        prc.file->addPoint(P, colour, material.size);
    }
  }
  prc.file->endgroup();
}

void LineSet::writePRC(prcout& prc)
{
  if (type!=GL_LINES || nverticesperelement!=2)
    return;
  const bool colorPerVertex = (material.useColorArray) && ( material.colors.getLength() > 1 );
  PRCoptions grpopt;

  prc.file->begingroup("lines",&grpopt,prc.transform);
  prcgroup group;
  uint32_t mat = m1;
  if (colorPerVertex ) {
      const RGBAColour colour(0,0,0,1);
      mat = prc.file->addLineMaterial(colour,material.lwd);
  }
  else {
      const Color color  = material.colors.getColor(0);
      const RGBAColour colour( color.getRedf(), color.getGreenf(), color.getBluef(), color.getAlphaf());
      mat = prc.file->addLineMaterial(colour,material.lwd);
  }
  for (int i=0; i<nprimitives; i++) {
    bool skip = false;
    for (int j=0; j<nverticesperelement; j++)
      skip |= vertexArray[nverticesperelement*i + j].missing();
    if (!skip) {
      vector<uint32_t> p(nverticesperelement); uint32_t c;
      for (int j=0; j<nverticesperelement; j++)
        p[j] = group.addVertex(vertexArray[nverticesperelement*i + j]);
      if (colorPerVertex) {
        const Color c0  = material.colors.getColor(nverticesperelement*i + 0);
        const Color c1  = material.colors.getColor(nverticesperelement*i + 1);
        const Color c05 = 0.5 * (c0 + c1);
        c = group.addColor(c05);
      }
      else
        c = m1;

      group.addLineSegment(p[0], p[1], c);
    }
  }
  if (!group.linesegments.empty()) {
    const uint32_t nI = (uint32_t)group.linesegments.size();
    const uint32_t nP = (uint32_t)group.points.size();
    double (*P)[3] = new double[nP][3];
    group.writePoints(P);
    uint32_t (*PI)[2] = new uint32_t[nI][2];
    for(uint32_t k = 0; k<nI; k++)
    {
            PI[k][0] = group.linesegments[k].pi[0];
            PI[k][1] = group.linesegments[k].pi[1];
    }
    if (colorPerVertex ) {
      const uint32_t nC = (uint32_t)group.colours.size();
      RGBAColour (*C) = new RGBAColour[nC];
      group.writeColours(C);
      uint32_t (*SCI) = new uint32_t[nI];
      for(uint32_t k = 0; k<nI; k++)
      {
        SCI[k] = group.linesegments[k].ci;
      }
      const uint32_t tess_index = prc.file->createLineSegments(nP, P, nI, PI, nC, C, NULL, SCI, false);
      prc.file->useLines(tess_index, mat);
      delete [] SCI;
      delete [] C;
    }
    else {
      const uint32_t tess_index = prc.file->createLineSegments(nP, P, nI, PI, 0, NULL, NULL, NULL, false);
      prc.file->useLines(tess_index, mat);
    }
    delete [] PI;
    delete [] P;
  }
  prc.file->endgroup();
}

void LineStripSet::writePRC(prcout& prc)
{
  if (type!=GL_LINE_STRIP || nverticesperelement!=1 || nvertices < 2)
    return;
  const bool colorPerVertex = (material.useColorArray) && ( material.colors.getLength() > 1 );
  PRCoptions grpopt;

  prc.file->begingroup("lines",&grpopt,prc.transform);
  prcgroup group;
  uint32_t mat = m1;
  if (colorPerVertex ) {
      const RGBAColour colour(0,0,0,1);
      mat = prc.file->addLineMaterial(colour,material.lwd);
  }
  else {
      const Color color  = material.colors.getColor(0);
      const RGBAColour colour( color.getRedf(), color.getGreenf(), color.getBluef(), color.getAlphaf());
      mat = prc.file->addLineMaterial(colour,material.lwd);
  }
  const uint32_t nI = (uint32_t)nvertices;
  uint32_t (*PI) = new uint32_t[nI];
  for (uint32_t i=0; i<nI; i++)
      PI[i] = group.addVertex(vertexArray[i]);
  const uint32_t nP = (uint32_t)group.points.size();
  double (*P)[3] = new double[nP][3];
  group.writePoints(P);
  if (colorPerVertex ) {
    uint32_t (*CI) = new uint32_t[nI-1];
    for (uint32_t i=0; i<nI-1; i++) {
      const Color c0  = material.colors.getColor(i + 0);
      const Color c1  = material.colors.getColor(i + 1);
      const Color c05 = 0.5 * (c0 + c1);
      CI[i] = group.addColor(c05);
    }
    const uint32_t nC = (uint32_t)group.colours.size();
    RGBAColour (*C) = new RGBAColour[nC];
    group.writeColours(C);
    const uint32_t tess_index = prc.file->createLine(nP, P, nI, PI, true, nC, C, CI, false);
    prc.file->useLines(tess_index, mat);
    delete [] C;
    delete [] CI;
  }
  else {
    const uint32_t tess_index = prc.file->createLine(nP, P, nI, PI, true, 0, NULL, NULL, false);
    prc.file->useLines(tess_index, mat);
  }
  delete [] PI;
  delete [] P;
  prc.file->endgroup();
}

void FaceSet::writePRC(prcout& prc)
{
  bool colorPerVertexHasAlpha = false;
  bool colorPerVertex = false;
  const Color color = material.colors.getColor(0);
  const RGBAColour colour( color.getRedf(), color.getGreenf(), color.getBluef(), color.getAlphaf());
  if ((material.useColorArray) && ( material.colors.getLength() > 1 ))
    for (int i=0; i<nprimitives; i++)
      for (int j=0; j<nverticesperelement; j++)
        if (!vertexArray[nverticesperelement*i + j].missing()) {
          const Color c = material.colors.getColor(nverticesperelement*i + j);
          colorPerVertexHasAlpha |= (c.getAlphaf() < 1.0f);
          colorPerVertex |= (c!=color);
        }
  PRCoptions grpopt;
  grpopt.tess = true;
  prcgroup group;

  if ((type==GL_TRIANGLES && nverticesperelement==3) || (type==GL_QUADS && nverticesperelement==4)) {
    if (material.front == material.FILL_FACE || material.back == material.FILL_FACE) {
      grpopt.closed = material.front == material.CULL_FACE || material.back == material.CULL_FACE; // set to true to make only front side visible
      const bool switchorientation = material.front == material.CULL_FACE;

      prc.file->begingroup("faceset_fill",&grpopt,prc.transform);
      const RGBAColour  ambient(  material.ambient.getRedf(),  material.ambient.getGreenf(),  material.ambient.getBluef(),  material.ambient.getAlphaf());
      const RGBAColour emission( material.emission.getRedf(), material.emission.getGreenf(), material.emission.getBluef(), material.emission.getAlphaf());
      const RGBAColour specular( material.specular.getRedf(), material.specular.getGreenf(), material.specular.getBluef(), material.specular.getAlphaf());
      uint32_t mat = m1;
      PRCtexture* tex = NULL;
      const bool textured = material.texture && texCoordArray.size()>0;
      const bool usenormals = material.lit;
      const bool usevc = colorPerVertex &&!(colorPerVertexHasAlpha || material.lit || (textured && material.texture->hasAlpha()));
      const bool averc = colorPerVertex && (colorPerVertexHasAlpha || material.lit || (textured && material.texture->hasAlpha()));

      if (textured) {
        tex = mktex(material);
      }

      if (usevc) {
        const RGBAColour black(0,0,0,1);
        const RGBAColour white(1,1,1,1);
        const PRCmaterial mater(
          black, // ambient
          white, // diffuse
          black, // emissive
          black, // specular
          1.0,0.0);
        if (textured) {
          tex->texture_applying_mode = PRC_TEXTURE_APPLYING_MODE_VERTEXCOLOR;
          mat = prc.file->addTexturedMaterial(mater,1,&tex);
          delete [] tex->data;
          tex->data = NULL;
          delete tex;
          tex = NULL;
        }
//      else
//        mat = prc.file->addMaterial(mater);
      }
      else {
        if (!averc) {
          if (material.lit) {
            const PRCmaterial mater(
              ambient,
              colour,
              emission,
              specular,
              colour.A,material.shininess
              );
            if (textured) {
              mat = prc.file->addTexturedMaterial(mater,1,&tex);
              delete [] tex->data;
              tex->data = NULL;
              delete tex;
              tex = NULL;
            }
            else
              mat = prc.file->addMaterial(mater);
          }
          else {
            const RGBAColour black(0,0,0,colour.A);
            const PRCmaterial mater(
              black,
              black,
              colour,
              black,
              colour.A,0.0
              );
            if (textured) {
              if (tex->mapping == PRC_TEXTURE_MAPPING_DIFFUSE)
                tex->mapping = PRC_TEXTURE_MAPPING_EMISSION;
              mat = prc.file->addTexturedMaterial(mater,1,&tex);
              delete [] tex->data;
              tex->data = NULL;
              delete tex;
              tex = NULL;
            }
            else
              mat = prc.file->addMaterial(mater);
          }
        }
      }

      PRC3DTess *tess = new PRC3DTess();
      PRCTessFace *tessFace = new PRCTessFace();
      tessFace->used_entities_flag = textured ? PRC_FACETESSDATA_TriangleTextured : PRC_FACETESSDATA_Triangle;
      tessFace->number_of_texture_coordinate_indexes = textured ? 1 : 0;
      tessFace->is_rgba=colorPerVertexHasAlpha;

      uint32_t numpri = 0;
      for (int i=0; i<nprimitives; i++) {
        bool skip = false;
        for (int j=0; j<nverticesperelement; j++)
          skip |= vertexArray[nverticesperelement*i + j].missing();
        if (skip)
          continue;
        
        numpri++;
        std::vector<uint32_t> pi(nverticesperelement,m1), ni(nverticesperelement,m1), ti(nverticesperelement,m1);
        Color avgcolor(0.0f,0.0f,0.0f,0.0f);
        for (int j=0; j<nverticesperelement; j++) {
          const int ip = nverticesperelement*i + j;
          if (usenormals)
            ni[j] = group.addNormal(normalArray[ip]*(switchorientation?-1:1));
          if (textured)
            ti[j] = group.addTexCoord(texCoordArray[ip]);
          pi[j] = group.addVertex(vertexArray[ip]);
          if (averc)
            avgcolor = avgcolor + material.colors.getColor(ip);
        }
        if (averc)
          avgcolor = (1.0f/nverticesperelement) * avgcolor;

        int jj[2][3];
        if (switchorientation) {
           jj[0][0]=0; jj[0][1]=2; jj[0][2]=1;
           jj[1][0]=2; jj[1][1]=0; jj[1][2]=3;
        } else {
           jj[0][0]=0; jj[0][1]=1; jj[0][2]=2;
           jj[1][0]=2; jj[1][1]=3; jj[1][2]=0;
        }
        for (int k=0; k<nverticesperelement-2; k++) {
          for (int l=0; l<3; l++) {
            const int ip = jj[k][l];
            if (usenormals)
              tess->triangulated_index.push_back(3*ni[ip]);
            if (textured)
              tess->triangulated_index.push_back(2*ti[ip]);
            tess->triangulated_index.push_back(3*pi[ip]);
            if (usevc) {
              const Color color = material.colors.getColor(ip);
              tessFace->rgba_vertices.push_back(color.getRedub());
              tessFace->rgba_vertices.push_back(color.getGreenub());
              tessFace->rgba_vertices.push_back(color.getBlueub());
              if (colorPerVertexHasAlpha)
              tessFace->rgba_vertices.push_back(color.getAlphaub());
            }
          }
          if (averc) {
            const RGBAColour avgcolour( avgcolor.getRedf(), avgcolor.getGreenf(), avgcolor.getBluef(), avgcolor.getAlphaf());
            if (material.lit) {
              const PRCmaterial mater(
                ambient,
                avgcolour,
                emission,
                specular,
                avgcolour.A,material.shininess
                );
              if (textured) {
                tessFace->line_attributes.push_back(prc.file->addTexturedMaterial(mater,1,&tex));
              }
              else
                tessFace->line_attributes.push_back(prc.file->addMaterial(mater));
            }
            else {
              const RGBAColour black(0,0,0,colour.A);
              const PRCmaterial mater(
                black,
                black,
                avgcolour,
                black,
                avgcolour.A,0.0
                );
              if (textured) {
                if (tex->mapping == PRC_TEXTURE_MAPPING_DIFFUSE)
                  tex->mapping = PRC_TEXTURE_MAPPING_EMISSION;
                tessFace->line_attributes.push_back(prc.file->addTexturedMaterial(mater,1,&tex));
              }
              else
                tessFace->line_attributes.push_back(prc.file->addMaterial(mater));
            }
          }
        }
      }

      tessFace->sizes_triangulated.push_back(nverticesperelement==3?numpri:2*numpri);

      tess->coordinates.resize(3*group.points.size());
      for(std::map<PRCVector3d,uint32_t>::const_iterator pPoint = group.points.begin(); pPoint != group.points.end(); pPoint++)
      {
        tess->coordinates[3*pPoint->second+0] = pPoint->first.x;
        tess->coordinates[3*pPoint->second+1] = pPoint->first.y;
        tess->coordinates[3*pPoint->second+2] = pPoint->first.z;
      }
      if (usenormals) {
        tess->normal_coordinate.resize(3*group.normals.size());
        for(std::map<PRCVector3d,uint32_t>::const_iterator pNormal = group.normals.begin(); pNormal != group.normals.end(); pNormal++)
        {
          tess->normal_coordinate[3*pNormal->second+0] = pNormal->first.x;
          tess->normal_coordinate[3*pNormal->second+1] = pNormal->first.y;
          tess->normal_coordinate[3*pNormal->second+2] = pNormal->first.z;
        }
      }
      if (textured) {
        tess->texture_coordinate.resize(2*group.texturecoords.size());
        for(std::map<PRCVector2d,uint32_t>::const_iterator pTC = group.texturecoords.begin(); pTC != group.texturecoords.end(); pTC++)
        {
          tess->texture_coordinate[2*pTC->second+0] = pTC->first.x;
          tess->texture_coordinate[2*pTC->second+1] = pTC->first.y;
        }
      }
   
      if (numpri==0) {
        delete tessFace;
        delete tess;
      }
      else {
        tess->addTessFace(tessFace);
        const uint32_t tess_index = prc.file->add3DTess(tess);
        prc.file->useMesh(tess_index, mat);
      }
   
      if (tex) {
        delete [] tex->data;
        tex->data = NULL;
        delete tex;
        tex = NULL;
      }

      prc.file->endgroup();
    }
    else if (material.front == material.LINE_FACE) {

      prc.file->begingroup("line",&grpopt,prc.transform);
      uint32_t gmat = m1;
      if (colorPerVertex ) {
          const RGBAColour black(0,0,0,1);
          gmat = prc.file->addLineMaterial(black,material.lwd);
      }
      else {
          const Color color = material.colors.getColor(0);
          const RGBAColour colour(color.getRedf(), color.getGreenf(), color.getBluef(), color.getAlphaf());
          gmat = prc.file->addLineMaterial(colour,material.lwd);
      }
      for (int i=0; i<nprimitives; i++) {
        bool skip = false;
        for (int j=0; j<nverticesperelement; j++)
          skip |= vertexArray[nverticesperelement*i + j].missing();
        if (!skip) {
          vector<uint32_t> p(nverticesperelement), c(nverticesperelement);
          for (int j=0; j<nverticesperelement; j++) {
            p[j] = group.addVertex(vertexArray[nverticesperelement*i + j]);
            if (colorPerVertex) {
              const Color c0 = material.colors.getColor(nverticesperelement*i + j);
              const Color c1 = material.colors.getColor(nverticesperelement*i + ((j+1)%nverticesperelement));
              const Color c05 = 0.5 * (c0 + c1);
              c[j] = group.addColor(c05);
            }
            else
              c[j] = m1;
          }

          if (nverticesperelement==3)
            group.addLineTriangle(p[0], c[0], p[1], c[1], p[2], c[2]);

          if (nverticesperelement==4)
            group.addLineQuad(p[0], c[0], p[1], c[1], p[2], c[2], p[3], c[3]);
        }
      }
      if (!group.linetriangles.empty()) {
        const uint32_t nI = (uint32_t)group.linetriangles.size();
        const uint32_t nP = (uint32_t)group.points.size();
        double (*P)[3] = new double[nP][3];
        group.writePoints(P);
        uint32_t (*PI)[3] = new uint32_t[nI][3];
        for(uint32_t k = 0; k<nI; k++)
        {
                PI[k][0] = group.linetriangles[k].pi[0];
                PI[k][1] = group.linetriangles[k].pi[1];
                PI[k][2] = group.linetriangles[k].pi[2];
        }
        if (colorPerVertex ) {
          const uint32_t nC = (uint32_t)group.colours.size();
          RGBAColour (*C) = new RGBAColour[nC];
          group.writeColours(C);
          uint32_t (*CI)[3] = new uint32_t[nI][3];
          for(uint32_t k = 0; k<nI; k++)
          {
            CI[k][0] = group.linetriangles[k].ci[0];
            CI[k][1] = group.linetriangles[k].ci[1];
            CI[k][2] = group.linetriangles[k].ci[2];
          }
          const uint32_t tess_index = prc.file->createLineTriangles(nP, P, nI, PI, true, nC, C, CI, false);
          prc.file->useLines(tess_index, gmat);
          delete [] CI;
          delete [] C;
        }
        else {
          const uint32_t tess_index = prc.file->createLineTriangles(nP, P, nI, PI, true, 0, NULL, NULL, false);
          prc.file->useLines(tess_index, gmat);
        }
        delete [] PI;
        delete [] P;
      }
      if (!group.linequads.empty()) {
        const uint32_t nI = (uint32_t)group.linequads.size();
        const uint32_t nP = (uint32_t)group.points.size();
        double (*P)[3] = new double[nP][3];
        group.writePoints(P);
        uint32_t (*PI)[4] = new uint32_t[nI][4];
        for(uint32_t k = 0; k<nI; k++)
        {
                PI[k][0] = group.linequads[k].pi[0];
                PI[k][1] = group.linequads[k].pi[1];
                PI[k][2] = group.linequads[k].pi[2];
                PI[k][3] = group.linequads[k].pi[3];
        }
        if (colorPerVertex ) {
          const uint32_t nC = (uint32_t)group.colours.size();
          RGBAColour (*C) = new RGBAColour[nC];
          group.writeColours(C);
          uint32_t (*CI)[4] = new uint32_t[nI][4];
          for(uint32_t k = 0; k<nI; k++)
          {
            CI[k][0] = group.linequads[k].ci[0];
            CI[k][1] = group.linequads[k].ci[1];
            CI[k][2] = group.linequads[k].ci[2];
            CI[k][3] = group.linequads[k].ci[3];
          }
          const uint32_t tess_index = prc.file->createLineQuads(nP, P, nI, PI, true, nC, C, CI, false);
          prc.file->useLines(tess_index, gmat);
          delete [] CI;
          delete [] C;
        }
        else {
          const uint32_t tess_index = prc.file->createLineQuads(nP, P, nI, PI, true, 0, NULL, NULL, false);
          prc.file->useLines(tess_index, gmat);
        }
        delete [] PI;
        delete [] P;
      }
      prc.file->endgroup();
    }
    else if (material.front == material.POINT_FACE) {

      prc.file->begingroup("point",&grpopt,prc.transform);
      const Color color = material.colors.getColor(0);
      for (int i=0; i<nprimitives; i++) {
        bool skip = false;
        for (int j=0; j<nverticesperelement; j++)
          skip |= vertexArray[nverticesperelement*i + j].missing();
        if (!skip) {
          for (int j=0; j<nverticesperelement; j++) {
            int index = nverticesperelement*i + j;
            if (colorPerVertex)
              group.addDot(vertexArray[index],material.colors.getColor(index));
            else
              group.addDot(vertexArray[index],color);
          }
        }
      }
      if (!group.dots.empty()) {
        for(std::set<prcdot>::const_iterator pDot = group.dots.begin(); pDot != group.dots.end(); pDot++)
          prc.file->addPoint(pDot->p.x, pDot->p.y, pDot->p.z, pDot->c, material.size);
      }
      prc.file->endgroup();
    }
  }
}
