typeSignedByte    <- 5120
typeUnsignedByte  <- 5121
typeSignedShort   <- 5122
typeUnsignedShort <- 5123
typeSignedInt     <- 5124  # Not supported in glTF
typeUnsignedInt   <- 5125
typeFloat         <- 5126
typeDouble        <- 5130  # Not supported in glTF

gltfTypes <- c(byte = 5120, ubyte = 5121,
                   short = 5122, ushort = 5123,
                   uint = 5125, float = 5126,                     int = 5124, double = 5130)

getType <- function(x, types = "anyGLTF") {
  types <- match.arg(types, 
                     c(names(gltfTypes), c("anyGLTF", "any")), 
                     several.ok = TRUE)
  if ("anyGLTF" %in% types)
    types <- c(types, names(gltfTypes)[1:6])
  if ("any" %in% types)
    types <- c(types, names(gltfTypes))
  types <- unique(setdiff(types, c("anyGLTF", "any")))
  r <- suppressWarnings(range(x, na.rm = TRUE))
  if (is.integer(x) && 
      !any(is.na(x)) &&
      (r[1] >= 0 && 
       any(c("byte", "short", "int", "ubyte", "ushort", "uint") %in% types) ||
      (r[1] < 0 && 
       any(c("byte", "short", "int") %in% types))))
      {
    if (r[1] < 0 && ("byte" %in% types)) {
      if (-128 <= r[1] && r[2] <= 127)
        "byte"
      else if (-32768 <= r[1] && r[2] <= 32767 && ("short" %in% types))
        "short"
      else
        "int"
    } else {
      if (r[2] <= 255 && ("ubyte" %in% types))
        "ubyte"
      else if (r[2] <= 65535 && ("ushort" %in% types))
        "ushort"
      else
        "uint"
    }
  } else if (is.numeric(x)) {
    if ((-32768 <= r[1] && r[2] <= 32767 ||
         0 <= r[1] && r[2] <= 65535) && 
        isTRUE(all(x == as.integer(x))) &&
        any(c("byte", "short", "ubyte", "ushort") %in% types))
      getType(as.integer(x), types)
    else if ("float" %in% types)
      "float"
    else if ("double" %in% types)
      "double"
  } else
    stop('Unrecognized or disallowed type')
}

#' @title R6 Class for binary buffers in glTF files.
#'
#' @description
#' These files typically have one buffer holding all the
#' binary data for a scene.

