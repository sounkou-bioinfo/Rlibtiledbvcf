library(RTileDBvcf)
library(vcfppR)

# TileDB-VCF CLI version
tiledb_vcf_cli_version() |>
    cat(sep = "\n")

# TileDB-VCF libraries version
tiledb_vcf_version() |>
    cat(sep = "\n")

# Raw CLI INTERFACE

run_tiledb_vcf_cli(c("--help"), echo = TRUE)

# Create a new dataset using the cli
uri <- file.path(tempdir(), "my_dataset")
cat("Dataset URI:", uri, "\n")
tiledb_vcf_create(uri, print_command = TRUE)


# Use pre-existing VCFs and their tabix indices from inst/extdata
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
cat("Samples file:", samples_file, "\n")
tiledb_vcf_store(
    uri,
    samples_file = samples_file,
    echo = TRUE,
    print_command = TRUE
)

# List samples in the dataset for debugging
cat("Listing samples in dataset:\n")
run_tiledb_vcf_cli(c("list", "--uri", uri), echo = TRUE)

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
