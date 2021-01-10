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
            checksum: "79eaa6aef840439bc276e19be6ffe2595b70e8e83f83a9dafc7517d59d6b4898"
        ),
        .binaryTarget(
            name: "libffi",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libffi.xcframework.zip",
            checksum: "429646b10fb9f8e6f821759a8d3535750cf89eb1363369010331da63667e2c5d"
        ),
        .binaryTarget(
            name: "libzmq",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libzmq.xcframework.zip",
            checksum: "3f18b13b060a45194940dda748c3eb9e5dab57f929555c948fa2181022c2a7ae"
        ),
        .binaryTarget(
            name: "openblas",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/openblas.xcframework.zip",
            checksum: "f498a5696768e3ca2a978eb881d7012c54dc888ba40cae6505e2dd22cd10fb84"
        ),
        .binaryTarget(
            name: "freetype",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/freetype.xcframework.zip",
            checksum: "14903ffb1fd1c66e6fc603e9ac963b2d08fb774db5999a758bad6b133e66d6e1"
        ),
        .binaryTarget(
            name: "harfbuzz",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/harfbuzz.xcframework.zip",
            checksum: "59ff0a796327cfca64ae76ba6688d18928c8bd5746456d7e417be5ef2433f11b"
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
            checksum: "6c7c73b1c64e9e2d7e968676afff141a5ae93dec8ba9e4e90294a7020a53de71"
        ),
        .binaryTarget(
            name: "libtiff",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libtiff.xcframework.zip",
            checksum: "923e06e9f3043460679e1eb5d24b33afbedfff1b860b9754616ef19a1c79b768"
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
79eaa6aef840439bc276e19be6ffe2595b70e8e83f83a9dafc7517d59d6b4898
libffi
429646b10fb9f8e6f821759a8d3535750cf89eb1363369010331da63667e2c5d
libzmq
3f18b13b060a45194940dda748c3eb9e5dab57f929555c948fa2181022c2a7ae
openblas
f498a5696768e3ca2a978eb881d7012c54dc888ba40cae6505e2dd22cd10fb84
freetype
14903ffb1fd1c66e6fc603e9ac963b2d08fb774db5999a758bad6b133e66d6e1
harfbuzz
59ff0a796327cfca64ae76ba6688d18928c8bd5746456d7e417be5ef2433f11b
crypto
d4003706407aefabfa28861f18de2ecc830a588891bf640083a528ad719fbccd
openssl
60b0800525210424d923ce3adb86132ee04f339b700ed36c5ade4ce73f0f352c
libjpeg
6c7c73b1c64e9e2d7e968676afff141a5ae93dec8ba9e4e90294a7020a53de71
libtiff
923e06e9f3043460679e1eb5d24b33afbedfff1b860b9754616ef19a1c79b768
libxslt
b389d2d21210ae48aafe598a20d550989746332be77fad67b6c6247668da35ce
libexslt
b0f427c42922e4a8caeaf5b8c7fa1208622140023f22d1aaaffc996c013f6e09
*/
