#!/bin/bash
set -euo pipefail

curl --fail --location --retry 3 --retry-all-errors -O https://ijg.org/files/jpegsrc.v9d.tar.gz
echo '2303a6acfb6cc533e0e86e8a9d29f7e6079e118b9de3f96e07a71a11c082fa6a  jpegsrc.v9d.tar.gz' | shasum -a 256 -c -
tar xzf jpegsrc.v9d.tar.gz
rm jpegsrc.v9d.tar.gz

pushd jpeg-9d
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
  ./configure CC=clang CXX=clang++ \
    CFLAGS="-target $triple -isysroot $sdkroot -O2" \
    CPPFLAGS="-target $triple -isysroot $sdkroot" \
    LDFLAGS="-target $triple -isysroot $sdkroot" \
    --build="$(sh ./config.guess)" --host="$host" --disable-shared cross_compiling=yes
  make -j 4
  mkdir -p "build-$target/include"
  cp .libs/libjpeg.a "build-$target/"
  cp j*.h "build-$target/include/"
done
mkdir -p build-iphonesimulator/include
cp build-iphonesimulator-arm64/include/*.h build-iphonesimulator/include/
diff build-iphonesimulator-arm64/include/jconfig.h build-iphonesimulator-x86_64/include/jconfig.h
lipo -create build-iphonesimulator-arm64/libjpeg.a build-iphonesimulator-x86_64/libjpeg.a -output build-iphonesimulator/libjpeg.a
popd

rm -rf libjpeg.xcframework
xcodebuild -create-xcframework \
  -library jpeg-9d/build-iphoneos/libjpeg.a -headers jpeg-9d/build-iphoneos/include \
  -library jpeg-9d/build-iphonesimulator/libjpeg.a -headers jpeg-9d/build-iphonesimulator/include \
  -output libjpeg.xcframework
