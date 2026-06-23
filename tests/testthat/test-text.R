library(rgl)

test_that("text cex", {
  open3d()
  m <- text3d(1:2, 1:2, 1:2, c("ab", "cde"), cex = c(1,2))
  expect_s3_class(m, c("rglLowlevel", "rglId"))
  expect_equal(rgl.attrib(m, "cex"), 
               matrix(c(1,2), ncol=1, dimnames=list(NULL, "cex")))
  expect_equal(rgl.attrib(m, "radii"), 
               matrix(c(1, 1, 2, 2, 2), ncol=1, dimnames=list(NULL, "r")))
})