# Required with Xcode 12 beta:
export M4=$(xcrun -f m4)
OSX_SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)
BASE=$PWD
# OSX 11: required to run gfortran
if [ -z "${LIBRARY_PATH}" ]; then
    export LIBRARY_PATH="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib"
else
    export LIBRARY_PATH="$LIBRARY_PATH:/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib"
fi

SOURCE_DIR=GDAL

# Now create frameworks:
for platform in osx iphoneos iphonesimulator
do 
	for binary in libgdal
	do
		FRAMEWORK_DIR=build/Release-${platform}/${binary}.framework
		rm -rf ${FRAMEWORK_DIR}
		mkdir -p ${FRAMEWORK_DIR}
		mkdir -p ${FRAMEWORK_DIR}/Headers
		cp -r $SOURCE_DIR/build-${platform}/include/* ${FRAMEWORK_DIR}/Headers
		cp $SOURCE_DIR/build-$platform/$binary.dylib ${FRAMEWORK_DIR}/$binary
		install_name_tool -change @rpath/libgdal.31.dylib  @rpath/libproj.framework/libgdal ${FRAMEWORK_DIR}/$binary
		if [ "$platform" == "iphoneos" ]; then
			cp basic_Info.plist ${FRAMEWORK_DIR}/Info.plist
		elif [ "$platform" == "iphonesimulator" ]; then
			cp basic_Info_Simulator.plist ${FRAMEWORK_DIR}/Info.plist
		else 
			cp basic_Info_OSX.plist ${FRAMEWORK_DIR}/Info.plist
		fi
		plutil -replace CFBundleExecutable -string $binary ${FRAMEWORK_DIR}/Info.plist
		plutil -replace CFBundleName -string $binary ${FRAMEWORK_DIR}/Info.plist
		plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.$binary  ${FRAMEWORK_DIR}/Info.plist
		install_name_tool -id @rpath/$binary.framework/$binary   ${FRAMEWORK_DIR}/$binary
	done
done

# 3 architectures framework
for framework in  libgdal 
do
   rm -rf $framework.xcframework
   xcodebuild -create-xcframework -framework build/Release-iphoneos/$framework.framework -framework build/Release-iphonesimulator/$framework.framework -framework build/Release-osx/$framework.framework -output $framework.xcframework
done

