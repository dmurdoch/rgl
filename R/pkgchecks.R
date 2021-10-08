# Suggested package checks

checkDeldir <- function(error = FALSE) {
  result <- requireNamespace("deldir", quietly = TRUE) &&
    (packageVersion("deldir") < "1.0.2" ||
       packageVersion("deldir") >= "1.0.4")
  if (error && !result)
    stop("This function requires the 'deldir' package (but is not compatible with version 1.0-2).", call. = FALSE)
  result
}
