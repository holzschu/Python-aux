#!/bin/bash
set -euo pipefail

# Build the six GIS frameworks from pinned sources for device and both Simulators.
root=$(cd "$(dirname "$0")" && pwd)
build=$root/.build/gis
minos=${IPHONEOS_DEPLOYMENT_TARGET:-14.0}
component=${1:-all}
case "$component" in all|geos|proj|spatialindex|gdal) ;; *) echo "Unknown GIS component: $component" >&2; exit 1 ;; esac
mkdir -p "$build"

if [[ $component == all || $component == gdal ]]; then
  # TARGET_OS_MAC also names iOS; classic Mac codec branches require obsolete APIs.
  patch=$root/patches/gdal-darwin-codecs.patch
  if ! git -C "$root/GDAL" apply --reverse --check "$patch" 2>/dev/null; then
    git -C "$root/GDAL" apply --check "$patch"
    git -C "$root/GDAL" apply "$patch"
  fi
fi

if [[ $component == all || $component == proj || $component == gdal ]]; then
  archive=$build/proj-9.1.0.tar.gz
  if [[ ! -f $archive ]]; then
    curl -fL --retry 3 https://download.osgeo.org/proj/proj-9.1.0.tar.gz -o "$archive.part"
    mv "$archive.part" "$archive"
  fi
  echo "81b2239b94cad0886222cde4f53cb49d34905aad2a1317244a0c30a553db2315  $archive" | shasum -a 256 -c -
  if [[ ! -d $build/proj-9.1.0 ]]; then tar xzf "$archive" -C "$build"; fi
fi

configure_build() {
  local name=$1 source=$2
  shift 2
  cmake -S "$source" -B "$build/$target/$name" -G Ninja \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_SYSROOT="$sdkroot" -DCMAKE_OSX_ARCHITECTURES="$arch" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="$minos" -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$prefix" -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_FIND_ROOT_PATH="$sdkroot;$prefix" \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
    -DCMAKE_INSTALL_NAME_DIR=@rpath -DCMAKE_MACOSX_RPATH=ON \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_INSTALL_RPATH=@loader_path \
    -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=OFF "$@"
  cmake --build "$build/$target/$name" --parallel 4
  cmake --install "$build/$target/$name"
}

for target in iphoneos iphonesimulator-arm64 iphonesimulator-x86_64; do
  sdk=iphonesimulator
  arch=arm64
  if [[ $target == iphoneos ]]; then sdk=iphoneos; fi
  if [[ $target == iphonesimulator-x86_64 ]]; then arch=x86_64; fi
  sdkroot=$(xcrun --sdk "$sdk" --show-sdk-path)
  prefix=$build/$target/install
  export PKG_CONFIG_LIBDIR=$prefix/lib/pkgconfig
  export PKG_CONFIG_PATH=
  if [[ $component == all || $component == geos ]]; then
    configure_build geos "$root/geos" -DBUILD_BENCHMARKS=OFF -DBUILD_GEOSOP=OFF -DGEOS_BUILD_DEVELOPER=OFF
  fi
  if [[ $component == all || $component == proj ]]; then
    configure_build proj "$build/proj-9.1.0" -DBUILD_APPS=OFF \
      -DENABLE_CURL=OFF -DENABLE_TIFF=OFF -DEXE_SQLITE3=/usr/bin/sqlite3 \
      -DSQLITE3_INCLUDE_DIR="$sdkroot/usr/include" -DSQLITE3_LIBRARY="$sdkroot/usr/lib/libsqlite3.tbd"
  fi
  if [[ $component == all || $component == spatialindex ]]; then
    configure_build spatialindex "$root/libspatialindex"
  fi
  if [[ $component == all || $component == gdal ]]; then
    # Preserve the legacy recipe's internal codecs and explicit GEOS/SQLite support.
    # The iOS SDK exports stat64 but does not declare struct stat64; use stat.
    # iconv.h declares char **; the -Werror probe fails on SDK deployment warnings.
    configure_build gdal "$root/GDAL" -DBUILD_APPS=OFF -DBUILD_PYTHON_BINDINGS=OFF \
      -DHAVE_STAT64=OFF \
      -DBUILD_JAVA_BINDINGS=OFF -DBUILD_CSHARP_BINDINGS=OFF \
      -DOGR_SQLITE_ALLOW_LOAD_EXTENSIONS=OFF \
      -DGDAL_HIDE_INTERNAL_SYMBOLS=OFF \
      -DGDAL_USE_CPL_MULTIPROC_PTHREAD=OFF -DGDAL_USE_ICONV=ON \
      -D_ICONV_SECOND_ARGUMENT_IS_NOT_CONST=ON \
      -DRENAME_INTERNAL_ZLIB_SYMBOLS=OFF -DRENAME_INTERNAL_GIF_SYMBOLS=OFF \
      -DGDAL_ENABLE_DRIVER_DAAS=OFF -DGDAL_ENABLE_DRIVER_OGCAPI=OFF \
      -DGDAL_ENABLE_DRIVER_WMTS=OFF -DOGR_ENABLE_DRIVER_CARTO=OFF \
      -DGDAL_USE_EXTERNAL_LIBS=OFF -DGDAL_USE_INTERNAL_LIBS=ON \
      -DGDAL_USE_GEOS=ON -DGDAL_USE_SQLITE3=ON \
      -DPROJ_DIR="$prefix/lib/cmake/proj" -DGEOS_DIR="$prefix/lib/cmake/GEOS" \
      -DSQLite3_INCLUDE_DIR="$sdkroot/usr/include" -DSQLite3_LIBRARY="$sdkroot/usr/lib/libsqlite3.tbd"
  fi
