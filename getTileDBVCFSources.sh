#!/bin/bash
# Script to download TileDB-VCF sources and extract to src directory
set -eux

# Configuration
VERSION="0.38.2"
TARBALL_FILE="${VERSION}.tar.gz"
TARBALL_URL="https://github.com/TileDB-Inc/TileDB-VCF/archive/refs/tags/${TARBALL_FILE}"
SRC_DIR="src"

echo "=== TileDB-VCF Source Download Script ==="
echo "Version: ${VERSION}"
echo "Target directory: ${SRC_DIR}"

# Create src directory if it doesn't exist
mkdir -p "${SRC_DIR}"

# Download tarball if it doesn't exist
if [ ! -f "${SRC_DIR}/${TARBALL_FILE}" ]; then
    echo "Downloading TileDB-VCF ${VERSION} source code..."
    wget -c -O "${SRC_DIR}/${TARBALL_FILE}" "${TARBALL_URL}" || {
        echo "Failed to download TileDB-VCF source code"
        exit 1
    }
    echo "Download completed: ${SRC_DIR}/${TARBALL_FILE}"
else
    echo "Tarball already exists: ${SRC_DIR}/${TARBALL_FILE}"
fi

# Extract only the libtiledbvcf subdirectory
echo "Extracting libtiledbvcf subdirectory from tarball..."
cd "${SRC_DIR}"

# Extract only the libtiledbvcf subdirectory
tar -xzf "${TARBALL_FILE}" "TileDB-VCF-${VERSION}/libtiledbvcf" --strip-components=1 || {
    echo "Failed to extract libtiledbvcf subdirectory"
    exit 1
}

echo "Extraction completed: libtiledbvcf subdirectory is now in ${SRC_DIR}/libtiledbvcf"

# List contents of extracted libtiledbvcf directory
echo ""
echo "=== Contents of extracted libtiledbvcf directory ==="
ls -la libtiledbvcf/

echo ""
echo "=== Directory structure in libtiledbvcf ==="
find libtiledbvcf/ -type d | sort

echo ""
echo "=== CMake files in libtiledbvcf ==="
find libtiledbvcf/ -name "*.cmake" -o -name "CMakeLists.txt" | head -20

echo ""
echo "=== Header files in libtiledbvcf ==="
find libtiledbvcf/ -name "*.h" -o -name "*.hpp" | head -20

echo ""
echo "=== Source files in libtiledbvcf ==="
find libtiledbvcf/ -name "*.c" -o -name "*.cpp" -o -name "*.cc" -o -name "*.cxx" | head -20

# Remove the tarball to save space
echo ""
echo "Cleaning up: removing tarball..."
rm -f "${TARBALL_FILE}"

echo ""
echo "=== Script completed successfully ==="
echo "libtiledbvcf subdirectory is now available at: ${SRC_DIR}/libtiledbvcf"