Buffer <- R6Class("Buffer",
    public = list(

#' @param json
#'   list read from glTF file.
#' @param binfile
#'   optional External binary filename, or raw vector
#'
      initialize = function(json = NULL, binfile = NULL) {
        if (!is.null(json)) {
          private$buffers <- json$buffers
          private$bufferViews <- json$bufferViews
          private$accessors <- json$accessors
        }
        buffer <- self$getBuffer(0)
        if (is.null(buffer$uri)) {
          if (is.character(binfile))
            buffer$uri <- binfile
          else if (is.raw(binfile))
            buffer$bytes <- binfile
        }
        self$setBuffer(0, buffer)
      },

#' @description
#'   Load from file.
#'
#' @param uri Which file to load.
#' @param buf Which buffer number to load.
#'
      load = function(uri, buf = 0) {
        buffer <- self$getBuffer(buf)
        if (is.null(buffer))
          buffer <- list(byteLength = 0)
        self$closeBuffer(buf)
        if (is.character(uri)) {
          bytes <- readBin(uri, "raw", n = file.size(uri))
          buffer$uri <- uri
        } else if (is.raw(uri))
          bytes <- uri
        buffer$byteLength <- length(bytes)
        buffer$con <- rawConnection(bytes, open = "r+b")
        self$setBuffer(buf, buffer)
      },

#' @description
#'   Write open buffer to connection.
#'
#' @param con
#'   Output connection.
#' @param buf
#'   Buffer number.
#'
      saveOpenBuffer = function(con, buf = 0) {
        buffer <- self$getBuffer(buf)
        if (is.null(buffer) ||
            is.null(con0 <- buffer$con) ||
            !inherits(con0, "connection") ||
            !isOpen(con0))
          stop("buffer ", buf, " is not open.")
        bytes <- rawConnectionValue(con0)
        writeBin(bytes, con)
      },

#' @description
#'   Get buffer object.
#'
#' @param buf Buffer number.
#' @param default Default buffer object if `buf` not found.
#'
#' @return A list containing components described here:
#' \url{https://www.khronos.org/registry/glTF/specs/2.0/glTF-2.0.html#reference-buffer}.
#'
      getBuffer = function(buf, default = list(byteLength = 0)) {
        buffer <- if (buf + 1 <= length(private$buffers))
          private$buffers[[buf + 1]]
        if (is.null(buffer))
          default
        else
          structure(buffer, class = "gltfBuffer")
      },

#' @description
#'   Set buffer object.
#'
#' @param buf Buffer number.
#' @param buffer New value to insert.
#'
      setBuffer = function(buf, buffer)
        private$buffers[[buf + 1]] <- unclass(buffer),

#' @description
#'   Open a connection for the data in a buffer.
#'
#' @param buf Buffer number.
#'
#' @return An open binary connection.
#'
      openBuffer = function(buf) {
        buffer <- self$getBuffer(buf)
        if (is.null(buffer))
          stop("no such buffer")
        if (is.null(buffer$con)) {
          if (!is.null(bytes <- buffer$bytes)) {
            buffer$con <- rawConnection(bytes, open = "r+b")
            buffer$bytes <- NULL
            self$setBuffer(buf, buffer)
          } else if (is.null(buffer$uri)) {
            buffer$con <- rawConnection(raw(0), open = "r+b")
            self$setBuffer(buf, buffer)
          } else
            self$load(buffer$uri, buf = buf)
        }
        self$getBuffer(buf)$con
      },

#' @description
#'   Write data to buffer.
#'
#' @param values Values to write.
#' @param type Type to write.
#' @param size Byte size of each value.
#' @param buf Which buffer to write to.
#'
#' @return Byte offset of start of bytes written.
#'
      writeBuffer = function(values, type, size, buf = 0) {
        if (is.null(buffer <- self$getBuffer(buf)))
          self$setBuffer(buf, buffer <- list(byteLength = 0))
        byteLength <- buffer$byteLength
        byteOffset <- byteLength
        con <- self$openBuffer(buf)
        seek(con, byteOffset)
        byteOffset <- bitwAnd(byteOffset + size - 1, bitwNot(size - 1))
        if (is.null(byteLength))
          browser()
        if (byteOffset > byteLength) {
          writeBin(raw(byteOffset - byteLength), con)
        }
        if (type %in% c(typeFloat, typeDouble))
          values <- as.numeric(values)
        else
          values <- as.integer(values)
        writeBin(values, con, size = size, endian = "little")
        buffer <- self$getBuffer(buf)
        buffer$byteLength <- byteOffset + length(values)*size
        self$setBuffer(buf, buffer)
        byteOffset
      },

#' @description
#'   Close the connection in a buffer.
#'
#' If there was a connection open, this will save the
#' contents in the raw vector `bytes` within the buffer object.
#'
#' @param buf The buffer number.
#'
      closeBuffer = function(buf) {
        buffer <- self$getBuffer(buf)
        if (!is.null(buffer) &&
            !is.null(buffer$con)) {
          buffer$bytes <- rawConnectionValue(buffer$con)
          close(buffer$con)
          buffer$con <- NULL
          self$setBuffer(buf, buffer)
        }
      },

#' @description
#'   Close any open buffers.
#'
#'   Call this after working with a GLTF file to avoid warnings
#'   from R about closing unused connections.
#'
      closeBuffers = function() {
        for (i in seq_along(private$buffers)) {
          self$closeBuffer(i - 1)
        }
      },

#' @description
#'   Get bufferView object.
#'
#' @param bufv bufferView number.
#'
#' @return A list containing components described here:
#' \url{https://www.khronos.org/registry/glTF/specs/2.0/glTF-2.0.html#reference-bufferview}.
#'
      getBufferview = function(bufv) {
        bufferview <- private$bufferViews[[bufv+1]]
        if (is.null(bufferview))
          stop("bufferView ", bufv, " not found.")
        structure(bufferview, class = "gltfBufferview")
      },

#' @description
#'   Add a new buffer view.
#'
#' @param values Values to put in the view.
#' @param type Type of values.
#' @param size Size of values in bytes.
#' @param target Optional target use for values.
#' @param buf Which buffer to write to.
#'
#' @return New bufferView number.
#'
      addBufferView = function(values, type, size, target = NULL, buf = 0) {
        bufferview <- list()
        bufferview$buffer <- buf
        bufferview$byteLength <- size*length(values)

        buffer <- self$getBuffer(buf)

        bufferview$byteOffset <- self$writeBuffer(values, type, size, buf)
        if (!is.null(target))
          bufferview$target <- target
        self$setBufferview(length(private$bufferViews), bufferview)
        length(private$bufferViews) - 1
      },

#' @description
#'   Open a connecton to a buffer view.
#'
#' @param bufv Which bufferView.
#'
#' @return A connection.

      openBufferview = function(bufv) {
        bufferview <- self$getBufferview(bufv)
        con <- self$openBuffer(bufferview$buffer)
        seek(con, bufferview$byteOffset)
        con
      },

#' @description
#'   Set bufferView object.
#'
#' @param bufv bufferView number.
#' @param bufferView New value to insert.

      setBufferview = function(bufv, bufferView)
        private$bufferViews[[bufv + 1]] <- unclass(bufferView),

#' @description
#'   Get accessor object
#'
#' @param acc Accessor number
#'
#' @return A list containing components described here:
#' \url{https://www.khronos.org/registry/glTF/specs/2.0/glTF-2.0.html#reference-accessor}
#'
      getAccessor = function(acc)
        structure(private$accessors[[acc + 1]], class = "gltfAccessor"),

#' @description
#'   Set accessor object.
#'
#' @param acc Accessor number.
#' @param accessor New value to insert.
#'
      setAccessor = function(acc, accessor)
        private$accessors[[acc + 1]] <- unclass(accessor),

#' @description
#'   Read data given by accessor object.
#'
#' @param acc Accessor number.
#'
#' @return A vector or array as specified in the accessor.  For the `MATn` types, the 3rd index
#' indexes the element.
#'
      readAccessor = function(acc) {
        typenames <- c("5120" = "byte", "5121" = "unsigned_byte",
                       "5122" = "short", "5123" = "unsigned_short",
                       "5125" = "unsigned_int", "5126" = "float")
        types <- c("5120" = "int", "5121" = "int",
                   "5122" = "int", "5123" = "int",
                   "5125" = "int", "5126" = "double")
        sizes <- c("5120" = 1, "5121" = 1,
                   "5122" = 2, "5123" = 2,
                   "5125" = 4, "5126" = 4)
        signeds <- c("5120" = TRUE, "5121" = FALSE,
                     "5122" = TRUE, "5123" = FALSE,
                     "5125" = TRUE, # not really, but make readBin happy
                     "5126" = TRUE)
        lens <- c(SCALAR = 1, VEC2 = 2, VEC3 = 3, VEC4 = 4,
                  MAT2 = 4, MAT3 = 9, MAT4 = 16)
        if (acc + 1 > length(private$accessors))
          stop("No such accessor")
        accessor <- self$getAccessor(acc)
        view <- self$getBufferview(accessor$bufferView)
        con <- self$openBufferview(accessor$bufferView)
        ctype <- as.character(accessor$componentType)
        atype <- accessor$type
        type <- types[ctype]
        len <- lens[atype]
        size <- sizes[ctype]
        signed <- signeds[ctype]
        count <- accessor$count
        if (is.null(view$byteStride)) {
          skip <- 0
        } else
          skip <- len*size - view$byteStride
        if (is.null(byteOffset <- accessor$byteOffset))
          byteOffset <- 0
        start <- seek(con) + byteOffset

        if (skip == 0) {
          seek(con, start)
          values <- readBin(con, type, n = len*count,  size = size,
                            signed = signed, endian = "little")
        } else {
          values <- numeric(count*len)
          for (i in seq_len(count)) {
            seek(con, start + (i-1)*view$byteStride)
            values[(i-1)*len + seq_len(len)] <-
              readBin(con, type, n = len,  size = size,
                      signed = signed, endian = "little")
          }
        }
        if (ctype == "5125") { # fix up unsigned integers
          values[is.na(values)] <- 2^31
          values[values < 0] <- values[values < 0] + 2^32
        }
        if (!is.null(accessor$normalized) && accessor$normalized)
          values <- switch(ctype,
                           "5120" = (values + 128)/255 - 1, # byte
                           "5121" = values/255,             # u byte
                           "5122" = (values + 2^15)/65535 - 1, # short
                           "5123" = values/65535,           # u short
                           values)                 # default
        if (len > 1)
          if (grepl("MAT", atype)) {
            values <- array(values, dim=c(sqrt(len), sqrt(len), count))
          } else
            values <- matrix(values, ncol = len, byrow = TRUE)
        values
      },

#' @description
#'   Write values to accessor, not including `min` and `max`.
#'
#' @param values Values to write.
#' @param target Optional target use for values.
#' @param glTF Whether this is for glTF use.
#' @param useDouble Whether to write doubles or singles.
#'
#' @return New accessor number

      addAccessor = function(values, target = NULL, types = "anyGLTF") {
        componentTypeName <- getType(values, types)
        size <- switch(componentTypeName,
            "byte" =,       # typeSignedByte
            "ubyte" = 1,     # typeUnsignedByte = 1,
            "short" =,       # typeSignedShort =,
            "ushort" = 2,     # typeUnsignedShort = 2,
            "uint" =,       # typeUnsignedInt =,
            "int" =,       # typeSignedInt =,
            "float" = 4,     # typeFloat = 4,
            "double" = 8)     # typeDouble = 8)

        bufferView <- self$addBufferView(c(values), gltfTypes[componentTypeName],
                                    size = size, target = target)
        if (is.matrix(values) && nrow(values) > 1) {
          count <- ncol(values)
          type <- paste0("VEC", nrow(values))
        } else {
          count <- length(values)
          type <- "SCALAR"
        }
        accessor <- list(bufferView = bufferView,
                         componentType = gltfTypes[[componentTypeName]], # double to drop name
                         count = count,
                         type = type)

        private$accessors <- c(private$accessors, list(accessor))
        length(private$accessors) - 1
      },

#' @description
#'   Convert buffer to data URI.
#'
#' @param buf Buffer to convert.
#'
#' @return String containing data URI.

      dataURI = function(buf = 0) {
        self$closeBuffer(buf)
        buffer <- self$getBuffer(buf)
        if (is.null(buffer))
          stop("Buffer ", buf, " does not exist.")
        bytes <- buffer$bytes
        if (is.null(bytes)) {
          if (is.null(buffer$uri))
            return(dataURI(raw(0), mime = "application/octet-stream"))
          else {
            self$load(buffer$uri, buf)
            self$closeBuffer(buf)
            buffer <- self$getBuffer(buf)
            bytes <- buffer$bytes
          }
        }
        base64enc::dataURI(bytes, mime = "application/octet-stream")
      },


#' @description Convert to list.
#' @return List suitable for writing using JSON.
      as.list = function() {
        result <- list()
        for (n in names(private)) {
          thelist <- private[[n]]
          if (is.list(thelist) && length(thelist)) {
            for (i in seq_along(thelist))
              thelist[[i]] <- unclass(thelist[[i]])
            result[[n]] <- thelist
          }
        }
        result
      }
  ),

  private = list(
    buffers = list(),
    bufferViews = list(),
    accessors = list()
    # ,
    # 
    # finalize = function() {
    #   self$closeBuffers()
    # }

  )
)
