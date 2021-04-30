expect_known_scene <- function(name, close = TRUE, file = paste0("testdata/", name, ".rds"), ...) {
	testthat::local_edition(2)
	result <- testthat::expect_known_value(object = scene3d(), file = file, ...)
  if (close)
  	close3d()
  result
}
