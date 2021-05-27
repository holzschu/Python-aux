#!/bin/bash

# Required with Xcode 12 beta:
export M4=$(xcrun -f m4)
OSX_SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)

# Set to 1 if you have gfortran for arm64 installed. gfortran support is highly experimental.
# You might need to edit the script as well.
USE_FORTRAN=0
if [ -e "/usr/local/aarch64-apple-darwin20/lib/libgfortran.dylib" ];then
	USE_FORTRAN=1
fi
# OSX 11: required for many things
if [ -z "${LIBRARY_PATH}" ]; then
	export LIBRARY_PATH="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib"
else
	export LIBRARY_PATH="$LIBRARY_PATH:/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib"
fi

# Using Xcode to create frameworks from archived libraries (lib.a) is failing randomly. 
# We stick to creating frameworks from dynamic libraries.
# We currently have a fortran compiler for iOS (experimental, gfortran) and OSX (gfortran), 
# but not yet for the simulator, so the simulator is built with NOFORTRAN.

# We have modified (slightly) Makefile and Makefile.system
pushd OpenBLAS
# Having the exact same script inside Xcode does not work. Strange but true.
# iphoneos:
if [ $USE_FORTRAN == 0 ];
then
	make TARGET=ARMV8 BINARY=64 \
		HOSTCC="clang -isysroot ${OSX_SDKROOT}" \
		CC="clang" \
		CFLAGS="-miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -arch arm64 -fembed-bitcode" \
		NOFORTRAN=1 \
		AR="$(xcrun -f ar)" clean
	make TARGET=ARMV8 BINARY=64 HOSTCC="clang -isysroot ${OSX_SDKROOT}" \
		CC="clang" \
		CFLAGS="-miphoneos-version-min=11.0 -isysroot  ${IOS_SDKROOT} -arch arm64 -fembed-bitcode" \
		NOFORTRAN=1 \
		AR="$(xcrun -f ar)" libs shared
else
	make TARGET=ARMV8 BINARY=64 \
		HOSTCC="clang -isysroot ${OSX_SDKROOT}" \
		CC="clang" \
		CFLAGS="-miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -arch arm64 -fembed-bitcode" \
		AR="$(xcrun -f ar)" clean
	make TARGET=ARMV8 BINARY=64 HOSTCC="clang -isysroot ${OSX_SDKROOT}" \
		CC="clang" \
		CFLAGS="-miphoneos-version-min=11.0 -isysroot  ${IOS_SDKROOT} -arch arm64 -fembed-bitcode" \
		FC="/usr/local/bin/aarch64-apple-darwin20-gfortran" \
		LDFLAGS="-miphoneos-version-min=11.0 -arch arm64 " \
		FFLAGS="-miphoneos-version-min=11.0 -arch arm64" \
		ASFLAGS="-miphoneos-version-min=11.0 -arch arm64" \
		AR="$(xcrun -f ar)"  all
    # gemm_tcopy.S and gemm_ncopy.S both create issues. Commented out in KERNEL.ARMV8.
	# same with sgemm_tcopy (scikit-learn) and presumably sgemm_ncopy. Commented out.
	# What if you don't give a target? (no assembly code, obviously).
    # make has created the libopenblas....dylib with no platform. Let's do it:
	pushd exports
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ld -syslibroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/ -dynamic -dylib -arch arm64 -dylib_install_name /Users/holzschu/src/Xcode_iPad/Python-aux/OpenBLAS/exports/../libopenblas.0.dylib -all_load -headerpad_max_install_names -weak_reference_mismatches non-weak -o ../libopenblas_armv8p-r0.3.13.dev.dylib -L/usr/local/lib/gcc/aarch64-apple-darwin20/10.2.1 -L/usr/local/lib/gcc/aarch64-apple-darwin20/10.2.1/../../../../aarch64-apple-darwin20/lib -L/usr/local/lib/gcc/aarch64-apple-darwin20/10.2.1 -L/usr/local/lib/gcc/aarch64-apple-darwin20/10.2.1/../../../../aarch64-apple-darwin20/lib -L/usr/local/lib/gcc/aarch64-apple-darwin20/10.2.1 -L/usr/local/lib/gcc/aarch64-apple-darwin20/10.2.1/../../../../aarch64-apple-darwin20/lib ../libopenblas_armv8p-r0.3.13.dev.a -exported_symbols_list osx.def -lSystem -lgfortran -lemutls_w -lemutls_w -lSystem -lgfortran -lemutls_w -lemutls_w -lSystem -lgfortran -lemutls_w -lgcc -lm -lemutls_w -lgcc -lSystem -lgcc -platform_version ios 11.0 11.0
	popd
