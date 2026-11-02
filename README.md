# Python-aux

Auxiliary libraries needed for Python3 compilation, precompiled (libpng, harfbuzz, freetype...). They can be useful for many other OpenSource projects on iOS, too.

What we have:
- [libpng](http://www.libpng.org/pub/png/libpng.html) (1.6.37)
- [libffi](https://github.com/libffi/libffi) (main branch)
- [libzmq](https://github.com/zeromq/libzmq) (zeroMQ) (main branch)
- [OpenBLAS](https://github.com/xianyi/OpenBLAS) (develop branch)
- [freetype](https://www.freetype.org) (2.10.2)
- [harfbuzz](https://github.com/harfbuzz/harfbuzz) (main branch)

## How to use: 

In your Xcode project, use the menu File -> "Swift Packages" -> "Add Package Dependency". In the window that opens, enter the address for this repository (https://github.com/holzschu/Python-aux.git). 

In the rightmost column, you will see "Swift Package Dependencies", and under it "Python-aux". Under "Referenced Binaries", you have all the libraries, precompiled, as "xcframework". You can link with them, embed them, and Xcode will extract the iOS or Simulator version as needed.

## How to compile: 

In this repository, run `build_all_packages.sh`. This will update the code, compile the packages, create the frameworks, create and compress the xcframeworks and output the hash sums.

For use in your own repository, update the hash sums in `Package.swift`, publish the xcframeworks.zip in the right place and enjoy.

## Work in progress: 

- libheif: needs libpng (OK), libde265 and libx265 (WIP): https://github.com/strukturag/libde265

## Releasing xcframeworks

CI builds libpng, FreeType, HarfBuzz, JPEG and TIFF on pull requests (except Markdown-only changes) and manual runs. Each xcframework contains arm64 device and universal arm64/x86_64 Simulator slices. JPEG and TIFF remain static libraries. It uploads the ZIPs, `checksums.txt` and `release.md` in the `xcframeworks` artifact. The build summary lists each slice and its architectures.

Run `bash build_libjpg.sh` before `bash build_libtiff.sh`. TIFF retains its built-in codecs and Deflate, and enables JPEG and old JPEG using the companion library. CI links the codec consumer for both Simulator architectures and runs it on arm64. Device and Intel Simulator libraries retain iOS 11; arm64 Simulator requires iOS 14.

To release from this repository, push a `v*` tag, then wait for the "Publishing release" job. It creates a release with the generated notes, or adds the assets to an existing release while keeping its notes. Uploads fail if an asset already exists; published files are never overwritten. Only the release job has write permission.

Update each consuming `binaryTarget` URL and checksum with the new release and the values in `checksums.txt`.

## OpenBLAS with Fortran LAPACK

The Fortran CI job builds arm64 device and universal arm64/x86_64 Simulator frameworks with Homebrew Flang and the LLVM runtime sources from the same release. It compiles LAPACK's `dpotrf.f` for each platform, links OpenBLAS against a shared `flang_rt.framework`, and runs Cholesky, linear-system and Fortran `dsyev` eigenvalue checks on the arm64 Simulator. The x86_64 Simulator consumer is compiled and linked only. The `openblas` artifact contains `openblas.xcframework.zip`, `flang_rt.xcframework.zip` and their SwiftPM checksums; tag releases include them alongside the other libraries. Embed both frameworks in consuming apps; both require iOS 14.

Run `nice -n 15 bash build_flang_runtime.sh <llvm-source> <runtime-build>`, then `nice -n 15 bash build_openblas_flang.sh <runtime-build> <openblas-build>`. The workflow checks out the LLVM release matching the installed Flang compiler; the runtime uses Xcode's C++ compiler and SDK headers. Both scripts use four build jobs. The x86_64 Simulator uses this revision's CORE2 cross-build configuration. The runtime patch makes command-line execution report unsupported on iOS and rejects executable trampolines there. LAPACK uses neither facility.

This build includes the Fortran BLAS and LAPACK APIs and CBLAS. LAPACKE is disabled (`NO_LAPACKE=ON`). NumPy and SciPy use the Fortran LAPACK API.

## NumPy and SciPy

The science CI job runs the pinned `demrom/cpython` package recipes after the Fortran job. It builds Python 3.13 from source, then NumPy 2.3.1 and SciPy 1.16.1 for arm64 device and both Simulator architectures using the matching Flang runtime. It preserves a-Shell's eight scientific framework products and `.fwork` module aliases. The `science` artifact contains their ZIPs, the pure Python packages in `python-science.tar.gz`, and `science-checksums.txt`.

The Simulator consumer checks linear solves, eigenvalues, Cholesky, SVD, special functions, quadrature, interpolation and PROPACK with real and complex single/double precision. CI executes the packaged arm64 slices, audits the x86_64 slices statically and links an x86_64 Python launcher. These checks run on two sequential command threads in one process through `Py_BytesMain` to exercise interpreter re-entry; CI requires a final marker from the C launcher. App launch checks remain separate.

## GIS frameworks

Run `nice -n 15 bash build_gis.sh` after initializing the `GDAL`, `geos` and `libspatialindex` submodules. CMake and Ninja build `libgdal`, `libgeos`, `libgeos_c`, `libproj`, `libspatialindex` and `libspatialindex_c` for arm64 device and universal arm64/x86_64 Simulator, all targeting iOS 14. The recipe also packages PROJ's platform-independent runtime data, including `proj.db`, in `proj-data.tar.gz`. Extract it into the app's resources so the data lives in `proj/`, then set `PROJ_DATA` to that directory before creating a PROJ context or pass it to `proj_context_set_search_paths`. The `gis` CI job links public C API consumers for both Simulator architectures, runs geometry, projection, encoding, raster and spatial-index checks on arm64, and uploads the six ZIPs and data archive with `gis-checksums.txt`. Its EPSG coordinate conversion uses the extracted archive. Tag releases include these files through the existing release job.

The source pins follow the published GIS assets: GDAL uses their embedded base revision `8ad5a79a33db18ef0f32c4b0435f7c59bcfda80b` (3.6.0 development), PROJ uses the checksummed official 9.1.0 archive, and libspatialindex retains 1.9.3. GEOS uses stable 3.11.0 in place of the published 3.11.0 beta3 build. The published GDAL version also reports unrecorded local changes; these recipes do not reproduce those unknown patches. The explicit GDAL patch corrects classic Mac conditions in zlib and PNG on iOS and retains GPX/SVG registration without Expat, matching the published binary. `build_gis.sh` selects the SDK's declared `stat` type with `HAVE_STAT64=OFF`; SQLite extension loading remains disabled as in that binary. The compatibility options retain exported internal symbols and the published driver-registration set, enable SDK iconv, and retain the legacy recipe's `--with-threads=no` behavior. GDAL therefore uses its stub multiprocessing layer. `build_gdal.sh` and `build_gdal_fw.sh` rebuild and package GDAL through the same CMake recipe after its dependencies have been built with `build_gis.sh`. These recipes produce iOS and Simulator slices; the published macOS slice is not rebuilt. Framework bundle identifiers replace underscores with hyphens. Rebuilt archives require new checksums and consumer validation before replacing published assets.
