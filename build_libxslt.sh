#!/bin/bash

# Required with Xcode 12 beta:
export M4=$(xcrun -f m4)
OSX_SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)

SOURCE_DIR=libxslt
# libpng
pushd $SOURCE_DIR
make distclean
sh ./configure CC=clang CXX=clang++ \
	CFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	CPPFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	CXXFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	EXSLT_LIBS="-lexslt -lxslt -L${IOS_SDKROOT}/usr/lib -lxml2 -lz -lpthread -licucore -lm" \
	LIBXML_CFLAGS="-I ${IOS_SDKROOT}/usr/include" \
	LIBXML_LIBS=" -L${IOS_SDKROOT}/usr/lib -lxml2 -lz -lpthread -licucore -lm" \
	--build=x86_64-apple-darwin --host=armv8-apple-darwin cross_compiling=yes
make -j4 
mkdir -p build-iphoneos
mkdir -p build-iphoneos/include
mkdir -p build-iphoneos/libxslt/include/libxslt/
mkdir -p build-iphoneos/libexslt/include/libexslt/
cp libxslt/.libs/libxslt.a build-iphoneos
cp libexslt/.libs/libexslt.a build-iphoneos
cp libxslt/*.h build-iphoneos/libxslt/include/libxslt/
cp libexslt/*.h build-iphoneos/libexslt/include/libexslt/

make distclean
sh ./configure CC=clang CXX=clang++ \
	CFLAGS="-arch x86_64 -miphonesimulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
	CPPFLAGS="-arch x86_64 -miphonesimulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
	CXXFLAGS="-arch x86_64 -miphonesimulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
	EXSLT_LIBS="-lexslt -lxslt -L${SIM_SDKROOT}/usr/lib -lxml2 -lz -lpthread -licucore -lm" \
	LIBXML_CFLAGS="-I ${SIM_SDKROOT}/usr/include" \
	LIBXML_LIBS=" -L${SIM_SDKROOT}/usr/lib -lxml2 -lz -lpthread -licucore -lm" \
	--build=x86_64-apple-darwin --host=armv8-apple-darwin cross_compiling=yes
make -j4 
mkdir -p build-iphonesimulator
mkdir -p build-iphonesimulator/include
mkdir -p build-iphonesimulator/libxslt/include/libxslt/
mkdir -p build-iphonesimulator/libexslt/include/libexslt/
cp libxslt/.libs/libxslt.a build-iphonesimulator
cp libexslt/.libs/libexslt.a build-iphonesimulator
cp libxslt/*.h build-iphonesimulator/libxslt/include/libxslt/
cp libexslt/*.h build-iphonesimulator/libexslt/include/libexslt/
popd

# then, merge them into XCframeworks:
for framework in libxslt libexslt
do
	rm -rf $framework.xcframework
	xcodebuild -create-xcframework \
		-library $SOURCE_DIR/build-iphoneos/$framework.a -headers $SOURCE_DIR/build-iphoneos/$framework/include/ \
		-library $SOURCE_DIR/build-iphonesimulator/$framework.a -headers $SOURCE_DIR/build-iphonesimulator/$framework/include/ \
		-output $framework.xcframework
done
