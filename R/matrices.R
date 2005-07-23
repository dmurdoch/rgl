# Functions for creating 4x4 graphics matrices

scale3d <- function(x,y,z) diag(c(x,y,z,1))

translate3d <- function(x,y,z)
{
    result <- diag(4)
    result[4,1:3] <- c(x,y,z)
    result
}

rotate3d <- function(angle,x,y,z,matrix)
{
    if (missing(matrix))
    {
        u <- c(x,y,z)/sqrt(x^2+y^2+z^2)
        cosa <- cos(angle)
        sina <- sin(angle)
        matrix <- (1-cosa)*outer(u,u)
        matrix <- matrix + diag(3)*cosa
        matrix[1,2] <- matrix[1,2] - sina*u[3]
        matrix[1,3] <- matrix[1,3] + sina*u[2]
        matrix[2,1] <- matrix[2,1] + sina*u[3]
        matrix[2,3] <- matrix[2,3] - sina*u[1]
        matrix[3,1] <- matrix[3,1] - sina*u[2]
        matrix[3,2] <- matrix[3,2] + sina*u[1]
    }
    cbind(rbind(matrix,c(0,0,0)),c(0,0,0,1))
}

# Coordinate conversions

as.homogeneous <- function(x) c(x,1)

as.euclidean <- function(x) c(x[1]/x[4],x[2]/x[4],x[3]/x[4])

