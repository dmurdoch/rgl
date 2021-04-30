set.seed(123)
test_that("3D sprites work", {
	open3d()
	particles3d( rnorm(100), rnorm(100), rnorm(100), color = rainbow(100) )
	# is the same as
	sprites3d( rnorm(100), rnorm(100), rnorm(100), color = rainbow(100),
						 lit = FALSE, alpha = .2,
						 textype = "alpha", texture = system.file("textures/particle.png", package = "rgl") )
	sprites3d( rnorm(10) + 6, rnorm(10), rnorm(10), shape = shade3d(tetrahedron3d(), col = "red") )
	expect_known_scene("r3d")
})
