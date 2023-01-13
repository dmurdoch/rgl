\name{rgl-duplicated}
\alias{rgl.pop}
\alias{rgl.cur}
\alias{rgl.ids}
\alias{terrain3d}
\title{
Duplicated functions in \pkg{rgl}
}
\description{
These functions are provided for compatibility with older versions of
\pkg{rgl}.  See the functions in the comments for the 
full documentation.
}
\usage{
rgl.cur()                             # cur3d      
rgl.ids(type = "shapes", 
        subscene = NA, tags = FALSE)  # ids3d 
rgl.pop(type = "shapes", 
        id = 0, tag = NULL)           # pop3d
terrain3d(x, y = NULL, z = NULL, ...,
          normal_x = NULL, normal_y = NULL, normal_z = NULL,
          texture_s = NULL, texture_t=NULL,
          flip = FALSE)               # surface3d
}
\seealso{\code{\link{cur3d}}, \code{\link{ids3d}}, \code{\link{pop3d}}, \code{\link{surface3d}}}
\keyword{internal}
\keyword{misc}