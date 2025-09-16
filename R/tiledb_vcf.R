#' Get TileDB-VCF Version
#'
#' Returns the version of the TileDB-VCF library.
#'
#' @return A character string containing the TileDB-VCF version.
#' @export
#' @examples
#' tiledb_vcf_version()
tiledb_vcf_version <- function() {
  .Call(RC_tiledb_vcf_version, PACKAGE = "Rlibtiledbvcf")
}

#' Check TileDB-VCF Availability
#'
#' Checks if the TileDB-VCF library is available and functional.
#'
#' @return A logical value indicating if TileDB-VCF is available.
#' @export
#' @examples
#' tiledb_vcf_available()
tiledb_vcf_available <- function() {
  .Call(RC_tiledb_vcf_available, PACKAGE = "Rlibtiledbvcf")
}

#' Get the TileDB-VCF Library Path
#'
#' Returns the path to the TileDB-VCF libraries installed with the Rlibtiledbvcf package.
#'
#' @return A character string containing the TileDB-VCF library path.
#' @export
tiledb_vcf_library_path <- function() {
  libs_path <- system.file(
    "TileDBVCF",
    "lib",
    package = "Rlibtiledbvcf"
  )
  return(libs_path)
}

#' Get TileDB-VCF Library Items
#' Returns the full path to the library items required to link against the TileDB-VCF libraries
#' @return A character string containing the library items.
#' @export
tiledb_vcf_library_items <- function() {
  libs_path <- tiledb_vcf_library_path()
  items <- list.files(libs_path, full.names = TRUE)
  items <- items[grepl(.Platform$dynlib.ext, items, fixed = TRUE)] |>
    normalizePath() |>
    paste0(collapse = " ")
  return(items)
}

#' Get TileDB-VCF Include Path
#' Returns the include path required to compile code that uses the TileDB-VCF library.
#' @return A character string containing the include path.
#' @export
tiledb_vcf_include_path <- function() {
  include_path <- system.file(
    "TileDBVCF",
    "include",
    package = "Rlibtiledbvcf"
  )
  return(include_path)
}

#' Get TileDB-VCF Include Headers
#' Returns the include headers required to compile code that uses the TileDB-VCF library.
#' @return A character string containing the include headers.
#' @export
tiledb_vcf_include_headers <- function() {
  include_path <- tiledb_vcf_include_path()
  headers <- list.files(include_path, full.names = TRUE, recursive = TRUE)
  headers <- headers[grepl("\\.h$", headers)] |>
    normalizePath() |>
    paste0(collapse = " ")
  return(headers)
}

#' Get TileDB-VCF Compilation Flags
#' Returns the compilation flags required to compile code that uses the TileDB-VCF library.
#' @return A character string containing the compilation flags.
#' @export
tiledb_vcf_pkg_cflags <- function() {
  libs <- tiledb_vcf_library_items()
  includes <- tiledb_vcf_include_headers()
  pkg_cflags <- paste0("-I", tiledb_vcf_include_path())
  return(pkg_cflags)
}

#' Get TileDB-VCF Linking Flags
#'' Returns the linking flags required to link against the TileDB-VCF library.
#'' @return A character string containing the linking flags.
#' @export
tiledb_vcf_pkg_lflags <- function() {
  libs <- tiledb_vcf_library_items()
  lflags <- paste0("-L", tiledb_vcf_library_path(), " -l:", libs)
  return(lflags)
}
