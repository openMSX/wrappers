#!/bin/sh
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
eval SOURCE_DIR='${'"${SOURCE_NAME}"'}'
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

# Perform a build using libraries from the 3rd-party system?
if [ "$OPENMSX_3RDPARTY" = "yes" ]
then
    echo "Performing a build including 3rd-party libraries"
    MAKE_TARGET=staticbindist
elif [ "$OPENMSX_3RDPARTY" = "no" ]
then
    echo "Performing a build using system libraries"
    MAKE_TARGET=bindist
else
    exit_with_error "Unknown value for OPENMSX_3RDPARTY: $OPENMSX_3RDPARTY"
fi

# Detect host OS.
detected() {
    HOST_CPU=$1
    HOST_OS=$2
}
detected `python3 build/detectsys.py`
echo "Building on host: OS $HOST_OS, CPU $HOST_CPU"

# Determine target OS.
case "$SF_TARGET" in
windows)
    OPENMSX_TARGET_OS=mingw-w64
    ;;
macos)
    OPENMSX_TARGET_OS=darwin
    ;;
"")
    OPENMSX_TARGET_OS="$HOST_OS"
    ;;
*)
    OPENMSX_TARGET_OS="$SF_TARGET"
    ;;
esac

# Determine target CPU.
if [ -z "$OPENMSX_TARGET_CPU" ]
then
    OPENMSX_TARGET_CPU="$HOST_CPU"
fi

echo "Building for target: OS $OPENMSX_TARGET_OS, CPU $OPENMSX_TARGET_CPU"

# Run build.
if [ -z "$OPENMSX_JOBS" ]
then
    OPENMSX_JOBS=1
fi
echo "Starting build for with $OPENMSX_JOBS parallel job(s)"
echo "report=build_log.txt" >> "$SF_RESULTS"
make -j "$OPENMSX_JOBS" "$MAKE_TARGET" \
    OPENMSX_FLAVOUR="$OPENMSX_FLAVOUR" \
    OPENMSX_TARGET_OS="$OPENMSX_TARGET_OS" \
    > "$SF_REPORT_ROOT/build_log.txt" 2>&1
MAKE_RESULT=$?
if [ $MAKE_RESULT -ne 0 ]
then
    exit_with_error "Make returned exit code $MAKE_RESULT"
fi

# Create executable output.
TUPLE="$OPENMSX_TARGET_CPU-$OPENMSX_TARGET_OS-$OPENMSX_FLAVOUR"
if [ "$OPENMSX_3RDPARTY" = "yes" ]
then
    TUPLE="$TUPLE-3rd"
fi
PRODUCT_DIR="$SF_PRODUCT_ROOT/$TUPLE"
mkdir -p "$PRODUCT_DIR"
case "$SF_TARGET" in
windows)
    EXECUTABLE=openmsx.exe
    ;;
*)
    EXECUTABLE=openmsx
    ;;
esac
mv "derived/$TUPLE/bin/$EXECUTABLE" "$PRODUCT_DIR"
echo "output.OPENMSX_EXECUTABLE.locator=$PRODUCT_DIR/$EXECUTABLE" >> "$SF_RESULTS"

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
