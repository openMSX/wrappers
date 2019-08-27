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

# Run APE.
apetest --check launch --css --result "$SF_RESULTS" \
    "$OPENMSX_SOURCE/doc/manual/" "$SF_REPORT_ROOT/report.html"
if [ $? -ne 0 ]
then
    exit_with_error "APE crashed"
fi

echo "report=report.html" >> "$SF_RESULTS"
