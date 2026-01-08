\name{rgl-defunct}
\alias{rgl-defunct}
\alias{subsetSlider}
\alias{subsetSetter}
\alias{clipplaneSlider}
\alias{toggleButton}
\alias{propertySlider}
\alias{propertySetter}
\alias{par3dinterpSetter}
\alias{matrixSetter}
\alias{vertexSetter}
\alias{elementId2Prefix}
\alias{rgl.texts}
\alias{rgl.sprites}
\alias{rgl.abclines}
\alias{rgl.bbox}
\alias{rgl.bg}
\alias{rgl.clear}
\alias{rgl.clipplanes}
\alias{rgl.close}
\alias{rgl.light}
\alias{rgl.lines}
\alias{rgl.linestrips}
\alias{rgl.material}
\alias{rgl.open}
\alias{rgl.planes}
\alias{rgl.points}
\alias{rgl.primitive}
\alias{rgl.quads}
\alias{rgl.select3d}
\alias{rgl.set}
\alias{rgl.setAxisCallback}
\alias{rgl.surface}
\alias{rgl.triangles}
\alias{rgl.viewpoint}
\alias{writeWebGL}
\title{
Defunct functions in \pkg{rgl}
}
\description{
These functions have been removed from \pkg{rgl}.
Comments indicate the replacements.
}
\usage{
# Removed in version 1.4.0:
elementId2Prefix(elementId, prefix = elementId)
rgl.abclines(x, y=NULL, z=NULL, a, b=NULL, c=NULL, ...)
rgl.bbox(xat = NULL, xlab = NULL, xunit = 0, xlen = 5, 
         yat = NULL, ylab = NULL, yunit = 0, ylen = 5, 
         zat = NULL, zlab = NULL, zunit = 0, zlen = 5, 
         marklen = 15, marklen.rel = TRUE, 
         expand = 1, draw_front = FALSE, ...)  # bbox3d
         
rgl.bg( sphere = FALSE, fogtype = "none", color = c("black", "white"), 
	back = "lines", fogScale = 1, ...)           # bg3d
	
rgl.clear( type = "shapes", subscene = 0 )     # clear3d
rgl.clipplanes( a, b=NULL, c=NULL, d=0)        # clipplanes3d
rgl.close()                                    # close3d
rgl.light( theta = 0, phi = 0, viewpoint.rel = TRUE, 
           ambient = "#FFFFFF", diffuse = "#FFFFFF", specular = "#FFFFFF", 
           x = NULL, y = NULL, z = NULL)       # light3d
rgl.lines(x, y = NULL, z = NULL, ... )         # segments3d
rgl.linestrips(x, y = NULL, z = NULL, ...)     # lines3d
rgl.material(...)                              # material3d
rgl.open(useNULL = rgl.useNULL())              # open3d
rgl.planes( a, b=NULL, c=NULL, d=0,...)        # planes3d
rgl.points(x, y = NULL, z = NULL, ... )        # points3d
rgl.primitive(...)                             
rgl.quads(x, y = NULL, z = NULL, 
          normals = NULL, 
          texcoords = NULL, ... )              # quads3d
rgl.select3d(button = c("left", "middle", "right"),
            dev = cur3d(), 
            subscene = currentSubscene3d(dev)) # select3d
rgl.set(which, silent = FALSE)                 # set3d
rgl.setAxisCallback(axis, draw = NULL, 
            dev = cur3d(), 
            subscene = currentSubscene3d(dev)) # setAxisCallback

rgl.sprites(x, y = NULL, z = NULL, radius = 1, 
            shapes = NULL, userMatrix, fixedSize = FALSE,
            adj = 0.5, pos = NULL, offset = 0.25, 
            rotating = FALSE, ...)
            
rgl.surface(x, z, y, coords = 1:3, ..., 
            normal_x = NULL, normal_y = NULL, normal_z = NULL,
            texture_s = NULL, texture_t = NULL) # surface3d
            
rgl.texts(x, y = NULL, z = NULL, text, 
          adj = 0.5, pos = NULL, offset = 0.5, 
          family = par3d("family"), 
          font = par3d("font"), 
          cex = par3d("cex"), 
          useFreeType = par3d("useFreeType"), 
          ...)                                  # text3d               

rgl.triangles(x, y = NULL, z = NULL, 
              normals = NULL, texcoords = NULL, 
              ... )                             # triangles3d
rgl.viewpoint( theta = 0, phi = 15, 
               fov = 60, zoom = 1, 
               scale = par3d("scale"), 
               interactive = TRUE, 
               userMatrix, 
               type = c("userviewpoint",
                        "modelviewpoint") )     # view3d
writeWebGL(dir = "webGL", 
           filename = file.path(dir, "index.html"), 
           template = system.file(file.path("WebGL", "template.html"), package = "rgl"),
           prefix = "",
           snapshot = TRUE, 
           commonParts = TRUE, 
           reuse = NULL, 
           font = "Arial", 
           width, height)                       # rglwidget


          
# Removed in version 1.0.0:

subsetSlider(subsets, labels = names(subsets), 
             fullset = Reduce(union, subsets),
             subscenes = currentSubscene3d(), prefixes = "",
             accumulate = FALSE, ...)
             
subsetSetter(subsets, subscenes = currentSubscene3d(), prefixes = "", 
			 fullset = Reduce(union, subsets),
                         accumulate = FALSE)
             
clipplaneSlider(a=NULL, b=NULL, c=NULL, d=NULL, 
                plane = 1, clipplaneids, prefixes = "", 
                labels = signif(values[,1],3), ...)
             
toggleButton(subset, subscenes = currentSubscene3d(), prefixes = "", 
             label = deparse(substitute(subset)), 
             id = paste0(basename(tempfile("input"))), name = id) 
propertySlider(setter = propertySetter,
             minS = NULL, maxS = NULL, step = 1, init = NULL, 
	     labels, 
	     id = basename(tempfile("input")), name = id,
	     outputid = paste0(id, "text"),
	     index = NULL,
	     ...) 
	     
propertySetter(values = NULL, entries, properties, objids, prefixes = "",
               param = seq_len(NROW(values)), interp = TRUE, digits = 7) 
               
par3dinterpSetter(fn, from, to, steps, subscene, omitConstant = TRUE, 
                  rename = character(), ...)

matrixSetter(fns, from, to, steps, subscene = currentSubscene3d(), 
             matrix = "userMatrix", omitConstant = TRUE, prefix = "", ...) 
             
vertexSetter(values, vertices = 1, attributes, objid, prefix = "",
	     param = seq_len(NROW(values)), interp = TRUE,
	     digits = 7)             
}
\seealso{
  \code{\link{Defunct}}
}
\keyword{internal}
\keyword{misc}