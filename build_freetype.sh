#!/bin/bash
set -euo pipefail

# Cross dependencies are supplied below; never discover macOS Homebrew libraries.
export PKG_CONFIG_LIBDIR= PKG_CONFIG_PATH=

OSX_SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)

freetype=freetype-2.10.2
# step 1: build freetype without harfbuzz support:
echo "Downloading freetype and building freetype without harfbuzz:"
curl --fail --location --retry 3 -O https://download.savannah.gnu.org/releases/freetype/$freetype.tar.gz
echo "e09aa914e4f7a5d723ac381420949c55c0b90b15744adce5d1406046022186ab  $freetype.tar.gz" | shasum -a 256 -c -
tar xvzf $freetype.tar.gz
rm $freetype.tar.gz
pushd $freetype
if [ -f Makefile ]; then make distclean; fi
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	CPPFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	CXXFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	LDFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	CC_BUILD="clang -isysroot ${OSX_SDKROOT}" \
	--build=x86_64-apple-darwin --host=armv8-apple-darwin --with-harfbuzz=no \
	--with-png=yes LIBPNG_CFLAGS="-I ${PWD}/../build/Release-iphoneos/libpng.framework/Headers" \
	LIBPNG_LIBS="-F${PWD}/../build/Release-iphoneos -framework libpng" \
	cross_compiling=yes
make -j 4
mkdir -p build-iphoneos
cp objs/.libs/libfreetype.a build-iphoneos
cp objs/.libs/libfreetype.dylib build-iphoneos
for sim_arch in arm64 x86_64; do
  sim_host=aarch64-apple-darwin
  if [[ $sim_arch == x86_64 ]]; then sim_host=x86_64-apple-darwin; fi
if [ -f Makefile ]; then make distclean; fi
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch ${sim_arch} -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	CPPFLAGS="-arch ${sim_arch} -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	CXXFLAGS="-arch ${sim_arch} -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	LDFLAGS="-arch ${sim_arch} -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	CC_BUILD="clang -isysroot ${OSX_SDKROOT}" \
	--build=x86_64-apple-darwin --host=${sim_host} --with-harfbuzz=no \
	--with-png=yes LIBPNG_CFLAGS="-I ${PWD}/../build/Release-iphonesimulator/libpng.framework/Headers" \
	LIBPNG_LIBS="-F${PWD}/../build/Release-iphonesimulator -framework libpng" \
	cross_compiling=yes
make -j 4
mkdir -p build-iphonesimulator-${sim_arch}
cp objs/.libs/libfreetype.a build-iphonesimulator-${sim_arch}
cp objs/.libs/libfreetype.dylib build-iphonesimulator-${sim_arch}

done
mkdir -p build-iphonesimulator
for suffix in a dylib; do
  lipo -create "build-iphonesimulator-arm64/libfreetype.$suffix" "build-iphonesimulator-x86_64/libfreetype.$suffix" -output "build-iphonesimulator/libfreetype.$suffix"
done
popd

# step 2: build harfbuzz using freetype 

echo "Building harfbuzz with freetype support:" 
# Match FreeType's callback ABI without incompatible function-pointer casts.
if ! git -C harfbuzz apply --reverse --check ../patches/harfbuzz-finalizers.patch 2>/dev/null; then
    git -C harfbuzz apply ../patches/harfbuzz-finalizers.patch
fi
# Note: need to call ./autogen.sh but only once.
pushd harfbuzz 
if [ ! -f configure ]; then NOCONFIGURE=1 ./autogen.sh; fi
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	CPPFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	CXXFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	LDFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -L${PWD}/../${freetype}/build-iphoneos/" \
	--build=x86_64-apple-darwin --host=armv8-apple-darwin --enable-static=yes --with-glib=no --with-cairo=no --with-freetype=yes FREETYPE_CFLAGS="-I${PWD}/../${freetype}/include/" FREETYPE_LIBS="-lfreetype" 
make -C src -j4 --quiet lib
mkdir -p build-iphoneos
cp src/.libs/libharfbuzz.a build-iphoneos
cp src/.libs/libharfbuzz.0.dylib build-iphoneos/libharfbuzz.dylib
for sim_arch in arm64 x86_64; do
  sim_host=aarch64-apple-darwin
  if [[ $sim_arch == x86_64 ]]; then sim_host=x86_64-apple-darwin; fi
if [ -f Makefile ]; then make distclean; fi
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch ${sim_arch} -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	CPPFLAGS="-arch ${sim_arch} -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	CXXFLAGS="-arch ${sim_arch} -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	LDFLAGS="-arch ${sim_arch} -mios-simulator-version-min=11.0 -isysroot${SIM_SDKROOT} -L${PWD}/../${freetype}/build-iphonesimulator-${sim_arch}/" \
	--build=x86_64-apple-darwin --host=${sim_host} --enable-static=yes --with-glib=no --with-cairo=no --with-freetype=yes FREETYPE_CFLAGS="-I${PWD}/../${freetype}/include/" FREETYPE_LIBS="-lfreetype" cross_compiling=yes
make -C src -j4 --quiet lib
mkdir -p build-iphonesimulator-${sim_arch}
cp src/.libs/libharfbuzz.a build-iphonesimulator-${sim_arch}
cp src/.libs/libharfbuzz.0.dylib build-iphonesimulator-${sim_arch}/libharfbuzz.dylib

