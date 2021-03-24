# Project the shadow of one mesh object onto another

shadow3d <- function(obj, mesh, plot = TRUE, 
										 up = c(0, 0, 1), P = projectDown(up),
										 outside = FALSE, ...) {
	triangles <- as.triangles3d(mesh)
	ntri <- nrow(triangles) / 3
	projected <- P %*% t(triangles)
	
	fn <- function(xyz) {
		result <- rep(-Inf, nrow(xyz))
		r <- rbind(P %*% t(xyz), 1)
		for (i in 1:ntri) {
			# For each triangle, find the barycentric parameters
			# of each point in xyz using relation R lambda = r = (x,y,1)'
			R <- rbind(projected[,(0:2) + 3*i - 2], 1)
			lambda <- tryCatch(solve(R, r),
												 error = function(e) matrix(-Inf, 3, ncol(r)))
			# If the smallest barycentric coord is positive, the point
			# is in the triangle
			minlambda <- apply(lambda, 2, min)
			result <- pmax(result, minlambda)
		}
		result
	}
	
	if (outside)
		levels <- c(Inf, 0, -Inf)
	else
	  levels <- c(0, Inf)

	filledContour3d(obj, fn, levels = levels, 
								  plot = plot, ...)
}

projectDown <- function(up) {
	P <- GramSchmidt(up, c(1, 0, 0), c(0, 1, 0))
	if (det(P) < 0)
		P[3,] <- -P[3,]
	P <- P[2:3,]	
}

facing3d <- function(obj, up = c(0, 0, 1),
										 P = projectDown(up), 
										 front = TRUE, strict = TRUE) {

	obj <- as.tmesh3d(obj)
	r <- P %*% t(asEuclidean(t(obj$vb)))
	area <- function(i) {
		x <- r[1,obj$it[,i]]
		y <- r[2,obj$it[,i]]
		area <- 0
		for (j in 1:3)
			area <- area + x[j]*y[j %% 3 + 1] - x[j %% 3 + 1]*y[j]
		area
	}
	areas <- vapply(seq_len(ncol(obj$it)), area, 0)
	if (isTRUE(front))
		keep <- areas > 0
	else
		keep <- areas < 0
	if (!strict)
		keep <- keep | areas == 0
	obj$it <- obj$it[, keep]
	cleanMesh3d(obj)
}
