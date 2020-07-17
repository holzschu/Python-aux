#!/bin/bash

# Required with Xcode 12 beta:
export M4=/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin//m4
OSX_SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)

# step 2: build freetype without harfbuzz support:
# curl -OL https://download.savannah.gnu.org/releases/freetype/freetype-2.10.2.tar.gz
# tar xvzf freetype-2.10.2.tar.gz
# rm freetype-2.10.2.tar.gz
# cd freetype-2.10.2
# make distclean
# ./configure CC=clang CXX=clang++ CFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" CPPFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" CXXFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" LDFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" CC_BUILD="clang -isysroot ${OSX_SDKROOT}" --build=x86_64-apple-darwin --host=armv8-apple-darwin --with-harfbuzz=no --with-png=yes LIBPNG_CFLAGS="-I ${PWD}/../build/Release-iphoneos/libpng.framework/Headers" LIBPNG_LIBS="-F${PWD}/../build/Release-iphoneos -framework libpng" cross_compiling=yes
# make -j 4
# mkdir -p build-iphoneos
# cp obj/.libs/libfreetype.a build-iphoneos
# make distclean 
# ./configure CC=clang CXX=clang++ CFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" CPPFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" CXXFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" LDFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" CC_BUILD="clang -isysroot ${OSX_SDKROOT}" --build=x86_64-apple-darwin --host=x86_64-apple-darwin --with-harfbuzz=no --with-png=yes LIBPNG_CFLAGS="-I ${PWD}/../build/Release-iphonesimulator/libpng.framework/Headers" LIBPNG_LIBS="-F${PWD}/../build/Release-iphonesimulator -framework libpng" cross_compiling=yes
# make -j 4
# mkdir -p build-iphonesimulator
# cp obj/.libs/libfreetype.a build-iphonesimulator
# cd ..

# step 3: build harfbuzz using freetype 


