#!/bin/bash

# Required with Xcode 12 beta:
export M4=$(xcrun -f m4)
OSX_SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)

# Using Xcode to create frameworks from archived libraries (lib.a) is failing randomly. 
# We stick to creating frameworks from dynamic libraries.

pushd OpenBLAS
# Having the exact same script inside Xcode does not work. Strange but true.
# iphoneos:
 make TARGET=ARMV8 BINARY=64 \
 	 HOSTCC="clang -isysroot ${OSX_SDKROOT}" \
 	 CC="clang" \
 	 CFLAGS="-miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -arch arm64 -fembed-bitcode" \
 	 NOFORTRAN=1 \
 	 AR="$(xcrun -f ar)" clean
 make TARGET=ARMV8 BINARY=64 HOSTCC="clang -isysroot ${OSX_SDKROOT}" \
 	 CC="clang" \
 	 CFLAGS="-miphoneos-version-min=11.0 -isysroot  ${IOS_SDKROOT} -arch arm64 -fembed-bitcode" \
 	 NOFORTRAN=1 \
 	 AR="$(xcrun -f ar)" libs shared
 mkdir -p build-iphoneos
 cp libopenblas_armv8p-r0.3.10.dev.a build-iphoneos/libopenblas.a
 cp libopenblas_armv8p-r0.3.10.dev.dylib build-iphoneos/libopenblas.dylib
# simulator
 make BINARY=64 HOSTCC="clang -isysroot ${OSX_SDKROOT}" \
 	 CC="clang" \
 	 CFLAGS="-mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -arch x86_64 -fembed-bitcode" \
 	 NOFORTRAN=1 clean
 make BINARY=64 HOSTCC="clang -isysroot${OSX_SDKROOT}" \
 	 CC="clang" \
 	 CFLAGS="-mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -arch x86_64 -fembed-bitcode" \
 	 NOFORTRAN=1 libs shared
  mkdir -p build-iphonesimulator
 cp libopenblas_haswellp-r0.3.10.dev.a build-iphonesimulator/libopenblas.a
 cp libopenblas_haswellp-r0.3.10.dev.dylib build-iphonesimulator/libopenblas.dylib
# for the headers:
 make BINARY=64 HOSTCC="clang -isysroot ${OSX_SDKROOT}" CC="clang" CFLAGS="-mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -arch x86_64 -fembed-bitcode" NOFORTRAN=1 install PREFIX=./install
# OSX: 
make BINARY=64 HOSTCC="clang -isysroot ${OSX_SDKROOT}" \
	CC="clang" CFLAGS="-isysroot${OSX_SDKROOT} -fembed-bitcode" \
	NOFORTRAN=1 \
	AR="$(xcrun -f ar)" clean
make BINARY=64 HOSTCC="clang -isysroot ${OSX_SDKROOT}" \
	CC="clang" CFLAGS="-isysroot${OSX_SDKROOT} -fembed-bitcode" \
	NOFORTRAN=1 \
	AR="$(xcrun -f ar)" libs shared
  mkdir -p build-osx
 cp libopenblas_skylakexp-r0.3.10.dev.a build-osx/libopenblas.a
 cp libopenblas_skylakexp-r0.3.10.dev.dylib build-osx/libopenblas.dylib
popd

binary=openblas
FRAMEWORK_DIR=build/Release-iphoneos/$binary.framework
rm -rf ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}/Headers
cp OpenBLAS/install/include/*.h ${FRAMEWORK_DIR}/Headers
cp OpenBLAS/build-iphoneos/libopenblas.dylib ${FRAMEWORK_DIR}/$binary
cp basic_Info.plist ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleExecutable -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleName -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.$binary  ${FRAMEWORK_DIR}/Info.plist
install_name_tool -id @rpath/$binary.framework/$binary   ${FRAMEWORK_DIR}/$binary

FRAMEWORK_DIR=build/Release-iphonesimulator/$binary.framework
rm -rf ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}/Headers
cp OpenBLAS/install/include/*.h ${FRAMEWORK_DIR}/Headers
cp OpenBLAS/build-iphonesimulator/libopenblas.dylib ${FRAMEWORK_DIR}/$binary
cp basic_Info_Simulator.plist ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleExecutable -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleName -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.$binary  ${FRAMEWORK_DIR}/Info.plist
install_name_tool -id @rpath/$binary.framework/$binary   ${FRAMEWORK_DIR}/$binary

FRAMEWORK_DIR=build/Release-osx/$binary.framework
rm -rf ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}/Headers
cp OpenBLAS/install/include/*.h ${FRAMEWORK_DIR}/Headers
cp OpenBLAS/build-osx/libopenblas.dylib ${FRAMEWORK_DIR}/$binary
cp basic_Info_Simulator.plist ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleExecutable -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleName -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.$binary  ${FRAMEWORK_DIR}/Info.plist
install_name_tool -id @rpath/$binary.framework/$binary   ${FRAMEWORK_DIR}/$binary


