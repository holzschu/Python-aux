#!/bin/bash
set -euo pipefail

# Usage: bash build_openblas_flang.sh RUNTIME_BUILD_DIRECTORY BUILD_DIRECTORY
runtime_root=$(cd "${1:?Runtime build directory is required}" && pwd)
mkdir -p "${2:?Build directory is required}"
build_root=$(cd "$2" && pwd)
script_root=$(cd "$(dirname "$0")" && pwd)
flang=$(brew --prefix flang)/bin/flang
llvm_prefix=$(brew --prefix llvm)
source_root=$script_root/OpenBLAS
patch_file=$script_root/patches/flang/openblas-llvm-flang.patch
if ! git -C "$source_root" apply --reverse --check "$patch_file" 2>/dev/null; then
  git -C "$source_root" apply "$patch_file"
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
  blas_target=ARMV8
  processor=aarch64
  if [[ $arch == x86_64 ]]; then blas_target=CORE2; processor=x86_64; fi
  cmake -S "$source_root" -B "$build_root/$target" -G Ninja \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_SYSROOT="$sdk" \
    -DCMAKE_OSX_ARCHITECTURES="$arch" \
    -DCMAKE_SYSTEM_PROCESSOR="$processor" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 \
    -DCMAKE_C_COMPILER="$llvm_prefix/bin/clang" \
    -DCMAKE_Fortran_COMPILER="$flang" \
    -DCMAKE_Fortran_COMPILER_TARGET="$triple" \
    -DCMAKE_Fortran_FLAGS="--target=$triple" \
    -DCMAKE_Fortran_COMPILER_WORKS=YES \
    -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
    -DNOFORTRAN=OFF -UNO_LAPACK -DBUILD_WITHOUT_LAPACK=OFF -DNO_LAPACKE=ON \
    -DBUILD_SHARED_LIBS=OFF -DTARGET="$blas_target" -DUSE_THREAD=OFF
  cmake --build "$build_root/$target" --target openblas -j 4
  framework=$build_root/$target/openblas.framework
  mkdir -p "$framework/Headers"
  xcrun --sdk "$sdk" clang -target "$triple" -dynamiclib \
    -Wl,-force_load,"$build_root/$target/lib/libopenblas.a" \
    -F"$runtime_root/$target" -framework flang_rt \
    -install_name @rpath/openblas.framework/openblas \
    -o "$framework/openblas"
  cp "$build_root/$target/openblas_config.h" \
    "$build_root/$target/generated/cblas.h" \
    "$build_root/$target/generated/f77blas.h" "$framework/Headers/"
  if [[ $sdk == iphoneos ]]; then
    cp "$script_root/basic_Info.plist" "$framework/Info.plist"
  else
    cp "$script_root/basic_Info_Simulator.plist" "$framework/Info.plist"
  fi
  plutil -replace CFBundleExecutable -string openblas "$framework/Info.plist"
  plutil -replace CFBundleName -string openblas "$framework/Info.plist"
  plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.openblas "$framework/Info.plist"
  xcrun vtool -show-build "$framework/openblas"
  xcrun otool -L "$framework/openblas"
done

# Merge Simulator slices without replacing the per-architecture outputs.
simulator=$build_root/iphonesimulator-universal
rm -rf "$simulator/openblas.framework"
mkdir -p "$simulator"
cp -R "$build_root/iphonesimulator/openblas.framework" "$simulator/"
lipo -create "$build_root/iphonesimulator/openblas.framework/openblas" \
  "$build_root/iphonesimulator-x86_64/openblas.framework/openblas" \
  -output "$simulator/openblas.framework/openblas"
test "$(lipo -archs "$simulator/openblas.framework/openblas")" = 'x86_64 arm64'
headers=$simulator/openblas.framework/Headers
cp "$headers/openblas_config.h" "$headers/openblas_config-arm64.h"
cp "$build_root/iphonesimulator-x86_64/openblas.framework/Headers/openblas_config.h" "$headers/openblas_config-x86_64.h"
cat > "$headers/openblas_config.h" <<'HEADER'
#if defined(__arm64__)
#include "openblas_config-arm64.h"
#elif defined(__x86_64__)
#include "openblas_config-x86_64.h"
#else
#error Unsupported OpenBLAS Simulator architecture
#endif
HEADER
