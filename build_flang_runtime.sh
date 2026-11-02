#!/bin/bash
set -euo pipefail

# Usage: bash build_flang_runtime.sh LLVM_SOURCE BUILD_DIRECTORY
# Requires Homebrew flang and llvm, cmake and ninja, plus Xcode.
# LLVM_SOURCE must contain flang-rt, flang, libc, runtimes, cmake and llvm.
llvm_source=$(cd "${1:?LLVM source directory is required}" && pwd)
mkdir -p "${2:?Build directory is required}"
build_root=$(cd "$2" && pwd)
script_root=$(cd "$(dirname "$0")" && pwd)
llvm_prefix=$(brew --prefix llvm)
flang=$(brew --prefix flang)/bin/flang
flang_version=$("$flang" --version | awk 'NR == 1 {for (i = 1; i < NF; i++) if ($i == "version") {print $(i+1); exit}}')
[[ $flang_version =~ ^[0-9]+[.][0-9]+[.][0-9]+$ ]] || exit 1
[[ $(git -C "$llvm_source" describe --exact-match --tags) == "llvmorg-$flang_version" ]] || {
  echo "LLVM source must match the installed Flang release: llvmorg-$flang_version" >&2
  exit 1
}
patch_file=$script_root/patches/flang/ios-runtime.patch
if ! git -C "$llvm_source" apply --reverse --check "$patch_file" 2>/dev/null; then
  git -C "$llvm_source" apply "$patch_file"
fi

for target in iphoneos iphonesimulator iphonesimulator-x86_64; do
  sdk=${target%%-*}
  arch=arm64
  triple=arm64-apple-ios14.0
  if [[ $sdk == iphonesimulator ]]; then
    triple=$triple-simulator
  fi
  if [[ $target == iphonesimulator-x86_64 ]]; then
    arch=x86_64
    triple=x86_64-apple-ios14.0-simulator
  fi
  cmake -S "$llvm_source/runtimes" -B "$build_root/$target" -G Ninja \
    -DLLVM_ENABLE_RUNTIMES=flang-rt \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_SYSROOT="$sdk" \
    -DCMAKE_OSX_ARCHITECTURES="$arch" \
    -DCMAKE_SYSTEM_PROCESSOR="$arch" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 \
    -DCMAKE_C_COMPILER="$llvm_prefix/bin/clang" \
    -DCMAKE_CXX_COMPILER="$(xcrun --sdk "$sdk" -f clang++)" \
    -DCMAKE_Fortran_COMPILER="$flang" \
    -DCMAKE_Fortran_COMPILER_TARGET="$triple" \
    -DCMAKE_Fortran_COMPILER_WORKS=YES \
    -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
    -DLLVM_DEFAULT_TARGET_TRIPLE="$triple" \
    -DFLANG_RT_INCLUDE_TESTS=OFF \
    -DFLANG_RT_FORTRAN_MODULES=OFF
  cmake --build "$build_root/$target" -j 4
  mkdir -p "$build_root/lib/$target"
  cp "$build_root/$target/lib/clang/${flang_version%%.*}/lib/ios/libflang_rt.runtime.a" "$build_root/lib/$target/"
  framework=$build_root/$target/flang_rt.framework
  mkdir -p "$framework"
  xcrun --sdk "$sdk" clang++ -target "$triple" -dynamiclib \
    -Wl,-force_load,"$build_root/lib/$target/libflang_rt.runtime.a" \
    -install_name @rpath/flang_rt.framework/flang_rt -o "$framework/flang_rt"
  if [[ $sdk == iphoneos ]]; then
    cp "$script_root/basic_Info.plist" "$framework/Info.plist"
  else
    cp "$script_root/basic_Info_Simulator.plist" "$framework/Info.plist"
  fi
  plutil -replace CFBundleExecutable -string flang_rt "$framework/Info.plist"
  plutil -replace CFBundleName -string flang_rt "$framework/Info.plist"
  plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.flang-rt "$framework/Info.plist"
  xcrun vtool -show-build "$framework/flang_rt"
  xcrun otool -L "$framework/flang_rt"
done

# Merge Simulator slices separately; OpenBLAS links against the thin runtimes.
simulator=$build_root/iphonesimulator-universal
rm -rf "$simulator/flang_rt.framework"
mkdir -p "$simulator"
cp -R "$build_root/iphonesimulator/flang_rt.framework" "$simulator/"
lipo -create "$build_root/iphonesimulator/flang_rt.framework/flang_rt" \
  "$build_root/iphonesimulator-x86_64/flang_rt.framework/flang_rt" \
  -output "$simulator/flang_rt.framework/flang_rt"
test "$(lipo -archs "$simulator/flang_rt.framework/flang_rt")" = 'x86_64 arm64'
