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
            checksum: "c699c76f93e91142832a342fe59d4012ceabc728694a89deeaee14ede4f3b133"
        ),
        .binaryTarget(
            name: "libffi",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libffi.xcframework.zip",
            checksum: "1fce5ee5fed2a864d7047082ec013751da78107bc58fe9b473810788a557c273"
        ),
        .binaryTarget(
            name: "libzmq",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libzmq.xcframework.zip",
            checksum: "80ea3ea3d369445b1abb0c61bde304e24695cb95f5808944ac6dabc634f4076a"
        ),
        .binaryTarget(
            name: "openblas",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/openblas.xcframework.zip",
            checksum: "d326c7b6731ddf4b541900e37752c12a760eca848d2fdffd33897d7ad700befa"
        ),
        .binaryTarget(
            name: "freetype",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/freetype.xcframework.zip",
            checksum: "e281c8f72f512652860385cb68d246ba787d134cc04589b6fca33608f449bd91"
        ),
        .binaryTarget(
            name: "harfbuzz",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/harfbuzz.xcframework.zip",
            checksum: "4b4e6672162d4491562eed5ef6e06a6de25d0f2e07ab8b095986a1921b497a07"
        )
    ]
)
/*
libpng
c699c76f93e91142832a342fe59d4012ceabc728694a89deeaee14ede4f3b133
libffi
1fce5ee5fed2a864d7047082ec013751da78107bc58fe9b473810788a557c273
libzmq
80ea3ea3d369445b1abb0c61bde304e24695cb95f5808944ac6dabc634f4076a
openblas
d326c7b6731ddf4b541900e37752c12a760eca848d2fdffd33897d7ad700befa
freetype
e281c8f72f512652860385cb68d246ba787d134cc04589b6fca33608f449bd91
harfbuzz
4b4e6672162d4491562eed5ef6e06a6de25d0f2e07ab8b095986a1921b497a07
*/
