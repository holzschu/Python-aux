#!/bin/bash
set -euo pipefail

OSX_SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)

curl --fail --location --retry 3 -O https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz
echo 'daeb2620d829575513e35fecc83f0d3791a620b9b93d800b763542ece9390fb4  libpng-1.6.37.tar.gz' | shasum -a 256 -c -
tar xzf libpng-1.6.37.tar.gz
rm libpng-1.6.37.tar.gz
# Use the standard math.h path on modern Apple SDKs.
patch -d libpng-1.6.37 -p1 < patches/libpng-math.patch

# libpng
pushd libpng-1.6.37
if [ -f Makefile ]; then make distclean; fi
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	CPPFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	CXXFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	--build=x86_64-apple-darwin --host=armv8-apple-darwin cross_compiling=yes
make -j4 --quiet
# We're going to need them:
mkdir -p ../libheif/lib_iphoneos
mkdir -p ../libheif/include_iphoneos
cp .libs/libpng16.16.dylib ../libheif/lib_iphoneos/libpng.dylib 
cp png.h pnglibconf.h pngconf.h  ../libheif/include_iphoneos/
# Library is now in: .libs/libpng16.16.dylib. Create framework:
popd
binary=libpng
FRAMEWORK_DIR=build/Release-iphoneos/$binary.framework
rm -rf ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}/Headers
cp libpng-1.6.37/png.h ${FRAMEWORK_DIR}/Headers
cp libpng-1.6.37/pnglibconf.h ${FRAMEWORK_DIR}/Headers
cp libpng-1.6.37/pngconf.h ${FRAMEWORK_DIR}/Headers
cp libpng-1.6.37/.libs/libpng16.16.dylib ${FRAMEWORK_DIR}/$binary
cp basic_Info.plist ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleExecutable -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleName -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.$binary  ${FRAMEWORK_DIR}/Info.plist
install_name_tool -id @rpath/$binary.framework/$binary   ${FRAMEWORK_DIR}/$binary
for sim_arch in arm64 x86_64; do
  sim_host=aarch64-apple-darwin
  if [[ $sim_arch == x86_64 ]]; then sim_host=x86_64-apple-darwin; fi
pushd libpng-1.6.37
if [ -f Makefile ]; then make distclean; fi
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch ${sim_arch} -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	CPPFLAGS="-arch ${sim_arch} -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	CXXFLAGS="-arch ${sim_arch} -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	--build=x86_64-apple-darwin --host=${sim_host} cross_compiling=yes
make -j4 --quiet
# We're going to need them:
mkdir -p ../libheif/lib_iphonesimulator-${sim_arch}
mkdir -p ../libheif/include_iphonesimulator-${sim_arch}
cp .libs/libpng16.16.dylib ../libheif/lib_iphonesimulator-${sim_arch}/libpng.dylib
cp png.h pnglibconf.h pngconf.h  ../libheif/include_iphonesimulator-${sim_arch}/
popd
FRAMEWORK_DIR=build/Release-iphonesimulator-${sim_arch}/$binary.framework
rm -rf ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}/Headers
cp libpng-1.6.37/png.h ${FRAMEWORK_DIR}/Headers
cp libpng-1.6.37/pnglibconf.h ${FRAMEWORK_DIR}/Headers
cp libpng-1.6.37/pngconf.h ${FRAMEWORK_DIR}/Headers
cp libpng-1.6.37/.libs/libpng16.16.dylib ${FRAMEWORK_DIR}/$binary
cp basic_Info_Simulator.plist ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleExecutable -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleName -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.$binary  ${FRAMEWORK_DIR}/Info.plist
install_name_tool -id @rpath/$binary.framework/$binary   ${FRAMEWORK_DIR}/$binary


done

mkdir -p build/Release-iphonesimulator
rm -rf build/Release-iphonesimulator/libpng.framework
cp -R build/Release-iphonesimulator-arm64/libpng.framework build/Release-iphonesimulator/
lipo -create build/Release-iphonesimulator-arm64/libpng.framework/libpng build/Release-iphonesimulator-x86_64/libpng.framework/libpng -output build/Release-iphonesimulator/libpng.framework/libpng
mkdir -p libheif/lib_iphonesimulator libheif/include_iphonesimulator
lipo -create libheif/lib_iphonesimulator-arm64/libpng.dylib libheif/lib_iphonesimulator-x86_64/libpng.dylib -output libheif/lib_iphonesimulator/libpng.dylib
cp libheif/include_iphonesimulator-arm64/* libheif/include_iphonesimulator/
