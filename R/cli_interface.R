#' TileDB-VCF Command Line Interface
#'
#' @description
#' These functions provide R interfaces to the TileDB-VCF command line utility.
#' They use the `processx` package to execute the TileDB-VCF binary that is
#' installed with this package.
#'
#' @details
#' The TileDB-VCF CLI provides commands for:
#' \itemize{
#'   \item \code{create}: Creating empty TileDB-VCF datasets
#'   \item \code{store}: Ingesting VCF files into datasets
#'   \item \code{export}: Exporting data from datasets
#'   \item \code{list}: Listing samples in datasets
#'   \item \code{stat}: Getting dataset statistics
#'   \item \code{delete}: Deleting samples from datasets
#' }
#'
#' @name tiledb_vcf_cli
#' @rdname tiledb_vcf_cli
NULL

#' Get TileDB-VCF CLI Path
#'
#' @description
#' Returns the path to the TileDB-VCF command line binary installed with this package.
#'
#' @return Character string with the path to the TileDB-VCF binary.
#' @export
#' @examples
#' \dontrun{
#' tiledb_vcf_cli_path()
#' }
tiledb_vcf_cli_path <- function() {
  # Find the CLI binary in the package installation
  cli_path <- system.file(
    "TileDBVCF",
    "bin",
    "tiledbvcf",
    package = "Rlibtiledbvcf"
  )

  if (!file.exists(cli_path) || cli_path == "") {
    stop(
      "TileDB-VCF CLI not found. Please ensure the package was installed correctly."
    )
  }

  return(cli_path)
}

#' Run TileDB-VCF CLI Command
#'
#' @description
#' Internal function to execute TileDB-VCF CLI commands using processx.
#'
#' @param args Character vector of command line arguments
#' @param timeout Timeout in seconds (default: 60)
#' @param echo Logical, whether to echo output to console (default: FALSE)
#' @param error_on_status Logical, whether to throw error on non-zero exit (default: TRUE)
#' @param wd Working directory (default: current directory)
#' @param print_command Logical, whether to print the command being run (default: FALSE)
#'
#' @return List with components:
#' \itemize{
#'   \item \code{status}: Exit status
#'   \item \code{stdout}: Standard output
#'   \item \code{stderr}: Standard error
#'   \item \code{timeout}: Whether timeout occurred
#' }
#' @keywords internal
#' @export
run_tiledb_vcf_cli <- function(
  args,
  timeout = 60,
  echo = FALSE,
  error_on_status = TRUE,
  wd = ".",
  print_command = FALSE
) {
  cli_path <- tiledb_vcf_cli_path()
  if (print_command) {
    cat("\nRunning command:\n")
    cat(cli_path, "\n")
    for (a in args) {
      cat("  ", a, "\n")
    }
    cat("\n")
  }
  result <- processx::run(
    command = cli_path,
    args = args,
    timeout = timeout,
    echo = echo,
    error_on_status = error_on_status,
    wd = wd
  )

  return(result)
}

#' Get TileDB-VCF CLI Version
#'
#' @description
#' Get the version of the TileDB-VCF command line utility.
#'
#' @param echo Logical, whether to echo output to console (default: FALSE)
#'
#' @return Character string with version information
#' @export
#' @examples
#' \dontrun{
#' tiledb_vcf_cli_version()
#' }
tiledb_vcf_cli_version <- function(echo = FALSE) {
  result <- run_tiledb_vcf_cli(c("--version"), echo = echo)
  return(trimws(result$stdout))
}

#' Create TileDB-VCF Dataset
#'
#' @description
#' Create an empty TileDB-VCF dataset at the specified URI.
#'
#' @param uri Character string specifying the dataset URI (required)
#' @param attributes Character vector of INFO/FORMAT field names to store as separate attributes
#' @param vcf_attributes Character string with VCF file to use for extracting all INFO/FORMAT fields
#' @param anchor_gap Integer, anchor gap size (default: 1000)
#' @param no_duplicates Logical, allow duplicate start positions (default: FALSE)
#' @param tile_capacity Integer, tile capacity for array schema (default: 10000)
#' @param checksum Character string, checksum type: "md5", "sha256", or "none" (default: "sha256")
#' @param echo Logical, whether to echo output to console (default: FALSE)
#' @param print_command Logical, whether to print the command being run (default: FALSE)
#' @param ... Additional arguments passed as --key=value pairs
#'
#' @return List with command execution results
#' @export
#' @examples
#' \dontrun{
#' # Create a basic dataset
#' tiledb_vcf_create("my_dataset")
#'
#' # Create with specific attributes
#' tiledb_vcf_create("my_dataset",
#'                   attributes = c("info_AF", "fmt_GT", "fmt_DP"))
#' }
tiledb_vcf_create <- function(
  uri,
  attributes = NULL,
  vcf_attributes = NULL,
  anchor_gap = 1000,
  no_duplicates = FALSE,
  tile_capacity = 10000,
  checksum = "sha256",
  echo = FALSE,
  print_command = FALSE,
  ...
) {
  args <- c("create", "--uri", uri)
  if (!is.null(attributes)) {
    args <- c(args, "--attributes", paste(attributes, collapse = ","))
  }
  if (!is.null(vcf_attributes)) {
    args <- c(args, "--vcf-attributes", vcf_attributes)
  }
  args <- c(args, "--anchor-gap", as.character(anchor_gap))
  args <- c(args, "--tile-capacity", as.character(tile_capacity))
  args <- c(args, "--checksum", checksum)
  if (no_duplicates) {
    args <- c(args, "--no-duplicates")
  }
  extra_args <- list(...)
  for (name in names(extra_args)) {
    args <- c(
      args,
      paste0("--", gsub("_", "-", name)),
      as.character(extra_args[[name]])
    )
  }
  result <- run_tiledb_vcf_cli(
    args,
    echo = echo,
    print_command = print_command
  )
  cat(result$stdout)
  return(result)
}

