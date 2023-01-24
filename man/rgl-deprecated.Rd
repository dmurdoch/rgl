\name{rgl-deprecated}
\alias{rgl-deprecated}
\alias{rgl.antialias}
\alias{rgl.bbox}
\alias{rgl.primitive}
\alias{rgl.points}
\alias{rgl.light}
\alias{rgl.lines}
\alias{rgl.linestrips}
\alias{rgl.material}
\alias{rgl.primitive}
\alias{rgl.select3d}
\alias{rgl.triangles}
\alias{rgl.quads}
\alias{rgl.viewpoint}
\alias{rgl.open}
\alias{rgl.close}
\alias{rgl.set}
\alias{rgl.setAxisCallback}
\alias{writeWebGL}
\alias{rgl.bg}
\alias{rgl.surface}
\alias{rgl.clear}
\alias{rgl.texts}
\title{
Deprecated functions in \pkg{rgl}
}
\description{
These functions are provided for compatibility with older versions of
\pkg{rgl} only, and may be defunct as soon as the next release.  See the comments for the replacements.
}
\usage{
rgl.bbox(xat = NULL, xlab = NULL, xunit = 0, xlen = 5, 
         yat = NULL, ylab = NULL, yunit = 0, ylen = 5, 
         zat = NULL, zlab = NULL, zunit = 0, zlen = 5, 
         marklen = 15, marklen.rel = TRUE, 
         expand = 1, draw_front = FALSE, ...)  # bbox3d
rgl.bg( sphere = FALSE, fogtype = "none", color = c("black", "white"), 
	back = "lines", fogScale = 1, ...)           # bg3d
rgl.clear( type = "shapes", subscene = 0 )     # clear3d

rgl.close()                                    # close3d
rgl.light( theta = 0, phi = 0, viewpoint.rel = TRUE, 
           ambient = "#FFFFFF", diffuse = "#FFFFFF", specular = "#FFFFFF", 
           x = NULL, y = NULL, z = NULL)       # light3d
rgl.lines(x, y = NULL, z = NULL, ... )         # segments3d
rgl.linestrips(x, y = NULL, z = NULL, ...)     # lines3d
rgl.open(useNULL = rgl.useNULL())              # open3d

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
}
\seealso{
  \code{\link{Deprecated}, \link{bbox3d}, \link{bg3d},
  \link{clear3d}, \link{close3d}, \link{light3d}, 
  \link{lines3d}, \link{open3d}, \link{points3d}, 
  \link{quads3d}, \link{rglwidget}, \link{segments3d},
  \link{select3d}, \link{set3d}, \link{surface3d},
  \link{text3d}, \link{triangles3d}, \link{view3d}}
}
\keyword{internal}
\keyword{misc}