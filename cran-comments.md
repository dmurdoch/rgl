0.108.3.2:

In addition to the change in 0.108.3.1, this submission
includes a correction to a typo in a font name that could
conceivably have caused trouble on the M1Mac test machine.

It makes no changes to the Pandoc test code.  If that's really
the problem instead of this font issue, then it might be a bug
in rmarkdown reported here: 

https://github.com/rstudio/rmarkdown/issues/2359

On the R-hub test machine, running "pandoc --version" produces 
a zero length result and that causes rmarkdown to error out.
I don't know if the same thing happens on CRAN.


0.108.3.1:

This is a small bug fix requested by Tomas Kalibera.  The only
change is to the startup code, to prevent crashes 
in R 4.2.0 under RStudio on Windows.

In particular, I haven't run new revdep checks, and haven't
attempted to address the problems shown on the CRAN checks due
to pandoc being missing on the check machine.

A more extensive update will come in a few weeks.
