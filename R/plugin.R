##
## R source file
## This file is part of rgl
##
## $Id: plugin.R,v 1.1 2003/06/04 07:46:44 dadler Exp $
##

##
## quit R plugin
## 
##

rgl.quit <- function() {

  detach(package:rgl)

}


