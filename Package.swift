// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Python-aux",
    products: [
        .library(name: "Python-aux", targets: ["libpng", "libffi", "libzmq", "openblas", "freetype", "harfbuzz", "crypto", "openssl", "libjpeg", "libtiff"])
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "libpng",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libpng.xcframework.zip",
            checksum: "f18d6bf17ccd5408a80fc79f0d50a5438853883e672d85503d936100639e23bd"
        ),
        .binaryTarget(
            name: "libffi",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libffi.xcframework.zip",
            checksum: "dd038a7da4249750bde7dcb223502a7e39474c4cc743ecb928964f7b995b2164"
        ),
        .binaryTarget(
            name: "libzmq",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libzmq.xcframework.zip",
            checksum: "fff8b579109df6c821e7d62e38f137d65fb9b51e5a310fecd01cd94574c66013"
        ),
        .binaryTarget(
            name: "openblas",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/openblas.xcframework.zip",
            checksum: "e7e433b23388923f03ba6ba8543617c1d8f15b2576e5090783beccd77bcf23cf"
        ),
        .binaryTarget(
            name: "freetype",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/freetype.xcframework.zip",
            checksum: "4f0cd2a6c4e336e3db1c899600165d4e6ba5c7be1fc09d03bc23be18bfac7959"
        ),
        .binaryTarget(
            name: "harfbuzz",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/harfbuzz.xcframework.zip",
            checksum: "e20e7ad3814bf2996e196fc296fc364d70ef496dbc7810e5b2e65c2d77010e25"
        ),
        .binaryTarget(
            name: "crypto",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/crypto.xcframework.zip",
            checksum: "d4003706407aefabfa28861f18de2ecc830a588891bf640083a528ad719fbccd"
        ),
        .binaryTarget(
            name: "openssl",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/openssl.xcframework.zip",
            checksum: "60b0800525210424d923ce3adb86132ee04f339b700ed36c5ade4ce73f0f352c"
        )
        .binaryTarget(
            name: "libjpeg",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libjpeg.xcframework.zip",
            checksum: "e46377519bd452f76ee9b0a6bec3a1864164a62f564ffbf5a1664d9b47c59961"
        )
        .binaryTarget(
            name: "libtiff",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libtiff.xcframework.zip",
            checksum: "de376bdc679f4725df5147bf0291458d1fc4e26d4b4e4e953be1daaaef2cf128"
        )
    ]
)
/*
libpng
f18d6bf17ccd5408a80fc79f0d50a5438853883e672d85503d936100639e23bd
libffi
dd038a7da4249750bde7dcb223502a7e39474c4cc743ecb928964f7b995b2164
libzmq
fff8b579109df6c821e7d62e38f137d65fb9b51e5a310fecd01cd94574c66013
openblas
e7e433b23388923f03ba6ba8543617c1d8f15b2576e5090783beccd77bcf23cf
freetype
4f0cd2a6c4e336e3db1c899600165d4e6ba5c7be1fc09d03bc23be18bfac7959
harfbuzz
e20e7ad3814bf2996e196fc296fc364d70ef496dbc7810e5b2e65c2d77010e25
crypto
d4003706407aefabfa28861f18de2ecc830a588891bf640083a528ad719fbccd
openssl
60b0800525210424d923ce3adb86132ee04f339b700ed36c5ade4ce73f0f352c
libjpeg
e46377519bd452f76ee9b0a6bec3a1864164a62f564ffbf5a1664d9b47c59961
libtiff
de376bdc679f4725df5147bf0291458d1fc4e26d4b4e4e953be1daaaef2cf128

*/
