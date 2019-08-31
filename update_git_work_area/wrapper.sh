#!/bin/sh
#
# The following environment variables can be set on the factory PC
# to customize how this wrapper runs:
#
# *_WORK_AREA (mandatory)
#     path of Git work area
#     the work area name will be filled in for "*"

exit_with_error() {
    echo "Aborting build because of error: $1"
    echo "result=error" >> "$SF_RESULTS"
    echo "summary=$1" >> "$SF_RESULTS"
    exit 0
}

WORK_AREA_VAR=${WORK_AREA_NAME}_WORK_AREA
eval WORK_AREA='${'"${WORK_AREA_VAR}"'}'

# Go to our Git work area.
if [ -z "$WORK_AREA" ]
then
    exit_with_error "${WORK_AREA_VAR} not defined"
fi
if [ ! -d "$WORK_AREA" ]
then
    exit_with_error "Work area does not exist: $WORK_AREA"
    exit 1
fi
cd "$WORK_AREA"

# Fetch new sources.
git fetch -f origin
GIT_RESULT=$?
if [ $GIT_RESULT -ne 0 ]
then
    exit_with_error "'git fetch' returned exit code $GIT_RESULT"
fi

# Update work area.
git checkout "$GIT_REFSPEC"
GIT_RESULT=$?
if [ $GIT_RESULT -ne 0 ]
then
    exit_with_error "'git checkout' returned exit code $GIT_RESULT"
fi

# Let Git describe the state.
DESCRIPTION=`git describe --always --dirty`
GIT_RESULT=$?
if [ $GIT_RESULT -ne 0 ]
then
    exit_with_error "'git describe' returned exit code $GIT_RESULT"
fi
case "$DESCRIPTION" in
*-dirty)
    echo "WARNING: Work area is dirty; build may not match refspec"
    RESULT=warning
    ;;
*)
    RESULT=ok
    ;;
esac

echo "result=$RESULT" > "$SF_RESULTS"
echo "summary=Work area updated to $DESCRIPTION" >> "$SF_RESULTS"
echo "output.${WORK_AREA_NAME}_SOURCE.locator=${WORK_AREA}" >> "$SF_RESULTS"
