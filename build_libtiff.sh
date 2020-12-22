#!/bin/bash

# Required with Xcode 12 beta:
export M4=$(xcrun -f m4)
OSX_SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)

curl -OL http://download.osgeo.org/libtiff/tiff-4.1.0.zip 
unzip -o tiff-4.1.0.zip 
rm tiff-4.1.0.zip 

SOURCE_DIR=tiff-4.1.0
# libpng
pushd $SOURCE_DIR
make distclean
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	CPPFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	CXXFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	--build=x86_64-apple-darwin --host=armv8-apple-darwin cross_compiling=yes
make -j4 --quiet
mkdir -p build-iphoneos
mkdir -p build-iphoneos/include
cp libtiff/.libs/libtiff.a build-iphoneos
cp libtiff/tiff.h libtiff/tiffio.h libtiff/tiffvers.h libtiff/tiffio.hxx libtiff/tiffconf.h build-iphoneos/include

make distclean
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
	CPPFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
	CXXFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
	--build=x86_64-apple-darwin --host=x86_64-apple-darwin cross_compiling=yes
make -j4 --quiet
mkdir -p build-iphonesimulator
mkdir -p build-iphonesimulator/include
cp libtiff/.libs/libtiff.a build-iphonesimulator
cp libtiff/tiff.h libtiff/tiffio.h libtiff/tiffvers.h libtiff/tiffio.hxx libtiff/tiffconf.h build-iphonesimulator/include
popd

# then, merge them into XCframeworks:
framework=libtiff
rm -rf $framework.xcframework
xcodebuild -create-xcframework \
	-library $SOURCE_DIR/build-iphoneos/libtiff.a -headers $SOURCE_DIR/build-iphoneos/include \
	-library $SOURCE_DIR/build-iphonesimulator/libtiff.a -headers $SOURCE_DIR/build-iphonesimulator/include \
	-output $framework.xcframework
