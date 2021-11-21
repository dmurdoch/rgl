
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
