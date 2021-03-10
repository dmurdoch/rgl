\name{tkspinControl}
\alias{tkspinControl}
\title{Create a spin control in a TCL/TK window}
\description{
    This function may be used to embed a spin control in a TCL/TK window.
}
\usage{
tkspinControl(base, dev = cur3d(), 
	continue=FALSE, speed=30, scale=100, ... )
}
\arguments{
  \item{base}{The TCL/TK frame in which to insert this control.  }
  \item{dev}{A vector of one or more rgl device numbers to control. }
  \item{continue}{Initial setting for continuous rotation checkbox. }
  \item{speed}{Initial setting for speed slider. }
  \item{scale}{Initial setting for scale slider. }
  \item{...}{Additional parameters to pass to \code{\link[tcltk:TkWidgets]{tkframe}}}
}
\author{ Ming Chen and Duncan Murdoch }
\seealso{\code{\link{spin3d}}}
\examples{
if (interactive() && !in_pkgdown_example()) { 
    library(tcltk)
    open3d()
    win1 <- cur3d()
    plot3d(rexp(100), rexp(100), rexp(100), size=3, col='green')
    
    open3d()
    win2 <- cur3d()
    plot3d(rt(100,2), rt(100,2), rt(100, 2), size=3, col='yellow')
    
    open3d()
    win3 <- cur3d()
    plot3d(rexp(100), rexp(100), rexp(100), size=3, col='red')
        
    open3d()
    win4 <- cur3d()
    plot3d(rbinom(100,10,0.5), rbinom(100,10,0.5), rbinom(100,10,0.5), size=3, col='cyan')
    
    base <- tktoplevel()
    tkwm.title(base, "Spinners")
    con1 <- tkspinControl(base, dev=c(win1,win2))
    con2 <- tkspinControl(base, dev=c(win3,win4))
    tkpack(con1, con2)
}
}
