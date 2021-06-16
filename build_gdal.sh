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

SOURCE_DIR=GDAL/gdal
pushd $SOURCE_DIR

make distclean
cp ${BASE}/libproj.xcframework/macos-x86_64/libproj.framework/libproj ./libproj.dylib
cp ${BASE}/libgeos_c.xcframework/macos-x86_64/libgeos_c.framework/libgeos_c ./libgeos_c.dylib
# Edited configure to use "-L ." for lgeos_c (line 38518)
./configure CC=clang CXX=clang++ \
	CFLAGS="-isysroot ${OSX_SDKROOT} -fembed-bitcode -I ${BASE}/libproj.xcframework/macos-x86_64/libproj.framework/Headers/" \
	CPPFLAGS="-isysroot ${OSX_SDKROOT} -fembed-bitcode -I ${BASE}/libproj.xcframework/macos-x86_64/libproj.framework/Headers/" \
	CXXFLAGS="-isysroot ${OSX_SDKROOT} -fembed-bitcode -I ${BASE}/libproj.xcframework/macos-x86_64/libproj.framework/Headers/" \
	LDFLAGS="-L${BASE}/${SOURCE_DIR}" \
	--with-threads=no --with-png=internal --with-jpeg=internal --with-libtiff=internal --with-libz=internal  --with-geos=yes 
make -j4 --quiet
mkdir -p build-osx
mkdir -p build-osx/include
cp .libs/libgdal.dylib build-osx
cp port/*.h build-osx/include
cp gcore/*.h build-osx/include
cp frmts/vrt/*.h build-osx/include
cp frmts/mem/*.h build-osx/include
cp alg/*.h build-osx/include
cp ogr/*.h build-osx/include

make distclean
unexport LIBRARY_PATH
cp ${BASE}/libproj.xcframework/ios-arm64/libproj.framework/libproj ./libproj.dylib
cp ${BASE}/libgeos_c.xcframework/ios-arm64/libgeos_c.framework/libgeos_c ./libgeos_c.dylib
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch arm64 -miphoneos-version-min=14.0 -isysroot ${IOS_SDKROOT} -I ${BASE}/libproj.xcframework/ios-arm64/libproj.framework/Headers/" \
	CPPFLAGS="-arch arm64 -miphoneos-version-min=14.0 -isysroot ${IOS_SDKROOT} -I ${BASE}/libproj.xcframework/ios-arm64/libproj.framework/Headers/" \
	CXXFLAGS="-arch arm64 -miphoneos-version-min=14.0 -isysroot ${IOS_SDKROOT} -I ${BASE}/libproj.xcframework/ios-arm64/libproj.framework/Headers/" \
	LDFLAGS="-arch arm64 -miphoneos-version-min=14.0 -isysroot ${IOS_SDKROOT} -L${BASE}/${SOURCE_DIR} -liconv" \
	--build=x86_64-apple-darwin --host=armv8-apple-darwin \
	--with-threads=no --with-png=internal --with-jpeg=internal --with-libtiff=internal --with-libz=internal --with-geos=yes
make -j4 --quiet
mkdir -p build-iphoneos
mkdir -p build-iphoneos/include
cp .libs/libgdal.dylib build-iphoneos
cp port/*.h build-iphoneos/include
cp gcore/*.h build-iphoneos/include
cp frmts/vrt/*.h build-iphoneos/include
cp frmts/mem/*.h build-iphoneos/include
cp alg/*.h build-iphoneos/include
cp ogr/*.h build-iphoneos/include


make distclean
cp ${BASE}/libproj.xcframework/ios-x86_64-simulator/libproj.framework/libproj ./libproj.dylib
cp ${BASE}/libgeos_c.xcframework/ios-x86_64-simulator/libgeos_c.framework/libgeos_c ./libgeos_c.dylib
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch x86_64 -mios-simulator-version-min=14.0  -isysroot ${SIM_SDKROOT} -I ${BASE}/libproj.xcframework/ios-x86_64-simulator/libproj.framework/Headers/" \
	CPPFLAGS="-arch x86_64 -mios-simulator-version-min=14.0  -isysroot ${SIM_SDKROOT} -I ${BASE}/libproj.xcframework/ios-x86_64-simulator/libproj.framework/Headers/" \
	CXXFLAGS="-arch x86_64 -mios-simulator-version-min=14.0  -isysroot ${SIM_SDKROOT} -I ${BASE}/libproj.xcframework/ios-x86_64-simulator/libproj.framework/Headers/" \
	LDFLAGS="-arch x86_64 -mios-simulator-version-min=14.0  -isysroot ${SIM_SDKROOT} -L${BASE}/${SOURCE_DIR} -liconv" \
	--host=x86_64-apple-darwin \
	--with-threads=no --with-png=internal --with-jpeg=internal --with-libtiff=internal --with-libz=internal --with-geos=yes
make -j4 --quiet
mkdir -p build-iphonesimulator
mkdir -p build-iphonesimulator/include
cp .libs/libgdal.dylib build-iphonesimulator
cp port/*.h build-iphonesimulator/include
cp gcore/*.h build-iphonesimulator/include
cp frmts/vrt/*.h build-iphonesimulator/include
cp frmts/mem/*.h build-iphonesimulator/include
cp alg/*.h build-iphonesimulator/include
cp ogr/*.h build-iphonesimulator/include
popd


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
		install_name_tool -change @rpath/libgdal.29.dylib  @rpath/libproj.framework/libgdal ${FRAMEWORK_DIR}/$binary
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

