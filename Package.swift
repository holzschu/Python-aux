// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Python-aux",
    products: [
        .library(name: "Python-aux", targets: ["libpng", "libffi", "libzmq", "openblas", "freetype", "harfbuzz", "crypto", "openssl", "libjpeg", "libtiff", "libxlst", "libexslt"])
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "libpng",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libpng.xcframework.zip",
            checksum: "e9717e039c6f80076ddc6bec3ab56fd4213c30c16058dcc9fe1da2f0f980e17e"
        ),
        .binaryTarget(
            name: "libffi",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libffi.xcframework.zip",
            checksum: "f3f39a73e7268e3a17e61db4d95c44cb9b08d8f1f95ec5ea9447ad6f3d058602"
        ),
        .binaryTarget(
            name: "libzmq",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libzmq.xcframework.zip",
            checksum: "d2882a48cab72e96883b8e3c09af7bc115d16cd2d5c97136880e950a69e760d5"
        ),
        .binaryTarget(
            name: "openblas",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/openblas.xcframework.zip",
            checksum: "13fd3c1b44ed1bf3db230adb8f8151ab17e77e9fb61df675074d7f16fec411c6"
        ),
        .binaryTarget(
            name: "freetype",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/freetype.xcframework.zip",
            checksum: "f547dd4944465e889e944cf809662af66109bc35fe09b88f231f0e2228e8aba4"
        ),
        .binaryTarget(
            name: "harfbuzz",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/harfbuzz.xcframework.zip",
            checksum: "d28dc80e57df750f1ae62f48785297c031874e33328888ccba96b1496b39a031"
        ),
        .binaryTarget(
            name: "crypto",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/crypto.xcframework.zip",
            checksum: "26682e31ab3bdad7bfb02236dafdd06409c3fd4fa9ef8ec2b404180d2c3c82c4"
        ),
        .binaryTarget(
            name: "openssl",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/openssl.xcframework.zip",
            checksum: "dda71e88ac9a1f02a44d5a7918ca5a14998653bed2d21a2a2874040861dc680c"
        ),
        .binaryTarget(
            name: "libjpeg",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libjpeg.xcframework.zip",
            checksum: "aeaaf1e14a1c5ea9b312fe8ade12d8d9d80d23f0e329cb407c53c4e16511b8f5"
        ),
        .binaryTarget(
            name: "libtiff",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libtiff.xcframework.zip",
            checksum: "0678de08083fd13256d4375f8c06e802e12dcabd5f41b80f64b84c065f86d2ad"
        ),
        .binaryTarget(
            name: "libxslt",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libxslt.xcframework.zip",
            checksum: "1c7e513edcc5c9a3a7dedfaaef966c851c7862cf854b3bd7185515412244d66d"
        ),
        .binaryTarget(
            name: "libexslt",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libexslt.xcframework.zip",
            checksum: "c4fc441665de546dde80d6e25b02d96f51a39c7ad4263376f6d37900cb947889"
        ),
        .binaryTarget(
            name: "libfftw3",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libfftw3.xcframework.zip",
            checksum: "d6ece560b5af600c01b520dac21d7b3f4667ecee44aab33a35f902c88b5fff7b"
        ),
        .binaryTarget(
            name: "libfftw3_threads",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libfftw3_threads.xcframework.zip",
            checksum: "5f78dcd006d0a0186a2a1db19915815cb8d16c9d142b10251a6099516395d1d3"
        )
    ]
)
/*
libpng
e9717e039c6f80076ddc6bec3ab56fd4213c30c16058dcc9fe1da2f0f980e17e
libffi
f3f39a73e7268e3a17e61db4d95c44cb9b08d8f1f95ec5ea9447ad6f3d058602
libzmq
d2882a48cab72e96883b8e3c09af7bc115d16cd2d5c97136880e950a69e760d5
openblas
13fd3c1b44ed1bf3db230adb8f8151ab17e77e9fb61df675074d7f16fec411c6
freetype
f547dd4944465e889e944cf809662af66109bc35fe09b88f231f0e2228e8aba4
harfbuzz
d28dc80e57df750f1ae62f48785297c031874e33328888ccba96b1496b39a031
crypto
26682e31ab3bdad7bfb02236dafdd06409c3fd4fa9ef8ec2b404180d2c3c82c4
openssl
dda71e88ac9a1f02a44d5a7918ca5a14998653bed2d21a2a2874040861dc680c
libjpeg
aeaaf1e14a1c5ea9b312fe8ade12d8d9d80d23f0e329cb407c53c4e16511b8f5
libtiff
bbda6117dec4495aeeb4f96c8a1cdb3fac7f0e79375dd7bce5117108d694110e
libxslt
1c7e513edcc5c9a3a7dedfaaef966c851c7862cf854b3bd7185515412244d66d
libexslt
c4fc441665de546dde80d6e25b02d96f51a39c7ad4263376f6d37900cb947889
libfftw3
d6ece560b5af600c01b520dac21d7b3f4667ecee44aab33a35f902c88b5fff7b
libfftw3_threads
5f78dcd006d0a0186a2a1db19915815cb8d16c9d142b10251a6099516395d1d3
*/
