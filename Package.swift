// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Python-aux",
    products: [
        .library(name: "Python-aux", targets: ["libpng", "libffi", "libzmq", "openblas", "freetype", "harfbuzz", "crypto", "openssl"])
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "libpng",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libpng.xcframework.zip",
            checksum: "676f8de88c5e2db7195d792ab5a3c028353453a367ebf446bf3dbf1cc0f7619a"
        ),
        .binaryTarget(
            name: "libffi",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libffi.xcframework.zip",
            checksum: "b87aab474a60a6906194e2c4325eb7e75f6b98fc405cc6f2a93b2aa0d8be9b7e"
        ),
        .binaryTarget(
            name: "libzmq",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libzmq.xcframework.zip",
            checksum: "f39faf8387951e77cf4c4a7e430a479055e6cf88638777e968679f996829b0f4"
        ),
        .binaryTarget(
            name: "openblas",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/openblas.xcframework.zip",
            checksum: "29d2e5a60901bc0461213ac6db595691094e2c79418ac6927d24b0fb15b0d7c6"
        ),
        .binaryTarget(
            name: "freetype",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/freetype.xcframework.zip",
            checksum: "58e3ce5d2c81f799bee4e20b6da883adc394f31318e7975e30b7d5b22fe2be28"
        ),
        .binaryTarget(
            name: "harfbuzz",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/harfbuzz.xcframework.zip",
            checksum: "c580567dbc47433f1aae312a62bdaaf97894cf9a70ce75e1d3ac31b5c2a2cd18"
        ),
        .binaryTarget(
            name: "crypto",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/crypto.xcframework.zip",
            checksum: "5caf39e44187d99cd9c89a4fb7a0b63439e29fc67437fe793e5b4d620c730bb9"
        ),
        .binaryTarget(
            name: "openssl",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/openssl.xcframework.zip",
            checksum: "3fcca6d84391c7bc927d3e606735560ce55b07710ce100f2bbdab166a7370473"
        )
    ]
)
/*
libpng
676f8de88c5e2db7195d792ab5a3c028353453a367ebf446bf3dbf1cc0f7619a
libffi
b87aab474a60a6906194e2c4325eb7e75f6b98fc405cc6f2a93b2aa0d8be9b7e
libzmq
f39faf8387951e77cf4c4a7e430a479055e6cf88638777e968679f996829b0f4
openblas
29d2e5a60901bc0461213ac6db595691094e2c79418ac6927d24b0fb15b0d7c6
freetype
58e3ce5d2c81f799bee4e20b6da883adc394f31318e7975e30b7d5b22fe2be28
harfbuzz
c580567dbc47433f1aae312a62bdaaf97894cf9a70ce75e1d3ac31b5c2a2cd18
crypto
5caf39e44187d99cd9c89a4fb7a0b63439e29fc67437fe793e5b4d620c730bb9
openssl
3fcca6d84391c7bc927d3e606735560ce55b07710ce100f2bbdab166a7370473
*/
