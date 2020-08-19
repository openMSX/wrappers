#!/bin/bash

exit_with_error() {
    echo "Aborting build because of error: $1"
    echo "result=error" >> "$SF_RESULTS"
    echo "summary=$1" >> "$SF_RESULTS"
    exit 0
}

# Find our input tarball.
SRC_PACKAGE="${!SF_INPUTS}"

# Create and enter source directory.
UNPACK_DIR="$SF_PRODUCT_ROOT/unpacked_source"
mkdir -p "$UNPACK_DIR"
cd "$UNPACK_DIR" || exit_with_error "Failed to enter unpack directory $UNPACK_DIR"

# Unpack tarball.
tar zxf "../$SRC_PACKAGE" || exit_with_error "Failed to unpack sources"

# Verify that the expected source directory exists.
SOURCE_DIR="$UNPACK_DIR"/`basename "$SRC_PACKAGE" .tar.gz`
if [ ! -d "$SOURCE_DIR" ]
then
    exit_with_error "Expected source directory $SOURCE_DIR was not created"
fi

# Write results file.
echo "result=ok" > "$SF_RESULTS"
echo "summary=Sources unpacked" >> "$SF_RESULTS"
echo "output.$SF_OUTPUTS.locator=$SOURCE_DIR" >> "$SF_RESULTS"
