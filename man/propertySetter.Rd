\name{propertySetter}
\alias{propertySlider}
\alias{propertySetter}
\alias{par3dinterpSetter}
\title{
Write HTML/Javascript code to control a WebGL display.
}
\description{
\code{propertySlider} writes out HTML code to control WebGL displays on the same page via a slider; \code{par3dinterpSetter} and
\code{propertySetter} return Javascript code
to be used in HTML controls.
}
\usage{
propertySlider(setter = propertySetter,
             minS = min(param), maxS = max(param), step = 1, init = minS, 
	     labels = displayVals(sliderVals), 
	     id = basename(tempfile("input")), name = id,
	     outputid = paste0(id, "text"),
	     ...) 
	     
propertySetter(values, entries, properties, objids, prefixes = "",
               param = seq_len(NROW(values)), interp = TRUE, digits = 7) 
               
par3dinterpSetter(fn, from, to, steps, subscene, omitConstant = TRUE, ...)
}
\arguments{
  \item{setter}{A function to write Javascript code, or its output.}
  \item{minS, maxS, step, init}{Slider values to be displayed.}
  \item{labels}{Labels to display for each slider value.  The
  defaults are calculated using internal variables.}
  \item{id}{The \code{id} of the input control that will be generated.}
  \item{name}{The name of the input control that will be generated.}
  \item{outputid}{The \code{id} of the output control that
will display the slider value, or \code{NULL} for none.}
  \item{...}{See Details below.}
  \item{values}{An array of values; rows correspond to slider positions.}
  \item{entries, properties, objids, prefixes}{Vectors describing
  the columns of \code{values}.  See the details below.}
  \item{param}{Parameter values corresponding to each row of \code{values}.}
  \item{interp}{Whether to interpolate values.  If \code{FALSE}, 
  the Javascript function will expect non-negative integer values.}
  \item{digits}{How many significant digits to emit in the Javascript code.}
  \item{fn}{A function returned from \code{\link{par3dinterp}}.}
  \item{from, to, steps}{Values where \code{fn} should be evaluated.}
  \item{subscene}{Which subscene's properties should be modified?}
  \item{omitConstant}{If \code{TRUE}, do not set values that are
  constant across the range.}
}
\details{
The \code{...} parameters to \code{propertySlider} will be passed to
\code{setter} if the latter is a function, otherwise ignored. 

The \code{...} parameters to \code{par3dinterpSetter} will be passed
to \code{propertySetter}.

\code{propertySetter} is a low-level general purpose function for modifying
properties of objects in the scene.  It is mainly for internal use.
\code{propertySlider} uses it to generate Javascript for a slider control
to manipulate those properties.  \code{par3dinterpSetter} uses
it to set parameters corresponding to values produced by the result of
\code{par3dinterp}.

The rows of the \code{values} matrix correspond to different settings
for numeric properties.  The columns are values to insert into those properties.

Argument \code{entries} gives the numeric (zero based) index into the Javascript
property named by \code{properties}, for the object id \code{objids}, in the
display with prefix \code{prefixes}.  All of these may be vectors, corresponding
to the columns of \code{values}.  All but \code{entries} will be recycled 
to the appropriate length; its length needs to match the number of 
columns in \code{values}.

There are two modes for determining the values to substitute.  In the simplest
mode (\code{interp = FALSE} in \code{propertySetter}), 
each row of \code{values} corresponds to a location for the slider, and
the values are simply copied into place.  This requires that \code{param}, 
\code{min}, \code{max} and \code{step} take on their default values.

In other cases, linear interpolation is used between successive rows of \code{values},
with extrapolation outside the range of \code{param} 
repeating the first or last row.   \code{param} should then
contain the values that correspond to exact rows.

In both cases, \code{param} must be a strictly increasing vector.

}
\value{
\code{propertySlider} prints the full code to generate the control, 
and returns the \code{id} of the control that was generated.  

\code{propertySetter} returns a single element character vector 
containing the Javascript source for a function to set
the appropriate properties.   It does not assign the function 
to a variable or include any of the HTML wrapper text that 
\code{propertySlider} adds.  

The character vector has class
\code{"propertySetter"}, and an attribute named \code{"env"}
which gives access to the local environment where it was
created, so for example \code{attr(value, "env")$prefixes} will
give access to the \code{prefixes} argument if \code{value}
was produced by \code{"propertySetter"}.
}
\author{
Duncan Murdoch
}

\seealso{
\code{\link{writeWebGL}}.  \code{\link{clipplaneSlider}} makes
use of \code{propertySlider}.

\code{\link{ageSetter}} can be used as the \code{setter} argument
to \code{propertySlider} to modify objects according to a linear (age)
scale.
}
\examples{
# Just the setter function
cat(propertySetter(1:4, entries = 12, properties = "values", objids = 13))

# A 4-position slider
propertySlider(values = 1:4, entries = 12, properties = "values", objids = 13, interp = FALSE)

# A 10-position slider interpolating the 4-position slider
propertySlider(values = 1:4, entries = 12, properties = "values", objids = 13,
               step = (4-1)/9)
               
# The userMatrix interpolation from example(play3d)
M <- r3dDefaults$userMatrix
fn <- par3dinterp(time = (0:2)*0.75, userMatrix = list(M,
                                     rotate3d(M, pi/2, 1, 0, 0),
                                     rotate3d(M, pi/2, 0, 1, 0) ) )
cat(par3dinterpSetter(fn, 0, 3, steps=10))
}
