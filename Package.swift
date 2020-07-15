// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Python-aux",
    products: [
        .library(name: "Python-aux", targets: ["libpng", "libffi", "libzmq"])
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "libpng",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libpng.xcframework.zip",
            checksum: "b7a37051c20c8d19d53b7a09ffe4fca9314bf5fdcd5caea136234a92f22e2a1b"
        ),
        .binaryTarget(
            name: "libffi",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libffi.xcframework.zip",
            checksum: "fe21a8e374ed7b24064c7b7fef912c9eb5f177562028ed6468a635f59b02c273"
        ),
        .binaryTarget(
            name: "libzmq",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libzmq.xcframework.zip",
            checksum: "ccfaca176f4bc616f42f7000c67aee44fcb28a98ad8f6805c05348249da629e3"
        )
    ]
)
/*
xcframework successfully written out to: /Users/holzschu/src/Xcode_iPad/Python-aux/libpng.xcframework
b7a37051c20c8d19d53b7a09ffe4fca9314bf5fdcd5caea136234a92f22e2a1b
xcframework successfully written out to: /Users/holzschu/src/Xcode_iPad/Python-aux/libffi.xcframework
fe21a8e374ed7b24064c7b7fef912c9eb5f177562028ed6468a635f59b02c273
xcframework successfully written out to: /Users/holzschu/src/Xcode_iPad/Python-aux/libzmq.xcframework
ccfaca176f4bc616f42f7000c67aee44fcb28a98ad8f6805c05348249da629e3*/
