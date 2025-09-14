
# libtiledbvcf and TileDB-VCF CLI For R

Minimal R bindings and CLI wrapper for
[TileDB-VCF](https://github.com/TileDB-Inc/TileDB-VCF).

We build the CLI and the library, provide a CLI wrapper. CLI wrapped
using processx is used for creating, ingesting, exporting, and querying
TileDB-VCF datasets and library will be used for future R bindings. We
may add some additional functionality using vcfppR (through callbacks
for example). This is a work in progress.

## Installation

This package build from source htslib among other dependencies of
libtiledbvcf per the official cmake build instructions. This setup
requires autoreconf and an up to date cmake sadly, so cmake, autoreconf,
neeeds to be installed on your system. In future we may use
[`biocmake`](https://github.com/LTLA/biocmake/) package to make sure
cmake is downloaded if needed. We may find the way to reliably use
external htlib to link against but this look brittle. So for macOS you
can use `brew install cmake autoconf automake libtool` to get started
(as the github action of this package does it) . For linux you can use
your package manager to install these dependencies (they are usally
installed). For windows we recommend using WSL2 with Ubuntu since we
have no plans to configure the package for windows.

## Setup and Version Checking

``` r
library(Rlibtiledbvcf)
library(vcfppR)
tiledb_vcf_cli_version() |> cat(sep = "\n")
#> TileDB-VCF version 
#> TileDB version 2.28.1
#> htslib version 1.22.1
tiledb_vcf_version() |> cat(sep = "\n")
#> TileDB-VCF version 
#> TileDB version 2.28.1
#> htslib version 1.22.1
```

## Cloud Access

``` r
# Set the URI for the public S3 dataset
uri <- "s3://tiledb-inc-demo-data/tiledbvcf-arrays/v4/vcf-samples-20"
# Set AWS region for public S3 access
Sys.setenv(AWS_DEFAULT_REGION = "us-east-1")
# bcf export
export_bcf_path <- tempfile(fileext = ".bcf")
tiledb_vcf_export(
    uri = uri,
    output_path = export_bcf_path,
    regions = "chr1:1-2489564",
    sample_names = c("v2-usVwJUmo", "v2-WpXCYApL"),
    output_format = "b",
    merge = TRUE,
    echo = TRUE,
    print_command = TRUE
)
#> 
#> Running command:
#> /usr/local/lib/R/site-library/Rlibtiledbvcf/TileDBVCF/bin/tiledbvcf 
#>    export 
#>    --uri 
#>    s3://tiledb-inc-demo-data/tiledbvcf-arrays/v4/vcf-samples-20 
#>    --output-format 
#>    b 
#>    --output-path 
#>    /tmp/RtmpvNIn7S/filea24e3105e3b64.bcf 
#>    --regions 
#>    chr1:1-2489564 
#>    --sample-names 
#>    v2-usVwJUmo,v2-WpXCYApL 
#>    --merge 
#>    --mem-budget-mb 
#>    2048
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

bcf_tab <- vcftable(export_bcf_path)
str(bcf_tab)
#> List of 10
#>  $ samples: chr [1:2] "v2-WpXCYApL" "v2-usVwJUmo"
#>  $ chr    : chr [1:61630] "chr1" "chr1" "chr1" "chr1" ...
#>  $ pos    : int [1:61630] 1 10099 10100 10256 10329 10331 10334 10352 10638 10639 ...
#>  $ id     : chr [1:61630] "." "." "." "." ...
#>  $ ref    : chr [1:61630] "N" "A" "C" "A" ...
#>  $ alt    : chr [1:61630] "<NON_REF>" "<NON_REF>" "<NON_REF>" "<NON_REF>" ...
#>  $ qual   : num [1:61630] 2.14e+09 2.14e+09 2.14e+09 2.14e+09 2.14e+09 ...
#>  $ filter : chr [1:61630] "LOWQ" "LOWQ" "LOWQ" "LOWQ" ...
#>  $ info   : chr [1:61630] "END=10098;AN=0;AC=0" "END=10099;AN=0;AC=0" "END=10255;AN=0;AC=0" "END=10637;AN=0;AC=0" ...
#>  $ gt     : int [1:61630, 1:2] NA NA NA NA NA NA NA NA 0 0 ...
#>  - attr(*, "class")= chr "vcftable"

# tab export

export_tsv_path <- tempfile(fileext = ".tsv")
tiledb_vcf_export(
    uri = uri,
    output_path = export_tsv_path,
    sample_names = c("v2-tJjMfKyL", "v2-eBAdKwID"),
    regions = "chr7:144000320-144008793,chr11:56490349-56491395",
    tsv_fields = "CHR,POS,REF,S:GT",
    output_format = "t",
    echo = TRUE,
    print_command = TRUE
)
#> 
#> Running command:
#> /usr/local/lib/R/site-library/Rlibtiledbvcf/TileDBVCF/bin/tiledbvcf 
#>    export 
#>    --uri 
#>    s3://tiledb-inc-demo-data/tiledbvcf-arrays/v4/vcf-samples-20 
#>    --output-format 
#>    t 
#>    --output-path 
#>    /tmp/RtmpvNIn7S/filea24e3466279b.tsv 
#>    --regions 
#>    chr7:144000320-144008793,chr11:56490349-56491395 
#>    --sample-names 
#>    v2-tJjMfKyL,v2-eBAdKwID 
#>    --tsv-fields 
#>    CHR,POS,REF,S:GT 
#>    --mem-budget-mb 
#>    2048
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
tsv_df <- read.table(
    export_tsv_path,
    header = TRUE,
    sep = "\t",
    stringsAsFactors = FALSE
)

str(tsv_df)
#> 'data.frame':    207 obs. of  5 variables:
#>  $ SAMPLE: chr  "v2-eBAdKwID" "v2-tJjMfKyL" "v2-tJjMfKyL" "v2-tJjMfKyL" ...
#>  $ CHR   : chr  "chr11" "chr11" "chr11" "chr11" ...
#>  $ POS   : int  56490100 56490179 56490365 56490368 56490369 56490387 56490401 56490402 56490404 56490407 ...
#>  $ REF   : chr  "C" "T" "G" "G" ...
#>  $ S.GT  : chr  "-1,-1" "-1,-1" "0,0" "0,0" ...
```

## Creating a TileDB-VCF Dataset

``` r
# Create a new dataset
uri <- file.path(tempdir(), "my_dataset")
tiledb_vcf_create(uri, print_command = TRUE)
#> 
#> Running command:
#> /usr/local/lib/R/site-library/Rlibtiledbvcf/TileDBVCF/bin/tiledbvcf 
#>    create 
#>    --uri 
#>    /tmp/RtmpvNIn7S/my_dataset 
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
        system.file("extdata", paste0(s, ".vcf.gz"), package = "Rlibtiledbvcf")
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
#> /usr/local/lib/R/site-library/Rlibtiledbvcf/TileDBVCF/bin/tiledbvcf 
#>    store 
#>    --uri 
#>    /tmp/RtmpvNIn7S/my_dataset 
#>    --samples-file 
#>    /tmp/RtmpvNIn7S/filea24e330c5a0df.txt 
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
