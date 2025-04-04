\name{makeDependency}
\alias{makeDependency}
\alias{RGL_DEBUGGING}
\title{
Process Javascript for HTML dependency
}
\description{
A utility function to help in development of internal 
Javascript code, this function processes the Javascript
to minify it and report on errors and bad style.
}
\usage{
makeDependency(name, src, script = NULL, package, 
               version = packageVersion(package),
               minifile = paste0(basename(src), ".min.js"),
               debugging = FALSE, ...)
}
\arguments{
  \item{name, src, script, package, version, ...}{
Arguments to pass to \code{htmltools::\link[htmltools]{htmlDependency}.}
}
  \item{minifile}{Basename of minified file.}
  \item{debugging}{
See details below.
}
}
\details{
This is a utility function used by RGL 
to process its Javascript code used when displaying \code{\link{rglwidget}} values.  It may be helpful in other packages to use
in their own installation.

If the \pkg{js} package version 1.2 or greater is installed,
the Javascript code will be minified and stored in the file named
by \code{minifile} in the \code{src} directory.  Syntax errors
in the code will stop the process; unused variables will be
reported.

If \code{debugging} is \code{TRUE}, the locations of Javascript syntax
errors will be reported, along with hints about improvements,
and the original files will be used in the dependency object
that is created.

If \code{debugging} is \code{FALSE} (the default), 
the minified file will be used in the dependency object,
hints won't be given, and syntax errors will lead to an
uninformative failure to minify.
}
\note{
The usual way to use \code{makeDependency} is 
to call it in a \file{.R} file in a package, saving
the result in a variable that will be used when an
HTML widget is created.  This way it is only run
during package installation, when it is safe to
write to the R library holding the package.  

Do not call it to write to the R library from 
code the user can run, as that is not allowed in
general.

If your package uses Roxygen, you may have problems
because by default Roxygen will run the code, and it
is likely to fail.  The current workaround is to
specify Roxygen option \code{load = "installed"}
which prevents it from running your \file{.R} code.
}
\value{
An object that can be included in a list of dependencies passed to \code{htmltools::\link[htmltools:htmlDependencies]{attachDependencies}}.
}
\author{
Duncan Murdoch
}
\examples{
\dontrun{
# This is a slightly simplified version of the code used to 
# produce one of the dependencies for rglwidget().  
# It writes to the system library copy of rgl so 
# has been marked not to run in the example code.

makeDependency("rglwidgetClass", 
               src = "htmlwidgets/lib/rglClass",
               script = c("rglClass.src.js",
                          "utils.src.js",
                          "buffer.src.js",
                          "subscenes.src.js",
                          "shaders.src.js",
                          "textures.src.js",
                          "projection.src.js",
                          "mouse.src.js",
                          "init.src.js",
                          "pieces.src.js",
                          "draw.src.js",
                          "controls.src.js",
                          "selection.src.js",
                          "rglTimer.src.js",
                          "pretty.src.js",
                          "axes.src.js",
                          "animation.src.js"),
               stylesheet = "rgl.css",
               package = "rgl",
               debugging = isTRUE(as.logical(Sys.getenv("RGL_DEBUGGING", "FALSE"))))
}
}
