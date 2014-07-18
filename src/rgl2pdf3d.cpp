
#include "R.h"
#include <Rcpp.h>
#include "scene.h"
#include <string>
#include <algorithm>

using namespace Rcpp;

#define PRINTTYPEOF( somesexp ) \
     switch (TYPEOF(somesexp)) { \
    case NILSXP:       Rprintf("%s\n","NILSXP");     break; \
    case SYMSXP:       Rprintf("%s\n","SYMSXP");     break; \
    case LISTSXP:      Rprintf("%s\n","LISTSXP");    break; \
    case CLOSXP:       Rprintf("%s\n","CLOSXP");     break; \
    case ENVSXP:       Rprintf("%s\n","ENVSXP");     break; \
    case PROMSXP:      Rprintf("%s\n","PROMSXP");    break; \
    case LANGSXP:      Rprintf("%s\n","LANGSXP");    break; \
    case SPECIALSXP:   Rprintf("%s\n","SPECIALSXP"); break; \
    case BUILTINSXP:   Rprintf("%s\n","BUILTINSXP"); break; \
    case CHARSXP:      Rprintf("%s\n","CHARSXP");    break; \
    case LGLSXP:       Rprintf("%s\n","LGLSXP");     break; \
    case INTSXP:       Rprintf("%s\n","INTSXP");     break; \
    case REALSXP:      Rprintf("%s\n","REALSXP");    break; \
    case CPLXSXP:      Rprintf("%s\n","CPLXSXP");    break; \
    case STRSXP:       Rprintf("%s\n","STRSXP");     break; \
    case DOTSXP:       Rprintf("%s\n","DOTSXP");     break; \
    case ANYSXP:       Rprintf("%s\n","ANYSXP");     break; \
    case VECSXP:       Rprintf("%s\n","VECSXP");     break; \
    case EXPRSXP:      Rprintf("%s\n","EXPRSXP");    break; \
    case BCODESXP:     Rprintf("%s\n","BCODESXP");   break; \
    case EXTPTRSXP:    Rprintf("%s\n","EXTPTRSXP");  break; \
    case WEAKREFSXP:   Rprintf("%s\n","WEAKREFSXP"); break; \
    case S4SXP:        Rprintf("%s\n","S4SXP");      break; \
    case RAWSXP:       Rprintf("%s\n","RAWSXP");     break; \
    default:           Rprintf("%s\n","<unknown>");    \
    } 

static Material::PolygonMode char2polymode(const char* mode)
{
  map<string,Material::PolygonMode> modes;
  modes["filled"] = Material::FILL_FACE;
  modes["lines"]  = Material::LINE_FACE;
  modes["points"] = Material::POINT_FACE;
  modes["culled"] = Material::CULL_FACE;
  map<string,Material::PolygonMode>::const_iterator it = modes.find(mode);
  if (it == modes.end() )
    return Material::FILL_FACE;
  else
    return it->second;
}
static const char* polymode2char(Material::PolygonMode mode)
{
  map<Material::PolygonMode,const char*> modes;
  modes[Material::FILL_FACE]  = "filled";
  modes[Material::LINE_FACE]  = "lines";
  modes[Material::POINT_FACE] = "points";
  modes[Material::CULL_FACE]  = "culled";
  map<Material::PolygonMode,const char*>::const_iterator it = modes.find(mode);
  if (it == modes.end() )
    return "filled";
  else
    return it->second;
}

static Texture::Type char2textype(const char* type)
{
  map<string,Texture::Type> types;
  types["alpha"]           = Texture::ALPHA;
  types["luminance"]       = Texture::LUMINANCE;
  types["luminance.alpha"] = Texture::LUMINANCE_ALPHA;
  types["rgb"]             = Texture::RGB;
  types["rgba"]            = Texture::RGBA;
  map<string,Texture::Type>::const_iterator it = types.find(type);
  if (it == types.end() )
    return Texture::RGB;
  else
    return it->second;
}
static const char* textype2char(Texture::Type type)
{
  map<Texture::Type, const char*> types;
  types[Texture::ALPHA]           = "alpha";
  types[Texture::LUMINANCE]       = "luminance";
  types[Texture::LUMINANCE_ALPHA] = "luminance.alpha";
  types[Texture::RGB]             = "rgb";
  types[Texture::RGBA]            = "rgba";
  map<Texture::Type, const char*>::const_iterator it = types.find(type);
  if (it == types.end() )
    return "rgb";
  else
    return it->second;
}

static unsigned int char2minfiltertype(const char* type)
{
  map<string,unsigned int> types;
  types["nearest"]                = 0;
  types["linear"]                 = 1;
  types["nearest.mipmap.nearest"] = 2;
  types["nearest.mipmap.linear"]  = 3;
  types["linear.mipmap.nearest"]  = 4;
  types["linear.mipmap.linear"]   = 5;
  map<string,unsigned int>::const_iterator it = types.find(type);
  if (it == types.end() )
    return 1;
  else
    return it->second;
}
static const char* minfiltertype2char(unsigned int type)
{
  map<unsigned int,const char*> types;
  types[0] = "nearest";
  types[1] = "linear";
  types[2] = "nearest.mipmap.nearest";
  types[3] = "nearest.mipmap.linear";
  types[4] = "linear.mipmap.nearest";
  types[5] = "linear.mipmap.linear";
  map<unsigned int,const char*>::const_iterator it = types.find(type);
  if (it == types.end() )
    return "linear";
  else
    return it->second;
}

static unsigned int char2magfiltertype(const char* type)
{
  map<string,unsigned int> types;
  types["nearest"]                = 0;
  types["linear"]                 = 1;
  map<string,unsigned int>::const_iterator it = types.find(type);
  if (it == types.end() )
    return 1;
  else
    return it->second;
}
static const char* magfiltertype2char(unsigned int type)
{
  map<unsigned int,const char*> types;
  types[0] = "nearest";
  types[1] = "linear";
  map<unsigned int,const char*>::const_iterator it = types.find(type);
  if (it == types.end() )
    return "linear";
  else
    return it->second;
}

