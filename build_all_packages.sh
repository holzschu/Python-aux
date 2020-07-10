#!/bin/bash

# First, creat all frameworks for both architectures: 
xcodebuild -project Python-aux.xcodeproj -alltargets -sdk iphoneos -configuration Release -quiet
xcodebuild -project Python-aux.xcodeproj -alltargets -sdk iphonesimulator -configuration Release -quiet

# then, merge them into XCframeworks:
for framework in libpng
do
   rm -rf $framework.xcframework
   xcodebuild -create-xcframework -framework build/Release-iphoneos/$framework.framework -framework build/Release-iphonesimulator/$framework.framework -output $framework.xcframework
   # while we're at it, let's compute the checksum:
   rm -f $framework.xcframework.zip
   zip -r $framework.xcframework.zip $framework.xcframework
   swift package compute-checksum $framework.xcframework.zip
done



