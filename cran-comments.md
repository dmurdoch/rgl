# 1.2.8

This small release is at the request of CRAN to address issues
shown in the CRAN checks.

- A call to Rf_warning() passed a variable; it now has a
separate constant format string.

- Some old documentation of arguments that were not present
has been removed.

These warnings/notes have not been addressed:

- The installed package size has not been improved.

- Some deprecated function warnings on MacOS are still
present, as those functions are still needed.  I hope that
the major changes I am in the process of making will allow
me to address these finally, but those changes are months
away from being done.

In addition to those changes, there are some minor improvements and bug fixes mentioned in the NEWS file.