static int char2depthtest(const char* test)
{
  map<string,int> tests;
  tests["never"]    = 0;
  tests["less"]     = 1;
  tests["equal"]    = 2;
  tests["lequal"]   = 3;
  tests["greater"]  = 4;
  tests["notequal"] = 5;
  tests["gequal"]   = 6;
  tests["always"]   = 7;
  map<string,int>::const_iterator it = tests.find(test);
  if (it == tests.end() )
    return 1;
  else
    return it->second;
}
static const char* depthtest2char(int test)
{
  map<int,const char*> tests;
  tests[0] = "never";
  tests[1] = "less";
  tests[2] = "equal";
  tests[3] = "lequal";
  tests[4] = "greater";
  tests[5] = "notequal";
  tests[6] = "gequal";
  tests[7] = "always";
  map<int,const char*>::const_iterator it = tests.find(test);
  if (it == tests.end() )
    return "less";
  else
    return it->second;
}
/*
static void RprintTexture( const Texture* tex )
{
#define RPRBOOL(bool_expr) Rprintf("%s = %s\n", #bool_expr, (bool_expr) ? "TRUE" : "FALSE")
#define RPRTEXT(VAR, FUNC) Rprintf(#VAR " = %s\n", FUNC(VAR)) 

  Texture::Type type;
  bool mipmap, envmap;
  unsigned int minfilter, magfilter;
  char filename[1024];

  tex->getParameters(&type, &mipmap, &minfilter, &magfilter, &envmap, 1023, filename);

  Rprintf("filename = %s\n", filename);
  RPRTEXT(type, textype2char);
  RPRBOOL(mipmap);
  
  RPRTEXT(minfilter, minfiltertype2char);
  RPRTEXT(magfilter, magfiltertype2char);
  
  RPRBOOL(envmap);

#undef RPRBOOL
#undef RPRTEXT
}
*/
static void RprintMaterial( const Material& mat )
{
#define RPRBOOL(bool_expr) Rprintf("%s = %s\n", #bool_expr, (mat.bool_expr) ? "TRUE" : "FALSE")
#define RPRDOUBLE(val) Rprintf("%s = %f\n", #val, mat.val)
#define RPRCOLOR(col) Rprintf("%s = %02X%02X%02X\n", #col, mat.col.getRedub(), mat.col.getGreenub(), mat.col.getBlueub())
#define RPRTEXT(VAR, FUNC) Rprintf(#VAR " = %s\n", FUNC(mat.VAR)) 

    Rprintf("colors %u\n",mat.colors.getLength());
    for( unsigned int i = 0; i < mat.colors.getLength(); i++) {
      const Color col = mat.colors.getColor(i);
      Rprintf("%02X%02X%02X%02X\n",col.getRedub(),col.getGreenub(),col.getBlueub(),col.getAlphaub());
    }

    RPRBOOL(lit);

    RPRCOLOR(ambient);
    RPRCOLOR(specular);
    RPRCOLOR(emission);

    RPRDOUBLE(shininess);
    RPRBOOL(smooth);

    RPRTEXT(front, polymode2char);
    RPRTEXT(back, polymode2char);

    RPRDOUBLE(lwd);
    RPRDOUBLE(size);
    RPRBOOL(fog);
    RPRBOOL(point_antialias);
    RPRBOOL(line_antialias);

    RPRBOOL(depth_mask);

    RPRTEXT(depth_test, depthtest2char);

#undef RPRBOOL
#undef RPRDOUBLE
#undef RPRCOLOR
#undef RPRTEXT

    if (mat.texture)
    {
#define RPRBOOL(bool_expr) Rprintf("%s = %s\n", #bool_expr, (bool_expr) ? "TRUE" : "FALSE")
#define RPRTEXT(VAR, FUNC) Rprintf(#VAR " = %s\n", FUNC(VAR)) 

      Rprintf("texture = ");

      Texture::Type type;
      bool mipmap, envmap;
      unsigned int minfilter, magfilter;
      char filename[1024];

      mat.texture->getParameters(&type, &mipmap, &minfilter, &magfilter, &envmap, 1023, filename);

      Rprintf("filename = %s\n", filename);
      RPRTEXT(type, textype2char);
      RPRBOOL(mipmap);
  
      RPRTEXT(minfilter, minfiltertype2char);
      RPRTEXT(magfilter, magfiltertype2char);
      
      RPRBOOL(envmap);
    
#undef RPRBOOL
#undef RPRTEXT
    }
    else
      Rprintf("texture = NULL\n");

}

