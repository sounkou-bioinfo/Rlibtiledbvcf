
# RTileDBvcf

Minimal R bindings and CLI wrapper for
[TileDB-VCF](https://github.com/TileDB-Inc/TileDB-VCF).

We build the CLI and the library, provide a CLI wrapper, and begin
building complete bindings to the TileDB VCF API and it’s HTSlib plugin.

## Setup and Version Checking

``` r
library(RTileDBvcf)
library(vcfppR)
tiledb_vcf_cli_version() |> cat(sep = "\n")
#> TileDB-VCF version 50e78a5
#> TileDB version 2.28.1
#> htslib version 1.22.1
tiledb_vcf_version() |> cat(sep = "\n")
#> TileDB-VCF version 
#> TileDB version 2.28.1
#> htslib version 1.21
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
#>    /tmp/Rtmpz2AlcX/my_dataset 
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
#>    /tmp/Rtmpz2AlcX/my_dataset 
#>    --samples-file 
#>    /tmp/Rtmpz2AlcX/file14900b6751da76.txt 
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
