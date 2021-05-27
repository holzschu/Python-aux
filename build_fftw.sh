# Required with Xcode 12 beta:
export M4=$(xcrun -f m4)
OSX_SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)

curl -OL http://www.fftw.org/fftw-3.3.9.tar.gz 
tar xzf fftw-3.3.9.tar.gz 
rm fftw-3.3.9.tar.gz 

SOURCE_DIR=fftw-3.3.9
pushd $SOURCE_DIR

make distclean
./configure CC=clang CXX=clang++ \
	CFLAGS="-isysroot ${OSX_SDKROOT} -fembed-bitcode" \
	CPPFLAGS="-isysroot ${OSX_SDKROOT} -fembed-bitcode" \
	CXXFLAGS="-isysroot ${OSX_SDKROOT} -fembed-bitcode" \
	F77="gfortran" --enable-threads
make -j4 --quiet
# in include: fftw3.h fftw3.f fftw3l.f03 fftw3q.f03
# in lib: libfftw3.a

mkdir -p build-macosx
mkdir -p build-macosx/include
cp .libs/libfftw3.a build-macosx
cp threads/.libs/libfftw3_threads.a build-macosx
cp api/fftw3.h api/fftw3.f api/fftw3l.f03 api/fftw3q.f03 build-macosx/include


make distclean
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch arm64 -miphoneos-version-min=14.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	CPPFLAGS="-arch arm64 -miphoneos-version-min=14.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	CXXFLAGS="-arch arm64 -miphoneos-version-min=14.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	F77="/usr/local/bin/aarch64-apple-darwin20-gfortran" \
	--build=x86_64-apple-darwin --host=armv8-apple-darwin --enable-threads cross_compiling=yes
make -j4 --quiet
# in include: fftw3.h fftw3.f fftw3l.f03 fftw3q.f03
# in lib: libfftw3.a

mkdir -p build-iphoneos
mkdir -p build-iphoneos/include
cp .libs/libfftw3.a build-iphoneos
cp threads/.libs/libfftw3_threads.a build-iphoneos
cp api/fftw3.h api/fftw3.f api/fftw3l.f03 api/fftw3q.f03 build-iphoneos/include

make distclean
./configure CC=clang CXX=clang++ \
        CFLAGS="-arch x86_64 -mios-simulator-version-min=14.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
        CPPFLAGS="-arch x86_64 -mios-simulator-version-min=14.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
        CXXFLAGS="-arch x86_64 -mios-simulator-version-min=14.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
        --build=x86_64-apple-darwin --host=x86_64-apple-darwin --enable-threads cross_compiling=yes
make -j4 --quiet
mkdir -p build-iphonesimulator
mkdir -p build-iphonesimulator/include
cp .libs/libfftw3.a build-iphonesimulator
cp threads/.libs/libfftw3_threads.a build-iphonesimulator
cp api/fftw3.h api/fftw3.f api/fftw3l.f03 api/fftw3q.f03 build-iphonesimulator/include
popd


# then, merge them into XCframeworks:
framework=libfftw3
rm -rf $framework.xcframework
xcodebuild -create-xcframework \
	-library $SOURCE_DIR/build-macosx/libfftw3.a -headers $SOURCE_DIR/build-iphoneos/include \
	-library $SOURCE_DIR/build-iphoneos/libfftw3.a -headers $SOURCE_DIR/build-iphoneos/include \
	-library $SOURCE_DIR/build-iphonesimulator/libfftw3.a -headers $SOURCE_DIR/build-iphonesimulator/include \
	-output $framework.xcframework

framework=libfftw3_threads
rm -rf $framework.xcframework
xcodebuild -create-xcframework \
	-library $SOURCE_DIR/build-macosx/libfftw3_threads.a  \
	-library $SOURCE_DIR/build-iphoneos/libfftw3_threads.a  \
	-library $SOURCE_DIR/build-iphonesimulator/libfftw3_threads.a  \
	-output $framework.xcframework