static void getMaterial(const List& lm, Material& mat)
{
#define GETBOOL(VAR)       { mat.VAR = as<bool>(lm[#VAR]); }
#define GETCOLOR(COL)      { mat.COL = Color(CHAR(as<const CharacterVector>(lm[#COL])[0])); }
#define GETDOUBLE(VAR)     { mat.VAR = as<double>(lm[#VAR]); }
#define GETTEXT(VAR, FUNC) { mat.VAR = FUNC(as<CharacterVector>(lm[#VAR])[0]); }

  {
    CharacterVector lmc = lm["color"];
    const int ncolor = lmc.size();
    vector<char*> colors(ncolor);
    for( int i = 0; i < ncolor; i++ )
      colors[i] = (char*)lmc[i];
    NumericVector   lmn = lm["alpha"];
    const int nalpha = lmn.size();
    double* alpha = lmn.begin();
    mat.colors.set( ncolor, &colors.front(), nalpha, alpha);
  }

  GETBOOL(lit);

  GETCOLOR(ambient);
  GETCOLOR(specular);
  GETCOLOR(emission);

  GETDOUBLE(shininess);
  GETBOOL(smooth);

  GETTEXT(front, char2polymode);
  GETTEXT(back, char2polymode);

  GETDOUBLE(lwd);
  GETDOUBLE(size);
  GETBOOL(fog);
  GETBOOL(point_antialias);
  GETBOOL(line_antialias);
  GETBOOL(depth_mask);

  GETTEXT(depth_test, char2depthtest);

#undef GETBOOL
#undef GETCOLOR
#undef GETDOUBLE
#undef GETTEXT

// #define GETBOOL(VAR)       { LogicalVector   lml = lm["tex" #VAR]; VAR = lml[0]; }
// #define GETTEXT(VAR, FUNC) { CharacterVector lmc = lm["tex" #VAR]; VAR = FUNC(lmc[0]); }
#define GETBOOL(VAR)       { VAR = as<bool>(lm["tex" #VAR]); }
#define GETTEXT(VAR, FUNC) { VAR = FUNC(as<CharacterVector>(lm["tex" #VAR])[0]); }
  Texture::Type type;
  GETTEXT(type, char2textype);
 
  bool mipmap;
  GETBOOL(mipmap);
 
  unsigned int minfilter;
  GETTEXT(minfilter, char2minfiltertype);
  unsigned int magfilter;
  GETTEXT(magfilter, char2magfiltertype);
 
  bool envmap;
  GETBOOL(envmap);

  mat.alphablend  = false;

  mat.texture = NULL;
  if (!Rf_isNull(lm["texture"]))
  {
    const char* ture;
    GETTEXT(ture, CHAR);
    if ( strlen(ture) > 0 ) {
      mat.texture = new Texture(ture, type, mipmap, minfilter, magfilter, envmap);
      mat.alphablend = mat.alphablend || mat.texture->hasAlpha();
    }
  }

  mat.alphablend  = mat.alphablend || mat.colors.hasAlpha();

#undef GETBOOL
#undef GETTEXT

// RprintMaterial(mat);
}

static void getMaterialIncremental(const List& lshape, Material& mat)
{
  const List lm(as<List>(lshape["material"]));
  if ( lshape.containsElementNamed("colors") ) {
    const NumericMatrix cols(as<NumericMatrix>(lshape["colors"]));
    const int ncolor = cols.nrow();
    vector<int> colors(3*ncolor);
    const int nalpha = ncolor;
    vector<double> alpha(nalpha);
    for(int i=0; i<ncolor; i++) {
      colors[3*i+0] = (u8) ( clamp( (float) cols(i,0), 0.0f, 1.0f) * 255.0f );
      colors[3*i+1] = (u8) ( clamp( (float) cols(i,1), 0.0f, 1.0f) * 255.0f );
      colors[3*i+2] = (u8) ( clamp( (float) cols(i,2), 0.0f, 1.0f) * 255.0f );
      alpha[i]      = cols(i,3);
    }
    mat.colors.set( ncolor, &colors.front(), nalpha, &alpha.front());
  }
  else
  {
#define GETBOOL(VAR)       { if (lm.containsElementNamed(#VAR)) mat.VAR = as<bool>(lm[#VAR]); }
#define GETCOLOR(COL)      { if (lm.containsElementNamed(#COL)) mat.COL = Color(CHAR(as<const CharacterVector>(lm[#COL])[0])); }
#define GETDOUBLE(VAR)     { if (lm.containsElementNamed(#VAR)) mat.VAR = as<double>(lm[#VAR]); }
#define GETTEXT(VAR, FUNC) { if (lm.containsElementNamed(#VAR)) mat.VAR = FUNC(as<CharacterVector>(lm[#VAR])[0]); }

#define GETOLDCOLORS \
  const int ncolor = mat.colors.getLength(); \
  vector<int>  colors(3*ncolor); \
  for(int i=0; i<ncolor; i++) { \
    const Color c = mat.colors.getColor(i); \
    colors[3*i+0] = c.getRedub(); \
    colors[3*i+1] = c.getGreenub(); \
    colors[3*i+2] = c.getBlueub(); \
  }

#define GETOLDALPHAS \
  const int nalpha = mat.colors.getLength(); \
  vector<double> alpha(nalpha); \
  for(int i=0; i<ncolor; i++) { \
    const Color c = mat.colors.getColor(i); \
    alpha[i] = c.getAlphaf(); \
  }

#define GETCOLORS \
  const CharacterVector lmc = lm["color"]; \
  const int ncolor = lmc.size(); \
  vector<char*> colors(ncolor); \
  for( int i = 0; i < ncolor; i++ ) \
    colors[i] = (char*)lmc[i];

#define GETALPHAS \
  const NumericVector   lmn = lm["alpha"]; \
  const int nalpha = lmn.size(); \
  double *alpha = lmn.begin();
  
  const bool hascolor = lm.containsElementNamed("color");
  const bool hasalpha = lm.containsElementNamed("alpha");

  if (hascolor || hasalpha) {
    {
      if (hascolor && hasalpha) {
        GETCOLORS
        GETALPHAS
        mat.colors.set( ncolor, &colors.front(), nalpha, alpha);
      } 
      else if (hascolor) {
        GETCOLORS
        GETOLDALPHAS
        mat.colors.set( ncolor, &colors.front(), nalpha, &alpha.front());
      } 
      else if (hasalpha) {
        GETOLDCOLORS
        GETALPHAS
        mat.colors.set( ncolor, &colors.front(), nalpha, alpha);
      } 
    } 
  } 

  } 

  mat.alphablend  = mat.colors.hasAlpha();
#undef GETCOLORS
#undef GETALPHAS
#undef GETOLDCOLORS
#undef GETOLDALPHAS

// (u8) ( clamp( (float) in_alpha[i%in_nalpha], 0.0f, 1.0f) * 255.0f )
  GETBOOL(lit);

  GETCOLOR(ambient);
  GETCOLOR(specular);
  GETCOLOR(emission);

  GETDOUBLE(shininess);
  GETBOOL(smooth);

  GETTEXT(front, char2polymode);
  GETTEXT(back, char2polymode);

  GETDOUBLE(lwd);
  GETDOUBLE(size);
  GETBOOL(fog);
  GETBOOL(point_antialias);
  GETBOOL(line_antialias);
  GETBOOL(depth_mask);

  GETTEXT(depth_test, char2depthtest);

#undef GETBOOL
#undef GETCOLOR
#undef GETDOUBLE
#undef GETTEXT

  if (lm.containsElementNamed("texture") ||
      lm.containsElementNamed("textype") ||
      lm.containsElementNamed("texmipmap") ||
      lm.containsElementNamed("texenvmap") ||
      lm.containsElementNamed("texminfilter") ||
      lm.containsElementNamed("texmagfilter")) {
#define GETBOOL(VAR)       { if (lm.containsElementNamed("tex" #VAR)) VAR = as<bool>(lm["tex" #VAR]); }
#define GETTEXT(VAR, FUNC) { if (lm.containsElementNamed("tex" #VAR)) VAR = FUNC(as<CharacterVector>(lm["tex" #VAR])[0]); }
    Texture::Type type = Texture::RGB;
    bool mipmap = false, envmap = false;
    unsigned int minfilter = 1, magfilter = 1;
    char filename[1024];
    const char *ture = NULL;
   
    if (mat.texture) {
      mat.texture->getParameters(&type, &mipmap, &minfilter, &magfilter, &envmap, 1023, filename);
      ture = filename;
    }
   
    GETTEXT(type, char2textype);
    GETBOOL(mipmap);
    GETTEXT(minfilter, char2minfiltertype);
    GETTEXT(magfilter, char2magfiltertype);
    GETBOOL(envmap);
   
    if (lm.containsElementNamed("texture")) {
      if (Rf_isNull(lm["texture"]))
        mat.texture = NULL;
      else
      {
        GETTEXT(ture, CHAR);
        if ( strlen(ture) > 0 ) {
          mat.texture = new Texture(ture, type, mipmap, minfilter, magfilter, envmap);
          mat.alphablend = mat.alphablend || mat.texture->hasAlpha();
        }
        else
          mat.texture = NULL;
      }
    }
    else {
      mat.texture = new Texture(ture, type, mipmap, minfilter, magfilter, envmap);
      mat.alphablend = mat.alphablend || mat.texture->hasAlpha();
    }
  }

#undef GETBOOL
#undef GETTEXT

// RprintMaterial(mat);
}

