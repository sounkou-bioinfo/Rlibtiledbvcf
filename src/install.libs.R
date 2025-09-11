#!/usr/bin/env Rscript

## Script to copy shared libraries to package installation location
## This ensures libraries are available when the package is loaded

# Get package installation directories
dest_dir <- file.path(R_PACKAGE_DIR, paste0("libs", R_ARCH))
source_dir <- file.path(R_PACKAGE_SOURCE, "inst", "TileDBVCF", "lib")

# Create destination directory if it doesn't exist
if (!dir.exists(dest_dir)) {
    dir.create(dest_dir, recursive = TRUE)
}
# Check if source directory exists
if (!dir.exists(source_dir)) {
    if (dir.exists(file.path(R_PACKAGE_SOURCE, "inst"))) {
        print(list.files(file.path(R_PACKAGE_SOURCE, "inst"), recursive = TRUE))
    }
    stop("TileDB-VCF libraries not found. Run ./configure first.")
}
so_files <- list.files(
    file.path(R_PACKAGE_SOURCE, "src"),
    pattern = "\\.so$",
    full.names = TRUE
)
if (length(so_files) > 0) {
    file.copy(so_files, dest_dir, overwrite = TRUE)
    for (f in so_files) {
        cat("Copied:", f, "->", dest_dir, "\n")
    }
} else {
    cat("Warning: No shared objects found in src/!\n")
}

if (file.exists(file.path(source_dir, "libtiledbvcf.a"))) {
    file.remove(file.path(source_dir, "libtiledbvcf.a"))
}
cat("=== install.libs.R completed ===\n")
