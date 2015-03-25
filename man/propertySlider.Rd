\name{propertySlider}
\alias{propertySlider}

\title{
Write HTML/Javascript code to control a WebGL display.
}
\description{
This function writes out HTML code to control WebGL displays on the same page.
}
\usage{
propertySlider(values, entries, properties, objids, prefixes = "",
             slider = seq_len(NROW(values)),
             minS = min(slider), maxS = max(slider), step = 1, init = minS, 
	     labels = signif(seq(minS, maxS, by = step), 2), 
	     id = paste0(basename(tempfile("input"))), name = id) 
}
\arguments{
  \item{values}{An array of values; rows correspond to slider positions.}
  \item{entries, properties, objids, prefixes}{Vectors describing
  the columns of \code{values}.  See the details below.}
  \item{slider}{Slider values corresponding to each row of \code{values}.}
  \item{minS, maxS, step, init}{Slider values to be displayed.}
  \item{labels}{Labels to display for each slider value.}
  \item{id}{The \code{id} of the input control that will be generated.}
  \item{name}{The name of the input control that will be generated.}

}
\details{
\code{propertySlider} is a low-level general purpose function for modifying
properties of objects in the scene.  It is mainly for internal use.

The rows of the \code{values} matrix correspond to different settings
for numeric properties.  The columns are values to insert into those properties.

Argument \code{entries} gives the numeric (zero based) index into the Javascript
property named by \code{properties}, for the object id \code{objids}, in the
display with prefix \code{prefixes}.  All of these may be vectors, corresponding
to the columns of \code{values}.  All but \code{entries} will be recycled 
to the appropriate length.

There are two modes for determining the values to substitute.  In the simplest
mode, each row of \code{values} corresponds to a location for the slider, and
the values are simply copied into place.  This requires that \code{slider}, 
\code{min}, \code{max} and \code{step} take on their default values.

In other cases, linear interpolation is used between successive rows of \code{values},
with extrapolation repeating the first or last row.   \code{slider} should then
contain the values that correspond to exact rows.  

}
\value{
The \code{id} of the control that was generated.
}
\author{
Duncan Murdoch
}

\seealso{
\code{\link{writeWebGL}}
}
\examples{
# A 4-position slider
propertySlider(1:4, entries = 12, properties = "values", objids = 13)

# A 10-position slider interpolating the 4-position slider
propertySlider(1:4, entries = 12, properties = "values", objids = 13,
               step = (4-1)/9)
               
}
