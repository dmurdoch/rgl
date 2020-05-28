\name{propertySetter}
\alias{propertySlider}
\alias{propertySetter}
\alias{par3dinterpSetter}
\alias{matrixSetter}
\alias{vertexSetter}
\title{
Obsolete function to write HTML/Javascript code to control a WebGL display.
}
\description{ These functions write 
out HTML code to control WebGL displays based
using the obsolete \code{writeWebGL}.  Use
\code{\link{playwidget}} and related functions instead.
}
\usage{
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
\arguments{
  \item{setter}{A function to write Javascript code, or its output, or
   a list containing several of these.}
  \item{minS, maxS, step, init}{Slider values to be displayed. Reasonable defaults are used if missing.}
  \item{labels}{Labels to display for each slider value.  The
  defaults are calculated using internal variables.  If \code{NULL},
  no labels will be shown.}
  \item{id}{The \code{id} of the input control that will be generated.}
  \item{name}{The name of the input control that will be generated.}
  \item{outputid}{The \code{id} of the output control that
will display the slider value, or \code{NULL} for none.}
  \item{index}{The 1-based index of this slider:  it controls the
  corresponding entry in an indexed setter such as \code{matrixSetter}.}
  \item{...}{Other parameters.}
  \item{values}{An array of values; rows correspond to slider positions.  Alternatively, \code{NULL}; the generated function takes a
  single value or array of values and applies them directly.}
  \item{entries, properties, objids, prefixes}{Vectors describing
  the columns of \code{values}.}
  \item{param}{Parameter values corresponding to each row of \code{values}.}
  \item{interp}{Whether to interpolate values.  If \code{FALSE}, 
  the Javascript function will expect non-negative integer values.
  Ignored if \code{values} is \code{NULL}.}
  \item{digits}{How many significant digits to emit in the Javascript code.}
  \item{fn}{A function returned from \code{\link{par3dinterp}}.}
  \item{from, to, steps}{Values where \code{fn} should be evaluated.}
  \item{subscene}{Which subscene's properties should be modified?}
  \item{omitConstant}{If \code{TRUE}, do not set values that are
  constant across the range.}
  \item{rename}{A named character vector of names of Javascript properties
  to modify.}
  \item{fns}{A list containing functions returned from 
    \code{\link{par3dinterp}}.}
  \item{matrix}{A character string giving the Javascript property
    name of the matrix to modify.}
  \item{prefix}{The prefix of the scene containing \code{matrix}.}
  \item{vertices}{A vector of vertex numbers (1-based) within 
  an object.}
  \item{attributes}{A vector of attributes of a vertex, 
  from \code{c("x", "y", "z", "r", "g", "b", "a", "nx", "ny", "nz",
               "radius", "ox", "oy", "oz", "ts", "tt")}.}
  \item{objid}{The object containing the vertices to be modified.}
}
\author{
Duncan Murdoch
}

\seealso{
\code{\link{rglwidget}}, \code{\link{playwidget}}
}
