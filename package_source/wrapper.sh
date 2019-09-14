#!/bin/sh

exit_with_error() {
    echo "Aborting build because of error: $1"
    echo "result=error" >> "$SF_RESULTS"
    echo "summary=$1" >> "$SF_RESULTS"
    exit 0
}

# Enter source directory.
eval SOURCE_DIR='${'"${SOURCE_NAME}"'}'
cd "$SOURCE_DIR"
if [ $? -ne 0 ]
then
    exit_with_error "Failed to enter source directory $SOURCE_DIR"
fi

# Create package.
PACKAGE_LOG="$SF_REPORT_ROOT/package_log.txt"
echo "Creating source package..."
echo "report=$PACKAGE_LOG" >> "$SF_RESULTS"
make dist > "$PACKAGE_LOG" 2>&1
MAKE_RESULT=$?
if [ $MAKE_RESULT -ne 0 ]
then
    exit_with_error "Make returned exit code $MAKE_RESULT"
fi

# Make package an output product.
ARCHIVE=`sed -n 's/^archive: //p' "$PACKAGE_LOG"`
if [ -z "$ARCHIVE" ]
then
    exit_with_error "No archive path found in package log"
fi
ARCHIVE_PRODUCT=`basename "$ARCHIVE"`
mkdir -p "$SF_PRODUCT_ROOT"
mv "$ARCHIVE" "$SF_PRODUCT_ROOT/$ARCHIVE_PRODUCT"
echo "output.OPENMSX_SRC_PACKAGE.locator=$ARCHIVE_PRODUCT" >> "$SF_RESULTS"

# Check package log for warnings.
grep '^WARNING:' "$PACKAGE_LOG" > /dev/null
if [ $? -eq 0 ]
then
    echo "result=warning" >> "$SF_RESULTS"
    echo "summary=Package log contains warnings" >> "$SF_RESULTS"
else
    echo "result=ok" >> "$SF_RESULTS"
    echo "summary=Package created" >> "$SF_RESULTS"
fi

# Add mid-level data.
INCLUDED=`sed -n 's/^entries: \([0-9]*\) included, \([0-9]*\) excluded$/\1/p' "$PACKAGE_LOG"`
if [ -n "$INCLUDED" ]
then
    echo "data.included=$INCLUDED" >> "$SF_RESULTS"
fi
EXCLUDED=`sed -n 's/^entries: \([0-9]*\) included, \([0-9]*\) excluded$/\2/p' "$PACKAGE_LOG"`
if [ -n "$EXCLUDED" ]
then
    echo "data.excluded=$EXCLUDED" >> "$SF_RESULTS"
fi