static void RprintNumericVector(const NumericVector& v)
{
    Rprintf("vector size %d\n",v.size());
    for( NumericVector::const_iterator it = v.begin(); it != v.end(); ++it ) {
     Rprintf("%td %f\n",it-v.begin(),*it);
    }
}
static void RprintIntegerVector(const IntegerVector& v)
{
    Rprintf("vector size %d\n",v.size());
    for( IntegerVector::const_iterator it = v.begin(); it != v.end(); ++it ) {
     Rprintf("%td %d\n",it-v.begin(),*it);
    }
}
static void RprintLogicalVector(const LogicalVector& v)
{
    Rprintf("vector size %d\n",v.size());
    for( LogicalVector::const_iterator it = v.begin(); it != v.end(); ++it ) {
     Rprintf("%td %s\n",it-v.begin(),*it?"TRUE":"FALSE");
    }
}
static void RprintCharacterVector(const CharacterVector& v)
{
    Rprintf("vector size %d\n",v.size());
    for( CharacterVector::const_iterator it = v.begin(); it != v.end(); ++it ) {
     Rprintf("%td %s\n",it-v.begin(),CHAR(*it));
    }
}
static void RprintList(const List& l)
{
//  LogicalVector   ll;
//  NumericVector   ln;
    Rprintf("list size %d\n",l.size());
    PRINTTYPEOF(l.attr("names"));
    CharacterVector lc;
    CharacterVector::iterator itc;
    bool names = false;
    if (TYPEOF(l.attr("names")) == STRSXP) {
      names = true;
      lc = l.names();
      itc = lc.begin();
      Rprintf("names lenght %d\n",Rf_length(l.attr("names")));
      Rprintf("lc size %d\n",lc.size());
    }
    for( List::const_iterator it = l.begin(); it != l.end(); ++it ) {
     if (names)
       Rprintf("%td %s %d\n",it-l.begin(),CHAR(*itc),Rf_length(*it));
     else
       Rprintf("%td %d\n",it-l.begin(),Rf_length(*it));
     PRINTTYPEOF(*it);
     switch (TYPEOF(*it)) {
       case NILSXP:       Rprintf("%s\n","NILSXP");     break;
//       case SYMSXP:       Rprintf("%s\n","SYMSXP");     break;
       case VECSXP:       RprintList(as<List>(*it));     break;
//       case CHARSXP:      Rprintf("%s\n","CHARSXP");    break;
       case LGLSXP:       RprintLogicalVector(as<LogicalVector>(*it));     break;
//       case INTSXP:       Rprintf("%s\n","INTSXP");     break;
       case INTSXP:       RprintIntegerVector(as<IntegerVector>(*it));    break;
       case REALSXP:      RprintNumericVector(as<NumericVector>(*it));    break;
//       case CPLXSXP:      Rprintf("%s\n","CPLXSXP");    break;
       case STRSXP:       RprintCharacterVector(as<CharacterVector>(*it));    break;
//       case DOTSXP:       Rprintf("%s\n","DOTSXP");     break;
     }
     if (names)
       ++itc;
    }
}

static const char* glprimitivetype2char(int type)
{
  map<int,const char*> types;
  types[GL_POINTS] = "points";
  types[GL_LINES] = "lines";
  types[GL_LINE_STRIP] = "linestrip";
  types[GL_TRIANGLES] = "triangles";
  types[GL_QUADS] = "quads";
  map<int,const char*>::const_iterator it = types.find(type);
  if (it == types.end() )
    return "unknown";
  else
    return it->second;
}

