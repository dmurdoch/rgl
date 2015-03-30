\name{propertySlider}
\alias{propertySlider}
\alias{propertySetter}

\title{
Write HTML/Javascript code to control a WebGL display.
}
\description{
\code{propertySlider} writes out HTML code to control WebGL displays on the same page via a slider; \code{propertySetter} returns Javascript code
to be used in HTML controls.
}
\usage{
propertySlider(setter = propertySetter,
             minS = min(param), maxS = max(param), step = 1, init = minS, 
	     labels = signif(seq(minS, maxS, by = step), 2), 
	     id = paste0(basename(tempfile("input"))), name = id,
	     ...) 
	     
propertySetter(values, entries, properties, objids, prefixes = "",
               param = seq_len(NROW(values)), interp = TRUE) 
}
\arguments{
  \item{setter}{A function to write Javascript code, or its output.}
  \item{minS, maxS, step, init}{Slider values to be displayed.}
  \item{labels}{Labels to display for each slider value.}
  \item{id}{The \code{id} of the input control that will be generated.}
  \item{name}{The name of the input control that will be generated.}
  \item{...}{If \code{propertySetter} is a function, additional 
  arguments will be passed to it.}
  \item{values}{An array of values; rows correspond to slider positions.}
  \item{entries, properties, objids, prefixes}{Vectors describing
  the columns of \code{values}.  See the details below.}
  \item{param}{Parameter values corresponding to each row of \code{values}.}
  \item{interp}{Whether to interpolate values.  If \code{FALSE}, 
  the Javascript function will expect non-negative integer values.}


}
\details{
\code{propertySetter} is a low-level general purpose function for modifying
properties of objects in the scene.  It is mainly for internal use.
\code{propertySlider} uses it to generate Javascript for a slider control
to manipulate those properties.

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
}
\examples{
# Just the setter function
cat(propertySetter(1:4, entries = 12, properties = "values", objids = 13))

# A 4-position slider
propertySlider(values = 1:4, entries = 12, properties = "values", objids = 13, interp = FALSE)

# A 10-position slider interpolating the 4-position slider
propertySlider(values = 1:4, entries = 12, properties = "values", objids = 13,
               step = (4-1)/9)
               
}
