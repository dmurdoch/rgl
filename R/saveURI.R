saveURI <- function(uri, con) {
  if (!grepl("^data:", uri))
    stop("Does not appear to be a data URI")
  header <- sub(",.*", "", uri)
  type <- sub(";.*", "", sub("^data:", "", header))
  encoding <- sub("^.*;", "", header)
  if (encoding != "base64")
    stop("Not encoded in base64")
  payload <- sub(paste0(header, ","), "", uri, fixed = TRUE)
  writeBin(base64_dec(payload), con)
  invisible(type)
}
