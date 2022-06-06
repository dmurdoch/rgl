0.108.47:

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
