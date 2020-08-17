// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Python-aux",
    products: [
        .library(name: "Python-aux", targets: ["libpng", "libffi", "libzmq", "openblas", "freetype", "harfbuzz"])
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "libpng",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libpng.xcframework.zip",
            checksum: "437d7bed230d23b03093d21db3e1c21f3f08e816692801b146b80ea8a74afc30"
        ),
        .binaryTarget(
            name: "libffi",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libffi.xcframework.zip",
            checksum: "015624143068a9c96e83580f8449227f694e1a84f3dfd887d384c819540e4afc"
        ),
        .binaryTarget(
            name: "libzmq",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libzmq.xcframework.zip",
            checksum: "684bf5f46a3ff4fb6e1ec96b78ed9481319dd05653856dbae5e2f7dee5e06335"
        ),
        .binaryTarget(
            name: "openblas",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/openblas.xcframework.zip",
            checksum: "206cb90fd163494f8d68d399d36000e5a5870ebe15ec63ace4c467127b09b4bf"
        ),
        .binaryTarget(
            name: "freetype",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/freetype.xcframework.zip",
            checksum: "836e4676d4fc23b057db5c233b1ce91ab331977845b02be08d0d7de628d45b02"
        ),
        .binaryTarget(
            name: "harfbuzz",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/harfbuzz.xcframework.zip",
            checksum: "c131861de000a79dd1c4c007962c4417d110708a067ce7b85ad5be13ca36c408"
        )
    ]
)
/*
libpng
437d7bed230d23b03093d21db3e1c21f3f08e816692801b146b80ea8a74afc30
libffi
015624143068a9c96e83580f8449227f694e1a84f3dfd887d384c819540e4afc
libzmq
684bf5f46a3ff4fb6e1ec96b78ed9481319dd05653856dbae5e2f7dee5e06335
openblas
206cb90fd163494f8d68d399d36000e5a5870ebe15ec63ace4c467127b09b4bf
freetype
836e4676d4fc23b057db5c233b1ce91ab331977845b02be08d0d7de628d45b02
harfbuzz
c131861de000a79dd1c4c007962c4417d110708a067ce7b85ad5be13ca36c408
*/