#' Store VCF Files in TileDB-VCF Dataset
#'
#' @description
#' Ingest VCF files into an existing TileDB-VCF dataset.
#'
#' @param uri Character string specifying the dataset URI (required)
#' @param vcf_files Character vector of VCF file paths to ingest
#' @param samples_file Character string, file with VCF paths (one per line)
#' @param threads Integer, number of threads (default: 4)
#' @param memory_budget_mb Integer, total memory budget in MB (default: 2048)
#' @param sample_batch_size Integer, samples per batch (default: 10)
#' @param scratch_dir Character string, directory for temporary files
#' @param echo Logical, whether to echo output to console (default: TRUE)
#' @param print_command Logical, whether to print the command being run (default: FALSE)
#' @param ... Additional arguments passed as --key=value pairs
#'
#' @return List with command execution results
#' @export
#' @examples
#' \dontrun{
#' # Store single VCF file
#' tiledb_vcf_store("my_dataset", "sample1.vcf.gz")
#'
#' # Store multiple VCF files
#' tiledb_vcf_store("my_dataset", c("sample1.vcf.gz", "sample2.vcf.gz"))
#'
#' # Store with custom settings
#' tiledb_vcf_store("my_dataset", "sample1.vcf.gz",
#'                  threads = 8, memory_budget_mb = 4096)
#' }
tiledb_vcf_store <- function(
  uri,
  vcf_files = NULL,
  samples_file = NULL,
  threads = 4,
  memory_budget_mb = 2048,
  sample_batch_size = 10,
  scratch_dir = NULL,
  echo = TRUE,
  print_command = FALSE,
  ...
) {
  args <- c("store", "--uri", uri)

  # Add VCF files as positional arguments (no --vcf flag)
  if (!is.null(vcf_files)) {
    args <- c(args, vcf_files)
  } else if (!is.null(samples_file)) {
    args <- c(args, "--samples-file", samples_file)
  } else {
    stop("Either 'vcf_files' or 'samples_file' must be provided")
  }

  # Add options
  args <- c(args, "--threads", as.character(threads))
  args <- c(args, "--total-memory-budget-mb", as.character(memory_budget_mb))
  args <- c(args, "--sample-batch-size", as.character(sample_batch_size))

  if (!is.null(scratch_dir)) {
    args <- c(args, "--scratch-dir", scratch_dir)
  }

  # Add additional arguments from ...
  extra_args <- list(...)
  for (name in names(extra_args)) {
    args <- c(
      args,
      paste0("--", gsub("_", "-", name)),
      as.character(extra_args[[name]])
    )
  }

  result <- run_tiledb_vcf_cli(
    args,
    echo = echo,
    timeout = 3600,
    print_command = print_command
  )
  cat(result$stdout)
  return(result)
}

