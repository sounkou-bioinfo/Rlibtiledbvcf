
# libtiledbvcf and TileDB-VCF CLI For R

Minimal R bindings and CLI wrapper for
[TileDB-VCF](https://github.com/TileDB-Inc/TileDB-VCF).

We build the CLI and the library, provide a CLI wrapper. CLI wrapped
using processx is used for creating, ingesting, exporting, and querying
TileDB-VCF datasets and library will be used for future R bindings. This
is a work in progress.

## Installation

This package build from source htslib among other dependencies of
libtiledbvcf per the official cmake build instructions. This setup
requires autoreconf and an up to date cmake sadly, so cmake, autoreconf,
neeeds to be installed on your system(in feature we may use `BioCmake`
package to make sure cmake is downloaded if needed). We may find the way
to reliably use external htlib to link against but this look brittle. So
for macOS you can use `brew install cmake autoconf automake libtool` to
get started. For linux you can use your package manager to install these
dependencies (they are usally installed). For windows we recommend using
WSL2 with Ubuntu since we have no plans to configure the package for
windows.

## Setup and Version Checking

``` r
library(Rlibtiledbvcf)
library(vcfppR)
tiledb_vcf_cli_version() |> cat(sep = "\n")
#> TileDB-VCF version fbb00ac
#> TileDB version 2.28.1
#> htslib version 1.22.1
tiledb_vcf_version() |> cat(sep = "\n")
#> TileDB-VCF version 0fe1b45-modified
#> TileDB version 2.28.1
#> htslib version 1.22.1
```

## Creating a TileDB-VCF Dataset

``` r
# Create a new dataset
uri <- file.path(tempdir(), "my_dataset")
tiledb_vcf_create(uri, print_command = TRUE)
#> 
#> Running command:
#> /usr/local/lib/R/site-library/RTileDBvcf/TileDBVCF/bin/tiledbvcf 
#>    create 
#>    --uri 
#>    /tmp/Rtmp6J341r/my_dataset 
#>    --anchor-gap 
#>    1000 
#>    --tile-capacity 
#>    10000 
#>    --checksum 
#>    sha256
#> $status
#> [1] 0
#> 
#> $stdout
#> [1] ""
#> 
#> $stderr
#> [1] ""
#> 
#> $timeout
#> [1] FALSE
```

## Ingesting Multiple VCFs

``` r
sample_names <- c("HG00096", "HG00097", "HG00099", "HG00100")
sample_vcfs <- vapply(
    sample_names,
    function(s) {
        system.file("extdata", paste0(s, ".vcf.gz"), package = "RTileDBvcf")
    },
    character(1)
)

# Write samples file for ingestion (one VCF per line)
samples_file <- tempfile(fileext = ".txt")
writeLines(sample_vcfs, samples_file)

# Ingest using TileDB-VCF CLI
tiledb_vcf_store(
    uri,
    samples_file = samples_file,
    echo = TRUE,
    print_command = TRUE
)
#> 
#> Running command:
#> /usr/local/lib/R/site-library/RTileDBvcf/TileDBVCF/bin/tiledbvcf 
#>    store 
#>    --uri 
#>    /tmp/Rtmp6J341r/my_dataset 
#>    --samples-file 
#>    /tmp/Rtmp6J341r/file1a33192f3e2633.txt 
#>    --threads 
#>    4 
#>    --total-memory-budget-mb 
#>    2048 
#>    --sample-batch-size 
#>    10
#> $status
#> [1] 0
#> 
#> $stdout
#> [1] ""
#> 
#> $stderr
#> [1] ""
#> 
#> $timeout
#> [1] FALSE
```

## Listing Samples in the Dataset

``` r
tiledb_vcf_list(uri)
#> [1] "HG00096" "HG00097" "HG00099" "HG00100"
```

## Exporting and Validating VCFs (Round-Trip)

``` r
# Export and compare each sample individually
all_identical <- TRUE
for (i in seq_along(sample_names)) {
    export_file <- tempfile(fileext = ".vcf")
    tiledb_vcf_export(
        uri = uri,
        output_path = export_file,
        sample_names = sample_names[i], # Export one sample at a time
        merge = TRUE,
        echo = TRUE
    )
    stopifnot(file.exists(export_file))
    orig_tab <- vcftable(sample_vcfs[i])
    exp_tab <- vcftable(export_file)
    # Filter exported table for current sample if needed
    if ("sample" %in% names(exp_tab)) {
        exp_tab <- exp_tab[exp_tab$sample == sample_names[i], ]
    }
    # Compare relevant columns
    identical_chr <- identical(orig_tab$chr, exp_tab$chr)
    identical_pos <- identical(orig_tab$pos, exp_tab$pos)
    identical_gt <- identical(orig_tab$gt, exp_tab$gt)
    if (!(identical_chr && identical_pos && identical_gt)) {
        all_identical <- FALSE
        cat("Comparison failed for sample:", sample_names[i], "\n")
    }
}
if (all_identical) {
    cat("All samples are identical in chrom, pos, and GT columns.\n")
}
#> All samples are identical in chrom, pos, and GT columns.
```

## References

- [TileDB-VCF GitHub
  Repository](https://github.com/TileDB-Inc/TileDB-VCF)
