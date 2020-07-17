// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Python-aux",
    products: [
        .library(name: "Python-aux", targets: ["libpng", "libffi", "libzmq", "openblas"])
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "libpng",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libpng.xcframework.zip",
            checksum: "f26409ee2501d50aa9a8eba782a600714a1b50c318cb21d8eac53df36eff41c3"
        ),
        .binaryTarget(
            name: "libffi",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libffi.xcframework.zip",
            checksum: "2ae0a29d261a17910375d251cfd3ed73133547c5aac064e337862d876a8d0fd1"
        ),
        .binaryTarget(
            name: "libzmq",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libzmq.xcframework.zip",
            checksum: "1252b600559d9721f688443564147a688b4d8713269324be7cf4ee3eea5a5efb"
        ),
        .binaryTarget(
            name: "openblas",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/openblas.xcframework.zip",
            checksum: "ea9d7e56329f531fd50ec47ee0959c0e3e98e46bbce99e0995e246b96a1d22ef"
        )
    ]
)
/*
libpng
f26409ee2501d50aa9a8eba782a600714a1b50c318cb21d8eac53df36eff41c3
libffi
2ae0a29d261a17910375d251cfd3ed73133547c5aac064e337862d876a8d0fd1
libzmq
1252b600559d9721f688443564147a688b4d8713269324be7cf4ee3eea5a5efb
openblas
ea9d7e56329f531fd50ec47ee0959c0e3e98e46bbce99e0995e246b96a1d22ef
*/
