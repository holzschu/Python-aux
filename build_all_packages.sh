#!/bin/bash

# update libffi and libzmq source:
git submodule update --init --recursive

# Required with Xcode 12 beta:
export M4=/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin//m4

pushd libffi
# we need to patch libffi to allow compilation with Xcode12, but only once:
# patch -p1 < ../libffi.patch 
xcodebuild -project libffi.xcodeproj -target libffi-iOS -sdk iphoneos -arch arm64 -configuration Debug -quiet
xcodebuild -project libffi.xcodeproj -target libffi-iOS -sdk iphonesimulator -configuration Debug -quiet
popd 

pushd libzmq
sh builds/ios/build_ios.sh
popd

pushd OpenBLAS
# Having the exact same script inside Xcode does not work. Strange but true.
# iphoneos:
 make TARGET=ARMV8 BINARY=64 HOSTCC="clang -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.16.sdk" CC="clang" CFLAGS="-miphoneos-version-min=11.0 -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS14.0.sdk -arch arm64 " NOFORTRAN=1 AR="/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ar" clean
 make TARGET=ARMV8 BINARY=64 HOSTCC="clang -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.16.sdk" CC="clang" CFLAGS="-miphoneos-version-min=11.0 -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS14.0.sdk -arch arm64 " NOFORTRAN=1 AR="/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ar" libs
 mkdir -p build-iphoneos
 cp libopenblas_armv8p-r0.3.10.dev.a build-iphoneos/libopenblas.a
# simulator
 make BINARY=64 HOSTCC="clang -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.16.sdk" CC="clang" CFLAGS="-mios-simulator-version-min=11.0 -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator14.0.sdk -arch x86_64 -fembed-bitcode" NOFORTRAN=1 clean
 make BINARY=64 HOSTCC="clang -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.16.sdk" CC="clang" CFLAGS="-mios-simulator-version-min=11.0 -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator14.0.sdk -arch x86_64 -fembed-bitcode" NOFORTRAN=1 libs
 mkdir -p build-iphonesimulator
 cp libopenblas_haswellp-r0.3.10.dev.a build-iphonesimulator/libopenblas.a
# for the headers:
 make BINARY=64 HOSTCC="clang -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.16.sdk" CC="clang" CFLAGS="-mios-simulator-version-min=11.0 -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator14.0.sdk -arch x86_64 -fembed-bitcode" NOFORTRAN=1 install PREFIX=./install 
popd

# curl -OL https://download.savannah.gnu.org/releases/freetype/freetype-2.10.2.tar.gz
# tar xvzf freetype-2.10.2.tar.gz
# rm freetype-2.10.2.tar.gz
# env CCexe_CFLAGS="-isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/" ./configure CC=clang CXX=clang++ CFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/ -fembed-bitcode" CPPFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/" CXXFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/ -fembed-bitcode" LDFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/ -fembed-bitcode" --build=x86_64-apple-darwin --host=armv7-apple-darwin --with-harfbuzz=no --with-png=yes LIBPNG_CFLAGS="-I ../build/Release-iphoneos/libpng.framework/Headers" LIBPNG_LIBS="-F../build/Release-iphoneos -framework libpng"
# make -j 4


# Now, creat all frameworks for both architectures: 
xcodebuild -project Python-aux.xcodeproj -alltargets -sdk iphoneos -configuration Release -quiet
xcodebuild -project Python-aux.xcodeproj -alltargets -sdk iphonesimulator -configuration Release -quiet

# then, merge them into XCframeworks:
for framework in libpng libffi libzmq openblas
do
   rm -rf $framework.xcframework
   xcodebuild -create-xcframework -framework build/Release-iphoneos/$framework.framework -framework build/Release-iphonesimulator/$framework.framework -output $framework.xcframework
   # while we're at it, let's compute the checksum:
   rm -f $framework.xcframework.zip
   zip -r $framework.xcframework.zip $framework.xcframework
   swift package compute-checksum $framework.xcframework.zip
done


# freetype, harfbuzz, openblas
