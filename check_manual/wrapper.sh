#!/bin/sh

exit_with_error() {
    echo "Aborting build because of error: $1"
    echo "result=error" >> "$SF_RESULTS"
    echo "summary=$1" >> "$SF_RESULTS"
    exit 0
}

# Install/upgrade APE.
pip install --user --upgrade apetest
if [ $? -ne 0 ]
then
    exit_with_error "APE install/upgrade failed"
fi

# Our task takes a single input, which is the source dir.
# The name differs depending on the application we're checking.
eval SOURCE_DIR='${'"${SF_INPUTS}"'}'

# Run APE.
apetest --check launch --css --result "$SF_RESULTS" \
    "$SOURCE_DIR/doc/manual/" "$SF_REPORT_ROOT/report.html"
if [ $? -ne 0 ]
then
    exit_with_error "APE crashed"
fi

echo "report=report.html" >> "$SF_RESULTS"
