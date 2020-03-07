# This code is mostly taken from Shiny, which has lots of authors:  see
# https://github.com/rstudio/shiny/blob/master/R/utils.R

# Evaluate an expression using our own private stream of
# randomness (not affected by set.seed).
withPrivateSeed <- local({
  
  ownSeed <- NULL
  
  function(expr) {
  # Save the old seed if present.
  if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
    hasOrigSeed <- TRUE
    origSeed <- .GlobalEnv$.Random.seed
  } else {
    hasOrigSeed <- FALSE
  }
  
  # Swap in the private seed.
  if (is.null(ownSeed)) {
    if (hasOrigSeed) {
      # Move old seed out of the way if present.
      rm(.Random.seed, envir = .GlobalEnv, inherits = FALSE)
    }
  } else {
    .GlobalEnv$.Random.seed <- ownSeed
  }
  
  # On exit, save the modified private seed, and put the old seed back.
  on.exit({
    ownSeed <<- .GlobalEnv$.Random.seed
    
    if (hasOrigSeed) {
      .GlobalEnv$.Random.seed <- origSeed
    } else {
      rm(.Random.seed, envir = .GlobalEnv, inherits = FALSE)
    }
    # Shiny had this workaround.  I think we don't need it, and have
    # commented it out.
    # Need to call this to make sure that the value of .Random.seed gets put
    # into R's internal RNG state. (Issue #1763)
    
    # httpuv::getRNGState()
  })
  
  expr
}
})

# Version of sample that runs with private seed
p_sample <- function(...) {
  withPrivateSeed(sample(...))
}