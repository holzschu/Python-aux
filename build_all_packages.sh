#!/bin/bash

# update libffi source:
git submodule update --init --recursive

export M4=/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin//m4

pushd libffi
# patch -p1 < ../libffi.patch 
xcodebuild -project libffi.xcodeproj -target libffi-iOS -sdk iphoneos -arch arm64 -configuration Debug -quiet
xcodebuild -project libffi.xcodeproj -target libffi-iOS -sdk iphonesimulator -configuration Debug -quiet
popd 


# First, creat all frameworks for both architectures: 
rm -f libffi.a
xcodebuild -project Python-aux.xcodeproj -alltargets -sdk iphoneos -configuration Release -quiet
rm -f libffi.a
xcodebuild -project Python-aux.xcodeproj -alltargets -sdk iphonesimulator -configuration Release -quiet


# then, merge them into XCframeworks:
for framework in libpng libffi
do
   rm -rf $framework.xcframework
   xcodebuild -create-xcframework -framework build/Release-iphoneos/$framework.framework -framework build/Release-iphonesimulator/$framework.framework -output $framework.xcframework
   # while we're at it, let's compute the checksum:
   rm -f $framework.xcframework.zip
   zip -r $framework.xcframework.zip $framework.xcframework
   swift package compute-checksum $framework.xcframework.zip
done