done

case "$component" in
  all) products='libgeos libgeos_c libproj libspatialindex libspatialindex_c libgdal' ;;
  geos) products='libgeos libgeos_c' ;;
  proj) products=libproj ;;
  spatialindex) products='libspatialindex libspatialindex_c' ;;
  gdal) products=libgdal ;;
esac

for name in $products; do
  case "$name" in
    libgeos|libgeos_c) headers=geos ;;
    libproj) headers=proj ;;
    libspatialindex|libspatialindex_c) headers=spatialindex ;;
    libgdal) headers=gdal ;;
  esac
  for target in iphoneos iphonesimulator-arm64 iphonesimulator-x86_64; do
    prefix=$build/$target/install
    framework=$build/$target/$name.framework
    rm -rf "$framework"
    mkdir -p "$framework/Headers"
    while IFS= read -r header || [[ -n $header ]]; do
      case "$header" in
        "$prefix/include/"*)
          relative=${header#"$prefix/include/"}
          if [[ $headers == gdal ]]; then relative=${relative#gdal/}; fi
          mkdir -p "$(dirname "$framework/Headers/$relative")"
          cp -L "$header" "$framework/Headers/$relative"
          ;;
      esac
    done < "$build/$target/$headers/install_manifest.txt"
    cp -L "$prefix/lib/$name.dylib" "$framework/$name"
    plist=basic_Info.plist
    if [[ $target == iphonesimulator-* ]]; then plist=basic_Info_Simulator.plist; fi
    cp "$root/$plist" "$framework/Info.plist"
    plutil -replace CFBundleExecutable -string "$name" "$framework/Info.plist"
    plutil -replace CFBundleName -string "$name" "$framework/Info.plist"
    plutil -replace CFBundleIdentifier -string "Nicolas-Holzschuch.${name//_/-}" "$framework/Info.plist"
    plutil -replace MinimumOSVersion -string "$minos" "$framework/Info.plist"
    install_name_tool -id "@rpath/$name.framework/$name" "$framework/$name"
    install_name_tool -rpath @loader_path @loader_path/.. "$framework/$name"
    # Convert only this graph's dylib dependencies; never hide host-library leakage.
    while IFS= read -r dependency; do
      base=$(basename "$dependency")
      for linked in libgeos_c libgeos libproj libspatialindex_c libspatialindex libgdal; do
        case "$base" in
          "$linked.dylib"|"$linked."*.dylib)
            install_name_tool -change "$dependency" "@rpath/$linked.framework/$linked" "$framework/$name"
            break
            ;;
        esac
      done
    done < <(otool -L "$framework/$name" | awk 'NR > 1 {print $1}')
    if otool -L "$framework/$name" | grep $'\t' | grep -E '/opt/homebrew|/usr/local|/Users/|/private/|/tmp/'; then
      echo "Nonportable dependency in $name/$target" >&2
      exit 1
    fi
  done
  simulator=$build/iphonesimulator-universal/$name.framework
  mkdir -p "$(dirname "$simulator")"
  rm -rf "$simulator"
  cp -R "$build/iphonesimulator-arm64/$name.framework" "$simulator"
  lipo -create "$build/iphonesimulator-arm64/$name.framework/$name" \
    "$build/iphonesimulator-x86_64/$name.framework/$name" -output "$simulator/$name"
  rm -rf "$root/$name.xcframework"
  xcodebuild -create-xcframework -framework "$build/iphoneos/$name.framework" \
    -framework "$simulator" -output "$root/$name.xcframework"
done

if [[ $component == all || $component == proj ]]; then
  # PROJ's database and init files are platform-independent runtime resources.
  data=$build/iphoneos/install/share/proj
  test -s "$data/proj.db"
  test "$(/usr/bin/sqlite3 "$data/proj.db" 'PRAGMA quick_check;')" = ok
  COPYFILE_DISABLE=1 tar --no-mac-metadata --no-xattrs \
    --uid 0 --gid 0 --uname root --gname wheel \
    -czf "$root/proj-data.tar.gz" -C "$(dirname "$data")" proj
fi
