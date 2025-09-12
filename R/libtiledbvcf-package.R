## usethis namespace: start
#' @useDynLib Rlibtiledbvcf, .registration = TRUE
## usethis namespace: end
NULL

#' Rlibtiledbvcf: R Interface to TileDB-VCF
#'
#' @description
#' The Rlibtiledbvcf package provides an R interface to the TileDB-VCF library,
#' a highly performant C++ library for storing and querying genomic variant data.
#' TileDB-VCF uses the TileDB storage engine to enable efficient compression,
#' parallel processing, and cloud-native capabilities for VCF (Variant Call Format) data.
#'
#' @details
#' This package provides R bindings to TileDB-VCF functionality, including:
#' \itemize{
#'   \item Low-level C API bindings for version information and availability checking
#'   \item High-level CLI interface using processx for all TileDB-VCF operations
#'   \item Dataset creation, VCF ingestion, and data export capabilities
#'   \item Sample management and dataset statistics
#'   \item Integration with the TileDB ecosystem and vcfppR for HTSLib support
#' }
#'
#' The package is designed to work with pre-built TileDB-VCF libraries and
#' integrates with the vcfppR package for HTSLib support.
#'
#' @section Key Functions:
#' \describe{
#'   \item{\code{\link{tiledb_vcf_version}}}{Get TileDB-VCF library version}
#'   \item{\code{\link{tiledb_vcf_available}}}{Check if TileDB-VCF is available}
#'   \item{\code{\link{tiledb_vcf_cli_version}}}{Get TileDB-VCF CLI version}
#'   \item{\code{\link{tiledb_vcf_create}}}{Create TileDB-VCF dataset}
#'   \item{\code{\link{tiledb_vcf_store}}}{Store VCF files in dataset}
#'   \item{\code{\link{tiledb_vcf_export}}}{Export data from dataset}
#'   \item{\code{\link{tiledb_vcf_list}}}{List samples in dataset}
#'   \item{\code{\link{tiledb_vcf_stat}}}{Get dataset statistics}
#'   \item{\code{\link{tiledb_vcf_delete}}}{Delete samples from dataset}
#' }
#'
#' @section System Requirements:
#' \itemize{
#'   \item cmake (for building TileDB-VCF)
#'   \item wget or curl (for downloading sources)
#'   \item C++17 compatible compiler
#'   \item vcfppR package (for HTSLib integration)
#' }
#'
#' @author Sounkalo Koutoure
#' @references
#' \itemize{
#'   \item TileDB-VCF: \url{https://github.com/TileDB-Inc/TileDB-VCF}
#'   \item TileDB: \url{https://tiledb.com/}
#'   \item VCF Format: \url{https://samtools.github.io/hts-specs/VCFv4.3.pdf}
#' }
#'
#' @name Rlibtiledbvcf
#' @aliases Rlibtiledbvcf
NULL
