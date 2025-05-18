% Macro to create link to an HTML vignette from a help page.
% arg 1 is the package name
% arg 2 is the name of the vignette (without .html)
% arg 3 is an optional anchor within the vignette (without the leading #)
% arg 4 is the text to show on the link.
% If a link isn't possible, just arg 4 will be shown.

\newcommand{\HTMLVignette}{\Sexpr[stage=render,results=rd]{
  local({vig <- suppressWarnings(utils::vignette("#2", package="#1"))
         exists <- is.list(vig) && nzchar(vig$PDF)
         if (exists)
           port <- tools::startDynamicHelp(NA)
         else
           port <- 0L
         anchor <- "#3"
         if (nchar(anchor)) 
           anchor <- paste0("#", anchor)   
         if (!exists || port == 0L || rgl::in_pkgdown())
           paste0("\\\\\\\\href{https://dmurdoch.github.io/#1/articles/#2.html", 
                anchor, "}{#4}")
         else {
           paste0("\\\\\\\\href{http://localhost:", 
                port, "/library/", 
                basename(vig$Dir), "/doc/",
                vig$PDF, anchor, "}{#4}")
          }})}}