#' Export Data from TileDB-VCF Dataset
#'
#' @description
#' Export variant data from a TileDB-VCF dataset.
#'
#' @param uri Character string specifying the dataset URI (required)
#' @param output_format Character string, output format: "b" (BCF), "v" (VCF), "z" (VCF.gz), "t" (TSV) (default: "v")
#' @param output_path Character string, output file path
#' @param regions Character vector of regions in format "chr:start-end"
#' @param regions_file Character string, BED file with regions
#' @param sample_names Character vector of sample names to export
#' @param samples_file Character string, file with sample names (one per line)
#' @param tsv_fields Character vector of TSV fields to export (for TSV format)
#' @param limit Integer, maximum number of records to export
#' @param merge Logical, export combined VCF file (default: FALSE)
#' @param memory_budget_mb Integer, memory budget in MB (default: 2048)
#' @param echo Logical, whether to echo output to console (default: TRUE)
#' @param print_command Logical, whether to print the command being run (default: FALSE)
#' @param ... Additional arguments passed as --key=value pairs
#'
#' @return List with command execution results
#' @export
#' @examples
#' \dontrun{
#' # Export all data as VCF
#' tiledb_vcf_export("my_dataset", output_path = "output.vcf")
#'
#' # Export specific region and samples
#' tiledb_vcf_export("my_dataset",
#'                   regions = "chr1:1000000-2000000",
#'                   sample_names = c("sample1", "sample2"),
#'                   output_path = "region.vcf")
#'
#' # Export as TSV with specific fields
#' tiledb_vcf_export("my_dataset",
#'                   output_format = "t",
#'                   tsv_fields = c("SAMPLE", "POS", "REF", "ALT"),
#'                   output_path = "variants.tsv")
#' }
tiledb_vcf_export <- function(
  uri,
  output_format = "v",
  output_path = NULL,
  regions = NULL,
  regions_file = NULL,
  sample_names = NULL,
  samples_file = NULL,
  tsv_fields = NULL,
  limit = NULL,
  merge = FALSE,
  memory_budget_mb = 2048,
  echo = TRUE,
  print_command = FALSE,
  ...
) {
  args <- c("export", "--uri", uri)

  # Output format and path
  args <- c(args, "--output-format", output_format)
  if (!is.null(output_path)) {
    args <- c(args, "--output-path", output_path)
  }

  # Regions
  if (!is.null(regions)) {
    args <- c(args, "--regions", paste(regions, collapse = ","))
  } else if (!is.null(regions_file)) {
    args <- c(args, "--regions-file", regions_file)
  }

  # Samples
  if (!is.null(sample_names)) {
    args <- c(args, "--sample-names", paste(sample_names, collapse = ","))
  } else if (!is.null(samples_file)) {
    args <- c(args, "--samples-file", samples_file)
  }

  # TSV fields
  if (!is.null(tsv_fields)) {
    args <- c(args, "--tsv-fields", paste(tsv_fields, collapse = ","))
  }

  # Other options
  if (!is.null(limit)) {
    args <- c(args, "--limit", as.character(limit))
  }

  if (merge) {
    args <- c(args, "--merge")
  }

  args <- c(args, "--mem-budget-mb", as.character(memory_budget_mb))

  # Add additional arguments from ...
  extra_args <- list(...)
  for (name in names(extra_args)) {
    args <- c(
      args,
      paste0("--", gsub("_", "-", name)),
      as.character(extra_args[[name]])
    )
  }

  result <- run_tiledb_vcf_cli(
    args,
    echo = echo,
    timeout = 3600,
    print_command = print_command
  ) # 1 hour timeout
  cat(result$stdout)
  return(result)
}

#' List Samples in TileDB-VCF Dataset
#'
#' @description
#' List all sample names present in a TileDB-VCF dataset.
#'
#' @param uri Character string specifying the dataset URI (required)
#' @param echo Logical, whether to echo output to console (default: FALSE)
#' @param print_command Logical, whether to print the command being run (default: FALSE)
#'
#' @return Character vector of sample names
#' @export
#' @examples
#' \dontrun{
#' samples <- tiledb_vcf_list("my_dataset")
#' print(samples)
#' }
tiledb_vcf_list <- function(uri, echo = FALSE, print_command = FALSE) {
  args <- c("list", "--uri", uri)
  result <- run_tiledb_vcf_cli(
    args,
    echo = echo,
    print_command = print_command
  )

  # Parse output to get sample names
  if (result$status == 0 && nchar(result$stdout) > 0) {
    samples <- strsplit(trimws(result$stdout), "\n")[[1]]
    return(samples)
  } else {
    return(character(0))
  }
}

#' Get TileDB-VCF Dataset Statistics
#'
#' @description
#' Print high-level statistics about a TileDB-VCF dataset.
#'
#' @param uri Character string specifying the dataset URI (required)
#' @param echo Logical, whether to echo output to console (default: TRUE)
#' @param print_command Logical, whether to print the command being run (default: FALSE)
#'
#' @return List with command execution results containing statistics
#' @export
#' @examples
#' \dontrun{
#' stats <- tiledb_vcf_stat("my_dataset")
#' }
tiledb_vcf_stat <- function(uri, echo = TRUE, print_command = FALSE) {
  args <- c("stat", "--uri", uri)
  result <- run_tiledb_vcf_cli(
    args,
    echo = echo,
    print_command = print_command
  )
  cat(result$stdout)
  return(result)
}

#' Delete Samples from TileDB-VCF Dataset
#'
#' @description
#' Delete specified samples from a TileDB-VCF dataset.
#'
#' @param uri Character string specifying the dataset URI (required)
#' @param sample_names Character vector of sample names to delete (required)
#' @param echo Logical, whether to echo output to console (default: TRUE)
#' @param print_command Logical, whether to print the command being run (default: FALSE)
#'
#' @return List with command execution results
#' @export
#' @examples
#' \dontrun{
#' # Delete specific samples
#' tiledb_vcf_delete("my_dataset", c("sample1", "sample2"))
#' }
tiledb_vcf_delete <- function(
  uri,
  sample_names,
  echo = TRUE,
  print_command = FALSE
) {
  if (is.null(sample_names) || length(sample_names) == 0) {
    stop("'sample_names' must be provided and non-empty")
  }

  args <- c(
    "delete",
    "--uri",
    uri,
    "--sample-names",
    paste(sample_names, collapse = ",")
  )
  result <- run_tiledb_vcf_cli(
    args,
    echo = echo,
    print_command = print_command
  )
  cat(result$stdout)
  return(result)
}
