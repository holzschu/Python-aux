for framework in libpng openblas
do
   rm -rf $framework.xcframework
   xcodebuild -create-xcframework -framework build/Release-iphoneos/$framework.framework -framework build/Release-iphonesimulator/$framework.framework -output $framework.xcframework
done

