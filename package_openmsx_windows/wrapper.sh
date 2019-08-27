#!/bin/sh

exit_with_error() {
    echo "Aborting build because of error: $1"
    echo "result=error" > "$SF_RESULTS"
    echo "summary=$1" >> "$SF_RESULTS"
    exit 0
}

cd "$BUILD_RESULT_OPENMSX"
PACKAGE_DIR="derived/$MSBUILD_TARGET-VC-$MSBUILD_CONFIG/package-windows"

# Clean up any old packages.
rm -rf "$PACKAGE_DIR"

# Create packages.
echo "Creating packages for target $MSBUILD_TARGET, configuration $MSBUILD_CONFIG..."
echo "$COMSPEC" //c "$PWD/build/package-windows/package.cmd" "$MSBUILD_TARGET" "$MSBUILD_CONFIG" "$BUILD_RESULT_CATAPULT"
"$COMSPEC" //c "$PWD/build/package-windows/package.cmd" "$MSBUILD_TARGET" "$MSBUILD_CONFIG" "$BUILD_RESULT_CATAPULT"
#start //b //wait "$OPENMSX_BUILD_RESULT/build/package-windows/package.cmd" "$MSBUILD_TARGET" "$MSBUILD_CONFIG" "$CATAPULT_BUILD_RESULT"
PACKAGE_RESULT=$?
if [ $PACKAGE_RESULT -ne 0 ]
then
    exit_with_error "Package script returned exit code $PACKAGE_RESULT"
fi

# Move packages to products directory.
PACKAGE_BIN=`echo "$PACKAGE_DIR"/*-bin.zip`
PACKAGE_MSI=`echo "$PACKAGE_DIR"/*-bin-msi.zip`
PACKAGE_PDB=`echo "$PACKAGE_DIR"/*-pdb.zip`
mkdir -p "$SF_PRODUCT_ROOT/packages"
mv "$PACKAGE_BIN" "$PACKAGE_MSI" "$PACKAGE_PDB" "$SF_PRODUCT_ROOT/packages"

echo "result=ok" > "$SF_RESULTS"
echo "summary=Packaging succeeded" >> "$SF_RESULTS"
echo "output.OPENMSX_BIN_PACKAGE.locator=${PACKAGE_BIN/#${PACKAGE_DIR}\//${SF_PRODUCT_ROOT}\\packages\\}" >> "$SF_RESULTS"
echo "output.OPENMSX_MSI_PACKAGE.locator=${PACKAGE_MSI/#${PACKAGE_DIR}\//${SF_PRODUCT_ROOT}\\packages\\}" >> "$SF_RESULTS"
echo "output.OPENMSX_PDB_PACKAGE.locator=${PACKAGE_PDB/#${PACKAGE_DIR}\//${SF_PRODUCT_ROOT}\\packages\\}" >> "$SF_RESULTS"
