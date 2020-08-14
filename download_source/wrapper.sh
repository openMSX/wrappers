#!/bin/bash

exit_with_error() {
    echo "Aborting build because of error: $1"
    echo "result=error" >> "$SF_RESULTS"
    echo "summary=$1" >> "$SF_RESULTS"
    exit 0
}

# Determine our input.
PACKAGE_URL="${!SF_INPUTS}"
PACKAGE_NAME=`basename "$PACKAGE_URL"`

# Determine output location.
mkdir -p "$SF_PRODUCT_ROOT"
SRC_PACKAGE="$SF_PRODUCT_ROOT/$PACKAGE_NAME"

# Download package.
wget "$PACKAGE_URL" -O "$SRC_PACKAGE" || exit_with_error "Failed to download sources"

# Write results file.
echo "result=ok" > "$SF_RESULTS"
echo "summary=Sources downloaded" >> "$SF_RESULTS"
echo "output.$SF_OUTPUTS.locator=$PACKAGE_NAME" >> "$SF_RESULTS"
