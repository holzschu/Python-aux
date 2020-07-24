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
            checksum: "9b66e33af4ece6a15faaaea7ecaed20da3ce4a3f2a0a87ff39813350cf461bbd"
        ),
        .binaryTarget(
            name: "libffi",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libffi.xcframework.zip",
            checksum: "224015c11527b760d0c6a29859379bd056570c8b28a0a13742578a9f327cea7f"
        ),
        .binaryTarget(
            name: "libzmq",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libzmq.xcframework.zip",
            checksum: "b80067bac79c385ae20a66e43e4b42c528c05a76e0e2e22a5307901c59fff045"
        ),
        .binaryTarget(
            name: "openblas",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/openblas.xcframework.zip",
            checksum: "9d508028805bc47ef6e1090f1008719770532fedeb32b785ea76e50857004149"
        ),
        .binaryTarget(
            name: "freetype",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/freetype.xcframework.zip",
            checksum: "5cfada203d02c5ca272235d1e293ea820f7e8d1a2718ec8382d42cbca91baa35"
        ),
        .binaryTarget(
            name: "harfbuzz",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/harfbuzz.xcframework.zip",
            checksum: "53310d1d0fb238d8c22768bb59e3717b4b70a062abb463261b1103d0f0c7e6a0"
        )
    ]
)
/*
libpng
9b66e33af4ece6a15faaaea7ecaed20da3ce4a3f2a0a87ff39813350cf461bbd
libffi
224015c11527b760d0c6a29859379bd056570c8b28a0a13742578a9f327cea7f
libzmq
b80067bac79c385ae20a66e43e4b42c528c05a76e0e2e22a5307901c59fff045
openblas
9d508028805bc47ef6e1090f1008719770532fedeb32b785ea76e50857004149
freetype
5cfada203d02c5ca272235d1e293ea820f7e8d1a2718ec8382d42cbca91baa35
harfbuzz
53310d1d0fb238d8c22768bb59e3717b4b70a062abb463261b1103d0f0c7e6a0
*/
