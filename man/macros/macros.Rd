% Macro to create link to an HTML vignette from a help page.  In
% this version the vignette must be in the same package as the help
% page
% arg 1 is the name of the vignette (without .html)
% arg 2 is an optional anchor within the vignette (without the leading #)
% arg 3 is the text to show on the link.

\newcommand{\HTMLVignette}{\Sexpr[stage=build,results=rd]{
  local({anchor <- "#2"
         if (nchar(anchor)) 
           anchor <- paste0("#", anchor)  
         if (rgl::in_pkgdown())
           vigparent <- "articles"
         else 
           vigparent <- "doc"
         paste0("\\\\\\\\href{../", vigparent, "/#1.html", 
                anchor, "}{#3}")
         })}}

% Macro to create link to an HTML vignette in another package on CRAN
% from a help page.
% arg 1 is the package name
% arg 2 is the name of the vignette (without .html)
% arg 3 is an optional anchor within the vignette (without the leading #)
% arg 4 is the text to show on the link.

\newcommand{\HTMLVignetteCRAN}{\Sexpr[stage=build,results=rd]{
  local({anchor <- "#3"
         if (nchar(anchor)) 
           anchor <- paste0("#", anchor)  
         paste0("\\\\\\\\href{https://cran.r-project.org/package=#1/vignettes/#2.html", 
                anchor, "}{#4}")
         })}}
