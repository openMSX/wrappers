#!/bin/bash
#
# The following environment variables can be set on the factory PC
# to customize how this wrapper runs:
#
# OPENMSX_JOBS (optional, default: 1)
#     number of parallel jobs Make will spawn

exit_with_error() {
    echo "Aborting build because of error: $1"
    echo "result=error" >> "$SF_RESULTS"
    echo "summary=$1" >> "$SF_RESULTS"
    exit 0
}

# Enter source directory.
SOURCE_DIR="${!SOURCE_NAME}"
cd "$SOURCE_DIR"
if [ $? -ne 0 ]
then
    exit_with_error "Failed to enter source directory $SOURCE_DIR"
fi

# Perform a clean build?
if [ "$CLEAN_BUILD" = "yes" ]
then
    echo "Performing a clean build"
    rm -rf derived
elif [ "$CLEAN_BUILD" = "no" ]
then
    echo "Performing an incremental build"
else
    exit_with_error "Unknown value for CLEAN_BUILD: $CLEAN_BUILD"
fi

# Run build.
if [ -z "$OPENMSX_JOBS" ]
then
    OPENMSX_JOBS=1
fi
echo "Starting build for with $OPENMSX_JOBS parallel job(s)"
echo "report=build_log.txt" >> "$SF_RESULTS"
make -j "$OPENMSX_JOBS" CATAPULT_FLAVOUR="$CATAPULT_FLAVOUR" \
    > "$SF_REPORT_ROOT/build_log.txt" 2>&1
MAKE_RESULT=$?
if [ $MAKE_RESULT -ne 0 ]
then
    exit_with_error "Make returned exit code $MAKE_RESULT"
fi

# Check build log for warnings.
grep '^src/.*: warning:' "$SF_REPORT_ROOT/build_log.txt" > /dev/null
if [ $? -eq 0 ]
then
    echo "result=warning" >> "$SF_RESULTS"
    echo "summary=Build log contains warnings" >> "$SF_RESULTS"
else
    echo "result=ok" >> "$SF_RESULTS"
    echo "summary=Build succeeded" >> "$SF_RESULTS"
fi
