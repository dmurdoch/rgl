# This file supports auto-printing of RGL scenes in
# RStudio

# Called just after a low level function has been
# called, likely changing an existing display
# Returns the ids that were created by the function,
# which should be passed as the ids arg.

lowlevel <- function(ids = integer()) {
  structure(ids, class = c("rglLowlevel", "rglId", "numeric"))
}

# Called just after a high level function (plot3d
# or persp3d) has been called, if it wasn't
# called with add = TRUE (in which case it would be
# treated as low level).
# Returns the ids that were created by the function,
# which should be passed as the ids arg.

highlevel <- function(ids = integer()) {
  structure(ids, class = c("rglHighlevel", "rglId", "numeric"))
}

rglId <- function(ids = integer()) {
  structure(ids, class = "rglId")
}

print.rglId <- function(x, rglwidget = getOption("rgl.printRglwidget", FALSE),
			...) {
  if (rglwidget)
    # FIXME:  For lowlevel, this should replace the scene, not update the history
    print(rglwidget(...))
  else if (in_pkgdown_example())
    pkgdown_print(x)
  else if (in_pkgdown()) # Must not have pkgdown_print defined
    cat("")
  invisible(x)
}
