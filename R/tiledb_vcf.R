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
