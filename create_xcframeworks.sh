# 2 architectures framework
for framework in libpng freetype harfbuzz
do
   rm -rf $framework.xcframework
   xcodebuild -create-xcframework -framework build/Release-iphoneos/$framework.framework -framework build/Release-iphonesimulator/$framework.framework -output $framework.xcframework
done

# 3 architectures framework
for framework in openblas
do
   rm -rf $framework.xcframework
   xcodebuild -create-xcframework -framework build/Release-iphoneos/$framework.framework -framework build/Release-iphonesimulator/$framework.framework -framework build/Release-osx/$framework.framework -output $framework.xcframework
done


