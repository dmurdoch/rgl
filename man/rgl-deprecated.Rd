\name{rgl-deprecated}
\alias{rgl-deprecated}
\alias{rgl.antialias}
\alias{rgl.bbox}
\alias{rgl.primitive}
\alias{rgl.points}
\alias{rgl.light}
\alias{rgl.lines}
\alias{rgl.linestrips}
\alias{rgl.triangles}
\alias{rgl.quads}
\alias{rgl.open}
\alias{rgl.close}
\alias{rgl.cur}
\alias{rgl.ids}
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
\pkg{rgl} only, and may be defunct as soon as the next release.
}
\usage{
rgl.bbox(xat = NULL, xlab = NULL, xunit = 0, xlen = 5, 
         yat = NULL, ylab = NULL, yunit = 0, ylen = 5, 
         zat = NULL, zlab = NULL, zunit = 0, zlen = 5, 
         marklen = 15, marklen.rel = TRUE, 
         expand = 1, draw_front = FALSE, ...)
rgl.bg( sphere = FALSE, fogtype = "none", color = c("black", "white"), 
	back = "lines", fogScale = 1, ...)
rgl.clear( type = "shapes", subscene = 0 )

rgl.close()    # close current device
rgl.cur()      # returns active device ID
rgl.ids(...)
rgl.light( theta = 0, phi = 0, viewpoint.rel = TRUE, 
           ambient = "#FFFFFF", diffuse = "#FFFFFF", specular = "#FFFFFF", 
           x = NULL, y = NULL, z = NULL)
rgl.lines(x, y = NULL, z = NULL, ... )
rgl.linestrips(x, y = NULL, z = NULL, ...)
rgl.open(useNULL = rgl.useNULL())     # open new device

rgl.points(x, y = NULL, z = NULL, ... )
rgl.quads(x, y = NULL, z = NULL, normals = NULL, texcoords = NULL, ... )
rgl.set(which, silent = FALSE) # set device as active
rgl.setAxisCallback(axis, draw = NULL, 
                    dev = cur3d(), subscene = currentSubscene3d(dev))
rgl.surface(x, z, y, coords = 1:3, ..., 
            normal_x = NULL, normal_y = NULL, normal_z = NULL,
            texture_s = NULL, texture_t = NULL)
rgl.texts(x, y = NULL, z = NULL, text, 
          adj = 0.5, pos = NULL, offset = 0.5, 
          family = par3d("family"), 
          font = par3d("font"), 
          cex = par3d("cex"), 
          useFreeType = par3d("useFreeType"), ...)
rgl.triangles(x, y = NULL, z = NULL, normals = NULL, texcoords = NULL, ... )
writeWebGL(dir = "webGL", filename = file.path(dir, "index.html"), 
           template = system.file(file.path("WebGL", "template.html"), package = "rgl"),
           prefix = "",
           snapshot = TRUE, commonParts = TRUE, reuse = NULL, 
           font = "Arial", width, height)
}
\seealso{
  \code{\link{Deprecated}}
}
\keyword{internal}
\keyword{misc}