1.0.1:

This update formalizes the deprecation of a large
slate of functions.  Use of these has been discouraged for a 
long time, but about 90 packages on CRAN and Bioconductor 
were using them.  Unfortunately, this led to support problems, 
because in many cases they weren't being used correctly.

I have notified all of the known users of these deprecated
functions, and in almost all cases have sent patches to them 
to correct their code.  

As of Jan 18, there is just one package on CRAN that
gives deprecation warnings.  On Jan 14, there were about 23,
and on Jan 9, the count was about 30.

The update also makes a few other small changes; see NEWS.md.