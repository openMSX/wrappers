#!/bin/sh

exit_with_error() {
    echo "Aborting build because of error: $1"
    echo "result=error" >> "$SF_RESULTS"
    echo "summary=$1" >> "$SF_RESULTS"
    exit 0
}

# Enter source directory.
cd "$OPENMSX_SOURCE"
if [ $? -ne 0 ]
then
    exit_with_error "Failed to enter source directory $OPENMSX_SOURCE"
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

# Update 3rdparty sources.
python build/thirdparty_download.py windows

# Run build.
echo "Starting build for target $MSBUILD_TARGET, configuration $MSBUILD_CONFIG..."
"$COMSPEC" //c "$SF_WRAPPER_ROOT/build.bat" "$MSBUILD_TARGET" "$MSBUILD_CONFIG" "$SF_REPORT_ROOT"
BUILD_RESULT=$?

echo "report.0=build_openmsx_log.txt" >> "$SF_RESULTS"
echo "report.1=build_3rdparty_log.txt" >> "$SF_RESULTS"

if [ $BUILD_RESULT -ne 0 ]
then
    exit_with_error "Build returned exit code $BUILD_RESULT"
fi

echo "result=ok" >> "$SF_RESULTS"
echo "summary=Build succeeded" >> "$SF_RESULTS"
echo "output.BUILD_RESULT_OPENMSX.locator=$OPENMSX_SOURCE" >> "$SF_RESULTS"