void PrimitiveSet::Rprint()
{
  Rprintf("PrimitiveSet\n type %s nverticesperelement %d nprimitives %d nvertices %d hasmissing %d\n", 
    glprimitivetype2char(type), nverticesperelement, nprimitives, nvertices, hasmissing);    
  Rprintf("vertices\n");
  for(int i=0; i<nvertices; i++) {
    const Vertex &v = vertexArray[i];
    if (v.missing())
      Rprintf("%d NA\n",i);
    else
      Rprintf("%d %f %f %f\n", i, v.x, v.y, v.z);
  }
  Rprintf("material\n");
  RprintMaterial(material);
}

void FaceSet::Rprint()
{
  Rprintf("FaceSet\n type %s nverticesperelement %d nprimitives %d nvertices %d hasmissing %d\n", 
    glprimitivetype2char(type), nverticesperelement, nprimitives, nvertices, hasmissing);    
  Rprintf("vertices\n");
  for (int i=0;i<nprimitives;i++)
  {
    Rprintf("%d ",i);
    for (int j=0;j<nverticesperelement;++j) {
      const Vertex &v = vertexArray[i*nverticesperelement+j];
      if (v.missing())
        Rprintf("NA ");
      else
        Rprintf("%f,%f,%f ", v.x, v.y, v.z);
    }
    Rprintf("\n");
  }

  if (material.lit) {
    Rprintf("normals\n");
    for (int i=0;i<nprimitives;i++)
    {
      Rprintf("%d ",i);
      for (int j=0;j<nverticesperelement;++j) {
        const Vertex &v = normalArray[i*nverticesperelement+j];
        if (v.missing())
          Rprintf("NA ");
        else
          Rprintf("%f,%f,%f ", v.x, v.y, v.z);
      }
      Rprintf("\n");
    }
  }

  if (texCoordArray.size()>0) {
    Rprintf("texcoords\n");
    for (int i=0;i<nprimitives;i++)
    {
      Rprintf("%d ",i);
      for (int j=0;j<nverticesperelement;++j) {
        TexCoord const &v = texCoordArray[i*nverticesperelement+j];
        Rprintf("%f,%f ", v.s, v.t);
      }
      Rprintf("\n");
    }
  }

  Rprintf("material\n");
  RprintMaterial(material);
}

void Surface::Rprint()
{
  Rprintf("Surface\n nx %d nz %d coords %d %d %d orientation %d user_normals %d user_textures %d use_normal %d use_texcoord %d\n", 
           nx, nz, coords[0], coords[1], coords[2], orientation, user_normals, user_textures, use_normal, use_texcoord);

  Rprintf("vertices\n");
  for(int iz=0;iz<nz;iz++) {
    Rprintf("%d ",iz);
    for(int ix=0;ix<nx;ix++) {     
      const Vertex &v = vertexArray[iz*nx+ix];
      if (v.missing())
        Rprintf("NA ");
      else
        Rprintf("%f,%f,%f ", v.x, v.y, v.z);
    }
    Rprintf("\n");
  }

  if (user_normals) {
    Rprintf("normals\n");
    for(int iz=0;iz<nz;iz++) {
      Rprintf("%d ",iz);
      for(int ix=0;ix<nx;ix++) {     
        const Vertex &v = normalArray[iz*nx+ix];
        if (v.missing())
          Rprintf("NA ");
        else
          Rprintf("%f,%f,%f ", v.x, v.y, v.z);
      }
      Rprintf("\n");
    }
  }

  if (use_texcoord) {
    Rprintf("texcoords\n");
    for(int iz=0;iz<nz;iz++) {
      Rprintf("%d ",iz);
      for(int ix=0;ix<nx;ix++) {
        const int iy = iz*nx+ix;
        Rprintf("%f,%f ", texCoordArray[iy].s, texCoordArray[iy].t);
      }
      Rprintf("\n");
    }
  }

  Rprintf("material\n");
  RprintMaterial(material);
}

void SphereSet::Rprint()
{
  Rprintf("SphereSet\n ncenter %d nradius %d\n", center.size(), radius.size());

  Rprintf("center\n");
  for(int i=0;i<center.size();i++) {
    const Vertex &v = center.get(i);
    if (v.missing())
      Rprintf("NA \n");
    else
      Rprintf("%f,%f,%f \n", v.x, v.y, v.z);
  }

  Rprintf("radius\n");
  for(int i=0;i<radius.size();i++) {
    Rprintf("%f \n", radius.get(i));
  }

//  Rprintf("material\n");
//  RprintMaterial(material);
}

void TextSet::Rprint()
{
  Rprintf("TextSet\n ntext %d nfonts %d\n", textArray.size(), fonts.size());

  Rprintf("center\n");
  for(int i=0;i<textArray.size();i++) {
    const Vertex &v = vertexArray[i];
    if (v.missing())
      Rprintf("NA \n");
    else
      Rprintf("%f,%f,%f \n", v.x, v.y, v.z);
  }

  Rprintf("text\n");
  for(int i=0;i<textArray.size();i++) {
    Rprintf("%s \n", textArray[i].text);
  }

  Rprintf("cex\n");
  for(size_t i=0;i<fonts.size();i++) {
    Rprintf("%f \n", fonts[i]);
  }

//  Rprintf("material\n");
//  RprintMaterial(material);
}

void SpriteSet::Rprint()
{
  Rprintf("SpriteSet\n nvertex %d nsize %d\n", vertex.size(), size.size());

  Rprintf("vertex\n");
  for(int i=0;i<vertex.size();i++) {
    const Vertex &v = vertex.get(i);
    if (v.missing())
      Rprintf("NA \n");
    else
      Rprintf("%f,%f,%f \n", v.x, v.y, v.z);
  }

  Rprintf("size\n");
  for(int i=0;i<size.size();i++) {
    Rprintf("%f \n", size.get(i));
  }

//  Rprintf("material\n");
//  RprintMaterial(material);
}

