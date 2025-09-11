#!/usr/bin/env Rscript

## Script to copy shared libraries to package installation location
## This ensures libraries are available when the package is loaded

# Get package installation directories
dest_dir <- file.path(R_PACKAGE_DIR, paste0("libs", R_ARCH))
source_dir <- file.path(R_PACKAGE_SOURCE, "inst", "TileDBVCF", "lib")

# Print debug information
cat("=== RTileDBvcf install.libs.R ===\n")
cat("R_PACKAGE_DIR:", R_PACKAGE_DIR, "\n")
cat("R_PACKAGE_SOURCE:", R_PACKAGE_SOURCE, "\n")
cat("R_ARCH:", R_ARCH, "\n")
cat("dest_dir:", dest_dir, "\n")
cat("source_dir:", source_dir, "\n")

# Create destination directory if it doesn't exist
if (!dir.exists(dest_dir)) {
    dir.create(dest_dir, recursive = TRUE)
    cat("Created directory:", dest_dir, "\n")
}

# Check if source directory exists
if (!dir.exists(source_dir)) {
    cat("ERROR: Source directory not found:", source_dir, "\n")
    cat("Available files in inst/:\n")
    if (dir.exists(file.path(R_PACKAGE_SOURCE, "inst"))) {
        print(list.files(file.path(R_PACKAGE_SOURCE, "inst"), recursive = TRUE))
    }
    stop("TileDB-VCF libraries not found. Run ./configure first.")
}

# List of shared libraries to copy
# Note: We include the versioned libraries and create symlinks if needed
lib_files <- c(
    "libtiledbvcf.so",
    "libtiledb.so.2.28",
    "libhts.so.1.22.1"
)

cat("Libraries to copy:\n")
for (lib in lib_files) {
    src_file <- file.path(source_dir, lib)
    dest_file <- file.path(dest_dir, lib)

    if (file.exists(src_file)) {
        # Copy the library
        file.copy(src_file, dest_file, overwrite = TRUE)
        cat("  Copied:", lib, "\n")

        # Create symlinks for versioned libraries
        if (lib == "libtiledb.so.2.28") {
            # Create libtiledb.so -> libtiledb.so.2.28
            link_name <- file.path(dest_dir, "libtiledb.so")
            if (file.exists(link_name)) {
                file.remove(link_name)
            }
            file.symlink(lib, link_name)
            cat("    Created symlink: libtiledb.so -> libtiledb.so.2.28\n")
        }

        if (lib == "libhts.so.1.22.1") {
            # Create libhts.so -> libhts.so.1.22.1
            link_name <- file.path(dest_dir, "libhts.so")
            if (file.exists(link_name)) {
                file.remove(link_name)
            }
            file.symlink(lib, link_name)
            cat("    Created symlink: libhts.so -> libhts.so.1.22.1\n")
        }
    } else {
        cat("  WARNING: Library not found:", src_file, "\n")
    }
}

# Verify copied files
cat("\nVerifying copied libraries:\n")
copied_files <- list.files(dest_dir, pattern = "\\.so", full.names = FALSE)
for (f in copied_files) {
    cat("  Found:", f, "\n")
}

# Automatically copy all shared objects from src/
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

cat("=== install.libs.R completed ===\n")
