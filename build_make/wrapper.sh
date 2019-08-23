#!/bin/sh

exit_with_error() {
    echo "Aborting build because of error: $1"
    echo "result=error" > "$SF_RESULTS"
    echo "summary=$1" >> "$SF_RESULTS"
    exit 0
}

# Go to our Git work area.
if [ -z "$OPENMSX_WORK_AREA" ]
then
    exit_with_error "OPENMSX_WORK_AREA not defined"
fi
if [ ! -d "$OPENMSX_WORK_AREA" ]
then
    exit_with_error "Work area does not exist: $OPENMSX_WORK_AREA"
    exit 1
fi
cd "$OPENMSX_WORK_AREA"

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

# Update sources.
git pull origin "$GIT_REFSPEC"
GIT_RESULT=$?
if [ $GIT_RESULT -ne 0 ]
then
    exit_with_error "Git returned exit code $GIT_RESULT"
fi

# Run build.
if [ -z "$OPENMSX_JOBS" ]
then
    OPENMSX_JOBS=1
fi
export OPENMSX_FLAVOUR
echo "Staring build with $OPENMSX_JOBS parallel job(s)"
gmake -j "$OPENMSX_JOBS"
MAKE_RESULT=$?
if [ $MAKE_RESULT -ne 0 ]
then
    exit_with_error "Make returned exit code $MAKE_RESULT"
fi

echo "result=ok" > "$SF_RESULTS"
echo "summary=Build succeeded" >> "$SF_RESULTS"
