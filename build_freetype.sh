#!/bin/bash

# In case we use Xcode-beta, use the proper m4:
export M4=$(xcrun -f m4)
OSX_SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)

freetype=freetype-2.10.2
# step 1: build freetype without harfbuzz support:
echo "Downloading freetype and building freetype without harfbuzz:"
curl -OL https://download.savannah.gnu.org/releases/freetype/$freetype.tar.gz
tar xvzf $freetype.tar.gz
rm $freetype.tar.gz
pushd $freetype
make distclean
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	CPPFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	CXXFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	LDFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	CC_BUILD="clang -isysroot ${OSX_SDKROOT}" \
	--build=x86_64-apple-darwin --host=armv8-apple-darwin --with-harfbuzz=no \
	--with-png=yes LIBPNG_CFLAGS="-I ${PWD}/../build/Release-iphoneos/libpng.framework/Headers" \
	LIBPNG_LIBS="-F${PWD}/../build/Release-iphoneos -framework libpng" \
	cross_compiling=yes
make -j 4
mkdir -p build-iphoneos
cp objs/.libs/libfreetype.a build-iphoneos
cp objs/.libs/libfreetype.dylib build-iphoneos
make distclean 
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
	CPPFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	CXXFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
	LDFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
	CC_BUILD="clang -isysroot ${OSX_SDKROOT}" \
	--build=x86_64-apple-darwin --host=x86_64-apple-darwin --with-harfbuzz=no \
	--with-png=yes LIBPNG_CFLAGS="-I ${PWD}/../build/Release-iphonesimulator/libpng.framework/Headers" \
	LIBPNG_LIBS="-F${PWD}/../build/Release-iphonesimulator -framework libpng" \
	cross_compiling=yes
make -j 4
mkdir -p build-iphonesimulator
cp objs/.libs/libfreetype.a build-iphonesimulator
cp objs/.libs/libfreetype.dylib build-iphonesimulator
popd

# step 2: build harfbuzz using freetype 

echo "Building harfbuzz with freetype support:" 
# Note: need to call ./autogen.sh but only once.
pushd harfbuzz 
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	CPPFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	CXXFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	LDFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -L${PWD}/../${freetype}/build-iphoneos/" \
	--build=x86_64-apple-darwin --host=armv8-apple-darwin --enable-static=yes --with-glib=no --with-cairo=no --with-freetype=yes FREETYPE_CFLAGS="-I${PWD}/../${freetype}/include/" FREETYPE_LIBS="-lfreetype" 
make -j4 --quiet 
mkdir -p build-iphoneos
cp src/.libs/libharfbuzz.a build-iphoneos
cp src/.libs/libharfbuzz.0.dylib build-iphoneos/libharfbuzz.dylib
make distclean
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	CPPFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	CXXFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	LDFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot${SIM_SDKROOT} -L${PWD}/../${freetype}/build-iphonesimulator/" \
	--build=x86_64-apple-darwin --host=x86_64-apple-darwin --enable-static=yes --with-glib=no --with-cairo=no --with-freetype=yes FREETYPE_CFLAGS="-I${PWD}/../${freetype}/include/" FREETYPE_LIBS="-lfreetype" cross_compiling=yes
make -j4 --quiet 
mkdir -p build-iphonesimulator
cp src/.libs/libharfbuzz.a build-iphonesimulator
cp src/.libs/libharfbuzz.0.dylib build-iphonesimulator/libharfbuzz.dylib
make distclean
popd 

# step 3: recompile freetype with harfbuzz support:
pushd $freetype
make distclean
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	CPPFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT}" \
	CXXFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	LDFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
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
make distclean 
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
	CPPFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT}" \
	CXXFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
	LDFLAGS="-arch x86_64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
	CC_BUILD="clang -isysroot ${OSX_SDKROOT}" \
	--build=x86_64-apple-darwin --host=x86_64-apple-darwin --with-harfbuzz=no \
	--with-png=yes LIBPNG_CFLAGS="-I ${PWD}/../build/Release-iphonesimulator/libpng.framework/Headers" \
	LIBPNG_LIBS="-F${PWD}/../build/Release-iphonesimulator -framework libpng" \
	--with-harfbuzz=yes HARFBUZZ_CFLAGS="-I${PWD}/../harfbuzz/src/" HARFBUZZ_LIBS="-L${PWD}/../harfbuzz/build-iphonesimulator -lharfbuzz" \
	cross_compiling=yes
make -j 4
mkdir -p build-iphonesimulator
cp objs/.libs/libfreetype.a build-iphonesimulator
cp objs/.libs/libfreetype.dylib build-iphonesimulator
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
