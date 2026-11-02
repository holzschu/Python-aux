#!/bin/bash
set -euo pipefail

SOURCE_DIR=$PWD/libxslt
BUILD_DIR=$PWD/.build/libxslt
patch=$PWD/patches/libxslt-apple-xpath-limits.patch
if git -C "$SOURCE_DIR" apply --check "$patch"; then
  git -C "$SOURCE_DIR" apply "$patch"
else
  git -C "$SOURCE_DIR" apply --reverse --check "$patch"
fi

for target in iphoneos iphonesimulator-arm64 iphonesimulator-x86_64; do
  sdk=iphonesimulator
  arch=arm64
  minos=14.0
  if [[ $target == iphoneos ]]; then
    sdk=iphoneos
    minos=11.0
  elif [[ $target == iphonesimulator-x86_64 ]]; then
    arch=x86_64
    minos=11.0
  fi
  sdkroot=$(xcrun --sdk "$sdk" --show-sdk-path)
  cmake -S "$SOURCE_DIR" -B "$BUILD_DIR/$target" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_SYSROOT="$sdk" -DCMAKE_OSX_ARCHITECTURES="$arch" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="$minos" -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_MACOSX_BUNDLE=OFF -DBUILD_SHARED_LIBS=OFF -DLIBXSLT_WITH_PYTHON=OFF \
    -DLIBXML2_INCLUDE_DIR="$sdkroot/usr/include/libxml2" \
    -DLIBXML2_LIBRARY="$sdkroot/usr/lib/libxml2.tbd"
  cmake --build "$BUILD_DIR/$target" --target LibXslt LibExslt --parallel 4
  for name in libxslt libexslt; do
    mkdir -p "$BUILD_DIR/$target/$name/include/$name"
    cp "$SOURCE_DIR/$name/"*.h "$BUILD_DIR/$target/$name/include/$name/"
    cp "$BUILD_DIR/$target/$name/"*.h "$BUILD_DIR/$target/$name/include/$name/"
  done
done

for name in libxslt libexslt; do
  diff -r "$BUILD_DIR/iphonesimulator-arm64/$name/include" "$BUILD_DIR/iphonesimulator-x86_64/$name/include"
  mkdir -p "$BUILD_DIR/iphonesimulator"
  lipo -create "$BUILD_DIR/iphonesimulator-arm64/$name.a" "$BUILD_DIR/iphonesimulator-x86_64/$name.a" -output "$BUILD_DIR/iphonesimulator/$name.a"
  rm -rf "$name.xcframework"
  xcodebuild -create-xcframework \
    -library "$BUILD_DIR/iphoneos/$name.a" -headers "$BUILD_DIR/iphoneos/$name/include" \
    -library "$BUILD_DIR/iphonesimulator/$name.a" -headers "$BUILD_DIR/iphonesimulator-arm64/$name/include" \
    -output "$name.xcframework"
done
