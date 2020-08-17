#!/bin/bash

# libzmq:
# create the static libraries
export M4=/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin//m4
pushd libzmq
make distclean
sh builds/ios/build_ios.sh
popd
# then, merge them into XCframeworks:
framework=libzmq
rm -rf $framework.xcframework
xcodebuild -create-xcframework \
	-library $framework/builds/ios/libzmq_build/arm64/lib/libzmq.a -headers $framework/builds/ios/libzmq_build/arm64/include \
	-library $framework/builds/ios/libzmq_build/x86_64/lib/libzmq.a -headers $framework/builds/ios/libzmq_build/x86_64/include \
	-output $framework.xcframework


