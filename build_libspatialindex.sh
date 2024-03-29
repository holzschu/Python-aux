#!/bin/bash

# M4 Required with Xcode beta:
export M4=$(xcrun -f m4)
OSX_SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)

mkdir -p libspatialindex-osx
pushd libspatialindex-osx
cmake ../libspatialindex \
	-DCMAKE_INSTALL_PREFIX=@rpath \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_OSX_SYSROOT=${OSX_SDKROOT} \
	-DCMAKE_C_COMPILER=$(xcrun --sdk macosx -f clang) \
	-DCMAKE_CXX_COMPILER=$(xcrun --sdk macosx -f clang++) \
	-DCMAKE_LIBRARY_PATH=${OSX_SDKROOT}/lib/ \
	-DCMAKE_INCLUDE_PATH=${OSX_SDKROOT}/include/ 
make
popd

mkdir -p libspatialindex-iphoneos
pushd libspatialindex-iphoneos
cmake ../libspatialindex \
	-DCMAKE_INSTALL_PREFIX=@rpath \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_OSX_SYSROOT=${IOS_SDKROOT} \
	-DCMAKE_C_COMPILER=$(xcrun --sdk iphoneos -f clang) \
	-DCMAKE_CXX_COMPILER=$(xcrun --sdk iphoneos -f clang++) \
	-DCMAKE_C_FLAGS="-arch arm64 -target arm64-apple-darwin19.6.0 -O2 -miphoneos-version-min=14  " \
	-DCMAKE_CXX_FLAGS="-arch arm64 -target arm64-apple-darwin19.6.0 -O2 -miphoneos-version-min=14 " \
	-DCMAKE_LIBRARY_PATH=${IOS_SDKROOT}/lib/ \
	-DCMAKE_INCLUDE_PATH=${IOS_SDKROOT}/include/ 
make
popd

mkdir -p libspatialindex-iphonesimulator
pushd libspatialindex-iphonesimulator
cmake ../libspatialindex \
	-DCMAKE_INSTALL_PREFIX=@rpath \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_OSX_SYSROOT=${SIM_SDKROOT} \
	-DCMAKE_C_COMPILER=$(xcrun --sdk iphonesimulator -f clang) \
	-DCMAKE_CXX_COMPILER=$(xcrun --sdk iphonesimulator -f clang++) \
	-DCMAKE_C_FLAGS="-target x86_64-apple-darwin19.6.0 -O2 -mios-simulator-version-min=14.0  " \
	-DCMAKE_CXX_FLAGS="-target x86_64-apple-darwin19.6.0 -O2 -mios-simulator-version-min=14.0 " \
	-DCMAKE_LIBRARY_PATH=${SIM_SDKROOT}/lib/ \
	-DCMAKE_INCLUDE_PATH=${SIM_SDKROOT}/include/ 
make
popd

# Now create frameworks:
for platform in osx iphoneos iphonesimulator
do 
	for binary in libspatialindex_c libspatialindex
	do
		FRAMEWORK_DIR=build/Release-${platform}/${binary}.framework
		rm -rf ${FRAMEWORK_DIR}
		mkdir -p ${FRAMEWORK_DIR}
		mkdir -p ${FRAMEWORK_DIR}/Headers
		cp -R libspatialindex/include/* ${FRAMEWORK_DIR}/Headers
		cp libspatialindex-$platform/bin/$binary.dylib ${FRAMEWORK_DIR}/$binary
		install_name_tool -change @rpath/libspatialindex_c.6.dylib  @rpath/libspatialindex_c.framework/libspatialindex_c ${FRAMEWORK_DIR}/$binary
		install_name_tool -change @rpath/libspatialindex.6.dylib  @rpath/libspatialindex.framework/libspatialindex ${FRAMEWORK_DIR}/$binary
		if [ "$platform" == "iphoneos" ]; then
			cp basic_Info.plist ${FRAMEWORK_DIR}/Info.plist
		elif [ "$platform" == "iphonesimulator" ]; then
			cp basic_Info_Simulator.plist ${FRAMEWORK_DIR}/Info.plist
		else 
			cp basic_Info_OSX.plist ${FRAMEWORK_DIR}/Info.plist
		fi
		plutil -replace CFBundleExecutable -string $binary ${FRAMEWORK_DIR}/Info.plist
		plutil -replace CFBundleName -string $binary ${FRAMEWORK_DIR}/Info.plist
		# underscore is not allowed in CFBundleIdentifier:
		signature=${binary//_/-}
		plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.$signature  ${FRAMEWORK_DIR}/Info.plist
		install_name_tool -id @rpath/$binary.framework/$binary   ${FRAMEWORK_DIR}/$binary
	done
done