static Shape *doShape(List::const_iterator it, Material& defaultMaterial, bool ignoreExtent)
{
      const List lobject(as<List>(*it));
      const string type = lobject["type"];
//    Rprintf("type %s\n",type.c_str());
      if (!( (type == "points" || type == "lines" || type == "linestrip" || type == "triangles" || type == "quads" || type == "abclines" || type == "planes")
           || (type == "surface") 
           || (type == "spheres")
           || (type == "text")
           || (type == "sprites"))) 
        return NULL;
      
//    RprintList(lobject);
      Material currentMaterial(defaultMaterial);
      getMaterialIncremental(lobject, currentMaterial);
      Shape* shape = NULL;
      if (type == "points" || type == "lines" || type == "linestrip" || type == "triangles" || type == "quads" || type == "abclines" || type == "planes") {
        int nvertices = 0;
        double* vertices = NULL;
        if (lobject.containsElementNamed("vertices")) {
           const NumericMatrix verts(as<NumericMatrix>(lobject["vertices"]));
           nvertices = verts.nrow();
           vertices = new double[3*nvertices];
           for(int i=0; i<nvertices; i++) {
             vertices[3*i+0] = verts(i,0);
             vertices[3*i+1] = verts(i,1);
             vertices[3*i+2] = verts(i,2);
           }
        }
   
        double* normals = NULL;
        if (lobject.containsElementNamed("normals")) {
           const NumericVector normalsV(as<NumericVector>(lobject["normals"]));
           normals = new double[3*nvertices];
           for(int i=0; i<nvertices; i++) {
             normals[3*i+0] = normalsV[nvertices*0+i];
             normals[3*i+1] = normalsV[nvertices*1+i];
             normals[3*i+2] = normalsV[nvertices*2+i];
           }
        }
        const bool useNormals = normals != NULL;
   
        double* texcoords = NULL;
        if (lobject.containsElementNamed("texcoords")) {
           const NumericVector texcoordsV(as<NumericVector>(lobject["texcoords"]));
           texcoords = new double[2*nvertices];
           for(int i=0; i<nvertices; i++) {
             texcoords[2*i+0] = texcoordsV[nvertices*0+i];
             texcoords[2*i+1] = texcoordsV[nvertices*1+i];
           }
        }
        const bool useTexcoords = texcoords != NULL;
   
//      Rprintf("vertices\n");
//      for (int i=0; i<nvertices; i++)
//        Rprintf("%d %f %f %f\n", i, vertices[3*i+0], vertices[3*i+1], vertices[3*i+2]);
//      if (useNormals) {
//        Rprintf("normals\n");
//        for (int i=0; i<nvertices; i++)
//          Rprintf("%d %f %f %f\n", i, normals[3*i+0], normals[3*i+1], normals[3*i+2]);
//      }
//      if (useTexcoords) {
//        Rprintf("texcoords\n");
//        for (int i=0; i<nvertices; i++)
//          Rprintf("%d %f %f\n", i, texcoords[2*i+0], texcoords[2*i+1]);
//      }
   
        if (type == "points")
          shape = new PointSet     ( currentMaterial, nvertices, vertices, ignoreExtent);
        if (type == "lines")
          shape = new LineSet      ( currentMaterial, nvertices, vertices, ignoreExtent);
        if (type == "abclines")
          shape = new LineSet      ( currentMaterial, nvertices, vertices, true, false);
        if (type == "linestrip")
          shape = new LineStripSet ( currentMaterial, nvertices, vertices, ignoreExtent);
        if (type == "triangles")
          shape = new TriangleSet  ( currentMaterial, nvertices, vertices, normals,
                                   texcoords, ignoreExtent, useNormals, useTexcoords);
        if (type == "quads")
          shape = new QuadSet      ( currentMaterial, nvertices, vertices, normals,
                                   texcoords, ignoreExtent, useNormals, useTexcoords);
        if (type == "planes")
          shape = new TriangleSet  ( currentMaterial, nvertices, vertices, normals,
                                   texcoords, true, useNormals, useTexcoords);
        delete [] texcoords;
        delete [] normals;
        delete [] vertices;
      }
      if (type == "surface") {
        const NumericVector dim(as<NumericVector>(lobject["dim"]));
        const int nx = dim[0], ny = dim[1];
        const int nz = nx*ny;

        const NumericVector vertices(as<NumericVector>(lobject["vertices"]));
        double *x = vertices.begin()     ;
        double *y = vertices.begin()+1*nz;
        double *z = vertices.begin()+2*nz;

        double *normals_x = NULL;
        double *normals_y = NULL;
        double *normals_z = NULL;
        int user_normals = 0;
        if (lobject.containsElementNamed("normals")) {
          const NumericVector normals(as<NumericVector>(lobject["normals"]));
          normals_x = normals.begin()     ;
          normals_y = normals.begin()+1*nz;
          normals_z = normals.begin()+2*nz;
          user_normals = 1;
        }

        double *texture_s = NULL;
        double *texture_t = NULL;
        int user_textures = 0;
        if (lobject.containsElementNamed("texcoords")) {
          const NumericVector texcoords(as<NumericVector>(lobject["texcoords"]));
          texture_s = texcoords.begin()     ;
          texture_t = texcoords.begin()+1*nz;
          user_textures = 1;
        }

        int coords[3] = {1, 3, 2};
        int orientation = (1 + (x[1] < x[0]) + (y[1] < y[0]) ) % 2;
        int flags[4] = {1, 1, user_normals, user_textures};
        shape = new Surface      ( currentMaterial, nx, ny, x, y, z, 
                                  normals_x, normals_y, normals_z, texture_s, texture_t, 
                                  coords, orientation, flags, ignoreExtent);
//      shape->Rprint();
      }
      if (type == "spheres") {
        const NumericMatrix verts(as<NumericMatrix>(lobject["vertices"]));
        const int ncenter = verts.nrow();
        double *center = new double[3*ncenter];
        for(int i=0; i<ncenter; i++) {
          center[3*i+0] = verts(i,0);
          center[3*i+1] = verts(i,1);
          center[3*i+2] = verts(i,2);
        }
        const NumericVector radii(as<NumericVector>(lobject["radii"]));
        const int nradius = radii.size();
        double *radius = radii.begin();

        shape = new SphereSet ( currentMaterial, ncenter, center, nradius, radius, ignoreExtent);

//      shape->Rprint();
        delete [] center;
      }
      if (type == "text") {
        CharacterVector ltexts(as<CharacterVector>(lobject["texts"]));
        const int ntexts = ltexts.size();
        vector<char*> texts(ntexts);
        for(int i=0; i<ntexts; i++)
          texts[i] = (char*)ltexts[i];
        const NumericMatrix verts(as<NumericMatrix>(lobject["vertices"]));
        const int ncenter = verts.nrow();
        vector<double> center(3*ncenter);
        for(int i=0; i<ncenter; i++) {
          center[3*i+0] = verts(i,0);
          center[3*i+1] = verts(i,1);
          center[3*i+2] = verts(i,2);
        }
        const NumericVector cex(as<NumericVector>(lobject["cex"]));
        FontArray fonts(as< vector<double> >(cex));
        const NumericVector adj(as<NumericVector>(lobject["adj"]));
        double adjx = adj[0];
        double adjy = adj[1];

        shape = new TextSet ( currentMaterial, ntexts, &texts.front(), &center.front(), adjx, adjy, ignoreExtent, fonts);

//      shape->Rprint();
      }
      if (type == "sprites") {
        Shape** shapelist = NULL;
        int count = 0;
        double userMatrix[16] = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};

        const NumericVector vertices(as<NumericVector>(lobject["vertices"]));
        const int nvertex = vertices.size()/3;
        double *vertex = new double[3*nvertex];
        for(int i=0; i<nvertex; i++) {
          vertex[3*i+0] = vertices[nvertex*0+i];
          vertex[3*i+1] = vertices[nvertex*1+i];
          vertex[3*i+2] = vertices[nvertex*2+i];
        }
        const NumericVector radii(as<NumericVector>(lobject["radii"]));
        const int  nsize = radii.size(); // length(lobject["radii"]);
        double *size = new double[nsize];
        copy(radii.begin(),radii.end(),size); // REAL(lobject["radii"]);

        if (lobject.containsElementNamed("objects")) {
          const List shapes(as<List>(lobject["objects"]));
          shapelist = new Shape*[shapes.size()];
          for( List::const_iterator it = shapes.begin(); it != shapes.end(); ++it ) {
            Shape *shape = doShape(it,defaultMaterial,ignoreExtent);
            if (shape)
              shapelist[count++] = shape;
          }
        }

        if (lobject.containsElementNamed("usermatrix")) {
          const NumericVector usermatrix(as<NumericVector>(lobject["usermatrix"]));
          copy(usermatrix.begin(),usermatrix.end(),userMatrix); // REAL(lobject["radii"]);
        }

        shape = new SpriteSet(currentMaterial, nvertex, vertex, nsize, size, ignoreExtent, count, shapelist, userMatrix);

        delete [] size;
        delete [] vertex;
      }
      return shape;
}

