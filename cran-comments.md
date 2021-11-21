0.108.2:

Sorry, I missed the notes from rchk on CRAN.  They should be fixed now.

The note from the M1mac check is too uninformative, so I haven't 
addressed it.  It just says "Error(s) in re-building vignettes:
--- re-building ‘WebGL.Rmd’ using rmarkdown".  If I knew what the error
was, perhaps I could fix it.

The other notes in the main CRAN checks are about the unavailability
of the webshot2 suggested package (which I have made available), the
lack of pandoc on some test machines (which I can't do anything about
other than listing pandoc as a system requirement, which I have done),
and some timing issues (where builds have just exceeded the limits).

0.108.1:

This release has some major internal changes:

 - data in rgl scenes in web pages is slightly compressed.  This makes the
 package a bit smaller, and should have the same effect on reverse
 dependencies that include HTML vignettes using rgl.
 
 - tags have been added to allow reverse dependencies to simplify their
 code that selects multiple objects.
 
 - indices have been added to allow vertices to be re-used.
 
Several smaller changes have also been made, as described in the NEWS.md 
file.

I have run checks on about 80% of the revdeps, and corrected the one new
bug that was introduced, so currently the only revdep changes I see are
small improvements to package sizes.  However, I'm unable to build the
remaining 20% of revdeps and so haven't checked them.
