\name{ageSetter}
\alias{ageSetter}
\title{
Obsolete function to set WebGL scene properties based on the age of components
of objects
}
\description{
Many RGL shapes contain lists of vertices with various
attributes (available via \code{\link{rgl.attrib}}).  This function
modifies the data for those attributes in a WebGL scene.
}
\usage{
ageSetter(births, ages, 
         colors = NULL, alpha = NULL, radii = NULL, 
         vertices = NULL, normals = NULL, origins = NULL, 
         texcoords = NULL, 
         objids, prefixes = "", digits = 7, 
         param = seq(floor(min(births)), ceiling(max(births))))
}
\arguments{
  \item{births}{
Numeric vector with one value per vertex, used to determine the
\dQuote{age} of the vertex when displaying it.
}
  \item{ages}{
A non-decreasing sequence of \dQuote{ages}.  
}
  \item{colors, alpha, radii, vertices, normals, origins, texcoords}{
Attributes of the vertices.  Non-\code{NULL} attributes will be 
interpolated from these values.  See the Details section below.
}
  \item{objids, prefixes}{
The object ids and scene prefixes to modify.  These are recycled to
the same length.
}
  \item{digits}{
How many digits to output in the generated Javascript code.
}
  \item{param}{
Default values to be used by a slider control calling the generated
function.
}
}
\details{
The vertex attributes
are specified as follows:
\describe{
\item{colors}{A vector of colors in a format suitable for input to \code{\link{col2rgb}}}
\item{alpha}{A numeric vector of alpha values between 0 and 1.}
\item{radii}{A numeric vector of sphere radii.}
\item{vertices}{A 3-column matrix of vertex coordinates.}
\item{normals}{A 3-column matrix of vertex normals.}
\item{origins}{A 2-column matrix of origins for text or sprites.}
\item{texcoords}{A 2-column matrix of texture coordinates.}
}

All attributes must have the same number of entries (rows for the matrices)
as the \code{ages} vector.  The \code{births} vector must have the
same number of entries as the number of vertices in the object.

Not all objects contain all attributes listed here; if one is
chosen that is not a property of the corresponding object, a
Javascript \code{alert()} will be generated.  
}
\value{
A character vector of class \code{c("ageSetter", "propertySetter")} 
containing Javascript
code defining a function suitable for use in a \code{\link{propertySlider}}.

The function takes a single argument, \code{time}, and uses it to compute the
\dQuote{age} of vertex \code{i} as \code{time - births[i]}.  
Those are then used with the \code{ages}
argument to linearly interpolate settings of the specified attributes.
Extrapolation is constant.  Repeated values in \code{ages} can be used
to obtain discontinuities in the settings.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{propertySlider}}; more detailed control is available in
\code{\link{vertexSetter}}.
}
