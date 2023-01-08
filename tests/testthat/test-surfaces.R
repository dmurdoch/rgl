library(rgl)

test_that("surface dimensions work", {
	x <- 1:3
	y <- 1:5
	z <- matrix(1:15, 3, 5)
	open3d()
	surface3d(x, y, z, col = "red")
	surface3d(x, z, y, col = "blue")
	surface3d(z, y, x, col = "green")
	surface3d(x, z, z, col = "purple")
	surface3d(z, y, z, col = "orange")
	surface3d(z, z, y, col = "brown")
	surface3d(z, z, z, col = "white")
	surface3d(x, y, as.numeric(z + 1), col = "black")
	expect_error( surface3d(y, x, z))
	expect_error( surface3d(y, z, x))
	expect_error( surface3d(z, x, y))
	expect_error( surface3d(y, z, z))
	expect_error( surface3d(z, z, x))
  expect_error( surface3d(z, x, z))
  expect_error( surface3d(as.numeric(z), y, x))
  expect_error( surface3d(x, as.numeric(z), y))
})
