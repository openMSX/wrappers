#!/bin/sh

exit_with_error() {
    echo "Aborting build because of error: $1"
    echo "result=error" >> "$SF_RESULTS"
    echo "summary=$1" >> "$SF_RESULTS"
    exit 0
}

cd "$SF_REPORT_ROOT"
"$OPENMSX_EXECUTABLE" --reporter junit --out results.xml
TEST_RESULT=$?
if [ $TEST_RESULT -ne 0 ]
then
    exit_with_error "Test run ended with exit code $TEST_RESULT"
fi
echo "report=results.xml" >> "$SF_RESULTS"