// [[Rcpp::export]]
CharacterVector rgl2pdf3d_conv(CharacterVector filename, List scene3d, bool writepdf, bool writeprc, bool writevws, bool writejs) {

    string fname(filename[0]);
    if(fname.empty()) {
      error("rgl2pdf3d: empty file name.\n");
      return CharacterVector("");
    }

    if (!scene3d.containsElementNamed("objects")) {
      error("rgl2pdf3d: empty scene.\n");
      return CharacterVector("");
    }

    const List lobjects(as<List>(scene3d["objects"]));
    if (lobjects.size()==0) {
      error("rgl2pdf3d: empty scene.\n");
      return CharacterVector("");
    }

    Scene *scene = new Scene;
    RenderContext *renderContext = new RenderContext;

    const List par3d(as<List>(scene3d["par3d"]));
//  RprintList(par3d);

    const float fov = as<double>(par3d["FOV"]);

    double modelMatrix[16];
    const NumericVector modelMatrixVector(as<NumericVector>(par3d["modelMatrix"]));
    copy(modelMatrixVector.begin(), modelMatrixVector.end(), modelMatrix);
    copy(modelMatrixVector.begin(), modelMatrixVector.end(), renderContext->modelview);

    double projMatrix[16];
    const NumericVector projMatrixVector(as<NumericVector>(par3d["projMatrix"]));
    copy(projMatrixVector.begin(), projMatrixVector.end(), projMatrix);
    copy(projMatrixVector.begin(), projMatrixVector.end(), renderContext->projection);

    double userMatrix[16];
    const NumericVector userMatrixVector(as<NumericVector>(par3d["userMatrix"]));
    copy(userMatrixVector.begin(), userMatrixVector.end(), userMatrix);

    const NumericVector scaleVector(as<NumericVector>(par3d["scale"]));
    const Vec3 scale(scaleVector[0], scaleVector[1], scaleVector[2]); // 1,1,1

    const IntegerVector viewportVector(as<IntegerVector>(par3d["viewport"]));
    copy(viewportVector.begin(), viewportVector.end(), renderContext->viewport);
    renderContext->rect.x      = renderContext->viewport[0];
    renderContext->rect.y      = renderContext->viewport[1];
    renderContext->rect.width  = renderContext->viewport[2];
    renderContext->rect.height = renderContext->viewport[3];
    
    const bool ignoreExtent = true; // as<bool>(par3d["ignoreExtent"]);

    const float zoom = as<double>(par3d["zoom"]);  // 1

    const double cex = as<double>(par3d["cex"]);
    renderContext->font = cex;

    const string fontname = as<string>(par3d["fontname"]);

    AABox bbox;
    const NumericVector bboxVector(as<NumericVector>(par3d["bbox"]));
    bbox.vmin.x = bboxVector[0];
    bbox.vmax.x = bboxVector[1];
    bbox.vmin.y = bboxVector[2];
    bbox.vmax.y = bboxVector[3];
    bbox.vmin.z = bboxVector[4];
    bbox.vmax.z = bboxVector[5];
    scene->setBoundingBox(bbox);

    scene->setIgnoreExtent(ignoreExtent);

    const List ldm(as<List>(scene3d["material"]));
    Material defaultMaterial(Color(1.0f,1.0f,1.0f),Color(1.0f,0.0f,0.0f));
    getMaterial(ldm, defaultMaterial);

    const List lbg(as<List>(scene3d["bg"]));
    // Color bgcolor(CHAR(as<const CharacterVector>(lbg["colors"])[0]));
    // Rprintf("bgcolor: %u %u %u \n",bgcolor.getRedub(),bgcolor.getGreenub(),bgcolor.getBlueub());
    // Material backgroundMaterial(bgcolor,bgcolor);
    Material backgroundMaterial(defaultMaterial);
    getMaterialIncremental(lbg, backgroundMaterial);
    Background *background = new Background(backgroundMaterial);
    scene->add(background);

    if (scene3d.containsElementNamed("bbox")) {
      const List lbbox(as<List>(scene3d["bbox"]));

      const bool draw_front = as<bool>(lbbox["draw_front"]);

      Material currentMaterial(defaultMaterial);
      getMaterialIncremental(lbbox, currentMaterial);

      const NumericMatrix verts(as<NumericMatrix>(lbbox["vertices"]));
      const size_t nticks = verts.nrow();

      CharacterVector texts;
      if (lbbox.containsElementNamed("texts"))
        texts = lbbox["texts"];
      else
        texts = CharacterVector(nticks,"");

      LogicalVector xm = is_na(verts(_,0));
      LogicalVector ym = is_na(verts(_,1));
      LogicalVector zm = is_na(verts(_,2));
      LogicalVector xl = !xm & ym & zm;
      LogicalVector yl = xm & !ym & zm;
      LogicalVector zl = xm & ym & !zm;

      int xnticks=0, ynticks=0, znticks=0;
      for(size_t i=0; i<nticks; i++) {
        if(xl[i] == TRUE) xnticks++;
        if(yl[i] == TRUE) ynticks++;
        if(zl[i] == TRUE) znticks++;
      }

      vector<char> tex(nticks*32); 
      vector<double>  xval(xnticks),   yval(ynticks),   zval(znticks);
      vector<char*> xtexts(xnticks), ytexts(ynticks), ztexts(znticks); 

      int xtick=0, ytick=0, ztick=0;
      for(size_t i=0; i<nticks; i++) {
        double val = 0;
        if(xl[i] == TRUE) {
          val = xval[xtick] = verts(i,0);
          xtexts[xtick++] = &tex[i*32];
        }
        if(yl[i] == TRUE) {
          val = yval[ytick] = verts(i,1);
          ytexts[ytick++] = &tex[i*32];
        }
        if(zl[i] == TRUE) {
          val = zval[ztick] = verts(i,2);
          ztexts[ztick++] = &tex[i*32];
        }
        if (texts[i]=="")
          snprintf(&tex[i*32], 32, "%.4g", val);
        else
          snprintf(&tex[i*32], 32, "%s",   (char*)texts[i]);
      }

      AxisInfo xaxis(xnticks,&xval.front(),&xtexts.front(),2,0);
      AxisInfo yaxis(ynticks,&yval.front(),&ytexts.front(),2,0);
      AxisInfo zaxis(znticks,&zval.front(),&ztexts.front(),2,0);
      // Material bboxmaterial( Color(0.6f,0.6f,0.6f,0.5f), Color(1.0f,1.0f,1.0f) );
      BBoxDeco *bboxdeco = new BBoxDeco(currentMaterial, xaxis, yaxis, zaxis, 15, true, 1.0, draw_front);
      scene->add(bboxdeco);
    }

    for( List::const_iterator it = lobjects.begin(); it != lobjects.end(); ++it ) {
      SceneNode *node = doShape(it,defaultMaterial,ignoreExtent);
      if (node) {
//      node->Rprint();
        bool success;
        success = scene->add( node );

        if (!success)
        delete node;
      }
    }

  const bool interactive=false;
  Viewpoint* viewpoint = new Viewpoint(userMatrix, fov, zoom, scale, interactive);
  viewpoint->setFOV(fov);
  Sphere total_bsphere(scene->getBoundingBox(), viewpoint->scale );
// Rprintf("total_bsphere %f,%f,%f %f\n", total_bsphere.center.x, total_bsphere.center.y, total_bsphere.center.z, total_bsphere.radius);
  viewpoint->setupFrustum( renderContext, total_bsphere );
// Rprintf("frustum left %f right %f bottom %f top %f znear %f zfar %f distance %f\n",  viewpoint->frustum.left, viewpoint->frustum.right, viewpoint->frustum.bottom, viewpoint->frustum.top, viewpoint->frustum.znear, viewpoint->frustum.zfar, viewpoint->frustum.distance);
  scene->add(viewpoint);

  renderContext->scene = scene;

  vector<string> ret = scene->writePRC((char*)(filename[0]), renderContext, writepdf, writeprc, writevws, writejs);

  delete renderContext;
  delete scene;

  CharacterVector ctmp(ret.size());
  for(size_t i=0; i<ret.size(); i++)
    ctmp[i] = ret[i];
  return ctmp;
}
