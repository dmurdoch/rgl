if (require(testthat)) {
  
  getknownscene <- function(name, file = paste0("testdata/", name, ".rds")) {
    readRDS(file)
  }
  
  library(rgl)
  options(rgl.useNULL = TRUE)
  test_check("rgl")
} else
	warning("'testthat' package is needed for tests")
