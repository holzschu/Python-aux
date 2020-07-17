#!/bin/bash

# Currently, libffi and libzmq scripts produce static libraries. 
# libffi:
pushd libffi
# we need to patch libffi to allow compilation with Xcode12, but only once:
# patch -p1 < ../libffi.patch 
xcodebuild -project libffi.xcodeproj -target libffi-iOS -sdk iphoneos -arch arm64 -configuration Debug -quiet
xcodebuild -project libffi.xcodeproj -target libffi-iOS -sdk iphonesimulator -configuration Debug -quiet
popd 
# then, merge them into XCframeworks:
framework=libffi
rm -rf $framework.xcframework
xcodebuild -create-xcframework \
	-library $framework/build/Debug-iphoneos/libffi.a -headers $framework/build/Debug-iphoneos/include \
	-library $framework/build/Debug-iphonesimulator/libffi.a -library $framework/build/Debug-iphonesimulator/include \
	-output $framework.xcframework
# while we're at it, let's compute the checksum:
rm -f $framework.xcframework.zip
zip -rq $framework.xcframework.zip $framework.xcframework
swift package compute-checksum $framework.xcframework.zip


