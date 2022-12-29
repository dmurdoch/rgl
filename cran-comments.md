0.111.4

This is a fairly small update, triggered by a request from CRAN.

Of the issues reported in the CRAN tests, the following have
been addressed:

- The C prototype in `gl2ps` has been corrected.
- `sprintf` calls have been replaced with `snprintf` calls.

The size notes haven't been dealt with.

The vignette build failure on M1mac isn't reproducible on 
my Intel Mac, nor on the macbuilder R-devel machine and hasn't
been addressed.  Prof.
Ripley suggested it's related to a Pandoc change; recent 
updates to `rmarkdown` and `htmlwidgets` addressed one of
those, so
perhaps it is now fixed.

Besides those issues, I have found and fixed an issue that
could cause a segfault, have made some minor improvements
that will allow the `rayshader` package to update to more
reliable `rgl` calls, and added an example mouse handler
for panning the display.

I have run revdep checks and identified no issues.

Version 0.111.4 fixes some changed URLs.
