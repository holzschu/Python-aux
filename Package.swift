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
            checksum: "0044ad2af5269f35fcbd9bd1690ed98f32a8fb06ee6ab2b508d74da87e7bd32d"
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
            checksum: "4b79372492f21cb43e58c1c0b2624e846a81177b94ac0c12072bfce1c80ae3fa"
        ),
        .binaryTarget(
            name: "freetype",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/freetype.xcframework.zip",
            checksum: "640290f398b0414d7592ac34de06e8e01e4ae094bca10b0a3a8ef63cb8c7f8b6"
        ),
        .binaryTarget(
            name: "harfbuzz",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/harfbuzz.xcframework.zip",
            checksum: "3a5730868725dfbb77142e016291ff112878198a4a6171e70a005d594e55a3c4"
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
            checksum: "c6a7612437f3ab1450dfaa3b06af3db193d6d6cba95fe5130a792c44d21e21a4"
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
        )
    ]
)
/*
libpng
0044ad2af5269f35fcbd9bd1690ed98f32a8fb06ee6ab2b508d74da87e7bd32d
libffi
f3f39a73e7268e3a17e61db4d95c44cb9b08d8f1f95ec5ea9447ad6f3d058602
libzmq
d2882a48cab72e96883b8e3c09af7bc115d16cd2d5c97136880e950a69e760d5
openblas
4b79372492f21cb43e58c1c0b2624e846a81177b94ac0c12072bfce1c80ae3fa
freetype
640290f398b0414d7592ac34de06e8e01e4ae094bca10b0a3a8ef63cb8c7f8b6
harfbuzz
3a5730868725dfbb77142e016291ff112878198a4a6171e70a005d594e55a3c4
crypto
26682e31ab3bdad7bfb02236dafdd06409c3fd4fa9ef8ec2b404180d2c3c82c4
openssl
dda71e88ac9a1f02a44d5a7918ca5a14998653bed2d21a2a2874040861dc680c
libjpeg
aeaaf1e14a1c5ea9b312fe8ade12d8d9d80d23f0e329cb407c53c4e16511b8f5
libtiff
c6a7612437f3ab1450dfaa3b06af3db193d6d6cba95fe5130a792c44d21e21a4
libxslt
1c7e513edcc5c9a3a7dedfaaef966c851c7862cf854b3bd7185515412244d66d
libexslt
c4fc441665de546dde80d6e25b02d96f51a39c7ad4263376f6d37900cb947889
*/