fi
 mkdir -p build-iphoneos
 cp libopenblas_armv8p-r0.3.13.dev.a build-iphoneos/libopenblas.a
 cp libopenblas_armv8p-r0.3.13.dev.dylib build-iphoneos/libopenblas.dylib
# for the headers:
 make BINARY=64 HOSTCC="clang -isysroot ${OSX_SDKROOT}" CC="clang" CFLAGS="-miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -arch arm64 -fembed-bitcode" install PREFIX=./install
# simulator
 make BINARY=64 HOSTCC="clang -isysroot ${OSX_SDKROOT}" \
 	 CC="clang" \
 	 CFLAGS="-mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -arch x86_64 -fembed-bitcode" \
 	 NOFORTRAN=1 clean
 make BINARY=64 HOSTCC="clang -isysroot${OSX_SDKROOT}" \
 	 CC="clang" \
 	 CFLAGS="-mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -arch x86_64 -fembed-bitcode" \
 	 NOFORTRAN=1 libs shared
  mkdir -p build-iphonesimulator
 cp libopenblas_haswellp-r0.3.13.dev.a build-iphonesimulator/libopenblas.a
 cp libopenblas_haswellp-r0.3.13.dev.dylib build-iphonesimulator/libopenblas.dylib
# OSX: 
if [ $USE_FORTRAN == 0 ];
then
	make BINARY=64 HOSTCC="clang -isysroot ${OSX_SDKROOT}" \
		CC="clang" CFLAGS="-isysroot${OSX_SDKROOT} -fembed-bitcode" \
		AR="$(xcrun -f ar)" NOFORTRAN=1 clean
	make BINARY=64 HOSTCC="clang -isysroot ${OSX_SDKROOT}" \
		CC="clang" CFLAGS="-isysroot${OSX_SDKROOT} -fembed-bitcode -mmacosx-version-min=10.15" \
		AR="$(xcrun -f ar)" NOFORTRAN=1 all
else 
	make BINARY=64 HOSTCC="clang -isysroot ${OSX_SDKROOT}" \
		CC="clang" CFLAGS="-isysroot${OSX_SDKROOT} -fembed-bitcode" \
		AR="$(xcrun -f ar)" clean
	make BINARY=64 HOSTCC="clang -isysroot ${OSX_SDKROOT}" \
		CC="clang" CFLAGS="-isysroot${OSX_SDKROOT} -fembed-bitcode -mmacosx-version-min=10.15" \
		AR="$(xcrun -f ar)" all
fi
  mkdir -p build-osx
 cp libopenblas_skylakexp-r0.3.13.dev.a build-osx/libopenblas.a
 cp libopenblas_skylakexp-r0.3.13.dev.dylib build-osx/libopenblas.dylib
popd

binary=openblas
FRAMEWORK_DIR=build/Release-iphoneos/$binary.framework
rm -rf ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}/Headers
cp OpenBLAS/install/include/*.h ${FRAMEWORK_DIR}/Headers
cp OpenBLAS/build-iphoneos/libopenblas.dylib ${FRAMEWORK_DIR}/$binary
cp basic_Info.plist ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleExecutable -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleName -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.$binary  ${FRAMEWORK_DIR}/Info.plist
install_name_tool -id @rpath/$binary.framework/$binary   ${FRAMEWORK_DIR}/$binary

FRAMEWORK_DIR=build/Release-iphonesimulator/$binary.framework
rm -rf ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}/Headers
cp OpenBLAS/install/include/*.h ${FRAMEWORK_DIR}/Headers
cp OpenBLAS/build-iphonesimulator/libopenblas.dylib ${FRAMEWORK_DIR}/$binary
cp basic_Info_Simulator.plist ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleExecutable -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleName -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.$binary  ${FRAMEWORK_DIR}/Info.plist
install_name_tool -id @rpath/$binary.framework/$binary   ${FRAMEWORK_DIR}/$binary

FRAMEWORK_DIR=build/Release-osx/$binary.framework
rm -rf ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}/Headers
cp OpenBLAS/install/include/*.h ${FRAMEWORK_DIR}/Headers
cp OpenBLAS/build-osx/libopenblas.dylib ${FRAMEWORK_DIR}/$binary
cp basic_Info_Simulator.plist ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleExecutable -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleName -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.$binary  ${FRAMEWORK_DIR}/Info.plist
install_name_tool -id @rpath/$binary.framework/$binary   ${FRAMEWORK_DIR}/$binary


