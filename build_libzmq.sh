#!/bin/bash

# libzmq:
pushd libzmq
sh builds/ios/build_ios.sh
popd
# then, merge them into XCframeworks:
framework=libzmq
rm -rf $framework.xcframework
xcodebuild -create-xcframework \
	-library $frameworklibzmq/builds/ios/libzmq_build/arm64/lib/libzmq.a -headers $framework/builds/ios/libzmq_build/arm64/include \
	-library $framework/builds/ios/libzmq_build/x86_64/lib/libzmq.a -library $framework/builds/ios/libzmq_build/x86_64/include \
	-output $framework.xcframework
# while we're at it, let's compute the checksum:
rm -f $framework.xcframework.zip
zip -rq $framework.xcframework.zip $framework.xcframework
swift package compute-checksum $framework.xcframework.zip


