library(rgl)

test_that("subscenes work", {
	
	# Show the Earth with a cutout by using clipplanes in subscenes
	
	lat <- matrix(seq(90, -90, len = 50)*pi/180, 50, 50, byrow = TRUE)
	long <- matrix(seq(-180, 180, len = 50)*pi/180, 50, 50)
	
	r <- 6378.1 # radius of Earth in km
	x <- r*cos(lat)*cos(long)
	y <- r*cos(lat)*sin(long)
	z <- r*sin(lat)
	
	open3d()
	obj <- surface3d(x, y, z, col = "white", 
									 texture = system.file("textures/worldsmall.png", package = "rgl"), 
									 specular = "black", axes = FALSE, box = FALSE, xlab = "", ylab = "", zlab = "",
									 normal_x = x, normal_y = y, normal_z = z)
	
	cols <- c(rep("chocolate4", 4), rep("burlywood1", 4), "darkgoldenrod1")
	rs <- c(6350, 5639, 4928.5, 4207, 3486, 
					(3486 + 2351)/2, 2351, (2351 + 1216)/2, 1216)
	for (i in seq_along(rs)) 
		obj <- c(obj, spheres3d(0, 0, col = cols[i], radius = rs[i]))
	
	root <- currentSubscene3d()
	
	newSubscene3d("inherit", "inherit", "inherit", copyShapes = TRUE, parent = root)
	clipplanes3d(1, 0, 0, 0)
	
	newSubscene3d("inherit", "inherit", "inherit", copyShapes = TRUE, parent = root)
	clipplanes3d(0, 1, 0, 0)
	
	newSubscene3d("inherit", "inherit", "inherit", copyShapes = TRUE, parent = root)
	clipplanes3d(0, 0, 1, 0)
	
	# Now delete the objects from the root subscene, to reveal the clipping planes
	useSubscene3d(root)
	delFromSubscene3d(obj)
  expect_known_scene("subscenes", tol = 1.e-6)
})