done
mkdir -p build-iphonesimulator
for suffix in a dylib; do
  lipo -create "build-iphonesimulator-arm64/libharfbuzz.$suffix" "build-iphonesimulator-x86_64/libharfbuzz.$suffix" -output "build-iphonesimulator/libharfbuzz.$suffix"
done
if [ -f Makefile ]; then make distclean; fi
popd 

# step 3: recompile freetype with harfbuzz support:
pushd $freetype
if [ -f Makefile ]; then make distclean; fi
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	CPPFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	CXXFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	LDFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	CC_BUILD="clang -isysroot ${OSX_SDKROOT}" \
	--build=x86_64-apple-darwin --host=armv8-apple-darwin --with-harfbuzz=no \
	--with-png=yes LIBPNG_CFLAGS="-I ${PWD}/../build/Release-iphoneos/libpng.framework/Headers" \
	LIBPNG_LIBS="-F${PWD}/../build/Release-iphoneos -framework libpng" \
	--with-harfbuzz=yes HARFBUZZ_CFLAGS="-I${PWD}/../harfbuzz/src/" HARFBUZZ_LIBS="-L${PWD}/../harfbuzz/build-iphoneos -lharfbuzz" \
	cross_compiling=yes
make -j 4
mkdir -p build-iphoneos
cp objs/.libs/libfreetype.a build-iphoneos
cp objs/.libs/libfreetype.dylib build-iphoneos
for sim_arch in arm64 x86_64; do
  sim_host=aarch64-apple-darwin
  if [[ $sim_arch == x86_64 ]]; then sim_host=x86_64-apple-darwin; fi
if [ -f Makefile ]; then make distclean; fi
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch ${sim_arch} -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	CPPFLAGS="-arch ${sim_arch} -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	CXXFLAGS="-arch ${sim_arch} -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	LDFLAGS="-arch ${sim_arch} -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	CC_BUILD="clang -isysroot ${OSX_SDKROOT}" \
	--build=x86_64-apple-darwin --host=${sim_host} --with-harfbuzz=no \
	--with-png=yes LIBPNG_CFLAGS="-I ${PWD}/../build/Release-iphonesimulator/libpng.framework/Headers" \
	LIBPNG_LIBS="-F${PWD}/../build/Release-iphonesimulator -framework libpng" \
	--with-harfbuzz=yes HARFBUZZ_CFLAGS="-I${PWD}/../harfbuzz/src/" HARFBUZZ_LIBS="-L${PWD}/../harfbuzz/build-iphonesimulator-${sim_arch} -lharfbuzz" \
	cross_compiling=yes
make -j 4
mkdir -p build-iphonesimulator-${sim_arch}
cp objs/.libs/libfreetype.a build-iphonesimulator-${sim_arch}
cp objs/.libs/libfreetype.dylib build-iphonesimulator-${sim_arch}

done
mkdir -p build-iphonesimulator
for suffix in a dylib; do
  lipo -create "build-iphonesimulator-arm64/libfreetype.$suffix" "build-iphonesimulator-x86_64/libfreetype.$suffix" -output "build-iphonesimulator/libfreetype.$suffix"
done
popd

# step 4: create the frameworks:
for platform in iphoneos iphonesimulator
do 
	for binary in freetype harfbuzz 
	do
		FRAMEWORK_DIR=build/Release-${platform}/${binary}.framework
		rm -rf ${FRAMEWORK_DIR}
		mkdir -p ${FRAMEWORK_DIR}
		mkdir -p ${FRAMEWORK_DIR}/Headers
		if [ "$binary" == "freetype" ]; then
			cp -R $freetype/include/* ${FRAMEWORK_DIR}/Headers
			cp $freetype/build-${platform}/libfreetype.dylib ${FRAMEWORK_DIR}/$binary
            install_name_tool -change /usr/local/lib/libharfbuzz.0.dylib  @rpath/harfbuzz.framework/harfbuzz ${FRAMEWORK_DIR}/$binary
		fi
		if [ "$binary" == "harfbuzz" ]; then
			cp -R harfbuzz/src/* ${FRAMEWORK_DIR}/Headers
			cp harfbuzz/build-${platform}/libharfbuzz.dylib ${FRAMEWORK_DIR}/$binary
            install_name_tool -change /usr/local/lib/libfreetype.6.dylib  @rpath/freetype.framework/freetype ${FRAMEWORK_DIR}/$binary
		fi
		if [ "$platform" == "iphoneos" ]; then
			cp basic_Info.plist ${FRAMEWORK_DIR}/Info.plist
		else 
			cp basic_Info_Simulator.plist ${FRAMEWORK_DIR}/Info.plist
		fi
		plutil -replace CFBundleExecutable -string $binary ${FRAMEWORK_DIR}/Info.plist
		plutil -replace CFBundleName -string $binary ${FRAMEWORK_DIR}/Info.plist
		plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.$binary  ${FRAMEWORK_DIR}/Info.plist
		install_name_tool -id @rpath/$binary.framework/$binary   ${FRAMEWORK_DIR}/$binary
	done
done
