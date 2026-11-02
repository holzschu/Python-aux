#!/bin/bash
set -euo pipefail

# Restrict optional dependency discovery to the target SDK and the JPEG recipe.
export PKG_CONFIG_LIBDIR='' PKG_CONFIG_PATH=''
curl --fail --location --retry 3 --retry-all-errors -O https://download.osgeo.org/libtiff/tiff-4.7.0.tar.gz
echo '67160e3457365ab96c5b3286a0903aa6e78bdc44c4bc737d2e486bcecb6ba976  tiff-4.7.0.tar.gz' | shasum -a 256 -c -
tar xzf tiff-4.7.0.tar.gz
rm tiff-4.7.0.tar.gz

pushd tiff-4.7.0
for target in iphoneos iphonesimulator-arm64 iphonesimulator-x86_64; do
  sdk=iphonesimulator
  host=aarch64-apple-darwin
  # arm64 Simulator support starts at iOS 14; device and Intel keep iOS 11.
  triple=arm64-apple-ios14.0-simulator
  if [[ $target == iphoneos ]]; then
    sdk=iphoneos
    triple=arm64-apple-ios11.0
  elif [[ $target == iphonesimulator-x86_64 ]]; then
    host=x86_64-apple-darwin
    triple=x86_64-apple-ios11.0-simulator
  fi
  if [[ -f Makefile ]]; then make distclean; fi
  sdkroot=$(xcrun --sdk "$sdk" --show-sdk-path)
  jpeg=$PWD/../jpeg-9d/build-$target
  ./configure CC=clang CXX=clang++ \
    CFLAGS="-target $triple -isysroot $sdkroot -O2" \
    CPPFLAGS="-target $triple -isysroot $sdkroot" \
    CXXFLAGS="-target $triple -isysroot $sdkroot -O2" \
    LDFLAGS="-target $triple -isysroot $sdkroot" \
    --build="$(sh ./config.guess)" --host="$host" --disable-shared \
    --with-jpeg-include-dir="$jpeg/include" --with-jpeg-lib-dir="$jpeg" cross_compiling=yes
  for codec in CCITT JPEG LOGLUV LZW MDI NEXT OJPEG PACKBITS PIXARLOG THUNDER ZIP; do
    grep -q "^#define ${codec}_SUPPORT 1" libtiff/tiffconf.h
  done
  make -j 4
  mkdir -p "build-$target/include"
  cp libtiff/.libs/libtiff.a "build-$target/"
  cp libtiff/tiff.h libtiff/tiffio.h libtiff/tiffvers.h libtiff/tiffio.hxx libtiff/tiffconf.h "build-$target/include/"
done
mkdir -p build-iphonesimulator/include
cp build-iphonesimulator-arm64/include/* build-iphonesimulator/include/
diff build-iphonesimulator-arm64/include/tiffconf.h build-iphonesimulator-x86_64/include/tiffconf.h
lipo -create build-iphonesimulator-arm64/libtiff.a build-iphonesimulator-x86_64/libtiff.a -output build-iphonesimulator/libtiff.a
popd

rm -rf libtiff.xcframework
xcodebuild -create-xcframework \
  -library tiff-4.7.0/build-iphoneos/libtiff.a -headers tiff-4.7.0/build-iphoneos/include \
  -library tiff-4.7.0/build-iphonesimulator/libtiff.a -headers tiff-4.7.0/build-iphonesimulator/include \
  -output libtiff.xcframework
