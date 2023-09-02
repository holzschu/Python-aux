#!/bin/bash

# M4 Required with Xcode beta:
export M4=$(xcrun -f m4)
OSX_SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)

export OSX_VERSION=11.5
export MACOSX_DEPLOYMENT_TARGET=$OSX_VERSION

# curl -OL https://download.osgeo.org/proj/proj-9.1.0.tar.gz
# tar xzf proj-9.1.0.tar.gz
# rm proj-9.1.0.tar.gz
source_dir=proj-9.1.0

# proj dos not use SYSROOT or CFLAGS with cmake, so we use configure

mkdir -p proj-osx
pushd proj-osx
cmake ../$source_dir \
	-DENABLE_CURL=OFF -DENABLE_TIFF=OFF -DBUILD_TESTING=OFF -DBUILD_PROJSYNC=OFF \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_VERSION} \
	-DCMAKE_INSTALL_PREFIX=@rpath \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_OSX_SYSROOT=${OSX_SDKROOT} \
	-DCMAKE_C_COMPILER=$(xcrun --sdk macosx -f clang) \
	-DCMAKE_CXX_COMPILER=$(xcrun --sdk macosx -f clang++) \
	-DCMAKE_LIBRARY_PATH=${OSX_SDKROOT}/lib/ \
	-DCMAKE_INCLUDE_PATH=${OSX_SDKROOT}/include/ 
make
popd

mkdir -p proj-iphoneos
pushd proj-iphoneos
cmake ../$source_dir \
	-DENABLE_CURL=OFF -DENABLE_TIFF=OFF -DBUILD_TESTING=OFF -DBUILD_PROJSYNC=OFF \
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

mkdir -p proj-iphonesimulator
pushd proj-iphonesimulator
cmake ../$source_dir \
	-DENABLE_CURL=OFF -DENABLE_TIFF=OFF -DBUILD_TESTING=OFF -DBUILD_PROJSYNC=OFF \
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
	for binary in libproj
	do
		FRAMEWORK_DIR=build/Release-${platform}/${binary}.framework
		rm -rf ${FRAMEWORK_DIR}
		mkdir -p ${FRAMEWORK_DIR}
		mkdir -p ${FRAMEWORK_DIR}/Headers
		cp -r $source_dir/include/proj ${FRAMEWORK_DIR}/Headers
		cp $source_dir/src/*.h ${FRAMEWORK_DIR}/Headers
		cp proj-$platform/src/proj_config.h ${FRAMEWORK_DIR}/Headers/proj/
		cp proj-$platform/lib/$binary.dylib ${FRAMEWORK_DIR}/$binary
		install_name_tool -change @rpath/libproj.22.dylib  @rpath/libproj.framework/libproj ${FRAMEWORK_DIR}/$binary
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


