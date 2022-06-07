0.109.2:

The noSuggests checks should all be in place now.
Added base64enc to the imports and dropped use of the
problematic knitr::image_uri.

I believe the M1mac issue is also fixed, but I don't have such
a system for testing.


0.109.1:

This is a fairly large update, fixing a lot of bugs and
adding a number of new features.

It removes akima from the Suggests list, as requested.

It makes several changes to attempt to deal with Pandoc
issues on some CRAN systems.  If none of these work, then 
the environment variable RGL_USE_WEBSHOT can be set to 
FALSE to stop Pandoc from being used when taking snapshots.
However, an acceptable version of Pandoc is needed to build
the vignettes.

Some CRAN notes are about the very large size of the libs
directory.  I don't know what is causing that; on my system
it builds to a reasonable size.

I've run revdep checks and saw no new errors, but there are
a few dozen packages I was unable to install, so the tests
were incomplete.
