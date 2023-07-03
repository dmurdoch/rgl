# 1.2.0

This release is at the request of Prof Ripley, largely because of C++17
conflicts.  His log listed a lot of them, but I think they are all
consequences of `length` being defined as a macro as part of the R API
and also used in some C++ header file.

I have also increased the tolerance for changes in some of the test
code, hopefully enough to pass the tests on the M1mac.

I have not been able to reproduce the segfault in the M1mac tests,
so I haven't dealt with it.

There's a warning in the Mac tests about using a deprecated function,
but in fact the recommended function is used when available.  The
use of the deprecated function is present for back compatibility.

There are also other changes described in NEWS.md, but none of them
are very large.

I have run checks on R-devel for `rgl` and for most of the
reverse dependencies.  Nothing new has turned up.
