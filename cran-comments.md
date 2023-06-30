# 1.2.0

This release is at the request of Prof Ripley because of C++17
conflicts.  His log listed a lot of them, but I think they are all
consequences of `length` being defined as part of the R API and also used
in the C++ run-time.

There are also other changes described in NEWS.md, but none of them
are very large.
