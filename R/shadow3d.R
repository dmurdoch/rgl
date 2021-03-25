# Project the shadow of one mesh object onto another

shadow3d <- function(obj, mesh, plot = TRUE, 
										 up = c(0, 0, 1), P = projectDown(up),
										 outside = FALSE, ...) {
	triangles <- as.triangles3d(mesh)
	ntri <- nrow(triangles) / 3
	
	P <- t(P)   # The convention in rgl is row vectors on the left
	# but we'll be using column vectors on the right
	
	projected <- P %*% rbind(t(triangles), 1)
	projected <- projected[1:2,]/rep(projected[4,], each = 2)
	
	fn <- function(xyz) {
		result <- rep(-Inf, nrow(xyz))
		r <- P %*% rbind(t(xyz), 1)
		r <- rbind(r[1:2,]/rep(r[4,], each = 2), 1)
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
	if (length(up) == 4)
		up <- up[1:3]/up[4]
	else if (length(up) != 3)
		stop("'up' vector should be length 3.")
	P <- GramSchmidt(up, c(1, 0, 0), c(0, 1, 0))
	if (det(P) < 0)
		P[3,] <- -P[3,]
	cbind(rbind(t(P[c(2,3,1),]), 0), c(0, 0, 0, 1))
}

facing3d <- function(obj, up = c(0, 0, 1),
										 P = projectDown(up), 
										 front = TRUE, strict = TRUE) {
	obj <- as.tmesh3d(obj)
	P <- t(P)   # The convention in rgl is row vectors on the left
	# but we'll be using column vectors on the right
	r <- P %*% obj$vb
	r <- r[1:2,]/rep(r[4,], each = 2)
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
