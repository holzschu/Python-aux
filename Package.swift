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
            checksum: "df9d3a7c089c4f31fb2b2b2f90e4dd36e398e363355076487c885347d3aae81a"
        ),
        .binaryTarget(
            name: "libffi",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libffi.xcframework.zip",
            checksum: "e039089e4ccbeaff15563f0f4c07805378ce56dd505b4ff413c9034bcb77133d"
        ),
        .binaryTarget(
            name: "libzmq",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libzmq.xcframework.zip",
            checksum: "27e23b418ec7ddfce1168cd245e3969e4320f05473441a99a1a2a4f7d16abe64"
        ),
        .binaryTarget(
            name: "openblas",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/openblas.xcframework.zip",
            checksum: "710471628739252df73dc4e33d536ef79e82401cb2ae43c4a047c361d89524ea"
        ),
        .binaryTarget(
            name: "freetype",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/freetype.xcframework.zip",
            checksum: "fcbad9bbd74d8aa54ae406786a0f3ba9c4e10268e4f585a70f732eaae87d25fb"
        ),
        .binaryTarget(
            name: "harfbuzz",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/harfbuzz.xcframework.zip",
            checksum: "a304ff6e9fc7b1597533fb9216e970ea01315da51dbbfdeb74748c4f465dd90d"
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
        ),
        .binaryTarget(
            name: "libjpeg",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libjpeg.xcframework.zip",
            checksum: "d9ed6a75628ef7f06b14d69bea000ded4b975a2abf52b4232f32dc899af14f2b"
        ),
        .binaryTarget(
            name: "libtiff",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libtiff.xcframework.zip",
            checksum: "de376bdc679f4725df5147bf0291458d1fc4e26d4b4e4e953be1daaaef2cf128"
        ),
        .binaryTarget(
            name: "libxslt",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libxslt.xcframework.zip",
            checksum: "b389d2d21210ae48aafe598a20d550989746332be77fad67b6c6247668da35ce"
        ),
        .binaryTarget(
            name: "libexslt",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libexslt.xcframework.zip",
            checksum: "b0f427c42922e4a8caeaf5b8c7fa1208622140023f22d1aaaffc996c013f6e09"
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
libxslt
48435e3174fff3fd0c26cf9350c6b6c51b7f351bc4af51568b75f8a19bda86c9
libexslt
2570d04ad57d0732455b26ae43c63945e80bf96ccd99c0ea07165978285fd9a9
*/
