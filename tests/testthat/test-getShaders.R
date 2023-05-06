library(rgl)

test_that("getShaders works", {
	x <- 1:3
	y <- 1:5
	z <- matrix(1:15, 3, 5)
	open3d()
	id <- surface3d(x, y, z, col = "red")
	if (requireNamespace("V8"))
	  expect_no_condition(getShaders(id))
})
