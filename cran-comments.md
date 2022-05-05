0.108.3.1:

This is a small bug fix requested by Tomas Kalibera.  The only
change is to the startup code, to prevent crashes 
in R 4.2.0 under RStudio on Windows.

In particular, I haven't run new revdep checks, and haven't
attempted to address the problems shown on the CRAN checks due
to pandoc being missing on the check machine.

A more extensive update will come in a few weeks.
