
#ifdef HAVE_FREETYPE

// We remap the names to avoid conflicts

#define FTBuffer 		rgl_FTBuffer
#define FTBufferFont 		rgl_FTBufferFont
#define FTBufferFontImpl 	rgl_FTBufferFontImpl
#define FTBufferGlyph 		rgl_FTBufferGlyph
#define FTBufferGlyphImpl 	rgl_FTBufferGlyphImpl
#define FTCharmap		rgl_FTCharmap
#define FTFace			rgl_FTFace
#define FTFont			rgl_FTFont
#define FTFontImpl		rgl_FTFontImpl
#define FTGlyph			rgl_FTGlyph
#define FTGlyphContainer 	rgl_FTGlyphContainer
#define FTGlyphImpl		rgl_FTGlyphImpl
#define FTLibrary		rgl_FTLibrary
#define FTPixmapFont		rgl_FTPixmapFont
#define FTPixmapFontImpl 	rgl_FTPixmapFontImpl
#define FTPixmapGlyph		rgl_FTPixmapGlyph
#define FTPixmapGlyphImpl 	rgl_FTPixmapGlyphImpl
#define FTSize			rgl_FTSize

#include "FTBuffer.cpp"
#include "FTCharmap.cpp"
#include "FTFace.cpp"
#include "FTFont/FTFont.cpp"
#include "FTFont/FTBufferFont.cpp"
#include "FTFont/FTPixmapFont.cpp"
#include "FTGlyphContainer.cpp"
#include "FTGlyph/FTGlyph.cpp"
#include "FTGlyph/FTPixmapGlyph.cpp"
#include "FTGlyph/FTBufferGlyph.cpp"
#include "FTLibrary.cpp"
#include "FTSize.cpp"

#endif
