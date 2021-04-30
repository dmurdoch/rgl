if (require(testthat)) {
  library(rgl)
  options(rgl.useNULL = TRUE)
  test_check("rgl")
} else
	warning("'testthat' package is needed for tests")
